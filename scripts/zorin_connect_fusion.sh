#!/bin/bash

# سكريبت إعداد وتخصيص تكامل الهاتف (بديل Zorin Connect)

echo "📱 جاري إعداد تكامل الهاتف (Zorin Connect Alternative)..."

# 1. تثبيت وتفعيل KDE Connect
# sudo pacman -S --needed kdeconnect

# 2. تخصيص أيقونة واسم الخدمة لتظهر كـ 'Zorin Connect'
# mkdir -p ~/.local/share/applications/
# cp /usr/share/applications/org.kde.kdeconnect.kcm.desktop ~/.local/share/applications/zorin-connect.desktop
# sed -i 's/Name=KDE Connect/Name=Zorin Connect/g' ~/.local/share/applications/zorin-connect.desktop
# sed -i 's/Icon=kdeconnect/Icon=zorin-connect/g' ~/.local/share/applications/zorin-connect.desktop

# 3. فتح منافذ الجدار الناري اللازمة
# sudo ufw allow 1714:1764/udp
# sudo ufw allow 1714:1764/tcp
# sudo ufw reload

echo "✅ تم إعداد تكامل الهاتف بنجاح."
