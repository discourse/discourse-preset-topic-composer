# frozen_string_literal: true

RSpec.describe "Preset Topic Composer | preset topic creation", type: :system  do
  let!(:admin) { Fabricate(:admin, name: "Admin") }

  before do
    SiteSetting.discourse_preset_topic_composer_enabled = true
    sign_in(admin)
    # Add tag group discourse
    tag_group = TagGroup.create!(name: "discourse")
    tag_group.tags = [
      Tag.create!(name: "question"),
      Tag.create!(name: "feature-request"),
    ]
    # string to hash
    site_setting = JSON.parse SiteSetting.button_types
    site_setting << {
      "id" => "new_question2",
      "icon" => "question",
      "name" => "New Question2",
      "description" => "Ask a new question in selected category.",
      "categoryId" => 0,
      "tagGroups" => [
        {
          "tagGroup" => "discourse",
          "multi" => false,
          "required" => true
        }
      ],
      "showTags" => false,
      "tags" => "",
      "access" => ""
    }
    SiteSetting.button_types = site_setting.to_json
  end

  describe "with plugin enabled" do
    it "should replace new topic button with new topic button preset" do
      visit "/"
      topic_button = find(".select-kit.single-select.dropdown-select-box .select-kit-header")
      expect(topic_button).to have_text("New Topic")

      topic_button.click

      new_question2 = find("li[title='New Question2']")
      new_question2.click

      #  has composer for creating a new topic
      composer_title = find(".action-title")
      expect(composer_title).to have_text("Create a new Topic")
    end


    it "should create a topic with a preset" do
      # 1 - select a preset
      visit "/"
      topic_button = find(".select-kit.single-select.dropdown-select-box .select-kit-header")
      expect(topic_button).to have_text("New Topic")
      topic_button.click
      new_question2 = find("li[title='New Question2']")
      new_question2.click
      # 2 - add a tag from the preset options
      # inside tag-group_wrapper div there is a select-kit .combobox .combo-box class
      # click on the select-kit .combobox .combo-box

      input_button = find(".tag-group_wrapper").find(".select-kit.combobox.combo-box")
      input_button.click

      find("li[title='question']").click

      title_input = find(".title-input").find("input")
      title_input.set("This is a test title")
      body_input = find(".d-editor-textarea-wrapper").find("textarea")
      body_input.set("This is a test body that should work!")
      find(".create").click
      pause_test
      #  fill composer title and post

      # 3 - create the topic
      # 4 - check if the topic was created with the tag
    end
  end

end
