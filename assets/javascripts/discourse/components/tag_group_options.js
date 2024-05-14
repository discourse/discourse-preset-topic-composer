import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";

export const tagGroupOptions = {
  siteSettings: service(),
  historyStore: service(),
  appEvents: service(),

  selectKitOptions: {
    filterable: true,
  },

  init() {
    this._super(...arguments);
    ajax(
      `topic_composer/tag_by_tag_group/${this.tagGroupOption.tagGroup}.json`
    ).then((result) => (this.content = result.tags));
  },

  content: tracked({ value: [] }),
  value: tracked({ value: null }),
  tagGroupOption: tracked({ value: null }),
  actions: {
    onChange(tagId) {
      this.value = tagId;

      const getTagById = (id) => this.content.find((tag) => tag.id === id);
      if (typeof tagId === "number") {
        this.composer.tag_groups[this.tagGroupOption.tagGroup] = [
          getTagById(tagId).name,
        ];
      } else {
        this.composer.tag_groups[this.tagGroupOption.tagGroup] = tagId.map(
          (tag) => getTagById(tag).name
        );
      }
    },
  },
};
