FROM debian:latest
COPY ngx_cache_purge-2.3.tar.gz /root
COPY zlib-1.2.12.tar.gz /root
COPY pcre-8.45.tar.gz /root
WORKDIR /root
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install ssh wget git unzip screen gcc libpcre3-dev libssl-dev libpcre3 zlib1g-dev make build-essential -y
RUN cd /root && \
    tar -zxvf ngx_cache_purge-2.3.tar.gz && \
    tar -zxvf zlib-1.2.12.tar.gz && \
    tar -zxvf pcre-8.45.tar.gz && \
    wget https://nginx.org/download/nginx-1.22.0.tar.gz && \
    tar -zxvf nginx-1.22.0.tar.gz && \
    cd nginx-1.22.0 && \
    ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_realip_module --with-http_ssl_module --with-http_gzip_static_module --with-http_perl_module --with-http_sub_module --with-pcre=../pcre-8.45 --with-zlib=../zlib-1.2.12 --add-module=../ngx_cache_purge-2.3 && \
    make && \
    make install && \
    useradd www && \
    chown -Rf www:www /usr/local/nginx/ && \
    mkdir /var/log/nginx  && \
    mkdir -p /ngcache  && \
    chown -R www:www /ngcache && \
    echo 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf  && \
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf  && \
    sysctl -p  && \
    echo -e "BBR启动成功！"'
ADD nginx.conf /usr/local/nginx/conf
EXPOSE 80
ENTRYPOINT [ "/usr/local/nginx/sbin/nginx", "-g", "daemon off;" ]
