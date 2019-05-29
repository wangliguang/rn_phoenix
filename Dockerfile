FROM node:10.15.2
COPY . /app
WORKDIR /app
USER root
RUN npm install
EXPOSE 3000