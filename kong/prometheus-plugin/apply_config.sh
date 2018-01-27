mkdir /usr/local/share/kong-extra-plugins/kong/plugins/kong-plugin-prometheus;
#cp /tmp/prometheus-plugin-setup/*.rockspec /tmp/kong-plugin-prometheus/;
cp /tmp/prometheus-plugin-setup/*.lua /usr/local/share/kong-extra-plugins/kong/plugins/kong-plugin-prometheus/;
cd /usr/local/share/kong-extra-plugins/kong/plugins/kong-plugin-prometheus/;
echo pwd;
ls -al;
#cd /tmp/kong-plugin-prometheus/
#luarocks make;
