import { tracked } from "@glimmer/tracking";
import Component from "@ember/component";
import { service } from "@ember/service";

export default Component.extend({
  router: service(),
  shouldHide: tracked({ value: false }),

  didUpdate() {
    this._super(...arguments);
    if (this.siteSettings.hide_new_topic_button_on_top_menu) {
      const currentRouteName = this.router.currentRouteName;
      const shouldHideButton =
        // Don't use this.siteSettings.top_menu as it is almost always has
        // limited options selected.
        "latest|new|unread|hot|categories|unseen|top|posted|bookmarks|read"
          .split("|")
          .any((p) => currentRouteName === `discovery.${p}`);

      if (shouldHideButton !== this.shouldHide) {
        this.shouldHide = shouldHideButton;
      }
    }
  },
});
