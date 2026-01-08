import Component from "@ember/component";
import { service } from "@ember/service";
import { classNames, tagName } from "@ember-decorators/component";
import { and } from "discourse/truth-helpers";
import NewTopicDropdown from "../../components/new-topic-dropdown";

@tagName("")
@classNames("after-create-topic-button-outlet", "new-topic-dropdown")
export default class NewTopicDropdownConnector extends Component {
  @service siteSettings;

  get showButton() {
    if (this.siteSettings.show_new_topic_button_only_on_categories) {
      return this.category !== null;
    }
    return true;
  }

  <template>
    {{#if (and this.currentUser this.showButton)}}
      <NewTopicDropdown @category={{this.category}} />
    {{/if}}
  </template>
}
