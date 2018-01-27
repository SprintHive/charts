mkdir -p /usr/local/share/kong-extra-plugins/kong/plugins/prometheus;
cp /tmp/prometheus-plugin-setup/*.lua /usr/local/share/kong-extra-plugins/kong/plugins/prometheus/;
cd /usr/local/share/kong-extra-plugins/kong/plugins/prometheus/;
chmod 755 ./*;
