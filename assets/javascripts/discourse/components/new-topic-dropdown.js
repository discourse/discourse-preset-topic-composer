import { computed } from "@ember/object";
import { getOwner } from "@ember/owner";
import { inject as service } from "@ember/service";
import Composer from "discourse/models/composer";
import DropdownSelectBoxComponent from "select-kit/components/dropdown-select-box";

export default DropdownSelectBoxComponent.extend({
  classNames: ["new-topic-dropdown"],
  siteSettings: service(),
  historyStore: service(),
  router: service(),

  selectKitOptions: {
    icon: "plus",
    showFullTitle: true,
    autoFilterable: false,
    filterable: false,
    showCaret: true,
    none: "topic.create",
  },

  getCurrentCategory() {
    return Number(this.router.currentURL.split("/").at(-1));
  },

  init() {
    this._super(...arguments);
    const isCategoryRoute =
      this.router.currentRoute.localName === "category" &&
      this.router.currentURL.startsWith("/c/") &&
      isNaN(this.getCurrentCategory()) === false;

    if (!isCategoryRoute) {
      return;
    }

    const currentCategory = this.getCurrentCategory();
    const buttonsToHighlight = this.currentUser.topic_preset_buttons.filter(
      (button) => button.categoryId === currentCategory
    );

    for (const button of buttonsToHighlight) {
      // highlight button
      console.log(button);
      // document.querySelector(`[data-value="${button.id}"]`).classList.add("is-highlighted");
    }
  },

  content: computed("new-topic", function () {
    return this.currentUser.topic_preset_buttons;
  }),

  actions: {
    onChange(selectedAction) {
      const composerController = getOwner(this).lookup("controller:composer");
      let selectedButton = this.historyStore.get("newTopicButtonOptions");

      if (!selectedButton || selectedAction !== selectedButton.id) {
        const buttons = JSON.parse(this.siteSettings.button_types);
        selectedButton = buttons.find((button) => button.id === selectedAction);
        this.historyStore.set("newTopicButtonOptions", selectedButton);
      }

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
