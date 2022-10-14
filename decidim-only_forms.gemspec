# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'decidim/only_forms/version'

Gem::Specification.new do |s|
  s.version = Decidim::OnlyForms.version
  s.authors = ['Hadrien Froger', 'Renato Silva']
  s.email = ['hadrien@octree.ch', 'renato@octree.ch']
  s.license = 'AGPL-3.0'
  s.homepage = 'https://github.com/decidim/decidim-module-only_forms'
  s.required_ruby_version = '>= 2.7'

  s.name = 'decidim-only_forms'
  s.summary = 'A decidim only_forms module'
  s.description = "Component for list followers in a participatory space for Mkutano's Decidim.'"

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency 'decidim-core', Decidim::OnlyForms.version
  s.add_dependency 'decidim-forms', Decidim::OnlyForms.version
  s.add_dependency 'decidim-surveys', Decidim::OnlyForms.version
  s.add_dependency 'decidim-templates', Decidim::OnlyForms.version
end
