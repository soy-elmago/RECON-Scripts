#!/bin/bash

# submagic.sh - Script para enumeración masiva de subdominios
# Autor: ElMago
# Uso: ./submagic.sh -l /ruta/a/domains.txt

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Banner
echo -e "${PURPLE}"
echo "  ███████╗██╗   ██╗██████╗ ███╗   ███╗ █████╗  ██████╗ ██╗ ██████╗"
echo "  ███╔════╝██║   ██║██╔══██╗████╗ ████║██╔══██╗██╔════╝ ██║██╔════╝"
echo "  ███████╗██║   ██║██████╔╝██╔████╔██║███████║██║  ███╗██║██║     "
echo "  ╚════██║██║   ██║██╔══██╗██║╚██╔╝██║██╔══██║██║   ██║██║██║     "
echo "  ███████║╚██████╔╝██████╔╝██║ ╚═╝ ██║██║  ██║╚██████╔╝██║╚██████╗"
echo "  ╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝ ╚═════╝"
echo -e "${NC}"
echo -e "${BLUE}[*] Script de Enumeración Masiva de Subdominios${NC}"
echo ""

# Función para mostrar ayuda
show_help() {
    echo -e "${YELLOW}Uso: $0 -l <archivo_dominios>${NC}"
    echo ""
    echo "Opciones:"
    echo "  -l    Archivo con lista de dominios (uno por línea)"
    echo "  -h    Mostrar esta ayuda"
    echo ""
    echo "Ejemplo:"
    echo "  $0 -l /tmp/domains.txt"
    echo ""
    echo "Herramientas utilizadas:"
    echo "  - subfinder (con -all)"
    echo "  - amass (con -passive)"
    echo "  - assetfinder (con --subs-only)"
    echo "  - findomain"
    echo "  - github-subdomains (con tokens automáticos)"
    echo "  - crt.sh (vía curl/jq)"
    echo ""
    echo -e "${GREEN}[*] Instalación automática:${NC}"
    echo "  El script detectará herramientas faltantes y ofrecerá instalarlas automáticamente"
    echo ""
    echo -e "${GREEN}[*] Prerequisitos:${NC}"
    echo "  - Go (golang) instalado y en PATH"
    echo "  - Conexión a internet"
    echo "  - Permisos para instalar paquetes (para curl/jq)"
}

