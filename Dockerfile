FROM debian:latest
COPY ngx_cache_purge-2.3.tar.gz /root
COPY zlib-1.2.12.tar.gz /root
COPY pcre-8.45.tar.gz /root
WORKDIR /root
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install ssh wget git unzip screen gcc libpcre3-dev libssl-dev libpcre3 libperl-dev zlib1g-dev make build-essential -y
RUN cd /root && \
         tar -zxvf ngx_cache_purge-2.3.tar.gz && \
         tar -zxvf zlib-1.2.12.tar.gz && \
         tar -zxvf pcre-8.45.tar.gz && \
         git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git && \
         wget https://nginx.org/download/nginx-1.22.0.tar.gz && \
         tar -zxvf nginx-1.22.0.tar.gz && \
         cd nginx-1.22.0 && \
         ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_realip_module --with-http_ssl_module --with-http_gzip_static_module --with-http_perl_module --with-http_sub_module --with-pcre=../pcre-8.45 --with-zlib=../zlib-1.2.12 --add-module=../ngx_cache_purge-2.3 --add-module=../ngx_http_substitutions_filter_module && \
         make && \
         make install && \
         useradd www && \
         chown -Rf www:www /usr/local/nginx/ && \
         mkdir /var/log/nginx  && \
         mkdir -p /ngcache  && \
         chown -R www:www /ngcache
RUN echo "* soft nproc 11000" >> /etc/security/limits.conf  && \
         echo "* hard nproc 11000" >> /etc/security/limits.conf  && \
         echo "* soft nofile 655350" >> /etc/security/limits.conf  && \
         echo "* hard nofile 655350" >> /etc/security/limits.conf  && \
         echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf  && \
         echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.conf  && \
         echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf  && \
         echo "kernel.sysrq = 0" >> /etc/sysctl.conf  && \
         echo "kernel.core_uses_pid = 1" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_syncookies = 1 >> /etc/sysctl.conf  && \
         echo "kernel.msgmnb = 65536" >> /etc/sysctl.conf  && \
         echo "kernel.msgmax = 65536" >> /etc/sysctl.conf  && \
         echo "kernel.shmmax = 68719476736" >> /etc/sysctl.conf  && \
         echo "kernel.shmall = 4294967296" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_max_tw_buckets = 6000" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_sack = 1" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_rmem = 4096 131072 1048576" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_wmem = 4096 131072 1048576" >> /etc/sysctl.conf  && \
         echo "net.core.wmem_default = 8388608" >> /etc/sysctl.conf  && \
         echo "net.core.wmem_max = 16777216" >> /etc/sysctl.conf  && \
         echo "net.core.rmem_default = 8388608" >> /etc/sysctl.conf  && \
         echo "net.core.rmem_max = 16777216" >> /etc/sysctl.conf  && \
         echo "net.core.netdev_max_backlog = 262144" >> /etc/sysctl.conf  && \
         echo "net.core.somaxconn = 262144" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_max_orphans = 3276800" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_max_syn_backlog = 262144" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_synack_retries = 1" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_syn_retries = 1" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_mem = 94500000 915000000 927000000" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_fin_timeout = 15" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_keepalive_time = 30" >> /etc/sysctl.conf  && \
         echo "net.ipv4.ip_local_port_range = 2048 65000" >> /etc/sysctl.conf  && \
         echo "fs.file-max = 102400" >> /etc/sysctl.conf  && \
         echo "net.core.default_qdisc=yh" >> /etc/sysctl.conf  && \
         echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf  && \
         sysctl -p  && \
         echo -e "系统优化成功！"'
ADD nginx.conf /usr/local/nginx/conf
EXPOSE 80
ENTRYPOINT [ "/usr/local/nginx/sbin/nginx", "-g", "daemon off;" ]
