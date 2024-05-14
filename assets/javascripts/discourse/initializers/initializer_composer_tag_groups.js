import { withPluginApi } from "discourse/lib/plugin-api";
import Composer from "discourse/models/composer";

export default {
  name: "preset-topic-composer-initializer",
  initialize() {
    Composer.serializeOnCreate("tag_groups");
    withPluginApi("0.8.12", (api) => {
      api.modifyClass("model:composer", {
        pluginId: "preset-topic-composer-initializer",
        tag_groups: {},
      });
    });
  },
};
