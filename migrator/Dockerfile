FROM ruby:2.6.5

WORKDIR /usr/src/app

RUN apt-get update -y && \
  apt-get install -y postgresql-client

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENTRYPOINT ["./bin/migrator"]
