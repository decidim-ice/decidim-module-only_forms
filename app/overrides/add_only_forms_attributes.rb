# frozen_string_literal: true

module AddOnlyFormsAttributes
  Deface::Override.new(
    virtual_path: "decidim/surveys/admin/settings/surveys/_form",
    name: "add_only_form_attributes",
    insert_after: "div.row.column:contains('form.check_box :allow_unregistered')",
    text: <<~ERB
      <div class="row column">
        <%= form.check_box :allow_multiple_answers, label: t("form.settings.allow_multiple_answers", scope: "decidim.only_forms.admin"), aria: { label: :allow_multiple_answers } %>
      </div>
      <div class="row column">
        <%= form.text_field :admin_email, label: t("form.settings.admin_email", scope: "decidim.only_forms.admin"), aria: { label: :admin_email }, help_text: t("form.settings.admin_email_help", scope: "decidim.only_forms.admin") %>
      </div>
    ERB
  )
end
