# 🚀 Clon Git Hub

![OS](https://img.shields.io/badge/OS-Linux-blue?logo=linux)
![Language](https://img.shields.io/badge/Language-Bash-green?logo=gnubash)
![License](https://img.shields.io/badge/License-MIT-yellow)

**Clon Git Hub** es una herramienta de automatización diseñada para simplificar la descarga de repositorios de GitHub. Su principal característica es la detección inteligente del usuario real (incluso bajo `sudo`), asegurando que los archivos y accesos directos se guarden siempre en el Escritorio del usuario correcto con los permisos adecuados.

## 🛠️ Funcionalidades

* **Detección de Usuario Real:** Identifica automáticamente el `$HOME` y el usuario original para evitar que los archivos pertenezcan a `root`.
* **Organización Automática:** Crea una carpeta llamada `Herramientas` en el Escritorio si no existe.
* **Acceso Directo Inteligente:** Genera un archivo `.desktop` en el Escritorio para ejecutar el clonador con un solo clic.
* **Gestión de Permisos:** Realiza un `chown` automático de los repositorios clonados para que el usuario pueda editarlos sin restricciones.
* **Detección de Idioma de Sistema:** Soporta rutas tanto en español (`/Escritorio`) como en inglés (`/Desktop`).

## 🚀 Instalación y Uso

1. **Clonar este repositorio:**
   ```bash
   git clone [https://github.com/BLEXS/Clon-Git-Hub.git](https://github.com/BLEXS/Clon-Git-Hub.git)
   cd Clon-Git-Hub
