# frozen_string_literal: true

require "rails"
require "decidim/core"
require "deface"

module Decidim
  module OnlyForms
    # This is the engine that runs on the public interface of only_forms.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::OnlyForms

      initializer "decidim_only_forms.admin_notification_email" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.forms.answer_questionnaire:after") do |event_name, data|
            Decidim::OnlyForms::AdminSubmissionNotification.handle(event_name, data)
          end
        end
      end
    end
  end
end
