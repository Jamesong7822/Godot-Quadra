import PyInstaller.__main__

PyInstaller.__main__.run([
    'server.py',
    "--clean",
    '--onedir',
    '--windowed',
    "-y",
    "--add-data", "venv/Lib/site-packages/pylsl/lib/lsl.dll;pylsl/lib/"
])