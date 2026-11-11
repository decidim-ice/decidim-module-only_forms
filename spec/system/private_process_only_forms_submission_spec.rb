# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/DescribeClass
RSpec.describe "Restricted participatory process only-forms submission" do
  let(:organization) { create(:organization, host: "#{SecureRandom.hex(4)}.lvh.me") }
  let(:participant) { create(:user, :confirmed, organization:) }
  let(:admin) { create(:user, :confirmed, :admin, organization:) }

  let(:process) do
    create(
      :participatory_process,
      :with_steps,
      :published,
      :restricted,
      organization:,
      title: { en: "Test Process" }
    )
  end

  let(:component) do
    create(
      :only_forms_component,
      participatory_space: process
    )
  end

  let(:questionnaire) { create(:questionnaire, questionnaire_for: process, title: { en: "Registration" }) }
  let!(:survey) { create(:survey, :published, :allow_responses, component:, questionnaire:) }

  before do
    survey.questionnaire.update!(questionnaire_for: survey)

    color_question = create(
      :questionnaire_question,
      questionnaire:,
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
      questionnaire:,
      position: 1,
      question_type: :single_option,
      body: { en: "i will attend the meetup" },
      options: [
        { "body" => { "en" => "yes" }, "free_text" => false },
        { "body" => { "en" => "no" }, "free_text" => false }
      ]
    )

    [color_question, attend_question].each(&:save!)

    Decidim::ParticipatorySpace::Member.create!(
      user: participant,
      participatory_space: process,
      role: { en: "member" },
      published: true
    )

    switch_to_host(organization.host)
  end

  it "allows invited participant to submit and makes responses exportable" do
    login_as participant, scope: :user

    url = Decidim::EngineRouter.main_proxy(component).survey_path(survey)

    visit url

    expect(page).to have_content("Registration")

    click_on("Accept only essential", match: :first) if page.has_button?("Accept only essential")

    check I18n.t("decidim.forms.questionnaires.show.tos_agreement")

    choose "red"
    choose "yes"

    accept_confirm do
      click_on I18n.t("decidim.forms.step_navigation.show.submit")
    end

    expect(page).to have_content(/successfully responded/i)

    responses = Decidim::Forms::Response.where(questionnaire:)
    expect(responses.where(user: participant).count).to be >= 2

    exported_responses = Decidim::Forms::QuestionnaireUserResponses.for(questionnaire).flatten
    exported_choice_bodies = exported_responses.flat_map { |a| a.choices.map(&:body) }.compact

    expect(exported_choice_bodies.join(" ")).to include("red")
    expect(exported_choice_bodies.join(" ")).to include("yes")

    login_as admin, scope: :user
    expect(Decidim::Forms::QuestionnaireUserResponses.for(questionnaire).count).to be >= 1
  end
end
# rubocop:enable RSpec/DescribeClass
