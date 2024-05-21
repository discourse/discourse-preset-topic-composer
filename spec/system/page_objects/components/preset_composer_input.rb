# frozen_string_literal: true

module PageObjects
  module Components
    class PresetComposerInput < PageObjects::Components::Base

      def select(title)
        input.click
        find("li[title='#{title}']").click
      end

      def input
        @input ||= find(".tag-group_wrapper").find(".select-kit.combobox.combo-box")
      end
    end
  end
end
