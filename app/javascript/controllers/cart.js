// import { Controller } from '@hotwired/stimulus';
// import { Turbo } from '@hotwired/turbo-rails';

// export default class extends Controller {
//   static targets = ["options"]

//   connect() {
//     console.log("Options controller connected");
//   }

//   updateOptions() {
//     const orderableId = this.locationTarget.value;
//     this.fetchAndUpdate(`/update_options?orderable_id=${orderableId}`);
//   }

//   fetchAndUpdate(url) {
//     fetch(url, {
//       method: 'GET',
//       headers: {
//         Accept: 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml',
//         'X-Requested-With': 'XMLHttpRequest',
//         'X-CSRF-Token': this.getMetaContent('csrf-token'),
//         'Cache-Control': 'no-cache',
//       },
//     })
//       .then(response => response.ok ? response.text() : Promise.reject('Response not OK'))
//       .then(html => Turbo.renderStreamMessage(html))
//       .catch(error => console.error('Error:', error));
//   }

//   getMetaContent(name) {
//     return document.querySelector(`meta[name="${name}"]`).getAttribute('content');
//   }
// }