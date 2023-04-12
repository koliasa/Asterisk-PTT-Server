#!/bin/bash

# Оновлення системи
sudo yum update -y

# Встановити Asterisk
sudo yum install -y asterisk

# Встановити пакети для підтримки RTP та RTCP
sudo yum install -y asterisk-voicemail asterisk-sounds-core-en asterisk-dahdi

# Налаштувати фаярвол
sudo firewall-cmd --zone=public --add-port=5060/tcp --permanent
sudo firewall-cmd --zone=public --add-port=5060/udp --permanent
sudo firewall-cmd --zone=public --add-port=10000-20000/udp --permanent
sudo firewall-cmd --reload

# Додаємо налаштування в файл /etc/asterisk/sip.conf
sudo cat <<EOT >> /etc/asterisk/sip.conf
[general]
context=unauthenticated
allowguest=no
srvlookup=yes
udpbindaddr=0.0.0.0
tcpenable=no
transport=udp
icesupport=no

[ptt-phone]
type=friend
secret=your_secret_password
host=dynamic
dtmfmode=rfc2833
context=ptt
canreinvite=no
disallow=all
allow=ulaw
nat=yes
EOT

# Додаємо налаштування в файл /etc/asterisk/extensions.conf
sudo cat <<EOT >> /etc/asterisk/extensions.conf
[ptt]
exten => s,1,Answer()
same => n,Set(TIMEOUT(absolute)=900)
same => n,Playback(press-talk)
same => n,WaitExten(10)
same => n,Hangup()
EOT

# Налаштовуємо файли RTP конфігурації
sudo cat <<EOT >> /etc/asterisk/rtp.conf
[general]
rtpstart=10000
rtpend=20000
icesupport=no
EOT

# Запускаємо Asterisk
sudo systemctl start asterisk

# Налаштувати автозапуск Asterisk при старті системи
sudo systemctl enable asterisk

# Виводимо інформацію про IP-адресу сервера та порти
echo "PTT server IP address: $(hostname -I | cut -d' ' -f1)"
echo "SIP port: 5060"
echo "RTP port range: 10000-20000"

# Кінець скрипта (для вільного користування усім окрім руснявих півнів!)
