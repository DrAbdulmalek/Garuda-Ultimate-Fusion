#!/bin/bash
# سكريبت إصلاح مشكلة Outline VPN على Garuda Linux

set -e

echo "======================================"
echo "🔒 إصلاح Outline VPN على Garuda Linux"
echo "======================================"
echo ""

# التحقق من صلاحيات الروت
if [ "$EUID" -eq 0 ]; then 
    echo "❌ لا تقم بتشغيل هذا السكريبت كمستخدم روت مباشرة"
    echo "استخدم المستخدم العادي، سيتم طلب كلمة السر عند الحاجة"
    exit 1
fi

# الوظيفة: طباعة رسالة ملونة
print_status() {
    echo -e "\n${1} ${2}\n"
}

# الوظيفة: التحقق من الاتصال بالإنترنت
check_internet() {
    if ping -c 1 8.8.8.8 &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# الوظيفة: الحصول على IP العام
get_public_ip() {
    curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "فشل الحصول على IP"
}

# 1. التحقق من الاتصال بالإنترنت
print_status "🌐" "التحقق من الاتصال بالإنترنت..."
if check_internet; then
    print_status "✅" "الاتصال بالإنترنت يعمل"
    ORIGINAL_IP=$(get_public_ip)
    print_status "📍" "عنوان IP الأصلي: $ORIGINAL_IP"
else
    print_status "❌" "لا يوجد اتصال بالإنترنت"
    exit 1
fi

# 2. التحقق من تثبيت Outline
print_status "📦" "التحقق من تثبيت Outline VPN..."
if [ -f ~/Outline-Client.AppImage ] || command -v outline-client &> /dev/null; then
    print_status "✅" "Outline مثبت"
else
    print_status "⬇️" "تحميل Outline VPN..."
    cd ~
    wget -O Outline-Client.AppImage https://raw.githubusercontent.com/Jigsaw-Code/outline-releases/master/client/Outline-Client.AppImage
    chmod +x Outline-Client.AppImage
    print_status "✅" "تم تحميل Outline VPN"
fi

# 3. التحقق من وحدات TUN/TAP
print_status "🔧" "التحقق من وحدات TUN/TAP..."
if lsmod | grep -q "^tun"; then
    print_status "✅" "وحدة TUN مفعلة"
else
    print_status "⚙️" "تفعيل وحدة TUN..."
    sudo modprobe tun
    sudo modprobe tap
    
    # جعلها دائمة
    echo "tun" | sudo tee /etc/modules-load.d/tun.conf > /dev/null
    echo "tap" | sudo tee /etc/modules-load.d/tap.conf > /dev/null
    print_status "✅" "تم تفعيل وحدات TUN/TAP"
fi

# 4. إعداد DNS
print_status "🌐" "إعداد DNS..."
sudo chattr -i /etc/resolv.conf 2>/dev/null || true
sudo tee /etc/resolv.conf > /dev/null << EOF
# DNS لـ Outline VPN
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 8.8.4.4
EOF
print_status "✅" "تم إعداد DNS"

# 5. تكوين NetworkManager لعدم التدخل في resolv.conf
print_status "⚙️" "تكوين NetworkManager..."
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/dns.conf > /dev/null << EOF
[main]
dns=none
systemd-resolved=false
EOF
sudo systemctl restart NetworkManager
print_status "✅" "تم تكوين NetworkManager"

# 6. إعداد Firewall
print_status "🛡️" "إعداد Firewall..."
if command -v ufw &> /dev/null; then
    print_status "📝" "تكوين UFW..."
    sudo ufw allow out on outline-tun0
    sudo ufw allow out 443/tcp
    sudo ufw allow out 8080/tcp
    sudo ufw allow out 53/udp
    print_status "✅" "تم تكوين UFW"
else
    print_status "ℹ️" "UFW غير مثبت، تخطي..."
fi

# 7. إنشاء سكريبت التوجيه التلقائي
print_status "📝" "إنشاء سكريبت التوجيه التلقائي..."
cat > ~/fix_vpn_routing.sh << 'ROUTING_SCRIPT'
#!/bin/bash
# سكريبت إصلاح توجيه Outline VPN

echo "🔍 فحص اتصال VPN..."

# التحقق من واجهة outline
if ip addr show | grep -q "outline-tun0"; then
    echo "✅ واجهة VPN نشطة: outline-tun0"
    
    # الحصول على عنوان Gateway للـ VPN
    VPN_GATEWAY=$(ip route show dev outline-tun0 | grep -oP 'via \K[0-9.]+' | head -1)
    
    if [ -z "$VPN_GATEWAY" ]; then
        # محاولة الحصول على Gateway من الواجهة
        VPN_GATEWAY=$(ip addr show outline-tun0 | grep -oP 'inet \K[0-9.]+' | head -1)
        # حذف آخر رقم واستبداله بـ 2
        VPN_GATEWAY=$(echo $VPN_GATEWAY | sed 's/\.[0-9]*$/.2/')
    fi
    
    echo "📍 VPN Gateway: $VPN_GATEWAY"
    
    # حفظ المسار الافتراضي القديم
    OLD_GATEWAY=$(ip route | grep default | grep -v outline | awk '{print $3}' | head -1)
    OLD_INTERFACE=$(ip route | grep default | grep -v outline | awk '{print $5}' | head -1)
    
    echo "📍 Old Gateway: $OLD_GATEWAY via $OLD_INTERFACE"
    
    # حذف المسار الافتراضي القديم (مؤقتاً)
    echo "🔄 تعديل جداول التوجيه..."
    sudo ip route del default 2>/dev/null || true
    
    # إضافة مسار VPN كافتراضي بأولوية عالية
    sudo ip route add default via $VPN_GATEWAY dev outline-tun0 metric 100
    
    # إضافة مسار الشبكة المحلية كاحتياطي
    if [ ! -z "$OLD_GATEWAY" ] && [ ! -z "$OLD_INTERFACE" ]; then
        sudo ip route add default via $OLD_GATEWAY dev $OLD_INTERFACE metric 600
        
        # إضافة مسار للشبكة المحلية
        LOCAL_NETWORK=$(ip -4 addr show $OLD_INTERFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        if [ ! -z "$LOCAL_NETWORK" ]; then
            LOCAL_SUBNET=$(echo $LOCAL_NETWORK | sed 's/\.[0-9]*$/.0/')
            sudo ip route add ${LOCAL_SUBNET}/24 via $OLD_GATEWAY dev $OLD_INTERFACE 2>/dev/null || true
        fi
    fi
    
    # إصلاح DNS
    echo "🌐 إصلاح DNS..."
    sudo chattr -i /etc/resolv.conf 2>/dev/null || true
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
    echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf > /dev/null
    
    # التحقق من النتيجة
    sleep 2
    echo ""
    echo "📊 النتائج:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "المسارات الحالية:"
    ip route show | head -5
    echo ""
    echo "واجهات الشبكة:"
    ip addr show | grep "inet " | grep -v "127.0.0.1"
    echo ""
    echo "عنوان IP العام:"
    NEW_IP=$(curl -s --max-time 10 ifconfig.me)
    echo "$NEW_IP"
    echo ""
    
    # التحقق من نجاح التغيير
    if [ "$NEW_IP" != "" ] && [ "$NEW_IP" != "$OLD_IP" ]; then
        echo "✅ نجح! تم تغيير IP بنجاح"
    else
        echo "⚠️ تحذير: قد لا يكون IP قد تغير"
        echo "جرب إعادة الاتصال بـ VPN"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
else
    echo "❌ خطأ: واجهة outline-tun0 غير موجودة"
    echo ""
    echo "الخطوات المطلوبة:"
    echo "1. تأكد من تشغيل Outline VPN"
    echo "2. تأكد من إدخال مفتاح الوصول بشكل صحيح"
    echo "3. جرب إعادة تشغيل التطبيق"
    echo ""
    exit 1
fi
ROUTING_SCRIPT

chmod +x ~/fix_vpn_routing.sh
print_status "✅" "تم إنشاء سكريبت التوجيه: ~/fix_vpn_routing.sh"

# 8. تثبيت proxychains كخطة احتياطية
print_status "📦" "تثبيت proxychains (خطة احتياطية)..."
if ! command -v proxychains &> /dev/null; then
    sudo pacman -S --needed --noconfirm proxychains-ng
    print_status "✅" "تم تثبيت proxychains"
else
    print_status "✅" "proxychains مثبت مسبقاً"
fi

# تكوين proxychains
print_status "⚙️" "تكوين proxychains..."
sudo tee /etc/proxychains.conf > /dev/null << EOF
# proxychains configuration for Outline VPN
strict_chain
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
# Outline VPN proxy (افتراضي على منفذ 1080)
socks5 127.0.0.1 1080
EOF
print_status "✅" "تم تكوين proxychains"

# 9. إنشاء سكريبت اختبار VPN
print_status "📝" "إنشاء سكريبت اختبار VPN..."
cat > ~/test_vpn.sh << 'TEST_SCRIPT'
#!/bin/bash
# سكريبت اختبار Outline VPN

echo "======================================"
echo "🧪 اختبار Outline VPN"
echo "======================================"
echo ""

# اختبار 1: واجهة الشبكة
echo "1️⃣ التحقق من واجهة VPN:"
if ip addr show outline-tun0 &> /dev/null; then
    echo "   ✅ outline-tun0 موجودة"
    ip addr show outline-tun0 | grep "inet "
else
    echo "   ❌ outline-tun0 غير موجودة"
fi
echo ""

# اختبار 2: عنوان IP العام
echo "2️⃣ عنوان IP العام:"
PUBLIC_IP=$(curl -s --max-time 10 ifconfig.me)
echo "   📍 IP: $PUBLIC_IP"
echo ""

# اختبار 3: DNS
echo "3️⃣ اختبار DNS:"
nslookup google.com 8.8.8.8 &> /dev/null && echo "   ✅ DNS يعمل" || echo "   ❌ DNS لا يعمل"
echo ""

# اختبار 4: جداول التوجيه
echo "4️⃣ المسار الافتراضي:"
ip route show | grep default
echo ""

# اختبار 5: اختبار تسرب DNS
echo "5️⃣ اختبار تسرب DNS:"
curl -s https://ipleak.net/json/ 2>/dev/null | grep -oP '"ip":"[^"]+' | head -3
echo ""

# اختبار 6: السرعة (ping)
echo "6️⃣ اختبار السرعة (ping):"
ping -c 3 8.8.8.8 | tail -1
echo ""

echo "======================================"
TEST_SCRIPT

chmod +x ~/test_vpn.sh
print_status "✅" "تم إنشاء سكريبت الاختبار: ~/test_vpn.sh"

# 10. إنشاء alias مفيد
print_status "📝" "إضافة aliases مفيدة..."
SHELL_RC=""
if [ -f ~/.zshrc ]; then
    SHELL_RC=~/.zshrc
elif [ -f ~/.bashrc ]; then
    SHELL_RC=~/.bashrc
fi

if [ ! -z "$SHELL_RC" ]; then
    if ! grep -q "# Outline VPN aliases" "$SHELL_RC"; then
        cat >> "$SHELL_RC" << 'EOF'

# Outline VPN aliases
alias vpnfix='~/fix_vpn_routing.sh'
alias vpntest='~/test_vpn.sh'
alias vpnip='curl ifconfig.me'
alias vpnstatus='ip addr show outline-tun0 2>/dev/null && echo "VPN متصل" || echo "VPN غير متصل"'
EOF
        print_status "✅" "تم إضافة aliases"
        echo "   استخدم: vpnfix للإصلاح، vpntest للاختبار"
    fi
fi

# 11. تعليمات الاستخدام
echo ""
echo "======================================"
print_status "✅" "اكتمل الإعداد بنجاح!"
echo "======================================"
echo ""
echo "📖 كيفية الاستخدام:"
echo ""
echo "1️⃣ شغّل Outline VPN من التطبيق"
echo "   cd ~ && ./Outline-Client.AppImage"
echo ""
echo "2️⃣ بعد الاتصال، شغّل سكريبت الإصلاح:"
echo "   ~/fix_vpn_routing.sh"
echo "   (أو استخدم: vpnfix)"
echo ""
echo "3️⃣ للتحقق من نجاح الاتصال:"
echo "   ~/test_vpn.sh"
echo "   (أو استخدم: vpntest)"
echo ""
echo "4️⃣ للتحقق من IP الحالي:"
echo "   curl ifconfig.me"
echo "   (أو استخدم: vpnip)"
echo ""
echo "📝 ملاحظات:"
echo "• يجب تشغيل سكريبت الإصلاح بعد كل اتصال بـ VPN"
echo "• إذا لم ينجح، جرب إعادة تشغيل Outline"
echo "• يمكنك استخدام proxychains كخطة احتياطية:"
echo "  proxychains firefox"
echo ""
echo "🆘 إذا استمرت المشكلة:"
echo "• تحقق من مفتاح الوصول"
echo "• جرب سيرفر VPN مختلف"
echo "• تأكد من أن مزود الإنترنت لا يحجب VPN"
echo ""
