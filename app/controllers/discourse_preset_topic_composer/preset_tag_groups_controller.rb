# frozen_string_literal: true

module ::DiscoursePresetTopicComposer
  class PresetTagGroupsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def search_tags_by_tag_group
      tag_group = params[:tag_group]
      tag_group = CGI.unescape(tag_group)

      tag_order =
        if SiteSetting.tags_sort_alphabetically
          "name ASC"
        else
          "public_topic_count DESC"
        end

      tags = TagGroup.visible(guardian).find_by(name: tag_group)&.tags&.order(tag_order) || []
      render json: {
               tags: ActiveModel::ArraySerializer.new(tags, each_serializer: TagSerializer).as_json,
             }
    end
  end
end
