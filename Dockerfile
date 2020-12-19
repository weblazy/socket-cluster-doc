FROM node:10

WORKDIR /app
COPY . .
RUN npm config set registry http://registry.npm.taobao.org
RUN npm install gitbook-cli -g
EXPOSE 4000
CMD [ "gitbook", "serve" ]

  