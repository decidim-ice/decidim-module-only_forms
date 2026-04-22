# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Private participatory process only-forms submission", type: :system do
  let(:organization) { create(:organization, host: "#{SecureRandom.hex(4)}.lvh.me") }
  let(:participant) { create(:user, :confirmed, organization:) }
  let(:admin) { create(:user, :confirmed, :admin, organization:) }

  let(:process) do
    create(
      :participatory_process,
      :with_steps,
      :published,
      :private,
      organization:,
      title: { en: "Test Process" }
    )
  end

  let(:component) do
    create(
      :only_forms_component,
      participatory_space: process,
      settings: { scopes_enabled: false },
      step_settings: {
        process.active_step.id => {
          allow_answers: true,
          allow_unregistered: false,
          allow_multiple_answers: true
        }
      }
    )
  end

  let(:questionnaire) { create(:questionnaire, questionnaire_for: process, title: { en: "Registration" }) }
  let!(:survey) { create(:survey, component:, questionnaire:) }

  before do
    survey.questionnaire.update!(questionnaire_for: survey)

    color_question = create(
      :questionnaire_question,
      questionnaire: questionnaire,
      position: 0,
      question_type: :single_option,
      body: { en: "what color do you prefer" },
      options: [
        { "body" => { "en" => "red" }, "free_text" => false },
        { "body" => { "en" => "blue" }, "free_text" => false }
      ]
    )

    attend_question = create(
      :questionnaire_question,
      questionnaire: questionnaire,
      position: 1,
      question_type: :single_option,
      body: { en: "i will attend the meetup" },
      options: [
        { "body" => { "en" => "yes" }, "free_text" => false },
        { "body" => { "en" => "no" }, "free_text" => false }
      ]
    )

    [color_question, attend_question].each(&:save!)

    create(:participatory_space_private_user, user: participant, privatable_to: process)

    switch_to_host(organization.host)
  end

  it "allows invited participant to submit and makes answers exportable" do
    login_as participant, scope: :user

    visit Decidim::EngineRouter.main_proxy(component).root_path

    expect(page).to have_content("Registration")

    click_button("Accept only essential", match: :first) if page.has_button?("Accept only essential")

    check I18n.t("decidim.forms.questionnaires.show.tos_agreement")

    choose "red"
    choose "yes"

    accept_confirm do
      click_button I18n.t("decidim.forms.step_navigation.show.submit")
    end

    expect(page).to have_content(/successfully answered/i)

    answers = Decidim::Forms::Answer.where(questionnaire:)
    expect(answers.where(user: participant).count).to be >= 2

    exported_answers = Decidim::Forms::QuestionnaireUserAnswers.for(questionnaire).flatten
    exported_choice_bodies = exported_answers.flat_map { |a| a.choices.map(&:body) }.compact

    expect(exported_choice_bodies.join(" ")).to include("red")
    expect(exported_choice_bodies.join(" ")).to include("yes")

    login_as admin, scope: :user
    expect(Decidim::Forms::QuestionnaireUserAnswers.for(questionnaire).count).to be >= 1
  end
end

