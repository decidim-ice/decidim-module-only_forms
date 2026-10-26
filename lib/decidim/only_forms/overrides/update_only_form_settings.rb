# frozen_string_literal: true

module Decidim
  module OnlyForms
    module Overrides
      module UpdateOnlyFormSettings
        extend ActiveSupport::Concern

        included do
          alias_method :decidim_original_update_survey_settings, :update_survey_settings

          private

          def update_survey_settings
            survey.update!(
              allow_responses: form.allow_responses,
              allow_editing_responses: form.allow_editing_responses,
              allow_unregistered: form.allow_unregistered,
              starts_at: form.starts_at,
              ends_at: form.ends_at,
              clean_after_publish: form.clean_after_publish,
              announcement: form.announcement,
              allow_multiple_answers: form.allow_multiple_answers,
              admin_email: form.admin_email
            )
          end
        end
      end
    end
  end
end
