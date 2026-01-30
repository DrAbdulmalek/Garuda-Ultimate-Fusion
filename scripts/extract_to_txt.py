#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import zipfile
import os
import sys
import pathlib
import mimetypes
import datetime
import glob
import subprocess
import tempfile
import argparse

# محاولة استيراد مكتبة rarfile
RAR_SUPPORT = False
rarfile = None
try:
    import rarfile
    RAR_SUPPORT = True
except ImportError:
    pass

def get_unique_filename(base_name, extension=".txt"):
    """إنشاء اسم ملف فريد إذا كان الملف موجودًا بالفعل"""
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    return f"{base_name}_contents_{timestamp}{extension}"

def list_files(startpath):
    """قائمة بجميع الملفات والمجلدات بشكل شجري"""
    output = []
    for root, dirs, files in os.walk(startpath):
        level = root.replace(startpath, '').count(os.sep)
        indent = ' ' * 4 * (level)
        output.append(f'{indent}{os.path.basename(root)}/')
        subindent = ' ' * 4 * (level + 1)
        for f in files:
            output.append(f'{subindent}{f}')
    return "\n".join(output)

def process_path(target_path):
    """معالجة المسار سواء كان مجلداً أو ملفاً مضغوطاً"""
    if not os.path.exists(target_path):
        return f"Error: Path {target_path} not found."

    output_file = get_unique_filename(target_path)
    
    with open(output_file, 'w', encoding='utf-8') as out:
        out.write(f"Report for: {target_path}\n")
        out.write(f"Generated on: {datetime.datetime.now()}\n")
        out.write("="*50 + "\n\n")

        if os.path.isdir(target_path):
            out.write("Folder Structure:\n")
            out.write(list_files(target_path))
        elif zipfile.is_zipfile(target_path):
            out.write("ZIP Archive Contents:\n")
            with zipfile.ZipFile(target_path, 'r') as z:
                for name in z.namelist():
                    out.write(f"{name}\n")
        elif RAR_SUPPORT and rarfile.is_rarfile(target_path):
            out.write("RAR Archive Contents:\n")
            with rarfile.RarFile(target_path, 'r') as r:
                for name in r.namelist():
                    out.write(f"{name}\n")
        else:
            out.write("Unsupported file type or archive.")

    return output_file

def main():
    parser = argparse.ArgumentParser(description="Extract contents to TXT")
    parser.add_argument("path", help="Path to folder or archive")
    args = parser.parse_args()
    
    result_file = process_path(args.path)
    print(f"Contents saved to: {result_file}")

if __name__ == "__main__":
    main()
