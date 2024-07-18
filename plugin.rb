# frozen_string_literal: true

# name: discourse-preset-topic-composer
# about: add presets to your new topic button
# meta_topic_id: 311174
# version: 0.0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-preset-topic-composer
# required_version: 2.7.0

enabled_site_setting :discourse_preset_topic_composer_enabled

module ::DiscoursePresetTopicComposer
  PLUGIN_NAME = "discourse-preset-topic-composer"
end

require_relative "lib/discourse_preset_topic_composer/engine"
register_asset "stylesheets/common/common.scss"

after_initialize do
  add_to_serializer(:site, :topic_preset_buttons) do
    buttons = JSON.parse(SiteSetting.button_types) || []
    current_user = scope.user

    buttons.select do |button|
      allowed_groups =
        button["access"]
          .split(/(?:,|\s)\s*/)
          .map { |group_name| Group.find_by(name: group_name)&.id }
          .compact
      allowed_groups = [Group::AUTO_GROUPS[:everyone]] if allowed_groups.empty?
      next true if allowed_groups.include?(Group::AUTO_GROUPS[:everyone])
      current_user.in_any_groups?(allowed_groups)
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
        tag = Tag.find_by_id(tag.target_tag_id) if tag.synonym?
        next unless tag
        next if topic.tags.exists?(tag.id)
        topic.tags << tag
      end
    end
  end
end
