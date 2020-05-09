FROM ubuntu:bionic AS libraries_builder

# proxy environment variables setup
ARG http_proxy
ARG https_proxy
ENV http_proxy $http_proxy
ENV https_proxy $https_proxy
ENV HTTP_PROXY $http_proxy
ENV HTTPS_PROXY $https_proxy

# install tesseract/leptonica/build dependencies
WORKDIR /
RUN apt-get update

RUN apt-get install -y apt-utils libjpeg-dev libtiff5-dev libpng-dev libwebp-dev libgif-dev libopenjp2-7-dev apt-transport-https wget software-properties-common build-essential git automake cmake libtool pkg-config libleptonica-dev


# git proxy configuration
RUN git config --global http.proxy $http_proxy

# leptonica
RUN mkdir /tess
RUN git clone https://github.com/DanBloomberg/leptonica.git
WORKDIR /leptonica
RUN git checkout 1.78.0
RUN mkdir build
WORKDIR /leptonica/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX:PATH=/tess -DSTATIC=0
RUN make -j8
RUN make install

# tesseract
WORKDIR /
RUN git clone https://github.com/tesseract-ocr/tesseract.git -b 4.1
WORKDIR /tesseract
ENV LIBLEPT_HEADERSDIR /tess/include/
RUN /bin/bash autogen.sh
RUN env
RUN ./configure --prefix=/tess/ --with-extra-libraries=/tess/lib
RUN make -j8
RUN make install

# build solution
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS builder

WORKDIR /sln

COPY ./tesseract_demo.sln ./
COPY ./ .
COPY --from=libraries_builder /tess /tess
RUN cp /tess/lib/libtesseract.so.4.0.1 ./tesseract_demo/x64/libtesseract41.so
RUN cp /tess/lib/libleptonica.so.1.78.0 ./tesseract_demo/x64/libleptonica-1.78.0.so
WORKDIR ./tesseract_demo

RUN apt-get update

RUN dotnet restore

RUN dotnet build -c Release --no-restore

RUN dotnet publish -c Release -o "/sln/dist" --no-restore

# run solution
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
ARG source
WORKDIR /app
COPY --from=builder /sln/dist .
COPY --from=builder /sln/tesseract_demo/tessdata ./tessdata
COPY --from=libraries_builder /tess /tess
RUN cp /tess/lib/libtesseract.so.4.0.1 ./x64/libtesseract41.so
RUN cp /tess/lib/libleptonica.so.1.78.0 ./x64/libleptonica-1.78.0.so
RUN chmod 777 ./x64/*.so
RUN apt-get update
RUN apt-get install -y  libleptonica-dev libtesseract4 libtesseract-dev libc6-dev libpng-dev libtiff5-dev libwebp-dev libopenjp2-7-dev libgif-dev multiarch-support wget
RUN wget http://security.ubuntu.com/ubuntu/pool/main/libj/libjpeg-turbo/libjpeg-turbo8_1.5.2-0ubuntu5.18.04.3_amd64.deb
RUN dpkg -i libjpeg-turbo8_1.5.2-0ubuntu5.18.04.3_amd64.deb
ENV LD_LIBRARY_PATH /app/x64/
ENTRYPOINT ["dotnet", "tesseract_demo.dll"]
