@echo off
setlocal

:: Define o nome da pasta
set "folderName=EasyNoiser"

:: Cria a pasta
mkdir "%folderName%"
mkdir "%folderName%\tools"

:: Copia os arquivos para a nova pasta
copy "tools\*" "%folderName%\tools\" /Y
copy "EasyNoiser.exe" "%folderName%"
copy "Readme.md" "%folderName%\Readme.txt"

:: Verifica se o 7-Zip está instalado e está no PATH
where 7z >nul 2>nul
if errorlevel 1 (
    echo 7-Zip não está instalado ou não está no PATH. Por favor, instale o 7-Zip e adicione ao PATH.
    exit /b
)

:: Comprime a pasta em um arquivo zip
7z a "%folderName%.zip" "%folderName%\*"

:: Limpa a pasta criada (opcional)
rmdir /s /q "%folderName%"

echo Arquivo zip foram criado com sucesso.
endlocal
