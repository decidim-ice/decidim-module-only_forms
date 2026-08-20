# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/DescribeClass
RSpec.describe "Admin email after a registered only-forms submission" do
  include AdminSubmissionEmailHelpers

  let(:organization) { create(:organization, host: "#{SecureRandom.hex(4)}.lvh.me") }
  let(:participant) { create(:user, :confirmed, organization:) }
  let(:admin_email) { "forms-admin@example.org" }
  let!(:organization_admin) { create(:user, :confirmed, :admin, organization:, email: admin_email) }

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
      settings: { scopes_enabled: false, admin_email: },
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
    create_mixed_only_forms_questions(questionnaire)
    create(:participatory_space_private_user, user: participant, privatable_to: process)
    ActionMailer::Base.deliveries.clear
    switch_to_host(organization.host)
  end

  it "emails the admin with native presenter HTML for the registered answers" do
    login_as participant, scope: :user
    submit_only_forms

    email = ActionMailer::Base.deliveries.last
    expect(email).to be_present
    expect(email.to).to eq([admin_email])
    expect(mail_html(email)).to include(participant.name)
    token = Decidim::Forms::Answer.where(questionnaire:, user: participant).pick(:session_token)
    expect_native_presented_answers(email, questionnaire, token)
  end

  def submit_only_forms
    visit Decidim::EngineRouter.main_proxy(component).root_path
    expect(page).to have_content("Registration")
    click_on("Accept only essential", match: :first) if page.has_button?("Accept only essential")
    check I18n.t("decidim.forms.questionnaires.show.tos_agreement")
    fill_mixed_only_forms
    perform_enqueued_jobs do
      accept_confirm { click_on I18n.t("decidim.forms.step_navigation.show.submit") }
      expect(page).to have_content(/successfully answered/i)
    end
  end
end
# rubocop:enable RSpec/DescribeClass
