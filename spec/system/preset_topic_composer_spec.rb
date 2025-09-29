# frozen_string_literal: true

RSpec.describe "Preset Topic Composer | preset topic creation", type: :system do
  let!(:admin) { Fabricate(:admin, name: "Admin") }
  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:user_group) { Fabricate(:group, users: [user]) }
  fab!(:restricted_category) { Fabricate(:category) }
  fab!(:category_group) do
    Fabricate(
      :category_group,
      category: restricted_category,
      group: user_group,
      permission_type: CategoryGroup.permission_types[:create_post],
    )
  end

  fab!(:tag1) { Fabricate(:tag, name: "tag1") }
  fab!(:tag2) { Fabricate(:tag, name: "tag2") }
  fab!(:tag_synonym_for_tag1) { Fabricate(:tag, name: "tag_synonym", target_tag: tag1) }
  fab!(:cat) { Fabricate(:category) }
  fab!(:tag_group) do
    Fabricate(:tag_group, tags: [tag1, tag2, tag_synonym_for_tag1], name: "tag/group0")
  end
  fab!(:tag_group2) { Fabricate(:tag_group, tags: [tag1, tag2]) }
  let(:composer) { PageObjects::Components::Composer.new }

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
        "tags" => "#{tag1.name}",
        "access" => "",
        :highlightUrls => %w[/tag/*],
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
        "access" => "admins",
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

    it "should add is-selected class to the button when in matching url" do
      visit "/tag/#{tag1.name}"
      PageObjects::Components::PresetTopicDropdown.new.button.click

      button = find(:css, ".is-selected")
      expect(button).to have_text("New Question2")
    end

    it "should add is-selected class to the button when in matching url and ignores casing" do
      tag = "#{tag1.name}".upcase
      visit "/tag/#{tag}"
      PageObjects::Components::PresetTopicDropdown.new.button.click

      button = find(:css, ".is-selected")
      expect(button).to have_text("New Question2")
    end

    it "should add is-selected class to the button when in categoryId" do
      visit "/c/#{cat.slug}"
      PageObjects::Components::PresetTopicDropdown.new.button.click

      button = find("li[title='New Question2']")
      expect(button[:class]).to include("is-selected")

      button = find("li[title='New Question3']")
      expect(button[:class]).to include("is-selected")
    end

    xit "should sort alphabetically if SiteSetting is enabled" do
      SiteSetting.tags_sort_alphabetically = true
      Fabricate(:topic, tags: [tag_synonym_for_tag1])
      visit "/"

      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.select("New Question2")
      preset_input = PageObjects::Components::PresetComposerInput.new
      expect(preset_input.get_first_list_options.first.text).to eq(tag1.name)

      SiteSetting.tags_sort_alphabetically = false
      visit "/"

      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.select("New Question2")
      preset_input = PageObjects::Components::PresetComposerInput.new
      expect(preset_input.get_first_list_options.first.text).to eq(tag_synonym_for_tag1.name)
    end

    it "should not create a topic with a preset and outside tags" do
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
      find("img[id='site-logo']").click
      preset_dropdown = PageObjects::Components::PresetTopicDropdown.new
      preset_dropdown.select("New Question3")
      preset_input = PageObjects::Components::PresetComposerInput.new
      preset_input.select_last_with(tag2.name)

      title = "Abc 123 test title!2"
      body = "This is a test body that should work!2"
      composer.fill_title(title)
      composer.type_content(body)

      composer.submit
      expect(page).to have_text(title, wait: 15)
      expect(page).to have_text(body)
      expect(page).to have_text(tag1.name, count: 1)
      expect(page).to have_text(tag2.name, count: 2)
    end

    describe "as a user with a restricted category" do
      before { sign_in(user) }

      it "should always show the new topic button" do
        visit "/c/#{restricted_category.slug}"
        expect(page).to have_css(".new-topic-dropdown")
        expect(page).to have_text("New Topic")
      end
    end
  end
end
