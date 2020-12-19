FROM node:12

WORKDIR /app
COPY . .
RUN npm install gitbook-cli -g
EXPOSE 3333
CMD [ "npm", "run" ,"start"]

  