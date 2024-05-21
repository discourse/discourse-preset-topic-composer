# frozen_string_literal: true

module PageObjects
  module Components
    class PresetComposerInput < PageObjects::Components::Base
      def select_first_with(title)
        input.first.click
        find("li[title='#{title}']").click
      end

      def select_last_with(title)
        input.last.click
        find("li[title='#{title}']").click
      end

      def input
        find(".tag-group_wrapper").find_all(".select-kit.combobox.combo-box")
      end
    end
  end
end
