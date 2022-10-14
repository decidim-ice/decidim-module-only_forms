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

Component for create forms in a participatory space, sponsored by the [Mkutano Community](mkutano.community).

## Usage

OnlyForms will be available as a Component for a Participatory
Space.

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

Run a postgres database
```
docker-compose up -d
```

Run if you haven't already:
```bash
bundle
```

And then
```bash
rake decidim:generate_external_development_app
```

Setup and run the decidim development server
```
source ./dev_app_vars
cd development_app
rails db:migrate
rails db:seed
rails s
```
Access your local environment [localhost:3000](http://localhost:3000)

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the [GNU AFFERO GENERAL PUBLIC LICENSE](LICENSE-AGPLv3.txt)

<br /><br />
<p align="center">
    <img src="https://raw.githubusercontent.com/octree-gva/meta/main/decidim/static/octree_and_decidim.png" height="90" alt="Decidim Installation by Octree" />
</p>
