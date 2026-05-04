def guardar_string_en_archivo(texto: str, ruta_archivo: str) -> bool:
    """
    Escribe el contenido de un string extenso en un archivo de texto.
    Retorna True si la operación es exitosa, False en caso contrario.
    """
    try:
        # 'with' garantiza el cierre automático del archivo, incluso si hay errores
        # 'w' crea o sobrescribe el archivo. Usa 'a' si deseas agregar al final.
        # encoding='utf-8' evita problemas con caracteres especiales
        with open(ruta_archivo, 'w', encoding='utf-8') as archivo:
            archivo.write(texto)
        print(f"✅ Contenido guardado exitosamente en: {ruta_archivo}")
        return True
    except PermissionError:
        print("❌ Error: No tienes permisos para escribir en esa ubicación.")
    except OSError as e:
        print(f"❌ Error del sistema operativo: {e}")
    except Exception as e:
        print(f"❌ Error inesperado: {e}")
    return False

# ==========================
# EJEMPLO DE USO
# ==========================
if __name__ == "__main__":
    # Simulamos un string extenso (aprox. 3 MB)
    mi_string_extenso = "Esta es una línea de prueba con datos extensos que se repetirá muchas veces para simular un volumen grande. " * 10000
    
    # Guardamos en archivo
    guardar_string_en_archivo(mi_string_extenso, "datos_extensos.txt")
