#!/bin/bash
set -euxo pipefail

# ======== Versiones / Vars ========
GLPI_TAG="11.0.2"
MARIADB_TAG="10.6"

# --- CREDENCIALES: primero ENV, luego SSM, luego defaults ---
DB_NAME="${DB_NAME:-glpidb}"
DB_USER="${DB_USER:-glpi}"
DB_PASS="${DB_PASS:-changeme}"

# ======== Logging ========
exec > >(tee /var/log/glpi-install.log | logger -t user-data -s 2>/dev/console) 2>&1

retry() { n=0; until [ $n -ge 5 ]; do "$@" && break; n=$((n+1)); echo "retry $n"; sleep 5; done; [ $n -lt 5 ]; }

# ======== AWS CLI / Región / SSM ========
dnf -y install amazon-ssm-agent awscli || true
systemctl enable --now amazon-ssm-agent || true

# Asegurar AWS_DEFAULT_REGION si el CLI no la resuelve solo
: "${AWS_DEFAULT_REGION:=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | sed -n 's/.*"region"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')}"
export AWS_DEFAULT_REGION

# Helper: intenta leer SSM (SecureString soportado); devuelve vacío si no existe
fetch_ssm() { aws ssm get-parameter --name "$1" --with-decryption --query 'Parameter.Value' --output text 2>/dev/null || true; }

# Override si SSM tiene valor
v="$(fetch_ssm "/glpi/db_name")";      [ -n "$v" ] && DB_NAME="$v"
v="$(fetch_ssm "/glpi/db_user")";      [ -n "$v" ] && DB_USER="$v"
v="$(fetch_ssm "/glpi/db_password")";  [ -n "$v" ] && DB_PASS="$v"

# ======== Discos / rutas ========
DATA_DEVICE="/dev/xvdb"
DATA_MOUNT="/srv"
GLPI_DB_DATA="${DATA_MOUNT}/mysql"
GLPI_FILES="${DATA_MOUNT}/glpi-files"
GLPI_NET="glpi-net"

dnf -y update
dnf -y install docker
systemctl enable docker
systemctl start docker

# ======== Montar EBS (/srv) ========
REAL_DEV="$(readlink -f "${DATA_DEVICE}" || true)"
[ -z "${REAL_DEV}" ] && [ -b /dev/nvme1n1 ] && REAL_DEV=/dev/nvme1n1
[ -b "${REAL_DEV}" ] || { echo "No se encontró dispositivo de datos"; lsblk; exit 1; }

blkid "${REAL_DEV}" >/dev/null 2>&1 || mkfs.xfs -f "${REAL_DEV}"
UUID="$(blkid -s UUID -o value "${REAL_DEV}")"
mkdir -p "${DATA_MOUNT}"
grep -q "UUID=${UUID} ${DATA_MOUNT} xfs" /etc/fstab || echo "UUID=${UUID} ${DATA_MOUNT} xfs defaults,nofail 0 2" >> /etc/fstab
mount -a

mkdir -p "${GLPI_DB_DATA}" "${GLPI_FILES}"
chcon -R -t container_file_t "${DATA_MOUNT}" || true

# ======== Docker espera /srv en boots futuros ========
mkdir -p /etc/systemd/system/docker.service.d
cat >/etc/systemd/system/docker.service.d/override.conf <<'EOF'
[Unit]
After=network-online.target remote-fs.target
Wants=network-online.target
RequiresMountsFor=/srv
EOF
systemctl daemon-reload
systemctl restart docker

# ======== Red / Imágenes ========
docker network create "${GLPI_NET}" || true
retry docker pull "mariadb:${MARIADB_TAG}"
retry docker pull "glpi/glpi:${GLPI_TAG}"

# ======== MariaDB ========
docker rm -f db || true
set +x  # evitar imprimir credenciales en el log
docker run -d --name db --restart unless-stopped --network "${GLPI_NET}" \
  -e "MARIADB_DATABASE=${DB_NAME}" \
  -e "MARIADB_USER=${DB_USER}" \
  -e "MARIADB_PASSWORD=${DB_PASS}" \
  -e "MARIADB_ROOT_PASSWORD=${DB_PASS}" \
  -v "${GLPI_DB_DATA}:/var/lib/mysql:Z" \
  --health-cmd='mysqladmin ping -h 127.0.0.1 --silent || exit 1' \
  --health-interval=10s --health-timeout=3s --health-retries=6 --health-start-period=20s \
  "mariadb:${MARIADB_TAG}"
set -x

# ======== GLPI ========
docker rm -f glpi || true
# Healthcheck con PHP (no depende de curl en el contenedor)
set +x
docker run -d --name glpi --restart unless-stopped --network "${GLPI_NET}" -p 80:80 \
  -e "GLPI_DB_HOST=db" \
  -e "GLPI_DB_NAME=${DB_NAME}" \
  -e "GLPI_DB_USER=${DB_USER}" \
  -e "GLPI_DB_PASSWORD=${DB_PASS}" \
  -v "${GLPI_FILES}:/var/www/html/files:Z" \
  --health-cmd='php -r "exit(@file_get_contents(\"http://127.0.0.1/?alive=1\")==false);"' \
  --health-interval=15s --health-timeout=5s --health-retries=8 --health-start-period=30s \
  "glpi/glpi:${GLPI_TAG}"
set -x

# ======== Systemd oneshot (espera DB healthy y /srv) ========
cat >/etc/systemd/system/glpi-boot.service <<'EOF'
[Unit]
Description=Revalidar EBS y contenedores GLPI al boot
After=network-online.target docker.service
Wants=network-online.target
RequiresMountsFor=/srv

[Service]
Type=oneshot
ExecStart=/bin/bash -lc '
  set -e
  mount -a || true
  docker network create glpi-net || true
  docker start db || true
  for i in $(seq 1 24); do
    s="$(docker inspect -f "{{.State.Health.Status}}" db 2>/dev/null || echo starting)"
    [ "$s" = "healthy" ] && { echo "DB healthy"; break; }
    echo "esperando DB (estado=$s) ... $i"; sleep 5
  done
  docker start glpi || true
  for i in $(seq 1 24); do
    s="$(docker inspect -f "{{.State.Health.Status}}" glpi 2>/dev/null || echo starting)"
    [ "$s" = "healthy" ] && { echo "GLPI healthy"; break; }
    echo "esperando GLPI (estado=$s) ... $i"; sleep 5
  done
'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable glpi-boot.service
systemctl restart glpi-boot.service

# ======== Checks ========
docker ps
ss -ltnp | grep ':80' || true
curl -I --max-time 5 http://127.0.0.1/ || true

echo "FIN user_data"
