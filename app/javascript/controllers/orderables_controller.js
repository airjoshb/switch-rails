import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  updateNotes(event) {
    const orderableId = event.target.dataset.orderablesOrderableIdParam;
    const selects = Array.from(this.element.querySelectorAll('select.bread-choice-select'));
    selects.sort((a, b) => {
      const prefA = parseInt(a.dataset.orderablesPrefIdxParam, 10);
      const prefB = parseInt(b.dataset.orderablesPrefIdxParam, 10);
      if (prefA !== prefB) return prefA - prefB;
      const unitA = parseInt(a.dataset.orderablesUnitIdxParam, 10);
      const unitB = parseInt(b.dataset.orderablesUnitIdxParam, 10);
      return unitA - unitB;
    });
    const selections = selects.map(select => select.value).join(';');

    fetch(`/orderables/${orderableId}/update_notes`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json"
      },
      body: JSON.stringify({ notes: selections })
    })
    .then(response => {
      if (!response.ok) throw new Error("Network error");
    })
    .catch(error => {
      console.error(error);
    });
  }
}