import { withPluginApi } from "discourse/lib/plugin-api";
import Composer from "discourse/models/composer";

export default {
  name: "preset-topic-composer-initializer",
  initialize() {
    Composer.serializeOnCreate("tags_to_add");

    withPluginApi("0.8.12", (api) => {

      api.onPageChange(() =>
        api.container.lookup("service:dropdown-buttons").refreshButtons()
      );

      api.modifyClass("model:composer", {
        pluginId: "preset-topic-composer-initializer",
        tag_groups: {},
        tags_to_add: {},
      });
      api.composerBeforeSave(() => {
        return new Promise((ok, notOk) => {
          const historyStore = api.container.lookup("service:history-store");
          const selectedButton = historyStore.get("newTopicButtonOptions");

          if (!selectedButton?.tagGroups) {
            return ok();
          }
          const composerModel = api.container.lookup("model:composer");
          let invalidInputs = [];
          for (const tagGroupInput of Object.values(composerModel.tag_groups)) {
            const isValid = tagGroupInput.component.validate();
            if (!isValid) {
              invalidInputs.push(tagGroupInput.component.tagGroupName);
            }
          }

          if (invalidInputs.length > 0) {
            const appEvents = api.container.lookup("service:app-events");
            appEvents.trigger("composer:preset-error", { isOk: false });
            return notOk();
          }

          return ok();
        });
      });
    });
  },
};
