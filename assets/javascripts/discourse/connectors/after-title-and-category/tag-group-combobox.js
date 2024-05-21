import Component from "@ember/component";
import { inject as service } from "@ember/service";

export default Component.extend({
  historyStore: service(),
  classNames: ["tag-group_wrapper"],
  init() {
    this._super(...arguments);
    const composerHTML = document.querySelector(".composer-fields");
    const selectedButton = this.historyStore.get("newTopicButtonOptions");
    const shouldShowTags = selectedButton?.showTags || false;
    if (!shouldShowTags) {
      composerHTML.classList.add("hide-tag");
    }
  },
  get tagGroupList() {
    const selectedButton = this.historyStore.get("newTopicButtonOptions");
    return selectedButton?.tagGroups || [];
  },

  willDestroyElement() {
    this._super(...arguments);
    const composerHTML = document.querySelector(".composer-fields");
    composerHTML.classList.remove("hide-tag");
    this.historyStore.set("newTopicButtonOptions", null);
  },
});
