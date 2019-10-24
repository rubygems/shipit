# FROM ruby:2.4-alpine
FROM ruby@sha256:79d055e4cebda14ea4afc33cd2793dc307721a381a0f96a6a5a51d31a0abdce7

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
