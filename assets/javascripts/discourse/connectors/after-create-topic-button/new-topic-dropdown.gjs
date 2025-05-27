import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";
import { and, not } from "truth-helpers";
import newTopicDropdown from "../../components/new-topic-dropdown";

@tagName("")
@classNames("after-create-topic-button-outlet", "new-topic-dropdown")
export default class NewTopicDropdown extends Component {
  <template>
    {{#if (and this.currentUser (not this.createTopicDisabled))}}
      {{newTopicDropdown category=this.category}}
    {{/if}}
  </template>
}
