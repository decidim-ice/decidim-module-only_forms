# frozen_string_literal: true
class AddOnlyFormsToSurveys < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        add_column :decidim_surveys_surveys, :allow_multiple_answers, :boolean, default: false, null: false
        add_column :decidim_surveys_surveys, :admin_email, :string
      end

      dir.down do
        remove_column :decidim_surveys_surveys, :allow_multiple_answers
        remove_column :decidim_surveys_surveys, :admin_email
      end
    end
  end
end
