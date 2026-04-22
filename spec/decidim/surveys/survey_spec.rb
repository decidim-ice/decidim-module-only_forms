# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Surveys::Survey do
  subject(:survey) { described_class.new }

  let(:settings) do
    instance_double(
      "settings",
      clean_after_publish?: true,
      starts_at: starts_at,
      ends_at: ends_at
    )
  end

  let(:component) { instance_double("Decidim::Component", settings: settings) }

  let(:starts_at) { nil }
  let(:ends_at) { nil }

  before do
    allow(survey).to receive(:component).and_return(component)
  end

  describe "#clean_after_publish?" do
    it "reads from component settings" do
      expect(survey.clean_after_publish?).to be(true)
    end
  end

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

    context "when both are present" do
      let(:starts_at) { 1.day.ago }
      let(:ends_at) { 1.day.from_now }

      it { expect(survey.open?).to be(true) }
    end

    context "when the window is in the past" do
      let(:starts_at) { 3.days.ago }
      let(:ends_at) { 2.days.ago }

      it { expect(survey.open?).to be(false) }
    end
  end
end

