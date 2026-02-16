#!/bin/bash

# --- COLORES ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  CLONADOR V2 - DETECTOR DE USUARIO REAL ${NC}"
echo -e "${BLUE}=========================================${NC}"

# 1. DETECTAR EL USUARIO REAL Y SU CARPETA HOME
# Si se usa sudo, SUDO_USER contiene el nombre del usuario real.
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    # Obtenemos el home de ese usuario específico
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER="$USER"
    REAL_HOME="$HOME"
fi

echo -e "${YELLOW}[*] Usuario detectado: $REAL_USER${NC}"
echo -e "${YELLOW}[*] Home detectado: $REAL_HOME${NC}"

# 2. DETECTAR ESCRITORIO (En la carpeta del usuario real)
if [ -d "$REAL_HOME/Escritorio" ]; then
    DESKTOP_DIR="$REAL_HOME/Escritorio"
elif [ -d "$REAL_HOME/Desktop" ]; then
    DESKTOP_DIR="$REAL_HOME/Desktop"
else
    echo -e "${RED}[!] No encontré Escritorio ni Desktop en $REAL_HOME${NC}"
    exit 1
fi

TARGET_DIR="$DESKTOP_DIR/Herramientas"

# 3. CREAR CARPETA 'HERRAMIENTAS'
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}[*] Creando carpeta 'Herramientas' en tu escritorio...${NC}"
    mkdir -p "$TARGET_DIR"
    # Si somos root, arreglamos los permisos inmediatamente
    if [ -n "$SUDO_USER" ]; then
        chown "$REAL_USER":"$REAL_USER" "$TARGET_DIR"
    fi
fi

# 4. CREAR ACCESO DIRECTO (Optimizado)
SCRIPT_PATH=$(realpath "$0")
SHORTCUT_NAME="ClonarRepo.desktop"
SHORTCUT_PATH="$DESKTOP_DIR/$SHORTCUT_NAME"

if [ ! -f "$SHORTCUT_PATH" ]; then
    echo -e "${YELLOW}[*] Creando acceso directo...${NC}"
    
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
    
    # IMPORTANTE: Cambiar dueño del acceso directo al usuario real
    if [ -n "$SUDO_USER" ]; then
        chown "$REAL_USER":"$REAL_USER" "$SHORTCUT_PATH"
    fi
    
    echo -e "${GREEN}[OK] Acceso directo creado en TU escritorio ($DESKTOP_DIR).${NC}"
fi

# 5. SOLICITAR URL Y CLONAR
echo ""
echo -e "${YELLOW}Pega la URL del repositorio de GitHub:${NC}"
read -p "> " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo -e "${RED}[!] URL vacía. Saliendo.${NC}"
    exit 1
fi

cd "$TARGET_DIR" || exit

echo -e "${BLUE}[*] Clonando...${NC}"
git clone "$REPO_URL"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✔ Listo.${NC}"
    
    # PASO FINAL: Si se corrió con sudo, el repo clonado será de root.
    # Vamos a devolvértelo a tu usuario.
    if [ -n "$SUDO_USER" ]; then
        echo -e "${YELLOW}[*] Ajustando permisos de los archivos descargados...${NC}"
        # Obtenemos el nombre de la carpeta recién clonada
        REPO_NAME=$(basename "$REPO_URL" .git)
        chown -R "$REAL_USER":"$REAL_USER" "$TARGET_DIR/$REPO_NAME"
    fi
    
else
    echo -e "${RED}✘ Error al clonar.${NC}"
fi

echo ""
