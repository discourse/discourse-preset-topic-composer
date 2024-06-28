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
  init() {
    this._super(...arguments);
  },

  shouldHighlightByURL(url) {
    // case 1 - url does not contain *, e.g. example, it should match exact url "example"
    // case 2 - url starts and ends with *, e.g. *example*, it should match any url containing "example"
    // case 3 - url starts with *, e.g. *example, it should match any url ending with "example"
    // case 4 - url ends with *, e.g. example*, it should match any url starting with "example"

    const startsWithStar = url.startsWith("*");
    const endsWithStar = url.endsWith("*");
    const exactMatch = !startsWithStar && !endsWithStar;

    if (exactMatch) {
      return url === this.router.currentURL;
    }

    if (startsWithStar && endsWithStar) {
      return this.router.currentURL.includes(url.replace(/\*/g, ""));
    }

    if (startsWithStar) {
      return this.router.currentURL.endsWith(url.replace(/\*/g, ""));
    }

    if (endsWithStar) {
      return this.router.currentURL.startsWith(url.replace(/\*/g, ""));
    }

    return false;
  },

  shouldHighlightByCategoryID(categoryId) {
    const isCategoryRoute =
      this.router.currentRoute.localName === "category" &&
      this.router.currentURL.startsWith("/c/");
    if (!isCategoryRoute) {
      return false;
    }

    const currentCategory = Number(this.router.currentURL.split("/").at(-1));
    if (isNaN(currentCategory)) {
      return false;
    }

    return categoryId === currentCategory;
  },

  content: computed("new-topic", function () {
    return this.currentUser.topic_preset_buttons
      .map((b) => ({
        ...b,
        highlightUrls: b.highlightUrls || [],
      }))
      .map((button) => {
        if (
          this.shouldHighlightByCategoryID(button.categoryId) ||
          button.highlightUrls.some((url) => this.shouldHighlightByURL(url))
        ) {
          button.classNames = "is-highlighted";
        }
        return button;
      });
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
