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

          const { invalidInputs, tagsToAdd } = selectedButton.tagGroups.reduce(
            (result, { tagGroup }) => {
              const composerModel = api.container.lookup("model:composer");
              result.tagsToAdd[tagGroup] = composerModel.tags_to_add[tagGroup];

              const isValid =
                composerModel.tag_groups[tagGroup].component.validate();
              if (!isValid) {
                result.invalidInputs.push(tagGroup);
              }
              return result;
            },
            { invalidInputs: [], tagsToAdd: {} }
          );

          if (invalidInputs.length > 0) {
            const appEvents = api.container.lookup("service:app-events");
            appEvents.trigger("composer:preset-error", { isOk: false });
            return notOk();
          }

          const composerModel = api.container.lookup("model:composer");
          composerModel.tags_to_add = tagsToAdd;
          return ok();
        });
      });
    });
  },
};
