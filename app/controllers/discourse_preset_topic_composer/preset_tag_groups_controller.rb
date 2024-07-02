# frozen_string_literal: true

module ::DiscoursePresetTopicComposer
  class PresetTagGroupsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def search_tags_by_tag_group
      tag_group = params[:tag_group]
      tag_group = CGI.unescape(tag_group)

      if SiteSetting.tags_sort_alphabetically
        tag_order = "name ASC"
      else
        tag_order = "public_topic_count DESC"
      end

      tags = TagGroup.visible(guardian).find_by(name: tag_group)&.tags.order(tag_order) || []
      render json: { tags: tags }
    end
  end
end
