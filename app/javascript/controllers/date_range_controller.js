import { Controller } from "@hotwired/stimulus";
import { DateTime } from "luxon";

export default class extends Controller {
  static targets = ["input"];

  connect() {
    this.initialStart = this.inputTarget.dataset.initialStartDate;
    this.initialEnd = this.inputTarget.dataset.initialEndDate;
    this.format = "MMMM d, yyyy";
  }

  validate(event) {
    if (window.isLitepickerActive) {
      console.log("=== DATE RANGE CONTROLLER: LITEPICKER ACTIVE ===");
      // Skip validation if Litepicker is active
      return;
    } else {
      console.log("=== DATE RANGE CONTROLLER: LITEPICKER INACTIVE ===");
    }

    event.preventDefault();
    const value = this.inputTarget.value.trim();
    const [startStr, endStr] = value.split(" - ").map((s) => s.trim());

    const isValid = this.isValidDateRange(startStr, endStr);

    if (!isValid) {
      alert("Please enter a valid date range (e.g., January 1, 2024 - March 15, 2024).")
    }
  }

  isValidDateRange(startStr, endStr) {
    try {
      const start = DateTime.fromFormat(startStr, this.format);
      const end = DateTime.fromFormat(endStr, this.format);

      return start.isValid && end.isValid && start <= end;
    } catch (error) {
      return false;
    }
  }
}
