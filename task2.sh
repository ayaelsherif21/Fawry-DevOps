ping -c 4 internal.example.com

######## 1-Initial Verification
# Local resolver
dig internal.example.com

######## 2-Comprehensive DNS Investigation
# Specific DNS server (Google)
dig @8.8.8.8 internal.example.com

# System resolver
getent hosts internal.example.com

# Check DNS configuration files
cat /etc/resolv.conf
cat /etc/nsswitch.conf | grep hosts

######### Check DNS cache
# For systemd-resolved
sudo systemd-resolve --statistics
sudo systemd-resolve --flush-caches

# For nscd
sudo nscd -g | grep hosts
sudo systemctl restart nscd

######## 3- Network Path Analysis
traceroute $(dig +short internal.example.com)
sudo iptables -L -nv --line-numbers
sudo iptables -L -nv -t nat # For NAT rules

####### 4- Service Availability Check
# Get the resolved IP
IP=$(dig +short internal.example.com | head -1)

# Check HTTP
curl -I "http://$IP" -H "Host: internal.example.com"
curl -vk "https://$IP" -H "Host: internal.example.com"

# Check raw TCP connectivity
nc -zvw3 $IP 80
nc -zvw3 $IP 443

# Alternative using telnet
echo "GET / HTTP/1.1\nHost: internal.example.com\n\n" | telnet $IP 80

######## 5- Permanent Solutions
echo "192.168.1.100 internal.example.com" | sudo tee -a /etc/hosts

sudo mkdir -p /etc/systemd/resolved.conf.d
echo -e "[Resolve]\nDNS=8.8.8.8 192.168.1.1\nDomains=example.com" | sudo tee /etc/systemd/resolved.conf.d/fallback.conf
sudo systemctl restart systemd-resolved

sudo nmcli con mod "Wired connection 1" ipv4.dns "192.168.1.1 8.8.8.8"
sudo nmcli con mod "Wired connection 1" ipv4.ignore-auto-dns yes
sudo nmcli con down "Wired connection 1" && sudo nmcli con up "Wired connection 1"

######## Verification Tests
# DNS resolution
dig +short internal.example.com

# HTTP connectivity
curl -I http://internal.example.com

# HTTPS connectivity
curl -Ik https://internal.example.com

# Network path
mtr -rwbc 10 internal.example.com

#My add some fixes
# Update DNS settings permanently
sudo nmcli con mod eth0 ipv4.dns "192.168.1.1 8.8.8.8"
sudo nmcli con mod eth0 ipv4.ignore-auto-dns yes
sudo nmcli con down eth0 && sudo nmcli con up eth0

# Bypass DNS temporarily for testing
echo "192.168.1.100 internal.example.com" | sudo tee -a /etc/hosts

# Flush all network caches and restart services
sudo systemd-resolve --flush-caches
sudo systemctl restart systemd-resolved
sudo systemctl restart NetworkManager
