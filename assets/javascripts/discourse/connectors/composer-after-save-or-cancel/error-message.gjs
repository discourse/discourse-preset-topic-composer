import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import i18n from "discourse-common/helpers/i18n";

export default class ErrorMessage extends Component {
  @service i18n;
  @service appEvents;
  @tracked shouldShowErrorMessage = false;

  constructor() {
    super(...arguments);
    this.appEvents.on(
      "composer:preset-error",
      ({ isOk }) => (this.shouldShowErrorMessage = !isOk)
    );
  }

  <template>
    {{#if this.shouldShowErrorMessage}}
      <i class="missing-input-error-message">
        {{i18n "dialog.error_message"}}
      </i>
    {{/if}}
  </template>
}
