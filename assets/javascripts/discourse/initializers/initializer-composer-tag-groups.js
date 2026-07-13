import { withPluginApi } from "discourse/lib/plugin-api";
import Composer from "discourse/models/composer";

export default {
  name: "preset-topic-composer-initializer",
  initialize() {
    Composer.serializeOnCreate("tags_to_add");

    withPluginApi((api) => {
      api.onPageChange(() =>
        api.container.lookup("service:dropdown-buttons").refreshButtons()
      );

      api.addModelField("composer", "tag_groups", { defaultValue: () => ({}) });
      api.addModelField("composer", "tags_to_add", {
        defaultValue: () => ({}),
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
              const composerModel =
                api.container.lookup("service:composer").model;
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

          const composerModel = api.container.lookup("service:composer").model;
          composerModel.tags_to_add = tagsToAdd;
          return ok();
        });
      });
    });
  },
};
