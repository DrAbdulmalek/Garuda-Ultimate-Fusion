#!/bin/bash
# سكريبت تثبيت البرامج الأساسية على Garuda Linux

set -e

echo "======================================"
echo "📦 تثبيت البرامج الأساسية - Garuda Linux"
echo "======================================"
echo ""

# التحقق من صلاحيات الروت
if [ "$EUID" -eq 0 ]; then 
    echo "❌ لا تقم بتشغيل هذا السكريبت كمستخدم روت مباشرة"
    exit 1
fi

# الوظيفة: طباعة رسالة
print_status() {
    echo -e "\n${1} ${2}\n"
}

# الوظيفة: التحقق من نجاح الأمر
check_success() {
    if [ $? -eq 0 ]; then
        print_status "✅" "$1"
    else
        print_status "❌" "فشل: $1"
    fi
}

# 1. تحديث النظام
print_status "🔄" "تحديث النظام..."
sudo pacman -Syu --noconfirm
check_success "تحديث النظام"

# 2. تثبيت yay إذا لم يكن موجوداً
print_status "📦" "التحقق من yay..."
if ! command -v yay &> /dev/null; then
    print_status "⬇️" "تثبيت yay..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    check_success "تثبيت yay"
else
    print_status "✅" "yay مثبت مسبقاً"
fi

# 3. تثبيت أدوات التطوير الأساسية
print_status "💻" "تثبيت أدوات التطوير..."
sudo pacman -S --needed --noconfirm \
    base-devel \
    git \
    wget \
    curl \
    vim \
    nano \
    htop \
    btop \
    neofetch
check_success "أدوات التطوير الأساسية"

# 4. تثبيت لغات البرمجة
print_status "🐍" "تثبيت Python..."
sudo pacman -S --needed --noconfirm \
    python \
    python-pip \
    python-virtualenv \
    python-pipenv \
    ipython
check_success "Python"

print_status "📗" "تثبيت Node.js..."
sudo pacman -S --needed --noconfirm \
    nodejs \
    npm \
    yarn
check_success "Node.js"

print_status "☕" "تثبيت Java..."
sudo pacman -S --needed --noconfirm \
    jdk-openjdk \
    jre-openjdk \
    maven \
    gradle
check_success "Java"

# 5. تثبيت بيئات التطوير
print_status "📝" "تثبيت VS Code..."
sudo pacman -S --needed --noconfirm code
check_success "VS Code"

# 6. تثبيت Docker
print_status "🐳" "تثبيت Docker..."
sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
check_success "Docker"

# 7. تثبيت قواعد البيانات
print_status "🗄️" "تثبيت قواعد البيانات..."
sudo pacman -S --needed --noconfirm \
    postgresql \
    postgresql-libs \
    mariadb \
    redis
check_success "قواعد البيانات"

# 8. تثبيت المتصفحات
print_status "🌐" "تثبيت المتصفحات..."
sudo pacman -S --needed --noconfirm \
    firefox \
    chromium
check_success "المتصفحات"

# 9. تثبيت برامج الوسائط المتعددة
print_status "🎬" "تثبيت برامج الوسائط..."
sudo pacman -S --needed --noconfirm \
    vlc \
    mpv \
    gimp \
    inkscape \
    kdenlive \
    obs-studio \
    audacity
check_success "برامج الوسائط"

# 10. تثبيت برامج المكتب
print_status "📄" "تثبيت برامج المكتب..."
sudo pacman -S --needed --noconfirm \
    libreoffice-fresh \
    libreoffice-fresh-ar \
    okular \
    thunderbird
check_success "برامج المكتب"

# 11. تثبيت أدوات النظام
print_status "🔧" "تثبيت أدوات النظام..."
sudo pacman -S --needed --noconfirm \
    gparted \
    gnome-disk-utility \
    timeshift \
    bleachbit \
    p7zip \
    unrar \
    unzip \
    zip
check_success "أدوات النظام"

# 12. تثبيت أدوات الشبكة
print_status "🌐" "تثبيت أدوات الشبكة..."
sudo pacman -S --needed --noconfirm \
    nmap \
    wireshark-qt \
    openvpn \
    networkmanager-openvpn
sudo usermod -aG wireshark $USER
check_success "أدوات الشبكة"

# 13. تثبيت برامج Flatpak الإضافية
print_status "📦" "تثبيت برامج Flatpak..."
flatpak install flathub --noninteractive -y com.spotify.Client 2>/dev/null || true
flatpak install flathub --noninteractive -y com.skype.Client 2>/dev/null || true
flatpak install flathub --noninteractive -y com.discordapp.Discord 2>/dev/null || true
flatpak install flathub --noninteractive -y us.zoom.Zoom 2>/dev/null || true
check_success "برامج Flatpak"

