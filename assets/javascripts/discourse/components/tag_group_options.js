import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import I18n from "I18n";

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
    ajax(`topic_composer/tag_by_tag_group/${this.tagGroupName}.json`).then(
      (result) => (this.content = result.tags)
    );
    this.refreshText();
    this.composer.tag_groups[this.tagGroupName] = {
      value: [],
      component: this,
    };
  },

  invalidate() {
    this.isInvalid = true;
    this.refreshText();
  },
  refreshText() {
    for (const option of this.selectKitOptions) {
      if ("translatedNone" in option) {
        option.translatedNone = this.isInvalid
          ? I18n.t("composer.error_message", {
              tag_group_name: this.tagGroupName,
            })
          : this.tagGroupName;
      }
    }
  },
  actions: {
    onChange(tagId) {
      this.value = tagId;
      this.isInvalid = false;
      this.refreshText();

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
