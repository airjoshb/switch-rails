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
  updatePrice() {
    let variationId = "";
    if (this.hasFrequencyTarget) {
      variationId = this.frequencyTarget.value;
    } else {
      const hiddenFreq = this.element.querySelector('input[data-recurring-variation-target="frequency"]');
      if (hiddenFreq) variationId = hiddenFreq.value;
    }

    // Find the variation
    let variation = this.variationsValue.find(v => String(v.id) === String(variationId));
    if (variation && this.hasPriceTarget) {
      // Assuming amount is in cents
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