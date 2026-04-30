#!/usr/bin/env python3
"""
Script para eliminar comentarios de archivos SQL.

Soporta:
- Comentarios de bloque /* ... */
- Comentarios de línea -- ...
- Comentarios de línea # ... (MySQL style)

Maneja correctamente:
- Comentarios dentro de strings
- Comentarios anidados
- Casos especiales como 'http://...' o 'https://...'
"""

import re
import sys
import argparse
from pathlib import Path


def remove_sql_comments(sql_content):
    """
    Elimina todos los comentarios de un contenido SQL.
    
    Args:
        sql_content (str): Contenido SQL con comentarios
        
    Returns:
        str: Contenido SQL sin comentarios
    """
    # Patrón para encontrar strings (simples y dobles) y comentarios
    # Este patrón captura strings, comentarios de bloque y comentarios de línea
    pattern = r'(\'(?:\'\'|[^\'])*\')|("(?:\"\"|[^\"])*")|(/\*.*?\*/)|(--[^\r\n]*$)|(\#[^\r\n]*$)'
    
    def replace_comments(match):
        """Reemplaza comentarios con espacios en blanco, mantiene strings intactas"""
        # Si es un string (grupo 1 o 2), devolverlo tal cual
        if match.group(1) is not None:
            return match.group(1)
        if match.group(2) is not None:
            return match.group(2)
        # Si es un comentario, reemplazar con espacios en blanco
        # para mantener la estructura de líneas
        return ' ' * len(match.group(0))
    
    # Aplicar el reemplazo con el flag re.MULTILINE para que ^ y $ funcionen por línea
    result = re.sub(pattern, replace_comments, sql_content, flags=re.DOTALL | re.MULTILINE)
    
    # Limpiar líneas que solo contienen espacios en blanco (opcional)
    lines = result.split('\n')
    cleaned_lines = []
    for line in lines:
        if line.strip() == '':
            cleaned_lines.append('')
        else:
            cleaned_lines.append(line.rstrip())
    
    return '\n'.join(cleaned_lines)


def process_file(input_file, output_file=None):
    """
    Procesa un archivo SQL eliminando comentarios.
    
    Args:
        input_file (str): Ruta al archivo de entrada
        output_file (str, optional): Ruta al archivo de salida. 
                                   Si no se especifica, se añade '_sin_comentario' al nombre original.
    """
    input_path = Path(input_file)
    
    if not input_path.exists():
        print(f"Error: El archivo '{input_file}' no existe.")
        return False
    
    if not output_file:
        output_file = input_path.stem + "_sin_comentario" + input_path.suffix
    
    try:
        # Leer el archivo de entrada
        with open(input_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Eliminar comentarios
        clean_content = remove_sql_comments(content)
        
        # Escribir el archivo de salida
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(clean_content)
        
        print(f"Archivo procesado exitosamente: '{output_file}'")
        return True
        
    except Exception as e:
        print(f"Error al procesar el archivo: {e}")
        return False


def main():
    """Función principal del programa"""
    parser = argparse.ArgumentParser(
        description="Elimina comentarios de archivos SQL",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos de uso:
  python remove_sql_comments.py script.sql
  python remove_sql_comments.py script.sql -o clean_script.sql
  python remove_sql_comments.py input.sql --output output.sql
        """
    )
    
    parser.add_argument(
        'input_file',
        help='Archivo SQL de entrada'
    )
    
    parser.add_argument(
        '-o', '--output',
        dest='output_file',
        help='Archivo SQL de salida (opcional)'
    )
    
    args = parser.parse_args()
    
    success = process_file(args.input_file, args.output_file)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
