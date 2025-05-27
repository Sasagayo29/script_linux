#!/bin/bash
ADS_DIR="/home/kali/ADS"
BACKUP_DIR="/home/kali/backup"
LOG_DIR="/home/kali/log"
LOG_FILE="$LOG_DIR/Log.txt"
tratar_erro() {
    echo "Erro: $1"
    exit 1
}
echo "Entrando na pasta ADS..."
cd "$ADS_DIR" || tratar_erro "Falha ao entrar na pasta ADS."
pwd
echo "Copiando imagem para a pasta de backup..."
cp 'imagem.jpeg' "$BACKUP_DIR/" || tratar_erro "Falha ao copiar a imagem."
echo "Entrando na pasta de backup..."
cd "$BACKUP_DIR" || tratar_erro "Falha ao entrar na pasta backup."
NOVO_NOME="PapaiLula_$(date +%Y_%m_%d_%H_%M).jpeg"
echo "Renomeando imagem para $NOVO_NOME..."
mv 'imagem.jpeg' "$NOVO_NOME" || tratar_erro "Falha ao renomear a imagem."
echo "Conteúdo da pasta de backup:"
pwd
ls
echo "Entrando na pasta de log..."
cd "$LOG_DIR" || tratar_erro "Falha ao entrar na pasta log."
echo "Backup realizado na data $(date +%Y_%m_%d_%H_%M): 'imagem.jpeg'" >> "$LOG_FILE"
echo "Log atualizado em $LOG_FILE."
echo "Processo concluído com sucesso!"