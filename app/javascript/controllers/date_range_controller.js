import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input"];

  connect() {
    this.initialStart = this.inputTarget.dataset.initialStartDate;
    this.initialEnd = this.inputTarget.dataset.initialEndDate;
  }

  validate(event) {
    const value = this.inputTarget.value;
    const dateRangePattern =
      /^[A-Za-z]+\s+\d{1,2},\s+\d{4}\s+-\s+[A-Za-z]+\s+\d{1,2},\s+\d{4}$/;

    if (!dateRangePattern.test(value)) {
      event.preventDefault();
      alert(
        "Please enter a valid date range (e.g., January 1, 2024 - March 15, 2024)."
      );
    }
  }
}
