import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = ["deliveryMethod", "frequency", "submit", "price"]
  static values = { variations: Array }


  connect() {
    this.updatePrice();
    this.checkReady();
  }

  checkReady() {
    // Try to get value from select or hidden input for delivery method
    let delivery = "";
    if (this.hasDeliveryMethodTarget) {
      delivery = this.deliveryMethodTarget.value;
    } else {
      const hiddenDelivery = this.element.querySelector('input[data-recurring-variation-target="deliveryMethod"]');
      if (hiddenDelivery) delivery = hiddenDelivery.value;
    }

    // Try to get value from select or hidden input for frequency
    let freq = "";
    if (this.hasFrequencyTarget) {
      freq = this.frequencyTarget.value;
    } else {
      const hiddenFreq = this.element.querySelector('input[data-recurring-variation-target="frequency"]');
      if (hiddenFreq) freq = hiddenFreq.value;
    }

    // Enable button only if both have a value
    this.submitTarget.disabled = !(delivery && freq);
    this.updatePrice();
    // Optionally, toggle a class for styling
    if (delivery && freq) {
      this.submitTarget.classList.remove("disable-action");
    } else {
      this.submitTarget.classList.add("disable-action");
    }
  }

  onDeliveryChange(event) {
    // Get the selected delivery method
    const delivery = event.target.value;

    // Find all frequency options (assumes select, adjust if using hidden input)
    if (this.hasFrequencyTarget) {
      const frequencySelect = this.frequencyTarget;
      const currentValue = frequencySelect.value;

      // Remove all options except the "Choose" option
      const chooseOption = frequencySelect.querySelector('option[value=""]');
      frequencySelect.innerHTML = "";
      if (chooseOption) frequencySelect.appendChild(chooseOption);

      // Add only options that match the selected delivery method
      this.variationsValue.forEach(v => {
        let deliveryMatch = false;
        if (delivery === "ship" && v.shippable) deliveryMatch = true;
        if (delivery === "delivery" && v.deliverable) deliveryMatch = true;
        if (delivery === "pickup" && v.pickupable) deliveryMatch = true;
        if (deliveryMatch) {
          // Build the label as in your view
          let freqLabel = v.interval_count === 1
            ? v.interval.charAt(0).toUpperCase() + v.interval.slice(1)
            : `${v.interval_count} ${v.interval.charAt(0).toUpperCase() + v.interval.slice(1)}s`;
          const option = document.createElement("option");
          option.value = v.id;
          option.textContent = `Every ${freqLabel}`;
          frequencySelect.appendChild(option);
        }
      });

      // If the current value is not valid for the new delivery method, reset to ""
      const validOption = Array.from(frequencySelect.options).some(opt => opt.value === currentValue);
      frequencySelect.value = validOption ? currentValue : "";

      // Trigger price and button update
      this.checkReady();
    }
  }

  updatePrice() {
  // Get selected delivery method
  let delivery = "";
  if (this.hasDeliveryMethodTarget) {
    delivery = this.deliveryMethodTarget.value;
  } else {
    const hiddenDelivery = this.element.querySelector('input[data-recurring-variation-target="deliveryMethod"]');
    if (hiddenDelivery) delivery = hiddenDelivery.value;
  }

  // Get selected frequency (variation id)
  let variationId = "";
  if (this.hasFrequencyTarget) {
    variationId = this.frequencyTarget.value;
  } else {
    const hiddenFreq = this.element.querySelector('input[data-recurring-variation-target="frequency"]');
    if (hiddenFreq) variationId = hiddenFreq.value;
  }

  // Find the variation that matches BOTH delivery and frequency
  let variation = this.variationsValue.find(v => {
    // Delivery method match
    let deliveryMatch = false;
    if (delivery === "ship" && v.shippable) deliveryMatch = true;
    if (delivery === "delivery" && v.deliverable) deliveryMatch = true;
    if (delivery === "pickup" && v.pickupable) deliveryMatch = true;
    // Frequency match (variation id)
    return deliveryMatch && String(v.id) === String(variationId);
  });

  // If not found, fall back to frequency only
  if (!variation) {
    variation = this.variationsValue.find(v => String(v.id) === String(variationId));
  }

  if (variation && this.hasPriceTarget) {
    this.priceTarget.textContent = this.formatPrice(variation.amount);
  } else if (this.hasPriceTarget) {
    this.priceTarget.textContent = "";
  }
}
  formatPrice(amount) {
    // Adjust this if your currency is not USD or not in cents
    return `$${(amount / 100).toFixed(2)}`;
  }

  addToCart(event) {
    event.preventDefault();

    let delivery = "";
    if (this.hasDeliveryMethodTarget) {
      delivery = this.deliveryMethodTarget.value;
    } else {
      const hiddenDelivery = this.element.querySelector('input[data-recurring-variation-target="deliveryMethod"]');
      if (hiddenDelivery) delivery = hiddenDelivery.value;
    }

    let variationId = "";
    if (this.hasFrequencyTarget) {
      variationId = this.frequencyTarget.value;
    } else {
      const hiddenFreq = this.element.querySelector('input[data-recurring-variation-target="frequency"]');
      if (hiddenFreq) variationId = hiddenFreq.value;
    }

    // Find the variation that matches both delivery and frequency
    let matchedVariation = this.variationsValue.find(v => {
      // Delivery method match
      let deliveryMatch = false;
      if (delivery === "ship" && v.shippable) deliveryMatch = true;
      if (delivery === "delivery" && v.deliverable) deliveryMatch = true;
      if (delivery === "pickup" && v.pickupable) deliveryMatch = true;

      // Frequency match
      return deliveryMatch && String(v.id) === String(variationId);
    });

    // If not found, prefer frequency (variationId)
    let finalVariationId = matchedVariation ? matchedVariation.id : variationId;

    const productId = this.submitTarget.dataset.recurringVariationProductId;

    if (!delivery || !finalVariationId) return;

    const formData = new FormData();
    formData.append("id", finalVariationId);
    formData.append("delivery_method", delivery);
    formData.append("product_id", productId);
    formData.append("quantity", 1);

    fetch("/cart/add", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/html,application/xhtml+xml,application/xml"
      },
      body: formData
    })
    .then(response => {
      if (!response.ok) throw new Error("Network error");
      window.location.href = "/cart";
    })
    .catch(error => {
      console.error(error);
    });
  }
}