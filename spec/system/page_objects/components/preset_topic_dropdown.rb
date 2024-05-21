# frozen_string_literal: true

module PageObjects
  module Components
    class PresetTopicDropdown < PageObjects::Components::Base
      def select(title)
        button.click
        find("li[title='#{title}']").click
      end

      def button
        @button ||= find(".select-kit.single-select.dropdown-select-box .select-kit-header")
      end
    end
  end
end
