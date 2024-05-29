# frozen_string_literal: true

# name: discourse-preset-topic-composer
# about: add presets to your new topic button
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discourse_preset_topic_composer_enabled

module ::DiscoursePresetTopicComposer
  PLUGIN_NAME = "discourse-preset-topic-composer"
end

require_relative "lib/discourse_preset_topic_composer/engine"
register_asset "stylesheets/common/common.scss"

after_initialize do

  add_to_serializer(:current_user, :topic_preset_buttons) do
    buttons = JSON.parse(SiteSetting.button_types) || []
    current_user_groups = scope.user.groups.pluck(:name)

    buttons.select do |button|
      allowed_groups = button["access"].split(/(?:,|\s)\s*/)
      allowed_groups.length == 0 || allowed_groups.any? do |group|
        current_user_groups.include?(group.strip)
      end
    end
  end


  add_permitted_post_create_param("tags_to_add", :hash)
  on(:topic_created) do |topic, opts, user|
    tag_groups = opts[:tags_to_add]
    guardian = Guardian.new(user)
    next unless tag_groups
    tag_groups.each do |tag_group_name, tags|
      tags.each do |tag|
        tag = Tag.visible(guardian).find_by(name: tag)
        next unless tag
        topic.tags << tag
      end
    end
  end
end
