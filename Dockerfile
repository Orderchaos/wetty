FROM node:boron-alpine as builder
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN apk add -U build-base python && \
    yarn && \
    yarn build

RUN yarn && yarn install --production --ignore-scripts --prefer-offline
FROM node:boron-alpine
LABEL maintainer="sean@linuxacademy.com"
WORKDIR /app
ENV NODE_ENV=production
RUN apk add -U openssh openssl && \
    adduser -D -h /home/term -s /bin/sh term && \
    echo "wettyuser:123456wettyuser" | chpasswd
EXPOSE 31297
COPY --from=builder /usr/src/app /app
RUN echo -e "Host *\n    StrictHostKeyChecking no\n    LogLevel QUIET" >> /etc/ssh/ssh_config
RUN openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/certs/key.pem -out /etc/ssl/certs/cert.pem -days 30000 \
        -nodes -subj "/C=US/ST=TX/L=Southlake/O=na/CN=lawebsh_internal_only_cert"
CMD yarn start
