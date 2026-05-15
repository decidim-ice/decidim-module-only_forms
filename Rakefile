# frozen_string_literal: true

require "decidim/dev/common_rake"
require "rake"
require "rake/file_utils"

def install_module(path)
  Dir.chdir(path) do
    # system("bundle exec rake decidim_vocacity_gem_tasks:install:migrations")
  end
end

def seed_db(path)
  Dir.chdir(path) do
    system("bundle exec rake db:seed")
  end
end

desc "Prepare for testing"
task :prepare_tests do
  # Doorkeeper is pinned in the Gemfile; Decidim ships doorkeeper migrations in the dummy app.
  # Do not run `bundle add doorkeeper` or vanilla doorkeeper generators here — they duplicate
  # decidim's setup and fail when run from the engine root (no config/routes.rb).
  # Remove previous existing db, and recreate one.
  disable_docker_compose = ENV.fetch("DISABLED_DOCKER_COMPOSE", "false") == "true"
  unless disable_docker_compose
    sh "docker compose down -v || docker-compose down -v"
    sh "docker compose up -d --remove-orphans || docker-compose up -d --remove-orphans"
  end
  ENV["RAILS_ENV"] = "test"
  database_yml = {
    "test" => {
      "adapter" => "postgresql",
      "encoding" => "unicode",
      "host" => ENV.fetch("DATABASE_HOST", "localhost"),
      "port" => ENV.fetch("DATABASE_PORT", "5432").to_i,
      "username" => ENV.fetch("DATABASE_USERNAME", "decidim"),
      "password" => ENV.fetch("DATABASE_PASSWORD", "TEST-baeGhi4Ohtahcee5eejoaxaiwaezaiGo"),
      "database" => "decidim_test",
      "sslmode" => ENV.fetch("DATABASE_SSLMODE", "disable")
    }
  }
  config_file = File.expand_path("spec/decidim_dummy_app/config/database.yml", __dir__)
  File.open(config_file, "w") { |f| YAML.dump(database_yml, f) }
  Dir.chdir("spec/decidim_dummy_app") do
    Bundler.with_original_env do
      sh "bundle exec rails db:migrate"
    end
  end
end

desc "Generates a dummy app for testing"
task :test_app do
  Bundler.with_original_env do
    generate_decidim_app(
      "spec/decidim_dummy_app",
      "--app_name",
      "decidim_test",
      "--path",
      "../..",
      "--skip_spring",
      "--demo",
      "--force_ssl",
      "false",
      "--locales",
      "en,fr,es"
    )
  end
  install_module("spec/decidim_dummy_app")
  Rake::Task["prepare_tests"].invoke
end

desc "Generates a development app"
task :development_app do
  Bundler.with_original_env do
    generate_decidim_app(
      "development_app",
      "--app_name",
      "#{base_app_name}_development_app",
      "--path",
      "..",
      "--recreate_db",
      "--demo"
    )
  end

  install_module("development_app")
  seed_db("development_app")
end
