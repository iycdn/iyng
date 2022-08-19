FROM debian:latest
COPY ngx_cache_purge-2.3.tar.gz /root
COPY zlib-1.2.12.tar.gz /root
COPY pcre-8.45.tar.gz /root
WORKDIR /root
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install wget git unzip gcc libpcre3-dev libssl-dev libpcre3 zlib1g-dev make build-essential -y
RUN cd /root && \
    tar -zxvf ngx_cache_purge-2.3.tar.gz && \
    tar -zxvf zlib-1.2.12.tar.gz && \
    tar -zxvf pcre-8.45.tar.gz && \
    git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git && \
    wget https://nginx.org/download/nginx-1.22.0.tar.gz && \
    tar -zxvf nginx-1.22.0.tar.gz && \
    cd nginx-1.22.0 && \
    ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_realip_module --with-http_ssl_module --with-http_gzip_static_module --with-pcre=../pcre-8.45 --with-zlib=../zlib-1.2.12 --add-module=../ngx_cache_purge-2.3 --add-module=../ngx_http_substitutions_filter_module && \
    make -j4 && \
    make install && \
    useradd www && \
    chown -Rf www:www /usr/local/nginx/ && \
    mkdir /var/log/nginx  && \
    mkdir -p /ngcache  && \
    chown -R www:www /ngcache
RUN echo "* soft nproc 11000" >> /etc/security/limits.conf && \
    echo "* hard nproc 11000" >> /etc/security/limits.conf && \
    echo "* soft nofile 655350" >> /etc/security/limits.conf && \
    echo "* hard nofile 655350" >> /etc/security/limits.conf && \
    echo -e "系统优化成功！"
ADD nginx.conf /usr/local/nginx/conf
EXPOSE 80
ENTRYPOINT [ "/usr/local/nginx/sbin/nginx", "-g", "daemon off;" ]
