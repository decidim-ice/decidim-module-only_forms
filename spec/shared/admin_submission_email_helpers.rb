# frozen_string_literal: true

module AdminSubmissionEmailHelpers
  MIXED_TEXTAREA_BODY = "Plenty of seating."

  def create_mixed_only_forms_questions(questionnaire)
    [
      create_textarea_question(questionnaire),
      create_multiple_option_question(questionnaire),
      create_matrix_question(questionnaire)
    ]
  end

  def create_mixed_only_forms_answers(questionnaire, user:, session_token:)
    long, multi, matrix = create_mixed_only_forms_questions(questionnaire)
    create(:answer, questionnaire:, question: long, user:, session_token:, body: MIXED_TEXTAREA_BODY)
    create_multiple_option_answer(questionnaire, multi, user, session_token)
    create_matrix_answer(questionnaire, matrix, user, session_token)
  end

  def fill_mixed_only_forms
    fill_in "Comments", with: MIXED_TEXTAREA_BODY
    check "Ruby"
    check "Python"
    choose_matrix_cell("Location", "Good")
    choose_matrix_cell("Sound", "Poor")
  end

  def choose_matrix_cell(row_label, option_label)
    find("tr", text: row_label).find("input[type=radio][value='#{option_label}']").choose
  end

  def presented_submission_answers(questionnaire, session_token)
    record = questionnaire.answers.find_by!(session_token:)
    presenter = Decidim::Forms::Admin::QuestionnaireParticipantPresenter.new(participant: record)
    presenter.answers
  end

  def mail_html(mail)
    (mail.html_part || mail).body.decoded
  end

  def expect_native_presented_answers(email, questionnaire, session_token)
    html = compact_html(mail_html(email))
    presented_submission_answers(questionnaire, session_token).each do |answer|
      expect(html).to include(compact_html(answer.question))
      expect(html).to include(compact_html(answer.body.to_s))
    end
  end

  def compact_html(html)
    html.to_s.gsub(/\s+/, "")
  end

  private

  def create_textarea_question(questionnaire)
    create(
      :questionnaire_question,
      questionnaire:,
      position: 0,
      question_type: :long_answer,
      body: { en: "Comments" }
    )
  end

  def create_multiple_option_question(questionnaire)
    create(
      :questionnaire_question,
      questionnaire:,
      position: 1,
      question_type: :multiple_option,
      body: { en: "Languages" },
      options: option_bodies("Ruby", "Python", "PHP")
    )
  end

  def create_matrix_question(questionnaire)
    create(
      :questionnaire_question,
      questionnaire:,
      position: 2,
      question_type: :matrix_single,
      body: { en: "Rate the venue" },
      options: option_bodies("Good", "Poor"),
      rows: [{ "body" => { "en" => "Location" } }, { "body" => { "en" => "Sound" } }]
    )
  end

  def option_bodies(*labels)
    labels.map { |label| { "body" => { "en" => label }, "free_text" => false } }
  end

  def create_multiple_option_answer(questionnaire, question, user, session_token)
    answer = create(:answer, questionnaire:, question:, user:, session_token:, body: nil)
    selected_options(question, "Ruby", "Python").each do |option|
      create(:answer_choice, answer:, answer_option: option, matrix_row: nil)
    end
  end

  def create_matrix_answer(questionnaire, question, user, session_token)
    answer = create(:answer, questionnaire:, question:, user:, session_token:, body: nil)
    rows = question.matrix_rows.order(:position)
    options = question.answer_options
    create(:answer_choice, answer:, answer_option: options.first, matrix_row: rows.first)
    create(:answer_choice, answer:, answer_option: options.second, matrix_row: rows.second)
  end

  def selected_options(question, *labels)
    question.answer_options.select { |option| labels.include?(option.body["en"]) }
  end
end
