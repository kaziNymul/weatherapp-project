FROM node:latest

RUN mkdir -p /usr/src/app/backend
WORKDIR /usr/src/app/backend

ADD . /usr/src/app/backend
RUN npm install

EXPOSE 9000

CMD [ "npm", "run", "dev" ]
