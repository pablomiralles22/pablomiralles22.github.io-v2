FROM ruby:latest
ENV DEBIAN_FRONTEND noninteractive

LABEL authors="Amir Pourmand,George Araújo" \
      description="Docker image for al-folio academic template" \
      maintainer="Amir Pourmand"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        imagemagick \
        inotify-tools \
        locales \
        nodejs \
        procps \
        python3-pip \
        zlib1g-dev && \
    pip --no-cache-dir install --upgrade --break-system-packages nbconvert

# clean up
RUN apt-get clean && \
apt-get autoremove && \
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*  /tmp/*

# set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# Fix imagemagick policy
RUN sed -i.bak '/<policy domain="coder" rights="none" pattern="PDF" \/>/s|^|<!-- |; s|$| -->|' /etc/ImageMagick-6/policy.xml


ENV EXECJS_RUNTIME=Node \
    JEKYLL_ENV=production \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN mkdir /srv/jekyll

ADD Gemfile.lock /srv/jekyll
ADD Gemfile /srv/jekyll

WORKDIR /srv/jekyll

# install jekyll and dependencies
RUN gem install --no-document jekyll bundler
RUN bundle install --no-cache

# && rm -rf /var/lib/gems/3.1.0/cache
EXPOSE 8080

COPY bin/entry_point.sh /tmp/entry_point.sh

CMD ["/tmp/entry_point.sh"]
