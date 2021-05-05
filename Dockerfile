FROM ghcr.io/graalvm/graalvm-ce:java11-21.1.0 as builder

WORKDIR /app

RUN gu install native-image

# BEGIN PRE-REQUISITES FOR STATIC NATIVE IMAGES FOR GRAAL
# SEE: https://github.com/oracle/graal/blob/master/substratevm/StaticImages.md
ARG RESULT_LIB="/staticlibs"

RUN mkdir ${RESULT_LIB} && \
    curl -L -o musl.tar.gz https://musl.libc.org/releases/musl-1.2.1.tar.gz && \
    mkdir musl && tar -xvzf musl.tar.gz -C musl --strip-components 1 && cd musl && \
    ./configure --prefix=${RESULT_LIB} --enable-shared --enable-pic && \
    make && make install && \
    cp /usr/lib/gcc/x86_64-redhat-linux/8/libstdc++.a ${RESULT_LIB}/lib/ && \
    cd .. && rm -rf musl musl.tar.gz

ENV PATH="$PATH:${RESULT_LIB}/bin"
ENV CC="musl-gcc"
ENV CFLAGS="$CFLAGS -fPIC"

RUN curl -L -o zlib.tar.gz https://zlib.net/zlib-1.2.11.tar.gz && \
   mkdir zlib && tar -xvzf zlib.tar.gz -C zlib --strip-components 1 && cd zlib && \
   ./configure --static --prefix=${RESULT_LIB} && \
    make && make install && \
   cd .. && rm -rf zlib zlib.tar.gz

RUN curl -L -o gperf.tar.gz http://ftp.gnu.org/pub/gnu/gperf/gperf-3.1.tar.gz && \
 mkdir gperf3 && tar -xvzf gperf.tar.gz -C gperf3 --strip-components 1 && cd gperf3 && \
 ./configure --prefix=${RESULT_LIB} --enable-pic && \
 make && make install && \
  cd .. && rm -rf gperf3 gperf.tar.gz

RUN curl -L -o bzip.tar.gz https://www.sourceware.org/pub/bzip2/bzip2-latest.tar.gz && \
 mkdir bzip2 && tar -xvzf bzip.tar.gz -C bzip2 --strip-components 1 && cd bzip2 && \
 make install PREFIX=${RESULT_LIB} CC=${CC} && \
 # Build shared library.
 make clean && \
 make -f Makefile-libbz2_so CC=${CC} && \
 cp -v bzip2-shared ${RESULT_LIB}/bin/bzip2 && \
 cp -av libbz2.so* ${RESULT_LIB}/lib && \
 ln -sv libbz2.so.1.0 ${RESULT_LIB}/lib/libbz2.so && \
 cd .. && rm -rf bzip2 bzip.tar.gz

RUN curl -L -o freetype.tar.gz  https://download.savannah.gnu.org/releases/freetype/freetype-2.10.4.tar.gz && \
   mkdir freetype2 && tar -xvzf freetype.tar.gz -C freetype2 --strip-components 1 && cd freetype2 && \
    ./configure --prefix=${RESULT_LIB} --enable-freetype-config && \
    make && make install && \
   cd .. && rm -rf freetype2 freetype.tar.gz

ENV LD_LIBRARY_PATH="$RESULT_LIB/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="$RESULT_LIB/lib/pkgconfig:$PKG_CONFIG_PATH"
ENV ACLOCAL_PATH="$RESULT_LIB}/share/aclocal:$ACLOCAL_PATH"

#END PRE-REQUISITES FOR STATIC NATIVE IMAGES FOR GRAAL

RUN curl -L -o xz.rpm https://www.rpmfind.net/linux/centos/8-stream/BaseOS/x86_64/os/Packages/xz-5.2.4-3.el8.x86_64.rpm
RUN rpm -iv xz.rpm

RUN curl -L -o upx-3.96-amd64_linux.tar.xz https://github.com/upx/upx/releases/download/v3.96/upx-3.96-amd64_linux.tar.xz
RUN tar -xvf upx-3.96-amd64_linux.tar.xz && \
    rm upx-3.96-amd64_linux.tar.xz

# docker build -t graalvm-base:latest .
