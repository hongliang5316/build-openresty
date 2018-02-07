#!/bin/bash

clean()
{
    rm -rf $MAIN_DIR/*
}


build_openssl()
{
    sh -c "wget https://www.openssl.org/source/openssl-$OPENSSL_VER.tar.gz -P $MAIN_DIR;
           cd $MAIN_DIR;
           tar -zxf openssl-$OPENSSL_VER.tar.gz;
           cd openssl-$OPENSSL_VER;
           wget 'https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-1.0.2h-sess_set_get_cb_yield.patch';
           patch -p1 < openssl-1.0.2h-sess_set_get_cb_yield.patch;
           ./config no-threads shared zlib -g \\
             --openssldir=$OPENSSL_PREFIX \\
             --libdir=lib \\
             -I$ZLIB_PREFIX/include \\
             -L$ZLIB_PREFIX/lib \\
             -Wl,-rpath,$ZLIB_PREFIX/lib:$OPENSSL_PREFIX/lib;
             make && make install_sw
          "
}


build_pcre()
{
    sh -c "wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PCRE_VER.tar.bz2 -P $MAIN_DIR;
           cd $MAIN_DIR;
           tar -xf pcre-$PCRE_VER.tar.bz2;
           cd pcre-$PCRE_VER;
           ./configure --prefix=$PCRE_PREFIX \\
             --disable-cpp \\
             --enable-jit \\
             --enable-utf \\
             --enable-unicode-properties;
           V=1 make && make install
          "
}


build_zlib()
{
    sh -c "wget http://www.zlib.net/zlib-$ZLIB_VER.tar.xz -P $MAIN_DIR;
           cd $MAIN_DIR;
           tar -xf zlib-$ZLIB_VER.tar.xz;
           cd zlib-$ZLIB_VER;
           ./configure --prefix=$ZLIB_PREFIX;
           CFLAGS='-O3 -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g' \\
           SFLAGS='-O3 -fPIC -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g';
           make && make install
          "
}


build_openresty()
{
    sh -c "wget https://openresty.org/download/openresty-$OPENRESTY_VER.tar.gz -P $MAIN_DIR;
           cd $MAIN_DIR;
           tar zxf openresty-$OPENRESTY_VER.tar.gz;
           cd openresty-$OPENRESTY_VER;
           ./configure \\
                 --prefix=$OPENRESTY_PREFIX \\
                 --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I$ZLIB_PREFIX/include -I$PCRE_PREFIX/include -I$OPENSSL_PREFIX/include' \\
                 --with-ld-opt='-L$ZLIB_PREFIX/lib -L$PCRE_PREFIX/lib -L$OPENSSL_PREFIX/lib -Wl,-rpath,$ZLIB_PREFIX/lib:$PCRE_PREFIX/lib:$OPENSSL_PREFIX/lib' \\
                 --with-pcre-jit \\
                 --without-http_rds_json_module \\
                 --without-http_rds_csv_module \\
                 --without-lua_rds_parser \\
                 --with-stream \\
                 --with-stream_ssl_module \\
                 --with-http_v2_module \\
                 --without-mail_pop3_module \\
                 --without-mail_imap_module \\
                 --without-mail_smtp_module \\
                 --with-http_stub_status_module \\
                 --with-http_realip_module \\
                 --with-http_addition_module \\
                 --with-http_auth_request_module \\
                 --with-http_secure_link_module \\
                 --with-http_random_index_module \\
                 --with-http_gzip_static_module \\
                 --with-http_sub_module \\
                 --with-http_dav_module \\
                 --with-http_flv_module \\
                 --with-http_mp4_module \\
                 --with-http_gunzip_module \\
                 --with-threads \\
                 --with-file-aio \\
                 --with-luajit-xcflags='-DLUAJIT_ENABLE_GC64 -DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT' \\
                 --with-dtrace-probes \\
                 --with-debug ;
                 make && make install
           "
}


pre_install()
{
    sh -c "mkdir -p $MAIN_DIR"
    sh -c "mkdir -p $OPENRESTY_PREFIX"
}


MAIN_DIR=/opt/tmp

ZLIB_VER=1.2.11
PCRE_VER=8.40
OPENSSL_VER=1.0.2k
OPENRESTY_VER=1.13.6.1

ZLIB_PREFIX=/usr/local/openresty/zlib
PCRE_PREFIX=/usr/local/openresty/pcre
OPENSSL_PREFIX=/usr/local/openresty/openssl
OPENRESTY_PREFIX=/usr/local/openresty

clean

pre_install

build_zlib

build_pcre

build_openssl

build_openresty

