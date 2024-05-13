import Component from "@ember/component";
import { inject as service } from "@ember/service";

export default Component.extend({
  historyStore: service(),

  get tagGroupList() {
    const selectedButton = this.historyStore.get("newTopicButtonOptions");
    return selectedButton?.tagGroups || [];
  },
});
