# frozen_string_literal: true

module DiscoursePresetTopicComposer
  module SiteSettings
    class ButtonTypesJsonSchema
      def self.schema
        @schema ||= {
          type: "array",
          uniqueItems: true,
          format: "tabs-top",
          items: {
            title: "Topic type",
            type: "object",
            format: "grid-strict",
            properties: {
              id: {
                title: "Unique ID",
                type: "string",
                description: "i.e. new_question",
              },
              icon: {
                title: "Icon",
                type: "string",
                description: "i.e. question",
              },
              name: {
                title: "Button label",
                type: "string",
                description: "i.e. New question",
              },
              description: {
                title: "Button description",
                type: "string",
                description: "i.e. Ask a new question in selected category.",
              },
              categoryId: {
                title: "Category ID",
                type: "number",
                description:
                  "Enter the category ID this topic should be created in, it will highlight button if in category. Set to 0 to enable all categories.",
                minimum: 0,
              },
              highlightUrls: {
                title: "Url patterns to highlight button",
                type: "array",
                uniqueItems: true,
                items: {
                  type: "string",
                  description:
                    "Use * as wildcard, i.e. /tag/food* to match all urls that start with /tag/food* or *pizza* to match all urls with pizza in the url.",
                },
              },
              tags: {
                title: "Tags",
                type: "string",
                description: "Enter comma, or space separated tags to assign to topic.",
                options: {
                  inputAttributes: {
                    placeholder: "tag1, tag2, tag3",
                  },
                },
              },
              showTags: {
                title: "Show tags",
                type: "boolean",
                description: "Show tags input field.",
                default: false,
                format: "checkbox",
              },
              access: {
                title: "Who can create",
                type: "string",
                description:
                  "Enter comma, or space separated user group ids. Only the members of those groups can create this topic. Leave empty to allow all logged-in users.",
              },
              tagGroups: {
                title: "Tag group dropdowns",
                type: "array",
                uniqueItems: true,
                items: {
                  type: "object",
                  properties: {
                    tagGroup: {
                      title: "Tag group",
                      type: "string",
                      description: "i.e. tag group name",
                    },
                    multi: {
                      title: "Multiple tags",
                      type: "boolean",
                      description: "Allow multiple tags from this group.",
                      default: false,
                      format: "checkbox",
                    },
                    required: {
                      title: "Required",
                      type: "boolean",
                      description: "Require at least one tag from this group.",
                      default: false,
                      format: "checkbox",
                    },
                  },
                },
              },
            },
          },
        }
      end
    end
  end
end
