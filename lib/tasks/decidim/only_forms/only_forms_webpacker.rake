# frozen_string_literal: true

require "decidim/gem_manager"

namespace :decidim_only_forms do
  namespace :webpacker do
    desc "Installs Only Forms webpacker files in Rails instance application"
    task install: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      install_only_forms_npm
    end

    desc "Adds Only Forms dependencies in package.json"
    task upgrade: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      install_only_forms_npm
    end

    def install_only_forms_npm
      return if only_forms_npm_dependencies.empty?

      puts "install NPM packages. You can also do this manually with this command:"
      puts "npm i #{only_forms_npm_dependencies.join(" ")}"
      only_forms_system! "npm i #{only_forms_npm_dependencies.join(" ")}"
    end

    def only_forms_npm_dependencies
      @only_forms_npm_dependencies ||= if only_forms_path.nil? || !File.exist?(only_forms_path.join("package.json"))
                                         []
                                       else
                                         package_json = JSON.parse(File.read(only_forms_path.join("package.json")))
                                         (package_json["dependencies"] || {}).map { |package, version| "#{package}@#{version}" }
                                       end
    end

    def only_forms_path
      @only_forms_path ||= Pathname.new(only_forms_gemspec.full_gem_path) if Gem.loaded_specs.has_key?(only_forms_gem_name)
    end

    def rails_app_path
      @rails_app_path ||= Rails.root
    end

    def only_forms_system!(command)
      system("cd #{rails_app_path} && #{command}") || abort("\n== Command #{command} failed ==")
    end

    def only_forms_gemspec
      @only_forms_gemspec ||= Gem.loaded_specs[only_forms_gem_name]
    end

    def only_forms_gem_name
      "decidim-only_forms"
    end
  end
end
