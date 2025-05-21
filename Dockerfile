FROM nginx:alpine

RUN apk add --no-cache ffmpeg

COPY nginx.conf /usr/local/nginx/conf/nginx.conf

CMD ["nginx", "-g", "daemon off;"]
