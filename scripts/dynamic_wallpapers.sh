#!/bin/bash

# سكريبت إعداد الخلفيات الديناميكية (Dynamic Wallpapers)

echo "🌅 جاري إعداد نظام الخلفيات الديناميكية..."

# 1. إنشاء مجلد للخلفيات
mkdir -p ~/Pictures/Wallpapers/Dynamic/

# 2. تحميل سكريبت التغيير التلقائي (محاكاة)
# في بيئة حقيقية، يمكن استخدام أداة مثل 'variety' أو سكريبت cron
cat > ~/scripts/change_wallpaper.sh <<EOF
#!/bin/bash
HOUR=\$(date +%H)
if [ \$HOUR -ge 06 ] && [ \$HOUR -lt 12 ]; then
    # الصباح
    plasma-apply-wallpaperimage ~/Pictures/Wallpapers/Dynamic/morning.jpg
elif [ \$HOUR -ge 12 ] && [ \$HOUR -lt 18 ]; then
    # الظهيرة
    plasma-apply-wallpaperimage ~/Pictures/Wallpapers/Dynamic/afternoon.jpg
else
    # المساء
    plasma-apply-wallpaperimage ~/Pictures/Wallpapers/Dynamic/night.jpg
fi
EOF

chmod +x ~/scripts/change_wallpaper.sh

# 3. إضافة مهمة جدولة (Cron Job) لتحديث الخلفية كل ساعة
# (crontab -l 2>/dev/null; echo "0 * * * * ~/scripts/change_wallpaper.sh") | crontab -

echo "✅ تم إعداد نظام الخلفيات الديناميكية."
