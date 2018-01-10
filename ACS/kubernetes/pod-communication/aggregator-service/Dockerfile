FROM centos:7

RUN yum -y update
RUN yum -y install epel-release
RUN yum -y install nodejs

RUN mkdir /app
WORKDIR /app

COPY code/package.json /app/package.json
RUN npm install

COPY code/app.js /app/app.js
COPY code/routes/ /app/routes

EXPOSE 4000
CMD [ "npm", "start" ]

