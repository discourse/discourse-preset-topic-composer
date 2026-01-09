import Component from "@ember/component";
import { service } from "@ember/service";
import { classNames, tagName } from "@ember-decorators/component";
import { and, notEq } from "discourse/truth-helpers";
import NewTopicDropdown from "../../components/new-topic-dropdown";

@tagName("")
@classNames("after-create-topic-button-outlet", "new-topic-dropdown")
export default class NewTopicDropdownConnector extends Component {
  @service siteSettings;

  <template>
    {{#if
      (and
        this.currentUser
        (if
          this.siteSettings.show_new_topic_button_only_on_categories
          (notEq this.category null)
          true
        )
      )
    }}
      <NewTopicDropdown @category={{this.category}} />
    {{/if}}
  </template>
}
