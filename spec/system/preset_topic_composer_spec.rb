# frozen_string_literal: true

RSpec.describe "Preset Topic Composer | preset topic creation", type: :system do
  let!(:admin) { Fabricate(:admin, name: "Admin") }
  let(:composer) { PageObjects::Components::Composer.new }
  fab!(:tag1) { Fabricate(:tag, name: "tag1") }
  fab!(:tag2) { Fabricate(:tag, name: "tag2") }
  fab!(:tag_synonym_for_tag1) { Fabricate(:tag, name: "tag_synonym", target_tag: tag1) }
  fab!(:cat) { Fabricate(:category) }
  fab!(:tag_group) do
    Fabricate(:tag_group, tags: [tag1, tag2, tag_synonym_for_tag1], name: "tag/group0")
  end
  fab!(:tag_group2) { Fabricate(:tag_group, tags: [tag1, tag2]) }

  class SiteSettingHelper
    def self.add_new_json(json)
      site_setting = JSON.parse SiteSetting.button_types
      site_setting << json
      SiteSetting.button_types = site_setting.to_json
    end
  end

  before do
    SiteSetting.discourse_preset_topic_composer_enabled = true
    sign_in(admin)

    SiteSettingHelper.add_new_json(
      {
        "id" => "new_question2",
        "icon" => "question",
        "name" => "New Question2",
        "description" => "Ask a new question in selected category.",
        "categoryId" => cat.id,
        "tagGroups" => [{ "tagGroup" => tag_group.name, "multi" => false, "required" => false }],
        "showTags" => false,
        "tags" => "",
        "access" => "",
      },
    )
    SiteSettingHelper.add_new_json(
      {
        "id" => "new_question3",
        "icon" => "question",
        "name" => "New Question3",
        "description" => "Ask a new question in selected category.",
        "categoryId" => cat.id,
        "tagGroups" => [
          { "tagGroup" => tag_group.name, "multi" => false, "required" => false },
          { "tagGroup" => tag_group2.name, "multi" => false, "required" => true },
        ],
        "showTags" => false,
        "tags" => "",
        "access" => admin.groups.first.id.to_s,
      },
    )
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

    it "can fetch a tag group with a / in the name" do
      visit "/"
      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.select("New Question2")

      preset_input = PageObjects::Components::PresetComposerInput.new
      preset_input.select_first_with(tag1.name)

      expect(preset_input.get_first_label).to eq(tag1.name)
    end

    it "should be able to fetch only visible buttons" do
      normal_user = Fabricate(:user)
      sign_in(normal_user)
      visit "/"
      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.button.click
      expect(page).not_to have_text("New Question3")

      sign_in(admin)

      visit "/"
      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.button.click

      expect(page).to have_text("New Question3")
    end

    it "should create a topic with a preset" do
      visit "/"
      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.select("New Question2")

      preset_input = PageObjects::Components::PresetComposerInput.new
      preset_input.select_first_with(tag1.name)

      title = "Abc 123 test title!"
      body = "This is a test body that should work!"
      composer.fill_title(title)
      composer.type_content(body)

      composer.submit

      expect(page).to have_text(title, wait: 15)
      expect(page).to have_text(body)
      expect(page).to have_text(tag1.name)
    end

    it "should create a topic with a preset and a tag synonym" do
      visit "/"
      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.select("New Question2")

      preset_input = PageObjects::Components::PresetComposerInput.new
      preset_input.select_first_with(tag_synonym_for_tag1.name)

      title = "Abc 123 test title!"
      body = "This is a test body that should work!"
      composer.fill_title(title)
      composer.type_content(body)

      composer.submit

      expect(page).to have_text(title, wait: 15)
      expect(page).to have_text(body)
      expect(page).to have_text(tag1.name)
    end

    it "should create a topic with a preset and multiple tags" do
      visit "/"
      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.select("New Question3")

      preset_input = PageObjects::Components::PresetComposerInput.new
      preset_input.select_first_with(tag1.name)
      preset_input.select_last_with(tag2.name)

      title = "Abc 123 test title!"
      body = "This is a test body that should work!"
      composer.fill_title(title)
      composer.type_content(body)

      composer.submit

      expect(page).to have_text(title, wait: 15)
      expect(page).to have_text(body)
      expect(page).to have_text(tag1.name)
      expect(page).to have_text(tag2.name)
    end

    it "should warn and make border red if tag is not filled" do
      visit "/"
      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.select("New Question3")

      preset_input = PageObjects::Components::PresetComposerInput.new
      preset_input.select_first_with(tag1.name)

      title = "Abc 123 test title!"
      body = "This is a test body that should work!"
      composer.fill_title(title)
      composer.type_content(body)

      composer.submit

      expect(page).to have_text(I18n.t("dialog.error_message"))
      expect(page).to have_css(".tag-group_wrapper .tag-group-input--invalid")
    end

    it "does not change input label if choose category" do
      visit "/"

      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.select("New Question3")

      preset_input = PageObjects::Components::PresetComposerInput.new

      expect(preset_input.get_first_label).to eq(I18n.t("composer.select") + tag_group.name)
      expect(preset_input.get_last_label).to eq("*" + I18n.t("composer.select") + tag_group2.name)

      composer.switch_category(cat.name)

      expect(preset_input.get_first_label).to eq(I18n.t("composer.select") + tag_group.name)
      expect(preset_input.get_last_label).to eq("*" + I18n.t("composer.select") + tag_group2.name)
    end

    it "does keep the tag input when reopening the composer" do
      visit "/"
      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.select("New Question3")

      preset_input = PageObjects::Components::PresetComposerInput.new
      preset_input.select_first_with(tag1.name)

      title = "Abc 123 test title!"
      body = "This is a test body that should work!"
      composer.fill_title(title)
      composer.type_content(body)

      composer.minimize

      preset_dropdown.select("New Question3")

      expect(preset_input.get_first_label).to eq(tag1.name)
    end
  end
end
