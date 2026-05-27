# frozen_string_literal: true

require "fileutils"
require "yaml"

require "decidim/dev/common_rake"
require "rake"
require "rake/file_utils"

# Stable dummy-app DB name; do not derive from `Dir.pwd` (Docker mounts `/home/module`).
def base_app_name
  "decidim_only_forms"
end

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
  disable_docker_compose = ENV.fetch("DISABLED_DOCKER_COMPOSE", "false") == "true"
  unless disable_docker_compose
    sh "docker compose down -v || docker-compose down -v"
    sh "docker compose up -d --remove-orphans || docker-compose up -d --remove-orphans"
  end

  common_db_config = {
    "adapter" => "postgresql",
    "encoding" => "unicode",
    "host" => ENV.fetch("DATABASE_HOST", "localhost"),
    "port" => ENV.fetch("DATABASE_PORT", "5432").to_i,
    "username" => ENV.fetch("DATABASE_USERNAME", "decidim"),
    "password" => ENV.fetch("DATABASE_PASSWORD", "TEST-baeGhi4Ohtahcee5eejoaxaiwaezaiGo"),
    "database" => "decidim_test",
    "sslmode" => ENV.fetch("DATABASE_SSLMODE", "disable")
  }

  config_file = File.expand_path("spec/decidim_dummy_app/config/database.yml", __dir__)
  FileUtils.mkdir_p(File.dirname(config_file))
  File.open(config_file, "w") { |f| YAML.dump({ "test" => common_db_config, "development" => common_db_config }, f) }

  dummy_root = File.expand_path("spec/decidim_dummy_app", __dir__)
  Dir.chdir(dummy_root) do
    prior_database_url = ENV.delete("DATABASE_URL")
    prior_rails_env = ENV.fetch("RAILS_ENV", nil)
    prior_disable_spring = ENV.fetch("DISABLE_SPRING", nil)
    prior_db_env_check = ENV.fetch("DISABLE_DATABASE_ENVIRONMENT_CHECK", nil)
    begin
      ENV["RAILS_ENV"] = "test"
      ENV["DISABLE_SPRING"] = "1"
      ENV["DISABLE_DATABASE_ENVIRONMENT_CHECK"] = "1"

      sh "bundle exec rake db:drop db:create db:migrate"
    ensure
      if prior_rails_env
        ENV["RAILS_ENV"] = prior_rails_env
      else
        ENV.delete("RAILS_ENV")
      end
      ENV["DATABASE_URL"] = prior_database_url if prior_database_url
      if prior_disable_spring
        ENV["DISABLE_SPRING"] = prior_disable_spring
      else
        ENV.delete("DISABLE_SPRING")
      end
      if prior_db_env_check
        ENV["DISABLE_DATABASE_ENVIRONMENT_CHECK"] = prior_db_env_check
      else
        ENV.delete("DISABLE_DATABASE_ENVIRONMENT_CHECK")
      end
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
