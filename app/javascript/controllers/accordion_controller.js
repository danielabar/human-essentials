import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="accordion"
// Capture the form in the closed section and wait to submit it when the new section is opened.
export default class extends Controller {
  connect() {
    this.formToSubmit = null; // Keep track of the form to submit when a new section opens
    this.isNewSectionOpening = false; // Flag to determine if a new section is being opened
    this.previousEventWasHide = false; // Track if the previous event was a 'hidden' event

    this.element.addEventListener(
      "hidden.bs.collapse",
      this.onSectionHidden.bind(this)
    );
    this.element.addEventListener(
      "shown.bs.collapse",
      this.onSectionShown.bind(this)
    );
  }

  disconnect() {
    this.element.removeEventListener("hidden.bs.collapse");
    this.element.removeEventListener("shown.bs.collapse");
  }

  onSectionHidden(event) {
    console.log("=== SECTION HIDDEN", event);
    const form = event.target.querySelector("form");

    // Save the form to submit later if and when a new section opens
    if (form) {
      this.formToSubmit = form;
    }

    // Set the flag to indicate the previous event was a hide event
    this.previousEventWasHide = true;

    // Check if the user explicitly closed the section by waiting for the shown event
    setTimeout(() => {
      if (!this.isNewSectionOpening) {
        // This means the user explicitly closed the section without opening a new section
        console.log("=== SECTION EXPLICITLY CLOSED BY THE USER AND NOTHING NEW OPENED");
        if (this.formToSubmit) {
          const hiddenInput = document.createElement("input");
          hiddenInput.type = "hidden";
          hiddenInput.name = "open_section_override";
          hiddenInput.value = "all_closed";

          this.formToSubmit.appendChild(hiddenInput);
          this.submitForm();
        }
      }
    }, 300);
  }

  // Called when an accordion section is expanded
  onSectionShown(event) {
    console.log("=== SECTION SHOWN", event);
    // Check if this is a show event without a preceding hide event
    if (!this.previousEventWasHide) {
      console.log("=== SHOW EVENT WITHOUT PRECEDING HIDE EVENT");
      // TODO: 4504 - anything special to do here?
    }

    // Flag that a new section is opening
    this.isNewSectionOpening = true;

    // Submit the form from the previously closed section (if any)
    if (this.formToSubmit) {
      console.log(`=== ADDING OPEN_SECTION_OVERRIDE HIDDEN INPUT TO FORM, VALUE: ${event.target.id}`);
      const hiddenInput = document.createElement("input");
      hiddenInput.type = "hidden";
      hiddenInput.name = "open_section_override";
      hiddenInput.value = event.target.id;

      this.formToSubmit.appendChild(hiddenInput);
      this.submitForm();
    }

    // Reset the flag after a small delay to account for user interactions
    setTimeout(() => {
      this.isNewSectionOpening = false;
      this.previousEventWasHide = false; // Reset the flag after the shown event
    }, 300);
  }

  submitForm() {
    const hasSubmitButton = this.formToSubmit.querySelector('[type="submit"], button[type="submit"]');

    if (hasSubmitButton) {
      console.log("=== SUBMITTING FORM");
      // this.disableAccordionButtons();
      this.formToSubmit.requestSubmit();
    } else {
      console.log("=== FORM HAS NO SUBMIT BUTTON");
    }
    this.formToSubmit = null;
  }

  // TODO: 4504 if get scroll preservation working and it requires turbo-frames, then the entire page doesn't reload
  // which means we need to detect a re-render of just the accordion section and then remove this disabled/saving
  disableAccordionButtons() {
    const buttons = document.querySelectorAll(".accordion-button");
    buttons.forEach(button => {
      button.disabled = true;
      button.classList.add("saving");
    });
  }
}
