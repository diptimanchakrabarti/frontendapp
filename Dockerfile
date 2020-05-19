#build app
FROM node:12.1-alpine as build
WORKDIR /usr/src/app

COPY package*.json ./


RUN npm install

COPY . .
ARG REACT_APP_BASE_API_URL=https://middleware001-demo01-cc-uc-other-antmeda.container-crush-02-4044f3a4e314f4bcb433696c70d13be9-0000.eu-de.containers.appdomain.cloud/psm_api
ENV REACT_APP_BASE_API_URL=$REACT_APP_BASE_API_URL
RUN REACT_APP_BASE_API_URL=https://middleware001-demo01-cc-uc-other-antmeda.container-crush-02-4044f3a4e314f4bcb433696c70d13be9-0000.eu-de.containers.appdomain.cloud/psm_api npm run build
#RUN REACT_APP_BASE_API_URL=$REACT_APP_BASE_API_URL npm run build
RUN chgrp -R 0 /usr/src/app/ && \
	chmod -R g=u /usr/src/app/


# prod box
FROM nginx:1.13.12-alpine

RUN rm -rf /etc/nginx/nginx.conf.default && rm -rf /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./nginx.conf /etc/nginx/conf.d/nginx.conf

## Remove default nginx index page
RUN rm -rf /usr/share/nginx/html/*
#COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /usr/src/app/build /usr/share/nginx/html

RUN chgrp -R 0 /var/cache/ /var/log/ /var/run/ && \
    chmod -R g=u /var/cache/ /var/log/ /var/run/

EXPOSE 8080

USER 1001
ENTRYPOINT ["nginx", "-g", "daemon off;"]