# Función para instalar herramientas faltantes
install_missing_tools() {
    local missing_tools=("$@")
    
    echo -e "${YELLOW}[*] Instalando herramientas faltantes...${NC}"
    
    for tool in "${missing_tools[@]}"; do
        echo -e "${BLUE}[*] Instalando $tool...${NC}"
        
        case $tool in
            "subfinder")
                go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}[✓] Subfinder instalado correctamente${NC}"
                else
                    echo -e "${RED}[!] Error instalando Subfinder${NC}"
                fi
                ;;
            "amass")
                go install -v github.com/owasp-amass/amass/v4/...@master
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}[✓] Amass instalado correctamente${NC}"
                else
                    echo -e "${RED}[!] Error instalando Amass${NC}"
                fi
                ;;
            "assetfinder")
                go install github.com/tomnomnom/assetfinder@latest
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}[✓] Assetfinder instalado correctamente${NC}"
                else
                    echo -e "${RED}[!] Error instalando Assetfinder${NC}"
                fi
                ;;
            "findomain")
                echo -e "${YELLOW}[*] Descargando Findomain...${NC}"
                # Detectar arquitectura
                local arch=""
                case $(uname -m) in
                    x86_64) arch="x86_64" ;;
                    aarch64) arch="aarch64" ;;
                    *) arch="x86_64" ;;
                esac
                
                # Crear directorio temporal
                local temp_dir=$(mktemp -d)
                cd "$temp_dir"
                
                # Descargar la última versión
                curl -LO "https://github.com/Findomain/Findomain/releases/latest/download/findomain-linux-$arch.zip"
                if [ $? -eq 0 ]; then
                    unzip findomain-linux-$arch.zip
                    chmod +x findomain
                    
                    # Mover a directorio en PATH
                    if [ -d "$HOME/.local/bin" ]; then
                        mv findomain "$HOME/.local/bin/"
                    elif [ -d "$HOME/go/bin" ]; then
                        mv findomain "$HOME/go/bin/"
                    else
                        sudo mv findomain /usr/local/bin/
                    fi
                    
                    echo -e "${GREEN}[✓] Findomain instalado correctamente${NC}"
                else
                    echo -e "${RED}[!] Error descargando Findomain${NC}"
                fi
                
                # Limpiar
                cd - > /dev/null
                rm -rf "$temp_dir"
                ;;
            "github-subdomains")
                go install github.com/gwen001/github-subdomains@latest
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}[✓] Github-subdomains instalado correctamente${NC}"
                else
                    echo -e "${RED}[!] Error instalando Github-subdomains${NC}"
                fi
                ;;
            "curl")
                if command -v apt &> /dev/null; then
                    sudo apt update && sudo apt install -y curl
                elif command -v yum &> /dev/null; then
                    sudo yum install -y curl
                elif command -v pacman &> /dev/null; then
                    sudo pacman -S curl
                else
                    echo -e "${RED}[!] No se pudo instalar curl automáticamente${NC}"
                    echo -e "${YELLOW}[*] Por favor instala curl manualmente${NC}"
                fi
                ;;
            "jq")
                if command -v apt &> /dev/null; then
                    sudo apt update && sudo apt install -y jq
                elif command -v yum &> /dev/null; then
                    sudo yum install -y jq
                elif command -v pacman &> /dev/null; then
                    sudo pacman -S jq
                else
                    echo -e "${RED}[!] No se pudo instalar jq automáticamente${NC}"
                    echo -e "${YELLOW}[*] Por favor instala jq manualmente${NC}"
                fi
                ;;
        esac
    done
    
    # Verificar que Go esté en el PATH
    if ! command -v go &> /dev/null; then
        echo -e "${RED}[!] Go no está instalado o no está en el PATH${NC}"
        echo -e "${YELLOW}[*] Para instalar Go:${NC}"
        echo -e "${YELLOW}    1. Descarga desde: https://golang.org/dl/${NC}"
        echo -e "${YELLOW}    2. O usa: sudo apt install golang-go (Ubuntu/Debian)${NC}"
        echo -e "${YELLOW}    3. Asegúrate de que \$HOME/go/bin esté en tu PATH${NC}"
        return 1
    fi
    
    # Verificar que el GOPATH/bin esté en PATH
    if [[ ":$PATH:" != *":$HOME/go/bin:"* ]] && [[ ":$PATH:" != *":$(go env GOPATH)/bin:"* ]]; then
        echo -e "${YELLOW}[*] Agregando Go bin al PATH...${NC}"
        echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
        echo -e "${GREEN}[✓] Agrega la siguiente línea a tu ~/.bashrc o ~/.zshrc:${NC}"
        echo -e "${GREEN}    export PATH=\$PATH:\$(go env GOPATH)/bin${NC}"
        echo -e "${GREEN}[✓] Luego ejecuta: source ~/.bashrc${NC}"
    fi
}

