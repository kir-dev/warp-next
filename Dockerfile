FROM ruby:3.0.2

RUN mkdir /warp-next
WORKDIR /warp-next

RUN gem install bundler -v 2.2.26
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install --retry 3

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y nodejs yarn

COPY . .

RUN yarn install --check-files
RUN rails assets:precompile
