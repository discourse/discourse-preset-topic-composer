import { withPluginApi } from "discourse/lib/plugin-api";
import Composer from "discourse/models/composer";
import I18n from "I18n";

export default {
  name: "preset-topic-composer-initializer",
  initialize() {
    Composer.serializeOnCreate("tag_groups");
    withPluginApi("0.8.12", (api) => {
      api.modifyClass("model:composer", {
        pluginId: "preset-topic-composer-initializer",
        tag_groups: {},
      });
      api.composerBeforeSave(() => {
        return new Promise((ok, notOk) => {
          const historyStore = api.container.lookup("service:history-store");
          const selectedButton = historyStore.get("newTopicButtonOptions");

          if (!selectedButton?.tagGroups) {
            return ok();
          }

          const requiredTagGroups = selectedButton.tagGroups.filter(
            (tagGroup) => tagGroup?.required
          );

          if (requiredTagGroups.length === 0) {
            return ok();
          }

          const composerModel = api.container.lookup("model:composer");
          const filledTagGroups = composerModel.tag_groups;

          let missingTagGroupsNames = [];
          for (const { tagGroup: name } of requiredTagGroups) {
            if (filledTagGroups[name].value.length > 0) {
              continue; // tag group is filled and has _something_ in it
            } else {
              missingTagGroupsNames.push(filledTagGroups[name]);
            }
          }
          if (missingTagGroupsNames.length > 0) {
            for (const tagGroup of missingTagGroupsNames) {
              tagGroup.component.invalidate();
            }
            const dialog = api.container.lookup("service:dialog");
            dialog.alert(I18n.t("dialog.error_message"));
            return notOk();
          }

          ok();
        });
      });
    });
  },
};
