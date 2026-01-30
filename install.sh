#!/bin/bash

# =================================================================
# 🦅 Garuda Ultimate Fusion (GUF) - Ultimate Installer v3.0
# =================================================================
# هذا السكريبت هو النسخة النهائية التي تجمع ميزات Zorin 18 و Win11.

set -e

# الألوان
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}=====================================================${NC}"
echo -e "${CYAN}    مرحباً بك في النسخة النهائية: Garuda Ultimate Fusion v3.0    ${NC}"
echo -e "${BLUE}=====================================================${NC}"

# 1. منح الصلاحيات
chmod +x scripts/*.sh configs/*.sh

# 2. الميزات الأساسية والبرامج المكافئة
echo -e "\n${BLUE}[1/8] تثبيت البرامج الأساسية ودعم العربية...${NC}"
./scripts/fusion_core.sh
./scripts/arabic_support.sh

# 3. ميزة استخراج المحتويات (الزر الأيمن)
echo -e "\n${BLUE}[2/8] تثبيت ميزة 'استخراج إلى ملف نصي'...${NC}"
sudo cp scripts/extract_to_txt.py /usr/local/bin/
sudo chmod +x /usr/local/bin/extract_to_txt.py
mkdir -p ~/.local/share/kservices5/ServiceMenus/
cp configs/extract_to_txt.desktop ~/.local/share/kservices5/ServiceMenus/

# 4. ميزات ويندوز 11 المتقدمة
echo -e "\n${PURPLE}[3/8] تفعيل ميزات Snap Layouts و Widgets...${NC}"
./scripts/win11_advanced_ui.sh

# 5. دعم تطبيقات الأندرويد (WSA Alternative)
echo -e "\n${PURPLE}[4/8] إعداد دعم تطبيقات الأندرويد (Waydroid)...${NC}"
./scripts/android_support.sh

# 6. ميزات Zorin OS 18 الجديدة
echo -e "\n${CYAN}[5/8] تفعيل ميزات Zorin 18 (Spatial Desktop)...${NC}"
./scripts/zorin18_spatial_desktop.sh

# 7. الخلفيات الديناميكية وتكامل الهاتف
echo -e "\n${CYAN}[6/8] إعداد الخلفيات الديناميكية وتكامل الهاتف...${NC}"
./scripts/dynamic_wallpapers.sh
./scripts/zorin_connect_fusion.sh

# 8. التحسينات النهائية
echo -e "\n${BLUE}[7/8] تطبيق التحسينات النهائية وإصلاحات VPN...${NC}"
./scripts/fix_outline_vpn.sh

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}      🎉 تم الانتهاء من التثبيت النهائي بنجاح! 🎉      ${NC}"
echo -e "${BLUE}      نظام غارودا الخاص بك الآن يجمع بين قوة Arch وجمال Zorin 18 وسهولة Win11.      ${NC}"
echo -e "${GREEN}=====================================================${NC}"
