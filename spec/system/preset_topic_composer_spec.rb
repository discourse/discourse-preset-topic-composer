# frozen_string_literal: true

RSpec.describe "Preset Topic Composer | preset topic creation", type: :system do
  let!(:admin) { Fabricate(:admin, name: "Admin") }
  let(:composer) { PageObjects::Components::Composer.new }
  fab!(:tag1) { Fabricate(:tag, name: "tag1") }
  fab!(:tag2) { Fabricate(:tag, name: "tag2") }
  fab!(:tag3) { Fabricate(:tag, name: "tag3") }
  fab!(:cat) { Fabricate(:category) }
  fab!(:tag_group) { Fabricate(:tag_group, tags: [tag1, tag2, tag3]) }

  before do
    SiteSetting.discourse_preset_topic_composer_enabled = true
    sign_in(admin)
    # string to hash
    site_setting = JSON.parse SiteSetting.button_types
    site_setting << {
      "id" => "new_question2",
      "icon" => "question",
      "name" => "New Question2",
      "description" => "Ask a new question in selected category.",
      "categoryId" => cat.id,
      "tagGroups" => [{ "tagGroup" => tag_group.name, "multi" => false, "required" => false }],
      "showTags" => false,
      "tags" => "",
      "access" => "",
    }
    SiteSetting.button_types = site_setting.to_json
  end

  describe "with plugin enabled" do
    it "should replace new topic button with new topic button preset" do
      visit "/"
      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new

      expect(preset_dropdown.button).to have_text("New Topic")
      preset_dropdown.select("New Question2")

      composer_title = find(".action-title")
      expect(composer_title).to have_text("Create a new Topic")
    end

    it "should create a topic with a preset" do
      visit "/"
      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.select("New Question2")

      preset_input = PageObjects::Components::PresetComposerInput.new(input_button)
      preset_input.select(tag1.name)

      title = "Abc 123 test title!"
      body = "This is a test body that should work!"
      composer.fill_title(title)
      composer.type_content(body)
      composer.submit
      expect(page).to have_text(title)
      expect(page).to have_text(body)
      expect(page).to have_text(tag1.name)
    end
  end
end
