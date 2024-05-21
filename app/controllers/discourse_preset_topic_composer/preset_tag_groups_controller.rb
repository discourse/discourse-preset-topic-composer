# frozen_string_literal: true

module ::DiscoursePresetTopicComposer
  class PresetTagGroupsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def search_tags_by_tag_group
      tag_group = params[:tag_group]
      tags = TagGroup.visible(guardian).find_by(name: tag_group)&.tags || []
      render json: { tags: tags }
    end
  end
end
