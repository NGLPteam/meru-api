FROM ghcr.io/maxmind/geoipupdate:v7.0.1 AS maxmind

ENV GEOIPUPDATE_DB_DIR="/usr/share/GeoIP"
ENV GEOIPUPDATE_EDITION_IDS="GeoLite2-ASN GeoLite2-City GeoLite2-Country"
ENV GEOIPUPDATE_PRESERVE_FILE_TIMES=1

RUN --mount=type=secret,id=maxmind_account_id \
  --mount=type=secret,id=maxmind_license_key \
  GEOIPUPDATE_ACCOUNT_ID_FILE=/run/secrets/maxmind_account_id \
  GEOIPUPDATE_LICENSE_KEY_FILE=/run/secrets/maxmind_license_key \
  /usr/bin/geoipupdate

FROM ruby:3.4.4-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    gnupg gnupg2 \
    libglib2.0-0 libglib2.0-dev \
    libjemalloc2 \
    libpoppler-glib8 \
    librsvg2-bin \
    libsndfile1-dev \
    libvips \
    libvips-dev \
    mediainfo \
    postgresql-common

RUN /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y

RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends postgresql-client-15

RUN gem update --system && gem install bundler:2.7.2

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle \
    RACK_ENV=development \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    PORT=8080
ENV PATH="${BUNDLE_BIN}:${PATH}"
ENV LD_PRELOAD=libjemalloc.so.2
ENV GEOIPUPDATE_ACCOUNT_ID_FILE=/run/secrets/maxmind_account_id
ENV GEOIPUPDATE_LICENSE_KEY_FILE=/run/secrets/maxmind_license_key
ENV GEOIPUPDATE_DB_DIR="/usr/share/GeoIP"
ENV GEOIPUPDATE_EDITION_IDS="GeoLite2-ASN GeoLite2-City GeoLite2-Country"
ENV GEOIPUPDATE_PRESERVE_FILE_TIMES=1
ENV GEOIPUPDATE_VERBOSE=1
ENV REMEMBERED_WB_UNPROTECTED_OBJECTS_LIMIT_RATIO=0.01

WORKDIR /srv/app
COPY Gemfile /srv/app/Gemfile
COPY Gemfile.lock /srv/app/Gemfile.lock

RUN bundle install -j 2

COPY . /srv/app

RUN bundle exec bootsnap precompile --gemfile app/ lib/ config/

COPY docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

COPY --from=maxmind /usr/bin/geoipupdate /usr/local/bin/geoipupdate
COPY --from=maxmind /usr/share/GeoIP /usr/share/GeoIP

EXPOSE 8080

CMD ["bin/puma", "-C", "config/puma.rb"]
