import PyInstaller.__main__
import shutil

PyInstaller.__main__.run([
    'server.py',
    "--clean",
    '--onefile',
    '--windowed',
    "-y",
    "--add-data", "venv/Lib/site-packages/pylsl/lib/lsl.dll;pylsl/lib/"
])

# Copy the executable over to the exports folder
shutil.copy("dist/server.exe", "../Exports")