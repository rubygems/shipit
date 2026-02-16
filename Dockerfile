FROM ruby:4.0.1-alpine3.23
ARG KRANE_VERSION=3.4.1
ARG KUBECTL_VERSION=1.34.4

ENV BUNDLE_WITHOUT="development:test"

RUN apk update && apk --update add \
  # libstdc++ \
  ca-certificates \
  tzdata \
  mysql-client \
  shared-mime-info \
  nodejs \
  yaml-dev

COPY Gemfile /app/
COPY Gemfile.lock /app/
COPY .ruby-version /app/

RUN apk --update add \
  --virtual build-dependencies \
  build-base \
  # openssl-dev \
  mysql-dev \
  libc-dev \
  linux-headers \
  git \
  bash && \
  cd /app ; bundle install && \
  gem install krane -f --no-document --version=$KRANE_VERSION

COPY . /app

ADD https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl /usr/bin/kubectl
RUN chmod +x /usr/bin/kubectl

COPY kubeconfig.yml /root/.kube/config
COPY kubeconfig.yml /home/deploy/.kube/config

WORKDIR /app

# We need to use dummy DATABASE_URL to be able to precompile assets
# since it fails with no config/database.yml by default, but the
# DB connection is acutally no needed.
RUN RAILS_ENV=production DATABASE_URL=mysql2://dummy/dummy bin/rails assets:precompile

EXPOSE 3000

ENTRYPOINT ["bin/entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
