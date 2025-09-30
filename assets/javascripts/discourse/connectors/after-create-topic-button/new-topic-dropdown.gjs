import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";
import NewTopicDropdown from "../../components/new-topic-dropdown";

@tagName("")
@classNames("after-create-topic-button-outlet", "new-topic-dropdown")
export default class NewTopicDropdownConnector extends Component {
  <template>
    {{#if this.currentUser}}
      <NewTopicDropdown @category={{this.category}} />
    {{/if}}
  </template>
}
