# frozen_string_literal: true

# name: discourse-preset-topic-composer
# about: add presets to your new topic button
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :plugin_name_enabled

module ::DiscoursePresetTopicComposer
  PLUGIN_NAME = "discourse-preset-topic-composer"
end

require_relative "lib/discourse_preset_topic_composer/engine"
register_asset "stylesheets/common/common.scss"

after_initialize do
  add_permitted_post_create_param('tag_groups')
  DiscourseEvent.on(:post_created) do |post, opts, user|
      # iterate tag groups and throw that into the the post?
  end
end
