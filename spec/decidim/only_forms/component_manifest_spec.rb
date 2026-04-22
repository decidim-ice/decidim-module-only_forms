# frozen_string_literal: true

require "spec_helper"

RSpec.describe "OnlyForms component manifest" do
  it "registers only_forms component with allow_multiple_answers enabled by default" do
    manifest = Decidim.find_component_manifest("only_forms")

    expect(manifest).to be_present
    expect(manifest.name.to_s).to eq("only_forms")

    step_settings = manifest.settings(:step)
    expect(step_settings.attributes).to include(:allow_multiple_answers)
    expect(step_settings.attributes[:allow_multiple_answers].default).to be(true)
  end

  it "defines survey user answers exports" do
    manifest = Decidim.find_component_manifest("only_forms")

    export = manifest.export_manifests.find { _1.name == :survey_user_answers }

    expect(export).to be_present
    expect(export.formats).to include("CSV", "JSON", "Excel")
    expect(export.serializer).to eq(Decidim::Forms::UserAnswersSerializer)
  end
end

