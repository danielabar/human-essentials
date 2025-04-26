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
    event.preventDefault();
    try {
      const value = this.inputTarget.value.trim();
      const [startStr, endStr] = value.split(" - ").map((s) => s.trim());

      const start = DateTime.fromFormat(startStr, this.format);
      const end = DateTime.fromFormat(endStr, this.format);

      const isValid = start.isValid && end.isValid && start <= end;

      if (!isValid) {
        alert(
          "Please enter a valid date range (e.g., January 1, 2024 - March 15, 2024)."
        );
      }
    } catch (error) {
      alert(
        "Please enter a valid date range (e.g., January 1, 2024 - March 15, 2024)."
      );
    }
  }
}
