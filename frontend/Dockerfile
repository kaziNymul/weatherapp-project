FROM node:latest

RUN mkdir -p /usr/src/app/frontend
WORKDIR /usr/src/app/frontend

ADD . /usr/src/app/frontend
RUN npm install
ENV NODE_OPTIONS=--openssl-legacy-provider
EXPOSE 8000

CMD [ "npm", "run", "start" ]
