FROM ruby:4.0.9-alpine AS Builder

ARG RAILS_ROOT=/app
ARG BUILD_PACKAGES="build-base curl-dev git"
ARG DEV_PACKAGES="sqlite-dev yaml-dev zlib-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"
ARG SECRET_KEY_BASE

ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
WORKDIR $RAILS_ROOT

# Install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES
# Install rubygem
COPY Gemfile* $RAILS_ROOT/
RUN bundle config set --global frozen false \
    && bundle config set --local without "development test assets" \
    && bundle config set --local path vendor/bundle \
    && bundle install -j4 --retry 3

COPY . .

RUN bin/rails assets:clobber && bundle exec rails assets:precompile

# Remove folders not needed in resulting image
RUN rm -rf node_modules tmp/cache vendor/assets spec

# Build step complete.


FROM ruby:4.0.9-alpine
ARG RAILS_ROOT=/app
ARG PACKAGES="tzdata sqlite sqlite-dev nodejs bash"
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
WORKDIR $RAILS_ROOT

# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES

# Add user
RUN addgroup -g 1000 -S app \
 && adduser -u 1000 -S app -G app
USER app

COPY --from=Builder --chown=app:app $RAILS_ROOT $RAILS_ROOT

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]