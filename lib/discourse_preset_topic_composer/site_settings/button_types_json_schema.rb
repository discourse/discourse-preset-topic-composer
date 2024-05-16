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
                  "Enter the category ID this topic should be created in. Set to 0 to enable all categories.",
                minimum: 0,
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
                    },
                    required: {
                      title: "Required",
                      type: "boolean",
                      description: "Require at least one tag from this group.",
                    }
                  },
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
              },
              access: {
                title: "Who can create",
                type: "string",
                description:
                  "Enter comma, or space separated user group names. Only the members of those groups can create this topic. Leave empty to allow all logged-in users.",
              },
            },
          },
        }
      end
    end
  end
end
