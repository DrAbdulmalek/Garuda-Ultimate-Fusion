#!/bin/bash

# سكريبت دعم اللغة العربية في Garuda Linux

echo "🎨 جاري إعداد دعم اللغة العربية..."

# 1. تثبيت الخطوط العربية الأساسية
echo "📦 تثبيت الخطوط..."
FONTS=(
    "ttf-amiri" 
    "ttf-sil-scheherazade" 
    "adobe-source-han-sans-otc-fonts"
    "noto-fonts-emoji"
)

# ملاحظة: في بيئة حقيقية سيتم استخدام yay أو pacman
# yay -S --noconfirm "${FONTS[@]}"

# 2. ضبط إعدادات الكيبورد (عربي/إنجليزي)
echo "⌨️ ضبط تخطيط لوحة المفاتيح..."
# localectl set-x11-keymap us,ar pc105 ,qwerty grp:alt_shift_toggle

# 3. تحسين ظهور الخطوط في المتصفح والواجهة
mkdir -p ~/.config/fontconfig/conf.d/
cat > ~/.config/fontconfig/conf.d/99-arabic-fonts.conf <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Amiri</family>
      <family>Noto Sans Arabic</family>
    </prefer>
  </alias>
</fontconfig>
EOF

echo "✅ تم إعداد دعم اللغة العربية بنجاح."
