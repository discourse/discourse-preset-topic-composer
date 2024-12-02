import Component from "@ember/component";
import { service } from "@ember/service";
import { classNames } from "@ember-decorators/component";

@classNames("tag-group_wrapper")
export default class TagGroupCombobox extends Component {
  @service historyStore;
  @service appEvents;

  init() {
    super.init(...arguments);

    const composerHTML = document.querySelector(".composer-fields");
    const selectedButton = this.historyStore.get("newTopicButtonOptions");
    const shouldShowTags = selectedButton?.showTags || false;
    if (!shouldShowTags) {
      composerHTML.classList.add("hide-tag");
    }
    this.appEvents.on("topic:created", () => {
      this.historyStore.set("newTopicButtonOptions", null);
    });
    this.appEvents.on("draft:destroyed", () => {
      this.historyStore.set("newTopicButtonOptions", null);
    });
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    const composerHTML = document.querySelector(".composer-fields");
    composerHTML.classList.remove("hide-tag");
  }

  get tagGroupList() {
    const selectedButton = this.historyStore.get("newTopicButtonOptions");
    return selectedButton?.tagGroups || [];
  }
}
