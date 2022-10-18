# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:only_forms) do |component|
  survey_component = Decidim.find_component_manifest("surveys")
  component.attributes = survey_component.attributes.deep_dup
  component.name = "only_forms"
  
  component.settings(:global) do |settings|
    settings.attribute :scopes_enabled, type: :boolean, default: false
    settings.attribute :scope_id, type: :scope
    settings.attribute :starts_at, type: :time
    settings.attribute :ends_at, type: :time
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :clean_after_publish, type: :boolean, default: true
  end

  component.settings(:step) do |settings|
    settings.attribute :allow_answers, type: :boolean, default: false
    settings.attribute :allow_unregistered, type: :boolean, default: false
    settings.attribute :allow_multiple_answers, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.exports :survey_user_answers do |exports|
    exports.collection do |f|
      survey = Decidim::Surveys::Survey.find_by(component: f)
      Decidim::Forms::QuestionnaireUserAnswers.for(survey.questionnaire)
    end

    exports.formats %w(CSV JSON Excel)

    exports.serializer Decidim::Forms::UserAnswersSerializer
  end

  component.register_resource(:survey) do |resource|
    resource.model_class_name = "Decidim::Surveys::Survey"
  end
  component
end
