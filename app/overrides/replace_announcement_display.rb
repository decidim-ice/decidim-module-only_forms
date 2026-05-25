# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/forms/questionnaires/show",
  name: "announcements_display",
  replace: "erb[loud]:contains('render partial: \"decidim/shared/component_announcement\"')",
  text: <<~ERB
    <%= render partial: "decidim/shared/component_announcement" if ["surveys", "only_forms"].include?(current_component.manifest_name) %>
  ERB
)
