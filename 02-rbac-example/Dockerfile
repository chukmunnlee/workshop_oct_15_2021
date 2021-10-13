FROM node:16

ARG APP_DIR=/app

WORKDIR ${APP_DIR}

ADD . .

RUN npm ci

ENV PORT=3000 SECRET="changeit" OPA_ADDRESS="localhost:8181"

EXPOSE ${PORT}

ENTRYPOINT [ "node", "main" ]
