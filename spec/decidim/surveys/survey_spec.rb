# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Surveys::Survey do
  subject(:survey) do
    create(
      :survey,
      component:,
      questionnaire: create(:questionnaire, questionnaire_for: component.participatory_space),
      allow_responses:,
      starts_at:,
      ends_at:
    )
  end

  let(:component) { create(:only_forms_component) }
  let(:allow_responses) { true }
  let(:starts_at) { nil }
  let(:ends_at) { nil }

  describe "#open?" do
    context "when no start/end are set" do
      it { expect(survey.open?).to be(true) }
    end

    context "when starts_at is in the past and ends_at is blank" do
      let(:starts_at) { 1.day.ago }

      it { expect(survey.open?).to be(true) }
    end

    context "when starts_at is blank and ends_at is in the future" do
      let(:ends_at) { 1.day.from_now }

      it { expect(survey.open?).to be(true) }
    end

    context "when both are present and the current time is within the range" do
      let(:starts_at) { 1.day.ago }
      let(:ends_at) { 1.day.from_now }

      it { expect(survey.open?).to be(true) }
    end

    context "when the window is in the past" do
      let(:starts_at) { 3.days.ago }
      let(:ends_at) { 2.days.ago }

      it { expect(survey.open?).to be(false) }
    end

    context "when the start date is in the future" do
      let(:starts_at) { 1.day.from_now }

      it { expect(survey.open?).to be(false) }
    end

    context "when responses are disabled" do
      let(:allow_responses) { false }

      it { expect(survey.open?).to be(false) }
    end
  end

  describe "#closed?" do
    context "when the survey is open" do
      it { expect(survey.closed?).to be(false) }
    end

    context "when responses are disabled" do
      let(:allow_responses) { false }

      it { expect(survey.closed?).to be(true) }
    end

    context "when the time window is in the past" do
      let(:starts_at) { 3.days.ago }
      let(:ends_at) { 2.days.ago }

      it { expect(survey.closed?).to be(true) }
    end
  end
end
