# syntax=docker/dockerfile:1.5

ARG RUBY_VERSION
ARG BUNDLE_DEPLOYMENT=1
ARG BUNDLE_PATH=/usr/local/bundle
ARG BUNDLE_WITHOUT=development:test
ARG BUNDLE_JOBS=4
ARG BUNDLE_RETRY=3
ARG UID=1000
ARG GID=1000

FROM ruby:${RUBY_VERSION}-alpine AS base

WORKDIR /app

ENV BUNDLE_DEPLOYMENT="${BUNDLE_DEPLOYMENT}" \
    BUNDLE_PATH="${BUNDLE_PATH}" \
    BUNDLE_WITHOUT="${BUNDLE_WITHOUT}" \
    BUNDLE_JOBS="${BUNDLE_JOBS}" \
    BUNDLE_RETRY="${BUNDLE_RETRY}" \
    MARIADB_TLS_DISABLE_PEER_VERIFICATION=1

RUN apk add --no-cache \
  tzdata \
  netcat-openbsd \
  mysql-client \
  postgresql-libs \
  nodejs \
  npm \
  mariadb-connector-c \
  yaml

FROM base AS build

ENV MAKEFLAGS="-j1"

RUN apk add --no-cache \
  build-base \
  git \
  linux-headers \
  pkgconf \
  postgresql-dev \
  yaml-dev \
  mariadb-connector-c-dev \
  chromium \
  chromium-chromedriver

COPY vendor ./vendor
COPY Gemfile Gemfile.lock ./
RUN --mount=type=cache,target=/usr/local/bundle \
  bundle install && \
  rm -rf /usr/local/bundle/cache /root/.bundle/cache /usr/lib/apk/cache

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
  npm ci

COPY . .

RUN chmod +x /app/ops/containers/app/entrypoint.sh

FROM build AS dev

RUN apk add --no-cache \
  bash \
  bind-tools \
  curl \
  vim

FROM base AS test

ENV BUNDLE_WITHOUT=""

ENV MAKEFLAGS="-j1"

RUN apk add --no-cache \
  build-base \
  git \
  linux-headers \
  pkgconf \
  postgresql-dev \
  yaml-dev \
  mariadb-connector-c-dev \
  chromium \
  chromium-chromedriver

COPY vendor ./vendor
COPY Gemfile Gemfile.lock ./
RUN --mount=type=cache,target=/usr/local/bundle \
  bundle install && \
  rm -rf /usr/local/bundle/cache /root/.bundle/cache /usr/lib/apk/cache

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
  npm ci

COPY . .

CMD ["bundle", "exec", "rake", "spec"]

FROM base AS final

ARG UID=1000
ARG GID=1000

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

RUN addgroup -g "$GID" -S app && adduser -S app -G app -u "$UID" && \
  chown -R app:app /app

USER app

ENTRYPOINT ["/app/ops/containers/app/entrypoint.sh"]
CMD ["bundle", "exec", "ruby", "scripts/ruby/run_flow.rb"]

FROM final AS qa

FROM final AS staging

FROM final AS prod
