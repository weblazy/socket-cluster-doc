FROM node:10

WORKDIR /app
COPY . .
RUN npm install gitbook-cli -g
EXPOSE 4000
CMD [ "gitbook", "serve" ]

  