FROM cytopia/ansible:2.8

RUN apk add --update --no-cache openssl libc6-compat gettext ncurses coreutils
RUN wget -qO- https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.17.3/kubeseal-0.17.3-linux-amd64.tar.gz \
    | tar -xzvf - kubeseal -C /usr/bin

WORKDIR /app
COPY day-2-generator.sh /app/
COPY templates /app/templates
RUN chmod +x /app/day-2-generator.sh

ENTRYPOINT ["/app/day-2-generator.sh"]