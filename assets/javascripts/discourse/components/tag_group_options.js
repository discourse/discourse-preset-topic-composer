import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";

export const tagGroupOptions = {
  classNames: ["tag-group-input"],
  classNameBindings: ["isInvalid:tag-group-input--invalid"],
  siteSettings: service(),
  historyStore: service(),
  appEvents: service(),

  content: tracked({ value: [] }),
  value: tracked({ value: null }),
  tagGroupName: tracked({ value: null }),
  isInvalid: tracked({ value: false }),

  selectKitOptions: {
    filterable: true,
  },

  init() {
    this._super(...arguments);
    ajax(
      `topic_composer/tag_by_tag_group/${this.tagGroupName}.json`
    ).then((result) => (this.content = result.tags));
    for (const option of this.selectKitOptions) {
      if ("translatedNone" in option) {
        option.translatedNone = this.tagGroupName;
      }
    }
    this.composer.tag_groups[this.tagGroupName] = {
      value: [],
      component: this
    };
  },


  invalidate() {
    this.isInvalid = true;
  },

  actions: {
    onChange(tagId) {
      this.value = tagId;
      this.isInvalid = false;

      const getTagById = (id) => this.content.find((tag) => tag.id === id);
      if (typeof tagId === "number") {
        this.composer.tag_groups[this.tagGroupName].value = [
          getTagById(tagId).name,
        ];
      } else {
        this.composer.tag_groups[this.tagGroupName].value = tagId.map(
          (tag) => getTagById(tag).name
        );
      }
    },
  },
};
