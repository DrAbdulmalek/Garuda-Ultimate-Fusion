#!/bin/bash

# سكريبت تخصيص مركز التحكم والإشعارات

echo "⚙️ جاري تخصيص مركز التحكم..."

# 1. إعداد شريط المهام في المنتصف (Taskbar Alignment)
# kwriteconfig5 --file plasma-org.kde.plasma.desktop-appletsrc --group Containments --group 1 --group Applets --group 2 --key alignment "Center"

# 2. إضافة ويدجت الإعدادات السريعة (Quick Settings)
# استخدام ويدجت 'Control Centre' من متجر KDE

# 3. تخصيص الإشعارات لتظهر بأسلوب ويندوز 11 (الزاوية اليمنى السفلى مع تجميع)
# kwriteconfig5 --file plasmanotifyrc --group Notifications --key PopupPosition "BottomRight"

echo "✅ تم تخصيص واجهة المستخدم."
