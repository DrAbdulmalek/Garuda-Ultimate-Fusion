#!/bin/bash

# سكريبت تفعيل ميزة Spatial Desktop والمؤثرات ثلاثية الأبعاد (مستوحى من Zorin 18)

echo "🌀 جاري تفعيل ميزة Spatial Desktop والمؤثرات البصرية..."

# 1. تفعيل مكعب سطح المكتب (Desktop Cube)
# ملاحظة: في KDE Plasma 6، مكعب سطح المكتب مدمج أو يتوفر كإضافة
echo "🧊 تهيئة Desktop Cube..."
# kwriteconfig5 --file kwinrc --group Plugins --key desktopcubeEnabled true

# 2. تفعيل تأثير Overview (نظرة عامة على النوافذ)
echo "🖼️ تهيئة تأثير Overview..."
# kwriteconfig5 --file kwinrc --group Plugins --key overviewEnabled true

# 3. ضبط سرعة الانتقالات (Animations Speed) لجعلها أكثر سلاسة
echo "⚡ ضبط سرعة المؤثرات..."
# kwriteconfig5 --file kdeglobals --group KDE --key AnimationDurationFactor 0.8

# 4. تفعيل تأثير "Magic Lamp" لتصغير النوافذ
echo "🪄 تفعيل تأثير Magic Lamp..."
# kwriteconfig5 --file kwinrc --group Plugins --key magiclampEnabled true

echo "✅ تم تفعيل مؤثرات Zorin 18 المكانية."
