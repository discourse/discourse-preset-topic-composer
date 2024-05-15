import { computed } from "@ember/object";
import { getOwner } from "@ember/owner";
import { inject as service } from "@ember/service";
import Composer from "discourse/models/composer";
import DropdownSelectBoxComponent from "select-kit/components/dropdown-select-box";

export default DropdownSelectBoxComponent.extend({
  classNames: ["new-topic-dropdown"],
  siteSettings: service(),
  historyStore: service(),

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
    const currentUserGroups = this.currentUser?.groups?.flatMap(
      (group) => group.name
    );

    return buttons.filter((button) => {
      const trimmedAccess = button.access.trim();
      if (trimmedAccess.length === 0) {
        return true;
      }

      const allowedGroups = trimmedAccess.split(/(?:,|\s)\s*/);
      return allowedGroups.some((group) =>
        currentUserGroups.includes(group.trim())
      );
    });
  }),

  actions: {
    onChange(selectedAction) {
      const composerController = getOwner(this).lookup("controller:composer");
      const buttons = JSON.parse(this.siteSettings.button_types);
      const selectedButton = buttons.find(
        (button) => button.id === selectedAction
      );

      this.historyStore.set("newTopicButtonOptions", selectedButton);

      const selectedButtonCategoryId =
        selectedButton.categoryId > 0 ? selectedButton.categoryId : null;

      const tags = selectedButton.tags.split(/(?:,|\s)\s*/).filter(Boolean); // remove [''] from tags;
      const options = {
        action: Composer.CREATE_TOPIC,
        draftKey: Composer.NEW_TOPIC_KEY,
        categoryId: selectedButtonCategoryId ?? this.category?.id ?? null,
        tags,
      };

      composerController.open(options);
    },
  },
});
