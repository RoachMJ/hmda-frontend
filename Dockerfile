FROM node:14.9.0-alpine3.11 as build-stage
WORKDIR /usr/src/app
ARG DOCKER_TAG="latest"

# install build dependencies
COPY package.json yarn.lock .yarnrc ./
# install packages offline
COPY npm-packages-offline-cache ./npm-packages-offline-cache
RUN yarn install

# create react app needs src and public directories
COPY src ./src
COPY public ./public

RUN echo "{ \"version\": \"${DOCKER_TAG}\" }" > ./src/common/constants/release.json

RUN yarn build

FROM nginx:1.19.2-alpine
ENV NGINX_USER=svc_nginx_hmda
RUN apk update; apk upgrade
RUN rm /var/cache/apk/*
ENV ENV="/etc/profile"
RUN echo "printf \" ***************************************************************************************************************************\n\
This is a Consumer Financial Protection Bureau (CFPB) information system. The CFPB is an independent agency\n\
of the United States Government. CFPB information systems are provided for the processing of official information\n\
only. Unauthorized or improper use of this system may result in administrative action, as well as civil and\n\
criminal penalties. Because this is a CFPB information system, you have no reasonable expectation of privacy\n\
regarding any communication or data transiting or stored on this information system. All data contained on CFPB\n\
information systems is owned by CFPB and your use of the CFPB information system serves as your consent to your\n\
usage being monitored, intercepted, recorded, read, copied, captured or otherwise audited in any manner, by\n\
authorized personnel, including but not limited to employees, contractors and/or agents of the United States Government.\n\
***************************************************************************************************************************\n\"" >> /etc/profile
RUN rm -rf /etc/nginx/conf.d
COPY nginx /etc/nginx
COPY --from=build-stage /usr/src/app/build /usr/share/nginx/html
RUN adduser -S $NGINX_USER nginx && \
    addgroup -S $NGINX_USER && \
    addgroup $NGINX_USER $NGINX_USER && \
    touch /run/nginx.pid && \
    chown -R $NGINX_USER:$NGINX_USER /etc/nginx /run/nginx.pid /var/cache/nginx/
EXPOSE 8080
USER svc_nginx_hmda
CMD ["nginx", "-g", "daemon off;"]
