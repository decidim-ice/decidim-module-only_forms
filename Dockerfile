FROM hfroger/decidim:0.27-dev

ENV RAILS_ENV=development \
    NODE_ENV=development \
    ROOT=/home/decidim/app
    
COPY . /home/decidim/decidim_module_only_forms

# Add app configuration for working in dev.
COPY ./.docker/config /home/decidim/app/config
COPY ./.docker/ecosystem.config.js /home/decidim/app/ecosystem.config.js
COPY ./.docker/ecosystem.config.js /usr/local/share/docker-entrypoint.d/ecosystem.config.js

RUN cd $ROOT \
  # Add the gem with a local path (bounded as volume)
  && echo "gem \"decidim-only_forms\", path: \"../decidim_module_only_forms\"" >> Gemfile \
  && bundle config set without "" \
  && bundle config set path "vendor" \
  && bundle install \
  && npm i \
  && npm i -g pm2

EXPOSE 3000
EXPOSE 3035
ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["sleep", "infinity"]
