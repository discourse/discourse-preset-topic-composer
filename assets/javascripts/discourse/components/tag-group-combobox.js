import { tracked } from "@glimmer/tracking";
import { computed } from "@ember/object";
import { inject as service } from "@ember/service";
import ComboBox from "select-kit/components/combo-box";

export default ComboBox.extend({
  classNames: ["tag-group-combobox"],
  siteSettings: service(),
  historyStore: service(),

  selectKitOptions: {
    filterable: true,
  },

  content: computed("content", function () {
    const selectedButton = this.historyStore.get("newTopicButtonOptions");
    // TODO: Call ajax to get the tag options, maybe in the moment while opening composer.
    // here can be a good place to call ajax.
    return [
      {
        id: 1,
        title: "First tag",
        description: "First tag description",
      },
      {
        id: 2,
        title: "Second tag",
        description: "Second tag description",
      },
    ];
  }),
  value: tracked({ value: null }),
  actions: {
    onChange(selectedAction) {
      this.value = selectedAction;
    },
  },
});
