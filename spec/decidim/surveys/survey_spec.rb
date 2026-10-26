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

  describe "validations" do
    it "requires a questionnaire" do
      survey = build(:survey, questionnaire: nil)
      expect(survey).not_to be_valid
      expect(survey.errors[:questionnaire]).to include("can't be blank")
    end
  end

  describe "#open?" do
    context "when allow_responses is false" do
      let(:allow_responses) { false }

      it { expect(survey.open?).to be(false) }
    end

    context "when allow_responses is nil" do
      let(:allow_responses) { nil }

      it { expect(survey.open?).to be(false) }
    end

    context "when no start/end are set (time_indefinite?)" do
      let(:allow_responses) { true }

      it { expect(survey.open?).to be(true) }
    end

    context "when starts_at is in the past and ends_at is blank (started_but_no_end?)" do
      let(:starts_at) { 1.day.ago }

      it { expect(survey.open?).to be(true) }
    end

    context "when starts_at is in the future and ends_at is blank" do
      let(:starts_at) { 1.day.from_now }

      it { expect(survey.open?).to be(false) }
    end

    context "when starts_at is blank and ends_at is in the future (no_start_but_ends_later?)" do
      let(:ends_at) { 1.day.from_now }

      it { expect(survey.open?).to be(true) }
    end

    context "when starts_at is blank and ends_at is in the past" do
      let(:ends_at) { 1.day.ago }

      it { expect(survey.open?).to be(false) }
    end

    context "when both are present and within range (time_range_defined? + within_time_range?)" do
      let(:starts_at) { 1.day.ago }
      let(:ends_at) { 1.day.from_now }

      it { expect(survey.open?).to be(true) }
    end

    context "when both are present but window is in the past" do
      let(:starts_at) { 3.days.ago }
      let(:ends_at) { 2.days.ago }

      it { expect(survey.open?).to be(false) }
    end

    context "when both are present but window is in the future" do
      let(:starts_at) { 2.days.from_now }
      let(:ends_at) { 3.days.from_now }

      it { expect(survey.open?).to be(false) }
    end
  end

  describe "#closed?" do
    context "when survey is open" do
      it { expect(survey.closed?).to be(false) }
    end

    context "when survey is not open" do
      let(:allow_responses) { false }

      it { expect(survey.closed?).to be(true) }
    end
  end

  describe "#allow_resource_permissions?" do
    it "returns true" do
      expect(survey.allow_resource_permissions?).to be(true)
    end
  end

  describe "delegates" do
    let(:questionnaire) { create(:questionnaire, questionnaire_for: component.participatory_space) }

    before do
      allow(questionnaire).to receive(:title).and_return("My Title")
      allow(questionnaire).to receive(:description).and_return("My Description")
      allow(questionnaire).to receive(:tos).and_return("My ToS")
    end

    it "delegates title to questionnaire" do
      expect(survey.title).to eq("My Title")
    end

    it "delegates description to questionnaire" do
      expect(survey.description).to eq("My Description")
    end

    it "delegates tos to questionnaire" do
      expect(survey.tos).to eq("My ToS")
    end
  end

  describe "scopes" do
    describe ".open" do
      it "includes surveys with allow_responses true and no time constraints" do
        survey
        expect(described_class.open).to include(survey)
      end

      it "excludes surveys with allow_responses false" do
        create(
          :survey,
          component:,
          questionnaire: create(:questionnaire, questionnaire_for: component.participatory_space),
          allow_responses: false
        )
        expect(described_class.open).not_to include(survey)
      end

      it "excludes surveys whose window is in the past" do
        closed = create(
          :survey,
          component:,
          questionnaire: create(:questionnaire, questionnaire_for: component.participatory_space),
          allow_responses: true,
          starts_at: 3.days.ago,
          ends_at: 2.days.ago
        )
        expect(described_class.open).not_to include(closed)
      end

      it "includes surveys whose window is currently active" do
        active = create(
          :survey,
          component:,
          questionnaire: create(:questionnaire, questionnaire_for: component.participatory_space),
          allow_responses: true,
          starts_at: 1.day.ago,
          ends_at: 1.day.from_now
        )
        expect(described_class.open).to include(active)
      end
    end

    describe ".closed" do
      it "includes surveys with allow_responses false" do
        closed = create(
          :survey,
          component:,
          questionnaire: create(:questionnaire, questionnaire_for: component.participatory_space),
          allow_responses: false
        )
        expect(described_class.closed).to include(closed)
      end

      it "includes surveys whose window ended in the past" do
        closed = create(
          :survey,
          component:,
          questionnaire: create(:questionnaire, questionnaire_for: component.participatory_space),
          allow_responses: true,
          starts_at: 3.days.ago,
          ends_at: 2.days.ago
        )
        expect(described_class.closed).to include(closed)
      end

      it "includes surveys whose window has not started yet" do
        future = create(
          :survey,
          component:,
          questionnaire: create(:questionnaire, questionnaire_for: component.participatory_space),
          allow_responses: true,
          starts_at: 2.days.from_now,
          ends_at: 3.days.from_now
        )
        expect(described_class.closed).to include(future)
      end
    end

    describe ".published" do
      it "includes surveys with published_at set" do
        survey.update!(published_at: Time.current)
        expect(described_class.published).to include(survey)
      end

      it "excludes surveys without published_at" do
        expect(described_class.published).not_to include(survey)
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns the expected attributes" do
      expect(described_class.ransackable_attributes).to contain_exactly("ends_at", "starts_at", "allow_responses")
    end
  end

  describe ".ransackable_scopes" do
    it "returns the expected scopes" do
      expect(described_class.ransackable_scopes).to eq([:with_any_state])
    end
  end

  describe ".log_presenter_class_for" do
    it "returns the admin log presenter" do
      expect(described_class.log_presenter_class_for(nil)).to eq(Decidim::Surveys::AdminLog::SurveyPresenter)
    end
  end
end
