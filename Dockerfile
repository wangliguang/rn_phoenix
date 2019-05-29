FROM node:10.15.2
COPY . /app
WORKDIR /app
RUN npm install
EXPOSE 3000