# Función para verificar dependencias
check_dependencies() {
    echo -e "${BLUE}[*] Verificando dependencias...${NC}"
    
    local tools=("subfinder" "amass" "assetfinder" "findomain" "github-subdomains" "curl" "jq")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}[!] Herramientas faltantes: ${missing_tools[*]}${NC}"
        echo -e "${YELLOW}[?] ¿Deseas instalar automáticamente las herramientas faltantes? (y/n)${NC}"
        read -r response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_missing_tools "${missing_tools[@]}"
            
            # Verificar nuevamente después de la instalación
            echo -e "${BLUE}[*] Verificando instalación...${NC}"
            local still_missing=()
            for tool in "${missing_tools[@]}"; do
                if ! command -v "$tool" &> /dev/null; then
                    still_missing+=("$tool")
                fi
            done
            
            if [ ${#still_missing[@]} -ne 0 ]; then
                echo -e "${RED}[!] Algunas herramientas no se pudieron instalar: ${still_missing[*]}${NC}"
                echo -e "${YELLOW}[*] Puedes continuar, pero los resultados podrían ser incompletos${NC}"
                echo -e "${YELLOW}[?] ¿Deseas continuar de todas formas? (y/n)${NC}"
                read -r continue_response
                
                if [[ ! "$continue_response" =~ ^[Yy]$ ]]; then
                    echo -e "${RED}[!] Abortando ejecución${NC}"
                    return 1
                fi
            else
                echo -e "${GREEN}[✓] Todas las herramientas instaladas correctamente${NC}"
            fi
        else
            echo -e "${YELLOW}[*] Puedes instalar las herramientas manualmente y volver a ejecutar el script${NC}"
            echo -e "${YELLOW}[*] O continuar con las herramientas disponibles${NC}"
            echo -e "${YELLOW}[?] ¿Deseas continuar con las herramientas disponibles? (y/n)${NC}"
            read -r continue_response
            
            if [[ ! "$continue_response" =~ ^[Yy]$ ]]; then
                echo -e "${RED}[!] Abortando ejecución${NC}"
                return 1
            fi
        fi
    else
        echo -e "${GREEN}[✓] Todas las dependencias están instaladas${NC}"
    fi
    
    return 0
}

# Función para ejecutar subfinder
run_subfinder() {
    local domain=$1
    local output_dir=$2
    local output_file="$output_dir/subfinder_$domain.txt"
    
    echo -e "${BLUE}[*] Ejecutando subfinder con -all para $domain...${NC}"
    
    # Verificar si existe el archivo de configuración
    local config_file="$HOME/.config/subfinder/provider-config.yaml"
    
    if [ ! -f "$config_file" ]; then
        echo -e "${YELLOW}[!] Archivo de configuración no encontrado en $config_file${NC}"
        echo -e "${YELLOW}[!] Creando archivo de configuración con las API keys proporcionadas...${NC}"
        
        # Crear directorio si no existe
        mkdir -p "$(dirname "$config_file")"
        
        # Crear archivo de configuración
        cat > "$config_file" << 'EOF'
bevigil: []
binaryedge: []
bufferover: []
c99: []
censys: []
certspotter: []
chaos: []
chinaz: []
dnsdb: []
dnsrepo: []
facebook: []
fofa: []
fullhunt: []
github: []
hunter: []
intelx: []
leakix: []
netlas: []
passivetotal: []
quake: []
robtex: []
securitytrails: []
shodan: []
threatbook: []
virustotal: []
whoisxmlapi: []
zoomeye: []
zoomeyeapi: []
EOF
        echo -e "${GREEN}[✓] Archivo de configuración creado exitosamente${NC}"
    fi
    
    # Crear archivo vacío por defecto
    touch "$output_file"
    
    # Ejecutar subfinder con -all
    if command -v subfinder &> /dev/null; then
        subfinder -d "$domain" -all -silent -o "$output_file" 2>/dev/null
    else
        echo -e "${YELLOW}[!] Subfinder no está disponible${NC}"
    fi
    
    local count=0
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        count=$(wc -l < "$output_file")
    fi
    
    echo -e "${GREEN}[✓] Subfinder encontró $count subdominios (usando todas las fuentes)${NC}"
}

# Función para ejecutar amass
run_amass() {
    local domain=$1
    local output_dir=$2
    local output_file="$output_dir/amass_$domain.txt"
    
    echo -e "${BLUE}[*] Ejecutando amass enum -passive para $domain...${NC}"
    
    # Crear archivo vacío por defecto
    touch "$output_file"
    
    if command -v amass &> /dev/null; then
        amass enum -passive -d "$domain" -silent -o "$output_file" 2>/dev/null
    else
        echo -e "${YELLOW}[!] Amass no está disponible${NC}"
    fi
    
    local count=0
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        count=$(wc -l < "$output_file")
    fi
    
    echo -e "${GREEN}[✓] Amass encontró $count subdominios (modo pasivo)${NC}"
}

# Función para ejecutar assetfinder
run_assetfinder() {
    local domain=$1
    local output_dir=$2
    local output_file="$output_dir/assetfinder_$domain.txt"
    
    echo -e "${BLUE}[*] Ejecutando assetfinder --subs-only para $domain...${NC}"
    
    # Crear archivo vacío por defecto
    touch "$output_file"
    
    if command -v assetfinder &> /dev/null; then
        assetfinder --subs-only "$domain" > "$output_file" 2>/dev/null
    else
        echo -e "${YELLOW}[!] Assetfinder no está disponible${NC}"
    fi
    
    local count=0
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        count=$(wc -l < "$output_file")
    fi
    
    echo -e "${GREEN}[✓] Assetfinder encontró $count subdominios (solo subdominios)${NC}"
}

# Función para ejecutar findomain
run_findomain() {
    local domain=$1
    local output_dir=$2
    local output_file="$output_dir/findomain_$domain.txt"
    
    echo -e "${BLUE}[*] Ejecutando findomain para $domain...${NC}"
    
    # Crear archivo vacío por defecto
    touch "$output_file"
    
    if command -v findomain &> /dev/null; then
        findomain -t "$domain" -q > "$output_file" 2>/dev/null
    else
        echo -e "${YELLOW}[!] Findomain no está disponible${NC}"
    fi
    
    local count=0
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        count=$(wc -l < "$output_file")
    fi
    
    echo -e "${GREEN}[✓] Findomain encontró $count subdominios${NC}"
}

# Función para ejecutar github-subdomains
run_github_subdomains() {
    local domain=$1
    local output_dir=$2
    local output_file="$output_dir/github_$domain.txt"
    
    echo -e "${BLUE}[*] Ejecutando github-subdomains para $domain con tokens del config...${NC}"
    
    # Crear archivo vacío por defecto
    touch "$output_file"
    
    if ! command -v github-subdomains &> /dev/null; then
        echo -e "${YELLOW}[!] Github-subdomains no está disponible${NC}"
        return
    fi
    
    # Extraer tokens de GitHub del archivo de configuración si existe
    local config_file="$HOME/.config/subfinder/provider-config.yaml"
    local github_tokens=""
    
    if [ -f "$config_file" ]; then
        # Extraer los tokens de GitHub del archivo YAML
        github_tokens=$(grep -A 10 "github:" "$config_file" | grep "^-" | sed 's/^- //' | tr '\n' ',' | sed 's/,$//')
        
        if [ -n "$github_tokens" ]; then
            echo -e "${BLUE}[*] Usando tokens de GitHub del archivo de configuración${NC}"
            # Usar el primer token disponible
            local first_token=$(echo "$github_tokens" | cut -d',' -f1)
            github-subdomains -d "$domain" -t "$first_token" -o "$output_file" 2>/dev/null
        else
            echo -e "${YELLOW}[!] No se encontraron tokens de GitHub en la configuración${NC}"
            github-subdomains -d "$domain" -o "$output_file" 2>/dev/null
        fi
    else
        echo -e "${YELLOW}[!] Archivo de configuración no encontrado, ejecutando sin token${NC}"
        github-subdomains -d "$domain" -o "$output_file" 2>/dev/null
    fi
    
    local count=0
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        count=$(wc -l < "$output_file")
    fi
    
    echo -e "${GREEN}[✓] Github-subdomains encontró $count subdominios${NC}"
}

# Función para ejecutar crt.sh
run_crtsh() {
    local domain=$1
    local output_dir=$2
    local output_file="$output_dir/crtsh_$domain.txt"
    
    echo -e "${BLUE}[*] Ejecutando consulta a crt.sh para $domain...${NC}"
    
    # Crear archivo vacío por defecto
    touch "$output_file"
    
    if command -v curl &> /dev/null && command -v jq &> /dev/null; then
        curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' 2>/dev/null | grep -i "$domain" | sort -u > "$output_file" 2>/dev/null
    else
        echo -e "${YELLOW}[!] curl o jq no están disponibles${NC}"
    fi
    
    local count=0
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        count=$(wc -l < "$output_file")
    fi
    
    echo -e "${GREEN}[✓] Crt.sh encontró $count subdominios${NC}"
}

# Función para procesar un dominio
process_domain() {
    local domain=$1
    local output_dir=$2
    
    echo -e "\n${PURPLE}[*] Procesando dominio: $domain${NC}"
    echo -e "${BLUE}================================${NC}"
    
    # Ejecutar todas las herramientas
    run_subfinder "$domain" "$output_dir"
    run_amass "$domain" "$output_dir"
    run_assetfinder "$domain" "$output_dir"
    run_findomain "$domain" "$output_dir"
    run_github_subdomains "$domain" "$output_dir"
    run_crtsh "$domain" "$output_dir"
    
    # Combinar todos los resultados para este dominio
    local temp_files=("$output_dir"/subfinder_"$domain".txt "$output_dir"/amass_"$domain".txt "$output_dir"/assetfinder_"$domain".txt "$output_dir"/findomain_"$domain".txt "$output_dir"/github_"$domain".txt "$output_dir"/crtsh_"$domain".txt)
    local combined_file="$output_dir/all_subdomains_$domain.txt"
    
    # Verificar que al menos un archivo existe y combinar
    local files_exist=false
    for file in "${temp_files[@]}"; do
        if [ -f "$file" ] && [ -s "$file" ]; then
            files_exist=true
            break
        fi
    done
    
    if [ "$files_exist" = true ]; then
        # Combinar archivos existentes, filtrar líneas vacías y ordenar
        cat "${temp_files[@]}" 2>/dev/null | grep -v "^$" | sort -u > "$combined_file"
    else
        # Si no hay archivos, crear archivo vacío
        touch "$combined_file"
    fi
    
    local total_count=0
    if [ -f "$combined_file" ] && [ -s "$combined_file" ]; then
        total_count=$(wc -l < "$combined_file")
    fi
    
    echo -e "${GREEN}[✓] Total de subdominios únicos para $domain: $total_count${NC}"
    
    # Limpiar archivos temporales
    for file in "${temp_files[@]}"; do
        [ -f "$file" ] && rm -f "$file"
    done
    
    # Renombrar el archivo final solo si existe
    if [ -f "$combined_file" ]; then
        mv "$combined_file" "$output_dir/$domain.txt"
    else
        # Crear archivo vacío con el nombre final
        touch "$output_dir/$domain.txt"
    fi
}

# Función principal
main() {
    local domains_file=""
    
    # Procesar argumentos
    while getopts "l:h" opt; do
        case ${opt} in
            l)
                domains_file="$OPTARG"
                ;;
            h)
                show_help
                exit 0
                ;;
            \?)
                echo -e "${RED}[!] Opción inválida: -$OPTARG${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Verificar que se proporcionó el archivo de dominios
    if [ -z "$domains_file" ]; then
        echo -e "${RED}[!] Debe especificar un archivo de dominios con -l${NC}"
        show_help
        exit 1
    fi
    
    # Verificar que el archivo existe
    if [ ! -f "$domains_file" ]; then
        echo -e "${RED}[!] El archivo $domains_file no existe${NC}"
        exit 1
    fi
    
    # Verificar dependencias
    if ! check_dependencies; then
        exit 1
    fi
    
    # Crear directorio de salida
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local output_dir="submagic_results_$timestamp"
    mkdir -p "$output_dir"
    
    echo -e "${BLUE}[*] Directorio de resultados: $output_dir${NC}"
    
    # Leer dominios y procesarlos
    local total_domains=$(wc -l < "$domains_file")
    echo -e "${BLUE}[*] Procesando $total_domains dominios...${NC}"
    
    local current=0
    while IFS= read -r domain || [ -n "$domain" ]; do
        # Limpiar el dominio (remover espacios y caracteres extraños)
        domain=$(echo "$domain" | tr -d '\r\n' | xargs)
        
        if [ -n "$domain" ]; then
            current=$((current + 1))
            echo -e "\n${YELLOW}[*] Progreso: $current/$total_domains${NC}"
            process_domain "$domain" "$output_dir"
        fi
    done < "$domains_file"
    
    # Combinar todos los resultados
    echo -e "\n${BLUE}[*] Combinando todos los resultados...${NC}"
    
    local final_output="$output_dir/all_subdomains_final.txt"
    local domain_files=("$output_dir"/*.txt)
    
    # Verificar si hay archivos de dominio para combinar
    local files_to_combine=()
    for file in "${domain_files[@]}"; do
        # Excluir el archivo final si ya existe
        if [ -f "$file" ] && [[ "$(basename "$file")" != "all_subdomains_final.txt" ]]; then
            files_to_combine+=("$file")
        fi
    done
    
    if [ ${#files_to_combine[@]} -gt 0 ]; then
        cat "${files_to_combine[@]}" | grep -v "^$" | sort -u > "$final_output"
    else
        touch "$final_output"
    fi
    
    local final_count=0
    if [ -f "$final_output" ] && [ -s "$final_output" ]; then
        final_count=$(wc -l < "$final_output")
    fi
    
    echo -e "\n${GREEN}================================${NC}"
    echo -e "${GREEN}[✓] Proceso completado exitosamente${NC}"
    echo -e "${GREEN}[✓] Total de subdominios únicos encontrados: $final_count${NC}"
    echo -e "${GREEN}[✓] Resultados guardados en: $output_dir/all_subdomains_final.txt${NC}"
    echo -e "${GREEN}================================${NC}"
}

# Ejecutar función principal
main "$@"