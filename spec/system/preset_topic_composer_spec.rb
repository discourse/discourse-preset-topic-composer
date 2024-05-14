# frozen_string_literal: true

RSpec.describe "Preset Topic Composer | preset topic creation", type: :system  do

  fab!(:admin)

  before do
    SiteSetting.discourse_preset_topic_composer_enabled = true
    sign_in(admin)
  end

  describe "with plugin enabled" do
    it "should replace new topic button with new topic button preset" do
      visit "/"
      # id: new-topic-preset-dropdown
      # topic_button = find("#new-topic-preset-dropdown")
      pause_test

      expect(page).to have_selector("#new-topic-preset-dropdown")
      expect(topic_button).to have_text("New Topic")

      topic_button.click
    end

    it "should have presets in the new topic button dropdown" do
      # TODO: Maybe some abstraction for this?
    end

    it "should create a topic with a preset" do
      # TODO:
      # 1 - select a preset
      # 2 - add a tag from the preset options
      # 3 - create the topic
      # 4 - check if the topic was created with the tag
    end
  end

end
