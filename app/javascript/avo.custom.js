import Trix from "trix"

addHeadingAttributes()

document.addEventListener("trix-initialize", function (event) {
    new RichText(event.target)
}, { once: true })

document.addEventListener("trix-action-invoke", function (event) {
  if (event.actionName == "x-horizontal-rule") insertHorizontalRule()

  function insertHorizontalRule() {
    event.target.editor.insertAttachment(buildHorizontalRule())
  }

  function buildHorizontalRule() {
    return new Trix.Attachment({ content: "<hr>", contentType: "application/vnd.rubyonrails.horizontal-rule.html" })
  }
}, { once: true })

class RichText {
  constructor(element) {
    this.element = element

    this.insertHeadingElements()
    this.insertDividerElements()
  }

  insertHeadingElements() {
    this.insertHeadingDialog()
  }

  insertHeadingDialog() {
    this.buttonGroupBlockTools.insertAdjacentHTML("beforeend", this.dialogHeadingTemplate)
  }

  insertDividerElements() {
    this.buttonGroupBlockTools.insertAdjacentHTML("beforeend", this.horizontalButtonTemplate)
  }

  get buttonGroupBlockTools() {
    return this.toolbarElement.querySelector("[data-trix-button-group=block-tools]")
  }

  get toolbarElement() {
    return this.element.toolbarElement
  }

  get horizontalButtonTemplate() {
    return '<button type="button" class="trix-button trix-button--icon trix-button--icon-horizontal-rule" data-trix-action="x-horizontal-rule" tabindex="-1" title="Divider">Divider</button>'
  }

  get dialogHeadingTemplate() {
    return `
    <button type="button" class="trix-button" data-trix-attribute="heading2">H2</button>
    <button type="button" class="trix-button" data-trix-attribute="heading3">H3</button>
    <button type="button" class="trix-button" data-trix-attribute="heading4">H4</button>
    `
  }

}

function addHeadingAttributes() {
  Array.from(["h1", "h2", "h3", "h4"]).forEach((tagName, i) => {
    Trix.config.blockAttributes[`heading${(i + 1)}`] = { tagName: tagName, terminal: true, breakOnReturn: true, group: false }
  })
}