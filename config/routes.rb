# frozen_string_literal: true

DiscoursePresetTopicComposer::Engine.routes.draw do
  get "/tag_by_tag_group/:tag_group" => "preset_tag_groups#search_tags_by_tag_group"
end

Discourse::Application.routes.draw do
  mount ::DiscoursePresetTopicComposer::Engine, at: "topic_composer"
end
