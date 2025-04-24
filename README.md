<h1 align="center"><img src="https://github.com/octree-gva/meta/blob/main/decidim/static/header.png?raw=true" alt="Decidim - Octree Participatory democracy on a robust and open source solution" /></h1>
<h4 align="center">
    <a href="https://www.octree.ch">Octree</a> |
    <a href="https://octree.ch/en/contact-us/">Contact Us</a> |
    <a href="https://blog.octree.ch">Our Blog (FR)</a><br/><br/>
    <a href="https://decidim.org">Decidim</a> |
    <a href="https://docs.decidim.org/en/">Decidim Docs</a> |
    <a href="https://meta.decidim.org">Participatory Governance (meta decidim)</a><br/><br/>
    <a href="https://matrix.to/#/+decidim:matrix.org">Decidim Community (Matrix+Element.io)</a>
</h4>
<p align="center">
<a href="https://mkutano.community"><img src="https://github.com/octree-gva/decidim-module-referral/blob/main/mkutano-logo.png?raw=true" alt="MKUTANO is a participatory platform where black canadians can effectively & democratically organize at scale" /></a> 
</p>

# Decidim::OnlyForms

Component to create forms in a participatory space, sponsored by the [Mkutano Community](mkutano.community).

## Usage

OnlyForms will be available as a Component for a Participatory Space.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-only_forms"
```

And then execute:

```bash
bundle
bundle exec rails decidim_only_forms:install:migrations
bundle exec rails db:migrate
```

## Testing
```
    bundle exec rake test_app
```

## Local development
For decidim version 0.27, use Gemfile.0.27. For version 0.26, use Gemfile.0.26
```
cp Gemfile.0.27 Gemfile
``` 

First, you need to run an empty database with a decidim dev container which runs nothing.
```
docker-compose down -v --remove-orphans
docker-compose up -d
```

Once created, you access the decidim container
```
# Get the id of the decidim dev container
docker ps --format {{.ID}} --filter=label=org.label-schema.name=decidim
# 841ae977c7da
docker exec -it 841ae977c7da bash
```
You are now in bash, run manually. This will check your environment and do migrations if needed
```
docker-entrypoint
```

You are now ready to use your container in the way you want for development:

* Run a rails seed: `bundle exec rails db:seed`
* Have live-reload on your assets: `bin/webpack-dev-server`
* Execute tasks, like `bundle exec rails g migration AddSomeColumn`
* Run the rails server: `bundle exec rails s -b 0.0.0.0`
* etc.

To stop everything, uses:
- `docker-compose down` to stop the containers
- `docker-compose down -v` to stop the containers and remove all previously saved data.

### Debugging
To debug something on the container:
1. Ensure `decidim-app` is running
```bash
docker ps --all
# CONTAINER ID   IMAGE                                   COMMAND                  CREATED       STATUS                 PORTS                                                                                  NAMES
# 915e9fc474f2   decidim-module-only_forms-decidim-app   "sleep infinity"         7 hours ago   Up 7 hours             0.0.0.0:3000->3000/tcp, :::3000->3000/tcp, 0.0.0.0:3035->3035/tcp, :::3035->3035/tcp   decidim-only-form-app
# 22304921b7eb   postgres:14-alpine                      "docker-entrypoint.s…"   7 hours ago   Up 7 hours (healthy)   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp                                              decidim-module-only_forms-pg-1

```

2. In another terminal, run `docker exec -it 915e9fc474f2 bash`
3. Run
    - `tail -f $ROOT/log/development.log` to **access logs**
    - `bundle exec rails restart` to **restart rails server AND keeps webpacker running**
    - `cd $ROOT` to access the `development_app`
    - `cd $ROOT/../decidim_module_only_forms` to access the module directory
## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the [GNU AFFERO GENERAL PUBLIC LICENSE](LICENSE-AGPLv3.txt)

<br /><br />
<p align="center">
    <img src="https://raw.githubusercontent.com/octree-gva/meta/main/decidim/static/octree_and_decidim.png" height="90" alt="Decidim Installation by Octree" />
</p>
