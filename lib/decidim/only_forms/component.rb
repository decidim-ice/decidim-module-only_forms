# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:only_forms) do |component|
  survey_component = Decidim.find_component_manifest("surveys")
  component.attributes = survey_component.attributes.deep_dup
  component.name = "only_forms"

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.exports :survey_user_responses do |exports|
    exports.collection do |_component, _user, survey_id|
      survey = Decidim::Surveys::Survey.find(survey_id)
      Decidim::Forms::QuestionnaireUserResponses.for(survey.questionnaire)
    end

    exports.formats %w(CSV JSON Excel FormPDF)

    exports.serializer Decidim::Forms::UserResponsesSerializer
  end

  component.exports :published_survey_user_responses do |exports|
    exports.collection do |component|
      survey = Decidim::Surveys::Survey.find_by(component:)

      Decidim::Forms::Response
        .joins(:question)
        .where(questionnaire: survey.questionnaire)
        .where.not(decidim_forms_questions: { question_type: %w(separator title_and_description) })
        .where.not(decidim_forms_questions: { survey_responses_published_at: nil })
        .includes(:question, :choices, :user)
    end

    exports.formats []
    exports.include_in_open_data = true
    exports.serializer Decidim::Surveys::UserResponsesSerializer
  end

  component.register_resource(:survey) do |resource|
    resource.model_class_name = "Decidim::Surveys::Survey"
    resource.card = "decidim/surveys/survey"
    resource.searchable = true
    resource.actions = %w(respond)
  end

  component
end
