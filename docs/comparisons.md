# مقارنة البرامج والسمات (Windows 11 & Zorin OS vs. Garuda)

## 1. بدائل برامج ويندوز 11 على غارودا

| برنامج ويندوز 11 | البديل الموصى به على غارودا | طريقة التثبيت |
| :--- | :--- | :--- |
| **Microsoft Office** | OnlyOffice / LibreOffice | `sudo pacman -S onlyoffice-bin` |
| **Adobe Acrobat** | Okular / Master PDF Editor | `sudo pacman -S okular` |
| **Adobe Photoshop** | GIMP / Krita | `sudo pacman -S gimp krita` |
| **Notepad** | Kate / Mousepad | `sudo pacman -S kate` |
| **Windows Explorer** | Dolphin (مع تخصيص) | مثبت مسبقاً |
| **Media Player** | VLC / MPV | `sudo pacman -S vlc mpv` |
| **Microsoft Edge** | Brave / Firefox | `sudo pacman -S brave-bin` |

## 2. سمات وخصائص Zorin OS المستهدفة

- **Zorin Appearance:** محاكاة أداة تخصيص المظهر لتغيير تخطيط الشريط السفلي (Taskbar).
- **السمات البصرية:** استخدام سمات `Zorin-Desktop` أو بدائلها مثل `WhiteSur` و `Fluent` لـ KDE Plasma.
- **المؤثرات:** تفعيل مؤثرات النوافذ (Wobbly Windows, Magic Lamp) التي يشتهر بها زورين.
- **الخطوط:** استخدام خطوط `Segoe UI` (لويندوز) و `Inter` (للمظهر الحديث).

## 3. تحسينات غارودا المدمجة
- دمج سكريبت `fix_outline_vpn.sh` للإصلاح التلقائي.
- دمج سكريبت `extract_to_txt.py` في قائمة الزر الأيمن.
- تعريب كامل للواجهات ودعم النصوص العربية.
