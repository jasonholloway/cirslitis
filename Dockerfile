FROM alpine:3.10

# bits and bobs
RUN apk add --no-cache wget git

# docker cli (host dockerd will be used via /var/run/docker.sock mount)
RUN wget https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz \
 && tar xvfz docker-18.06.3-ce.tgz \
 && mv docker/docker /usr/bin/ \
 && rm -rf docker*

# linuxkit
RUN wget \
		https://github.com/linuxkit/linuxkit/releases/download/v0.7/linuxkit-linux-amd64 \
		-O /usr/bin/linuxkit \
  && chmod +x /usr/bin/linuxkit

# more bits and bobs
RUN apk add --no-cache qemu-img
RUN apk add --no-cache gettext

WORKDIR /build

COPY ./src .
COPY .env .
COPY buildImage.sh .

CMD [ "./buildImage.sh" ]
