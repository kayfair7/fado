FROM ubuntu:latest
ENV container docker
COPY . /var/www/html
EXPOSE 2080
ENTRYPOINT ["/var/www/html/docker/start.sh"]
RUN ["/var/www/html/docker/deploy-forky.sh"]
HEALTHCHECK  --interval=5m --timeout=3s \
CMD curl -f http://localhost:2080 || exit 1
