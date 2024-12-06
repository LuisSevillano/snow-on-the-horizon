#!/bin/bash
timestamp=$(date +%s)
# Directorio base donde se organizan las imágenes
base_dir="images"

# Archivo de entrada con las URLs
input_file="camaras.txt"

# Función para crear directorios si no existen
create_dir_if_not_exists() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

# Función para obtener el hash MD5 de una imagen
get_image_hash() {
    local image="$1"
    md5sum "$image" | awk '{ print $1 }'
}

# Función para verificar si la imagen descargada es un duplicado de la última imagen modificada
is_duplicate() {
    local url="$1"
    local directory="$2"

    # Obtener la última imagen modificada en el directorio
    last_image=$(ls -t "$directory"/*.jpg | head -n 1)
    last_image_hash=$(get_image_hash "$last_image")
    remote_hash=$(curl -s $url | md5sum | awk '{ print $1 }')


    if [ "$last_image_hash" == "$remote_hash" ]; then
        echo "Es un duplicado de $last_image"
        return 0 # Es un duplicado
    fi

    return 1 # No es duplicado
}

# Descargar las imágenes
while IFS= read -r line; do
    if [[ $line == \#* ]]; then
        province="${line#\# }" # Eliminar el '#' y cualquier espacio inicial
        continue
    fi

    # Extraer los datos de la carretera y el kilómetro
    if [[ $line =~ ^([A-Za-z0-9]+)PK([0-9]+(\.[0-9]+)?) ]]; then
        carretera="${BASH_REMATCH[1]}"
        kilometro="${BASH_REMATCH[2]}"
        url_raw="${line#*=}"
        url="${url_raw}?${timestamp}"

        # Crear estructura de carpetas
        province_dir="$base_dir/$province"
        create_dir_if_not_exists "$province_dir"

        carretera_dir="$province_dir/$carretera"
        create_dir_if_not_exists "$carretera_dir"

        kilometro_dir="$carretera_dir/$kilometro"
        create_dir_if_not_exists "$kilometro_dir"

        # Nombre temporal para la imagen descargada (con un nombre único)

        temp_image_name="$kilometro_dir/temp.jpg"
        final_image="$kilometro_dir/$carretera"_"PK${kilometro}_${timestamp}.jpg"


        # Descargar la imagen temporal
        echo ""
        echo "Comprobando $url"
        # Verificar si la carpeta está vacía (sin imágenes existentes)
        if [ -z "$(ls -A $kilometro_dir)" ]; then
            echo "La carpeta está vacía. Guardando imagen como $final_image"
            curl -s $url -o "$final_image"
        else

            echo "Existen imágenes en la carpeta. Verificando duplicados..."
            if is_duplicate $url $kilometro_dir; then
                # Eliminar la imagen temporal si es duplicada
                echo "No se descarga"
            else
                curl -s $url -o "$final_image"
                # Si no es duplicada, la imagen ya está guardada con el nombre adecuado
                echo "Guardando imagen como $final_image"

            fi
        fi
    fi
done < "$input_file"

echo "Proceso de descarga y verificación de duplicados completado."
