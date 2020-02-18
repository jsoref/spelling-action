FROM debian:9.5-slim

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update < /dev/null > /dev/null && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qq curl git jq < /dev/null > /dev/null

WORKDIR /app
COPY docker-setup exclude.pl reporter.json reporter.pl ./
COPY w spelling-unknown-word-splitter.pl

RUN ./docker-setup &&\
    rm docker-setup

LABEL "com.github.actions.name"="Spell Checker"
LABEL "com.github.actions.description"="Check repository for spelling errors"
LABEL "com.github.actions.icon"="edit-3"
LABEL "com.github.actions.color"="red"

LABEL "repository"="http://github.com/jsoref/spelling-action"
LABEL "homepage"="http://github.com/jsoref/spelling-action/tree/master/README.md"
LABEL "maintainer"="Josh Soref <jsoref@noreply.users.github.com>"

COPY test-spelling-unknown-words test-spelling-unknown-words.sh

ENTRYPOINT ["/app/test-spelling-unknown-words.sh"]
