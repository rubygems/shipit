FROM ruby:3.0.3-alpine3.15

RUN apk update && apk --update add \
  ruby-io-console \
  # libstdc++ \
  tzdata \
  mysql-client \
  shared-mime-info \
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
  cd /app ; bundle install --without development test && \
  gem install activesupport --no-document -v 6.1.5 && \
  gem install krane -f --no-document --version=2.4.6

COPY . /app

COPY root/ root/
RUN chmod -R 700 root/.ssh

ADD https://dl.k8s.io/release/v1.23.5/bin/linux/amd64/kubectl /usr/bin/kubectl
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
