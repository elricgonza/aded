#!/usr/bin/env python3
"""
Script para eliminar líneas en blanco de archivos SQL.

Elimina:
- Líneas completamente vacías
- Líneas que solo contienen espacios, tabulaciones u otros caracteres de whitespace

Mantiene:
- Todas las líneas con contenido SQL real
- La integridad del código SQL
"""

import sys
import argparse
from pathlib import Path


def remove_blank_lines(sql_content):
    """
    Elimina todas las líneas en blanco de un contenido SQL.
    
    Args:
        sql_content (str): Contenido SQL con líneas en blanco
        
    Returns:
        str: Contenido SQL sin líneas en blanco
    """
    lines = sql_content.split('\n')
    non_blank_lines = []
    
    for line in lines:
        # strip() elimina espacios, tabs, etc. al inicio y final
        if line.strip():  # Si la línea no está vacía después de strip()
            non_blank_lines.append(line.rstrip())  # rstrip() para eliminar espacios al final
    
    return '\n'.join(non_blank_lines)


def process_file(input_file, output_file=None):
    """
    Procesa un archivo SQL eliminando líneas en blanco.
    
    Args:
        input_file (str): Ruta al archivo de entrada
        output_file (str, optional): Ruta al archivo de salida. 
                                   Si no se especifica, se añade '_sin_lineas' al nombre original.
    """
    input_path = Path(input_file)
    
    if not input_path.exists():
        print(f"Error: El archivo '{input_file}' no existe.")
        return False
    
    if not output_file:
        output_file = input_path.stem + "_sin_lineas" + input_path.suffix
    
    try:
        # Leer el archivo de entrada
        with open(input_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Eliminar líneas en blanco
        clean_content = remove_blank_lines(content)
        
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
        description="Elimina líneas en blanco de archivos SQL",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos de uso:
  python remove_blank_lines.py script.sql
  python remove_blank_lines.py script.sql -o clean_script.sql
  python remove_blank_lines.py input.sql --output output.sql
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
