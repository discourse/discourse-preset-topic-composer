import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
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
  composer: tracked({ value: {} }),
  isInvalid: tracked({ value: false }),
  required: tracked({ value: false }),

  selectKitOptions: {
    filterable: true,
  },

  init() {
    this._super(...arguments);
    ajax(
      `/topic_composer/tag_by_tag_group/${encodeURIComponent(
        this.tagGroupName
      )}.json`
    ).then((result) => (this.content = result.tags));

    this.composer.tag_groups[this.tagGroupName] = {
      component: this,
    };
    const selectedButton = this.historyStore.get("newTopicButtonOptions");
    this.value = selectedButton.tagGroups.find(
      (tagGroup) => tagGroup?.value && tagGroup.tagGroup === this.tagGroupName
    )?.value;

    this.appEvents.on("composer:created-post", () => {
      delete this.composer.tags_to_add[this.tagGroupName];
      delete this.composer.tag_groups[this.tagGroupName];
    });
  },

  // used by initializer-composer-tag-groups.js
  validate() {
    if (this.required && !this.value) {
      this.isInvalid = true;
      return false;
    }
    return true;
  },

  actions: {
    onChange(tagId) {
      this.value = tagId;
      this.isInvalid = false;

      const getTagById = (id) => this.content.find((tag) => tag.id === id);
      if (typeof tagId === "number") {
        this.composer.tags_to_add[this.tagGroupName] = [getTagById(tagId).name];
      } else {
        this.composer.tags_to_add[this.tagGroupName] = tagId.map(
          (tag) => getTagById(tag).name
        );
      }

      const selectedButton = this.historyStore.get("newTopicButtonOptions");
      for (const tagGroup of selectedButton.tagGroups) {
        if (tagGroup.tagGroup === this.tagGroupName) {
          tagGroup.value = this.value;
          break;
        }
      }
      this.historyStore.set("newTopicButtonOptions", selectedButton);
    },
  },
};
