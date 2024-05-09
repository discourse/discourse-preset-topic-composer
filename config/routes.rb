# frozen_string_literal: true

DiscoursePresetTopicComposer::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::DiscoursePresetTopicComposer::Engine, at: "my-plugin" }
