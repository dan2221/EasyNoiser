@echo off
setlocal

:: Define o nome da pasta
set "folderName=EasyNoiser"

:: Cria a pasta
mkdir "%folderName%"

:: Copia os arquivos para a nova pasta
copy "VampConvert.exe" "%folderName%"
copy "noise.exe" "%folderName%"
copy "noise.dpr" "%folderName%"
copy "ajustar_dpi_lote.exe" "%folderName%"
copy "EasyNoiser.exe" "%folderName%"
copy "License - LGPL 2.1 (VampConvert).txt" "%folderName%"
copy "Readme.md" "%folderName%\Readme.txt"

:: Verifica se o 7-Zip está instalado e está no PATH
where 7z >nul 2>nul
if errorlevel 1 (
    echo 7-Zip não está instalado ou não está no PATH. Por favor, instale o 7-Zip e adicione ao PATH.
    exit /b
)

:: Obtém a data atual no formato YYYY-MM-DD
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| find "="') do set "currentDate=%%I"
set "formattedDate=%currentDate:~0,4%-%currentDate:~4,2%-%currentDate:~6,2%"

:: Comprime a pasta em um arquivo zip com a data atual no nome
7z a "%folderName%_%formattedDate%.zip" "%folderName%\*"

:: Limpa a pasta criada (opcional)
rmdir /s /q "%folderName%"

echo Arquivo zip foi criado com sucesso: %folderName%_%formattedDate%.zip
endlocal
