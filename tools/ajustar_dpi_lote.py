import os
import sys
from PIL import Image

def ajustar_dpi_diretorio(pasta, dpi=96):
    # Extensões comuns de imagem
    extensoes = ['.bmp', '.png', '.jpg', '.jpeg', '.tiff']
    arquivos = os.listdir(pasta)

    imagens_processadas = 0

    for nome_arquivo in arquivos:
        caminho_completo = os.path.join(pasta, nome_arquivo)

        if os.path.isfile(caminho_completo) and os.path.splitext(nome_arquivo)[1].lower() in extensoes:
            try:
                with Image.open(caminho_completo) as img:
                    img.save(caminho_completo, dpi=(dpi, dpi))
                    imagens_processadas += 1
            except Exception as e:
                print(f"Erro ao processar {nome_arquivo}: {e}")

    print(f"{imagens_processadas} imagem(ns) ajustada(s) com sucesso para {dpi} DPI.")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Uso: ajustar_dpi_lote.exe <caminho_para_pasta>")
        sys.exit(1)

    pasta = sys.argv[1]

    if not os.path.isdir(pasta):
        print("Erro: o caminho informado não é uma pasta válida.")
        sys.exit(1)

    ajustar_dpi_diretorio(pasta)
