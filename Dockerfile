# FROM ruby:2.3-alpine
FROM ruby@sha256:a668c39a8a91944269c31bf6aca3b94e0f1e9bed6d7a156aa54b2bfb6d56e98b

RUN apk update && apk --update add \
  ruby-io-console \
  # libstdc++ \
  tzdata \
  mysql-client \
  nodejs

COPY Gemfile /app/
COPY Gemfile.lock /app/

RUN apk --update add \
  --virtual build-dependencies \
  build-base \
  ruby-dev \
  # openssl-dev \
  mysql-dev \
  libc-dev \
  linux-headers \
  git \
  openssh-client \
  bash \
  && gem install bundler && \
  cd /app ; bundle install --without development test deploy

COPY . /app

COPY root/ root/
RUN chmod -R 700 root/.ssh

ADD https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/amd64/kubectl /usr/bin/kubectl
RUN chmod +x /usr/bin/kubectl

COPY kubeconfig.yml /root/.kube/config
COPY kubeconfig.yml /home/deploy/.kube/config

WORKDIR /app

RUN RAILS_ENV=production SECRET_KEY_BASE=1234 REDIS_URL=redis://localhost bin/rails assets:precompile

EXPOSE 3000

ENTRYPOINT ["bin/entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
