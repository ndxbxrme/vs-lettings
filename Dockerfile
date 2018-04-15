FROM node

WORKDIR /
COPY . /
ARG KEY
RUN if test -e env-enc.sh; then openssl aes-256-cbc -d -in env-enc.sh -out env.sh -k $KEY; fi
RUN if test -e key-enc.pem; then openssl aes-256-cbc -d -in key-enc.pem -out key.pem -k $KEY; fi
RUN if test -e cert-enc.pem; then openssl aes-256-cbc -d -in cert-enc.pem -out cert.pem -k $KEY; fi
RUN mkdir /data && mkdir /backup && mkdir /logs && mkdir /uploads
RUN npm install
RUN npm install -g bower grunt-cli
RUN bower install --allow-root
RUN grunt build

EXPOSE 23232
CMD if test -e env.sh; then . /env.sh; fi && node --expose-gc server/app.js