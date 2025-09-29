#!/bin/bash

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${GREEN}-- YouTube Downloader Script --${NC}"

# 1. Video URL
read -p "İndirmek istediğiniz video URL'sini girin: " VIDEO_URL
[[ -z "$VIDEO_URL" ]] && { echo -e "${RED}URL boş bırakılamaz!${NC}"; exit 1; }

# 2. Kalite / Format Menüsü
clear
declare -A QUALITY_OPTIONS=(
    ["1"]="1080p"
    ["2"]="720p"
    ["3"]="480p"
    ["4"]="360p"
    ["5"]="Sadece Ses (mp3)"
)

echo -e "${YELLOW}Kalite / Format Seçenekleri:${NC}"
for key in "${!QUALITY_OPTIONS[@]}"; do
    echo "$key) ${QUALITY_OPTIONS[$key]}"
done

read -p "Seçiminizi girin (varsayılan 720p): " QUALITY_CHOICE
QUALITY_CHOICE=${QUALITY_CHOICE:-2}
SELECTED_QUALITY=${QUALITY_OPTIONS[$QUALITY_CHOICE]}

MP3_ONLY=false
if [[ "$SELECTED_QUALITY" == "En iyi ses (mp3)" ]]; then
    MP3_ONLY=true
fi

# 3. SponsorBlock
clear
read -p "SponsorBlock etkinleştirilsin mi? (E/h): " SPONSOR
SPONSOR=${SPONSOR,,}
SPONSORBLOCK=$([[ "$SPONSOR" == "e" ]] && echo "--sponsorblock-remove all" || echo "")

# 4. Video aralığı
clear
read -p "Videonun belirli bir aralığını indirmek ister misiniz?: " TIME_RANGE
TIME_OPTION=""
if [[ -n "$TIME_RANGE" ]]; then
    TIME_OPTION="--download-sections *${TIME_RANGE}*"
fi

# =========================================
# İndirme ve birleştirme
# =========================================
clear
echo -e "${GREEN}İndirme başlıyor...${NC}"

# Basit terminal progress bar
PROGRESS_BAR() {
    while kill -0 $1 2>/dev/null; do
        echo -n "."
        sleep 1
    done
}

if [ "$MP3_ONLY" = true ]; then
    yt-dlp $SPONSORBLOCK -f bestaudio "$VIDEO_URL" --extract-audio --audio-format mp3 &
    PID=$!
    PROGRESS_BAR $PID
    wait $PID
else
    # Video + ses ayrı indirilecek, yt-dlp merge edecek
    yt-dlp $SPONSORBLOCK -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]" $TIME_OPTION "$VIDEO_URL" &
    PID=$!
    PROGRESS_BAR $PID
    wait $PID
fi

echo -e "\n${GREEN}İndirme tamamlandı!${NC}"
