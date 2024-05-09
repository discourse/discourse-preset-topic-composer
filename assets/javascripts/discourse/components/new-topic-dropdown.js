import { computed } from "@ember/object";
import { inject as service } from "@ember/service";
import Composer from "discourse/models/composer";
import { getOwner } from "discourse-common/lib/get-owner";
import DropdownSelectBoxComponent from "select-kit/components/dropdown-select-box";

export default DropdownSelectBoxComponent.extend({
  classNames: ["new-topic-dropdown"],
  siteSettings: service(),

  selectKitOptions: {
    icon: "plus",
    showFullTitle: true,
    autoFilterable: false,
    filterable: false,
    showCaret: true,
    none: "topic.create",
  },

  content: computed("new-topic", function () {
    const buttons = JSON.parse(this.siteSettings.button_types) || [];
    const currentUserGroups = this.currentUser?.groups?.flatMap((group) => group.name);

    const available_buttons = [];
    buttons.forEach((button) => {
      if (button.access.trim().length > 0) {
        button.access.trim().split(/(?:,|\s)\s*/).filter((allowed_group) => {
          if (currentUserGroups.includes(allowed_group.trim())) {
            available_buttons.push(button);
          }
        });
      }
      else {
        available_buttons.push(button);
      }
    });
    return available_buttons;
  }),

  actions: {
    onChange(selectedAction) {
      const composerController = getOwner(this).lookup("controller:composer");

      const buttons = JSON.parse(this.siteSettings.button_types);
      const selectedButton = buttons.find((button) => button.id === selectedAction);
      const selectedButtonCategoryId = selectedButton.categoryId > 0 ? selectedButton.categoryId : null;

      const options = {
        action: Composer.CREATE_TOPIC,
        draftKey: Composer.NEW_TOPIC_KEY,
        categoryId: selectedButtonCategoryId ?? this.category?.id ?? null,
        tags: selectedButton.tags.split(/(?:,|\s)\s*/) ?? null,
      };

      composerController.open(options);
    },
  }
});
