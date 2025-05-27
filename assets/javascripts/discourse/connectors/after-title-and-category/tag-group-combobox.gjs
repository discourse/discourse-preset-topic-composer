import Component from "@ember/component";
import { concat, hash } from "@ember/helper";
import { service } from "@ember/service";
import { classNames } from "@ember-decorators/component";
import { i18n } from "discourse-i18n";
import tagGroupCombobox from "../../components/tag-group-combobox";
import tagGroupMultiselect from "../../components/tag-group-multiselect";

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

  <template>
    {{#if this.currentUser.can_create_topic}}
      {{#each this.tagGroupList as |tagGroupOption|}}
        {{#if tagGroupOption.multi}}
          {{tagGroupMultiselect
            composer=@outletArgs.model
            tagGroupName=tagGroupOption.tagGroup
            required=tagGroupOption.required
            options=(hash
              translatedNone=(if
                tagGroupOption.required
                (concat "*" (i18n "composer.select") tagGroupOption.tagGroup)
                (concat (i18n "composer.select") tagGroupOption.tagGroup)
              )
            )
          }}
        {{else}}
          {{tagGroupCombobox
            composer=@outletArgs.model
            tagGroupName=tagGroupOption.tagGroup
            required=tagGroupOption.required
            options=(hash
              translatedNone=(if
                tagGroupOption.required
                (concat "*" (i18n "composer.select") tagGroupOption.tagGroup)
                (concat (i18n "composer.select") tagGroupOption.tagGroup)
              )
            )
          }}
        {{/if}}
      {{/each}}
    {{/if}}
  </template>
}