# 14. تثبيت الخطوط
print_status "🔤" "تثبيت الخطوط..."
sudo pacman -S --needed --noconfirm \
    ttf-liberation \
    ttf-dejavu \
    ttf-ubuntu-font-family \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-extra
check_success "الخطوط"

# 15. تثبيت أدوات الألعاب (اختياري)
read -p "هل تريد تثبيت أدوات الألعاب؟ (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "🎮" "تثبيت أدوات الألعاب..."
    sudo pacman -S --needed --noconfirm \
        steam \
        lutris \
        wine-staging \
        winetricks \
        gamemode \
        mangohud
    
    # حل تعارض goverlay
    sudo pacman -R goverlay-git --noconfirm 2>/dev/null || true
    sudo pacman -S --needed --noconfirm goverlay
    check_success "أدوات الألعاب"
fi

# 16. تحسينات الأداء
print_status "⚡" "تطبيق تحسينات الأداء..."

# تفعيل TRIM للـ SSD
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

# تحسين Swappiness
if ! grep -q "vm.swappiness" /etc/sysctl.d/99-swappiness.conf 2>/dev/null; then
    echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf > /dev/null
    sudo sysctl -p /etc/sysctl.d/99-swappiness.conf
fi

check_success "تحسينات الأداء"

# 17. تثبيت aliases مفيدة
print_status "📝" "إضافة aliases مفيدة..."
SHELL_RC=""
if [ -f ~/.zshrc ]; then
    SHELL_RC=~/.zshrc
elif [ -f ~/.bashrc ]; then
    SHELL_RC=~/.bashrc
fi

if [ ! -z "$SHELL_RC" ]; then
    if ! grep -q "# Garuda useful aliases" "$SHELL_RC"; then
        cat >> "$SHELL_RC" << 'EOF'

# Garuda useful aliases
alias update='sudo pacman -Syu && flatpak update'
alias clean='sudo pacman -Sc && sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null'
alias myip='curl ifconfig.me'
alias ports='sudo netstat -tulanp'
alias ll='ls -lah'
EOF
        print_status "✅" "تم إضافة aliases"
    fi
fi

# 18. إنشاء ملف بالبرامج المثبتة
print_status "📋" "إنشاء قائمة بالبرامج المثبتة..."
pacman -Qq > ~/installed_packages_$(date +%Y%m%d).txt
flatpak list --app --columns=application > ~/installed_flatpaks_$(date +%Y%m%d).txt 2>/dev/null || true
print_status "✅" "تم حفظ القوائم في المجلد الرئيسي"

# 19. ملخص النهائي
echo ""
echo "======================================"
print_status "✅" "اكتمل تثبيت البرامج الأساسية!"
echo "======================================"
echo ""
echo "📊 ملخص ما تم تثبيته:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ أدوات التطوير الأساسية"
echo "✅ Python, Node.js, Java"
echo "✅ VS Code"
echo "✅ Docker & Docker Compose"
echo "✅ قواعد البيانات (PostgreSQL, MariaDB, Redis)"
echo "✅ المتصفحات (Firefox, Chromium)"
echo "✅ برامج الوسائط (VLC, GIMP, OBS, Kdenlive)"
echo "✅ برامج المكتب (LibreOffice, Okular)"
echo "✅ أدوات النظام والشبكة"
echo "✅ الخطوط العربية والإنجليزية"
echo ""
echo "📝 ملاحظات مهمة:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣ قم بتسجيل الخروج ثم الدخول لتفعيل docker group"
echo "2️⃣ قوائم البرامج المثبتة في:"
echo "   ~/installed_packages_*.txt"
echo "   ~/installed_flatpaks_*.txt"
echo "3️⃣ تم إضافة aliases مفيدة:"
echo "   update - لتحديث النظام"
echo "   clean - لتنظيف النظام"
echo "   myip - لعرض IP العام"
echo "4️⃣ لتثبيت المزيد من البرامج:"
echo "   sudo pacman -S اسم_البرنامج"
echo "   yay -S اسم_البرنامج"
echo "   flatpak install flathub اسم_البرنامج"
echo ""
echo "🚀 الخطوات التالية:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. إعداد قواعد البيانات:"
echo "   sudo systemctl start postgresql"
echo "   sudo systemctl start mariadb"
echo ""
echo "2. إعداد Git:"
echo "   git config --global user.name 'اسمك'"
echo "   git config --global user.email 'email@example.com'"
echo ""
echo "3. تثبيت إضافات VS Code المفضلة"
echo ""
echo "4. تخصيص الواجهة حسب رغبتك"
echo ""
