import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";

export default class DropdownButtonsService extends Service {
  @service router;
  @service site;

  @tracked buttons;

  constructor() {
    super(...arguments);
    this.refreshButtons();
  }

  refreshButtons() {
    this.buttons = this.site.topic_preset_buttons
      .map((b) => ({
        ...b,
        highlightUrls: b.highlightUrls || [],
      }))
      .map((button) => {
        if (
          this.#shouldHighlightByCategoryID(button.categoryId) ||
          button.highlightUrls.some((url) =>
            this.#shouldHighlightByURL(url.toLowerCase())
          )
        ) {
          button.classNames = "is-selected";
        }
        return button;
      });
  }

  #shouldHighlightByURL(url) {
    // case 1 - url does not contain *, e.g. example, it should match exact url "example"
    // case 2 - url starts and ends with *, e.g. *example*, it should match any url containing "example"
    // case 3 - url starts with *, e.g. *example, it should match any url ending with "example"
    // case 4 - url ends with *, e.g. example*, it should match any url starting with "example"

    // Do all string comparisons in lowercase.
    // the "url" is alredy in lowercase, but the currentURL is not.
    const currentURL = this.router.currentURL.toLowerCase();

    const startsWithStar = url.startsWith("*");
    const endsWithStar = url.endsWith("*");
    const exactMatch = !startsWithStar && !endsWithStar;

    if (exactMatch) {
      return url === currentURL;
    }

    if (startsWithStar && endsWithStar) {
      return currentURL.includes(url.replace(/\*/g, ""));
    }

    if (startsWithStar) {
      return currentURL.endsWith(url.replace(/\*/g, ""));
    }

    if (endsWithStar) {
      return currentURL.startsWith(url.replace(/\*/g, ""));
    }

    return false;
  }

  #shouldHighlightByCategoryID(categoryId) {
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
  }
}
