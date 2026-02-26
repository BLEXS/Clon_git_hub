#!/bin/bash

# --- COLORES MATRIX ---
BLACK='\033[0;30m'
GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
DIM_GREEN='\033[2;32m'
NC='\033[0m'

clear

# Banner Matrix
echo -e "${BRIGHT_GREEN}"
echo "  ██████╗██╗      ██████╗ ███╗   ██╗ █████╗ ██████╗  ██████╗ ██████╗ "
echo " ██╔════╝██║     ██╔═══██╗████╗  ██║██╔══██╗██╔══██╗██╔═══██╗██╔══██╗"
echo " ██║     ██║     ██║   ██║██╔██╗ ██║███████║██║  ██║██║   ██║██████╔╝"
echo " ██║     ██║     ██║   ██║██║╚██╗██║██╔══██║██║  ██║██║   ██║██╔══██╗"
echo " ╚██████╗███████╗╚██████╔╝██║ ╚████║██║  ██║██████╔╝╚██████╔╝██║  ██║"
echo "  ╚═════╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${GREEN}⚡ =========================================== ⚡${NC}"
echo -e "${BRIGHT_GREEN}  ⚡  CLONADOR V2 - DETECTOR DE USUARIO REAL  ⚡${NC}"
echo -e "${GREEN}⚡ =========================================== ⚡${NC}"

# --- DETECTAR USUARIO REAL ---
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER="$USER"
    REAL_HOME="$HOME"
fi

echo -e "${DIM_GREEN}[*] Usuario detectado: ${BRIGHT_GREEN}$REAL_USER${NC}"
echo -e "${DIM_GREEN}[*] Home detectado:    ${BRIGHT_GREEN}$REAL_HOME${NC}"

# --- DETECTAR ESCRITORIO ---
if [ -d "$REAL_HOME/Escritorio" ]; then
    DESKTOP_DIR="$REAL_HOME/Escritorio"
elif [ -d "$REAL_HOME/Desktop" ]; then
    DESKTOP_DIR="$REAL_HOME/Desktop"
else
    echo -e "${BRIGHT_GREEN}[!] No encontré Escritorio ni Desktop en $REAL_HOME${NC}"
    exit 1
fi

TARGET_DIR="$DESKTOP_DIR/Herramientas"

# --- CREAR CARPETA HERRAMIENTAS ---
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${DIM_GREEN}[*] Creando carpeta 'Herramientas' en tu escritorio...${NC}"
    mkdir -p "$TARGET_DIR"
    if [ -n "$SUDO_USER" ]; then
        chown "$REAL_USER":"$REAL_USER" "$TARGET_DIR"
    fi
fi

# --- CREAR ACCESO DIRECTO ---
SCRIPT_PATH=$(realpath "$0")
SHORTCUT_NAME="ClonarRepo.desktop"
SHORTCUT_PATH="$DESKTOP_DIR/$SHORTCUT_NAME"

if [ ! -f "$SHORTCUT_PATH" ]; then
    echo -e "${DIM_GREEN}[*] Creando acceso directo...${NC}"

    cat <<EOF > "$SHORTCUT_PATH"
[Desktop Entry]
Version=1.0
Type=Application
Name=Clonar Repo GitHub
Comment=Descargar herramientas
Exec=bash -c "sudo $SCRIPT_PATH; read -p 'Presiona Enter para salir...' var"
Icon=utilities-terminal
Path=$TARGET_DIR
Terminal=true
StartupNotify=false
EOF

    chmod +x "$SHORTCUT_PATH"

    if [ -n "$SUDO_USER" ]; then
        chown "$REAL_USER":"$REAL_USER" "$SHORTCUT_PATH"
    fi

    echo -e "${BRIGHT_GREEN}[OK] ⚡ Acceso directo creado en: ${GREEN}$DESKTOP_DIR${NC}"
fi

# --- SOLICITAR URL Y CLONAR ---
echo ""
echo -e "${GREEN}⚡ =========================================== ⚡${NC}"
echo -e "${BRIGHT_GREEN}  Pega la URL del repositorio de GitHub:${NC}"
echo -e "${GREEN}⚡ =========================================== ⚡${NC}"
read -p "> " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo -e "${BRIGHT_GREEN}[!] URL vacía. Saliendo.${NC}"
    exit 1
fi

cd "$TARGET_DIR" || exit

echo -e "${DIM_GREEN}[*] Clonando repositorio...${NC}"
git clone "$REPO_URL"

CLONE_STATUS=$?

if [ $CLONE_STATUS -eq 0 ]; then
    echo ""
    echo -e "${BRIGHT_GREEN}⚡ Clonado exitosamente.${NC}"

    if [ -n "$SUDO_USER" ]; then
        REPO_NAME=$(basename "$REPO_URL" .git)
        CLONED_PATH="$TARGET_DIR/$REPO_NAME"

        if [ -d "$CLONED_PATH" ]; then
            chown -R "$REAL_USER":"$REAL_USER" "$CLONED_PATH"
            echo -e "${BRIGHT_GREEN}[OK] ⚡ Permisos asignados a ${GREEN}$REAL_USER${BRIGHT_GREEN} correctamente.${NC}"
        else
            echo -e "${BRIGHT_GREEN}[!] No se encontró la carpeta clonada: $CLONED_PATH${NC}"
        fi
    fi

else
    echo -e "${BRIGHT_GREEN}[✘] Error al clonar el repositorio.${NC}"
fi

echo ""
echo -e "${GREEN}⚡ =========================================== ⚡${NC}"
echo -e "${DIM_GREEN}              Creado por: BLEXS${NC}"
echo -e "${GREEN}⚡ =========================================== ⚡${NC}"
echo ""
