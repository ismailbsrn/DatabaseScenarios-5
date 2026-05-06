#!/bin/bash
PATH=/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:$PATH

BACKUP_TYPE=$1 
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$HOME/Desktop/DB_Backups/backup_log.txt"

if [ "$BACKUP_TYPE" == "full" ]; then
    echo "[$DATE] Tam (Full) yedek baslatiliyor..." >> "$LOG_FILE"
    pgbackrest --stanza=proje_db_stanza --type=full backup
elif [ "$BACKUP_TYPE" == "diff" ]; then
    echo "[$DATE] Fark (Differential) yedegi baslatiliyor..." >> "$LOG_FILE"
    pgbackrest --stanza=proje_db_stanza --type=diff backup
else
    echo "HATA: Gecerli bir yedek tipi belirtilmedi (full veya diff)."
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "[$DATE] BASARILI: $BACKUP_TYPE yedek alindi." >> "$LOG_FILE"
else
    echo "[$DATE] HATA: $BACKUP_TYPE yedekleme basarisiz!" >> "$LOG_FILE"
    
    curl --ssl-reqd \
      --url 'smtps://smtp.gmail.com:465' \
      --user 'ismailbasaran0614@gmail.com:udjp cxjzaivcvqtu' \
      --mail-from 'ismailbasaran0614@gmail.com' \
      --mail-rcpt 'bsrn.ismail@gmail.com' \
      --upload-file <(echo -e "Subject: DIKKAT: Veritabani Yedekleme HATASI\n\n$BACKUP_TYPE yedeklemesi BASARISIZ oldu!\n\nLutfen loglari kontrol edin.")
fi
