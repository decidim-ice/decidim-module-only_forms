# frozen_string_literal: true

module Decidim
  module Forms
    # This command is executed when the user answers a Questionnaire.
    class AnswerQuestionnaire < Decidim::Forms::Command
      delegate :current_user, to: :form
      include ::Decidim::MultipleAttachmentsMethods

      # Initializes a AnswerQuestionnaire Command.
      #
      # form - The form from which to get the data.
      # questionnaire - The current instance of the questionnaire to be answered.
      def initialize(form, questionnaire)
        @form = form
        @questionnaire = questionnaire
      end

      # Answers a questionnaire if it is valid
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid? || user_already_answered?

        answer_questionnaire

        if @errors
          reset_form_attachments
          broadcast(:invalid)
        else
          broadcast(:ok)
        end
      end

      attr_reader :form, :questionnaire

      private

      # This method will add an error to the `add_documents` field only if there's
      # any error in any other field or an error in another answer in the
      # questionnaire. This is needed because when the form has
      # an error, the attachments are lost, so we need a way to inform the user
      # of this problem.
      def reset_form_attachments
        @form.responses.each do |answer|
          answer.errors.add(:add_documents, :needs_to_be_reattached) if answer.has_attachments? || answer.has_error_in_attachments?
        end
      end

      def answer_questionnaire
        @main_form = @form
        @errors = nil

        Answer.transaction(requires_new: true) do
          form.responses_by_step.flatten.select(&:display_conditions_fulfilled?).each do |form_answer|
            answer = Answer.new(
              user: current_user,
              questionnaire: @questionnaire,
              question: form_answer.question,
              body: form_answer.body,
              session_token: form.context.session_token,
              ip_hash: form.context.ip_hash
            )

            form_answer.selected_choices.each do |choice|
              answer.choices.build(
                body: choice.body,
                custom_body: choice.custom_body,
                decidim_answer_option_id: choice.answer_option_id,
                decidim_question_matrix_row_id: choice.matrix_row_id,
                position: choice.position
              )
            end

            answer.save!

            next unless form_answer.question.has_attachments?

            # The attachments module expects `@form` to be the form with the
            # attachments
            @form = form_answer
            @attached_to = answer

            build_attachments

            if attachments_invalid?
              @errors = true
              next
            end

            create_attachments if process_attachments?
            document_cleanup!
          end

          @form = @main_form
          raise ActiveRecord::Rollback if @errors
        end
      end

      def user_already_answered?
        return false if allow_multiple_answers?

        questionnaire.answered_by?(current_user || form.context.session_token)
      end

      def allow_multiple_answers?
        current_settings.allow_multiple_answers if current_settings.respond_to?("allow_multiple_answers")
      end

      def current_settings
        return nil unless questionnaire.respond_to?(:questionnaire_for)

        questionnaire_for = questionnaire.questionnaire_for

        return questionnaire_for.current_settings if questionnaire_for.respond_to?(:current_settings)
        return questionnaire_for.settings if questionnaire_for.respond_to?(:settings)

        questionnaire_for_component = questionnaire_for.component if questionnaire_for.respond_to?(:component)

        return questionnaire_for_component.current_settings if questionnaire_for_component.respond_to?(:current_settings)
        return questionnaire_for_component.settings if questionnaire_for_component.respond_to?(:settings)

        nil
      end
    end
  end
end
