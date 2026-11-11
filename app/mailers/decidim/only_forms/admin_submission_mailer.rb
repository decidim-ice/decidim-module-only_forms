# frozen_string_literal: true

module Decidim
  module OnlyForms
    class AdminSubmissionMailer < Decidim::ApplicationMailer
      include TranslatableAttributes

      def notify(email, questionnaire, response_ids)
        @questionnaire = questionnaire
        records = responses_for(questionnaire, response_ids)
        @author_user = records.first&.user
        @responses = presented_responses(records)
        @organization = organization_for(questionnaire)
        deliver_notification(email)
      end

      private

      def deliver_notification(email)
        I18n.with_locale(@organization.default_locale) do
          assign_titles
          mail(to: email, subject: subject_for)
        end
      end

      def assign_titles
        @questionnaire_title = translated_attribute(@questionnaire.title)
        @participatory_space_title = translated_attribute(participatory_space.title)
        @author_label = author_label
      end

      def subject_for
        I18n.t("notify.subject", scope: i18n_scope, questionnaire_title: @questionnaire_title)
      end

      def i18n_scope
        "decidim.only_forms.admin_submission_mailer"
      end

      def organization_for(questionnaire)
        questionnaire.questionnaire_for.component.organization
      end

      def responses_for(questionnaire, response_ids)
        records_for(questionnaire)
          .where(id: response_ids)
          .joins(:question)
          .order("decidim_forms_questions.position ASC")
      end

      def records_for(questionnaire)
        return questionnaire.responses if questionnaire.respond_to?(:responses)

        questionnaire.responses
      end

      def presented_responses(records)
        records.map { |response| Decidim::Forms::Admin::QuestionnaireResponsePresenter.new(response:) }
      end

      def participatory_space
        @questionnaire.questionnaire_for.component.participatory_space
      end

      def author_label
        user = @author_user
        return unregistered_label if user.blank?

        "#{user.name} (#{user.email})"
      end

      def unregistered_label
        I18n.t("notify.unregistered", scope: i18n_scope)
      end
    end
  end
end
