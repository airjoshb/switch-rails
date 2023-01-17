// import Trix from 'trix';

// window.Trix = Trix; // Don't need to bind to the window, but useful for debugging.
// Trix.config.toolbar.getDefaultHTML = toolbarDefaultHTML;

// addHeadingAttributes()

// // trix-before-initialize runs too early.
// // We only need to do this once. Everything after initialize will get the
// // defaultHTML() call automatically.
// document.addEventListener('trix-initialize', updateToolbars, { once: true });

// function updateToolbars(event) {
//   const toolbars = document.querySelectorAll('trix-toolbar');
//   const html = Trix.config.toolbar.getDefaultHTML();
//   toolbars.forEach((toolbar) => (toolbar.innerHTML = html));
// }

// document.addEventListener("trix-action-invoke", function (event) {
//   if (event.actionName == "x-horizontal-rule") insertHorizontalRule()

//   function insertHorizontalRule() {
//     event.target.editor.insertAttachment(buildHorizontalRule())
//   }

//   function buildHorizontalRule() {
//     return new Trix.Attachment({ content: "<hr>", contentType: "application/vnd.rubyonrails.horizontal-rule.html" })
//   }
// })


// const {lang} = Trix.config;
// /**
//  * This is the default Trix toolbar. Feel free to change / manipulate it how you would like.
//  * see https://github.com/basecamp/trix/blob/main/src/trix/config/toolbar.coffee
//  */
// function toolbarDefaultHTML() {
//   const {lang} = Trix.config;
//   return `
//   <div class="trix-button-row">
//      <span class="trix-button-group trix-button-group--text-tools" data-trix-button-group="text-tools">
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-bold" data-trix-attribute="bold" data-trix-key="b" title="${lang.bold}" tabindex="-1">#{lang.bold}</button>
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-italic" data-trix-attribute="italic" data-trix-key="i" title="${lang.italic}" tabindex="-1">${lang.italic}</button>
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-strike" data-trix-attribute="strike" title="${lang.strike}" tabindex="-1">${lang.strike}</button>
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-horizontal-rule" data-trix-action="x-horizontal-rule" title="horzontal rule" tabindex="-1">${lang.horizontal_rule}</button>
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-link" data-trix-attribute="href" data-trix-action="link" data-trix-key="k" title="${lang.link}" tabindex="-1">${lang.link}</button>
//      </span>
//      <span class="trix-button-group trix-button-group--block-tools" data-trix-button-group="block-tools">
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-heading-1" data-trix-attribute="heading1" title="${lang.heading1}" tabindex="-1">${lang.heading1}</button>
//        <button type="button" class="trix-button" data-trix-attribute="heading2" title="h2">H2</button>
//        <button type="button" class="trix-button" data-trix-attribute="heading3" title="h3">H3</button>
//        <button type="button" class="trix-button" data-trix-attribute="heading4" title="h4">H4</button>
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-quote" data-trix-attribute="quote" title="${lang.quote}" tabindex="-1">${lang.quote}</button>
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-bullet-list" data-trix-attribute="bullet" title="${lang.bullets}" tabindex="-1">${lang.bullets}</button>
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-number-list" data-trix-attribute="number" title="${lang.numbers}" tabindex="-1">${lang.numbers}</button>
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-decrease-nesting-level" data-trix-action="decreaseNestingLevel" title="${lang.outdent}" tabindex="-1">${lang.outdent}</button>
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-increase-nesting-level" data-trix-action="increaseNestingLevel" title="${lang.indent}" tabindex="-1">${lang.indent}</button>
//      </span>
//      <span class="trix-button-group trix-button-group--file-tools" data-trix-button-group="file-tools">
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-attach" data-trix-action="attachFiles" title="${lang.attachFiles}" tabindex="-1">${lang.attachFiles}</button>
//      </span>
//      <span class="trix-button-group trix-button-group--history-tools" data-trix-button-group="history-tools">
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-undo" data-trix-action="undo" data-trix-key="z" title="${lang.undo}" tabindex="-1">${lang.undo}</button>
//        <button type="button" class="trix-button trix-button--icon trix-button--icon-redo" data-trix-action="redo" data-trix-key="shift+z" title="${lang.redo}" tabindex="-1">${lang.redo}</button>
//      </span>
//    </div>
//    <div class="trix-dialogs" data-trix-dialogs>
//      <div class="trix-dialog trix-dialog--link" data-trix-dialog="href" data-trix-dialog-attribute="href">
//        <div class="trix-dialog__link-fields">
//          <input type="url" name="href" class="trix-input trix-input--dialog" placeholder="${lang.urlPlaceholder}" aria-label="${lang.url}" required data-trix-input>
//          <div class="trix-button-group">
//            <input type="button" class="trix-button trix-button--dialog" value="${lang.link}" data-trix-method="setAttribute">
//            <input type="button" class="trix-button trix-button--dialog" value="${lang.unlink}" data-trix-method="removeAttribute">
//          </div>
//        </div>
//      </div>
//    </div>
// `;
// }

// function addHeadingAttributes() {
//   Array.from(["h1", "h2", "h3", "h4"]).forEach((tagName, i) => {
//     Trix.config.blockAttributes[`heading${(i + 1)}`] = { tagName: tagName, terminal: true, breakOnReturn: true, group: false }
//   })
// }

import Trix from "trix"

addHeadingAttributes()
addForegroundColorAttributes()
addBackgroundColorAttributes()

document.addEventListener("trix-initialize", function (event) {
    new RichText(event.target)
}, { once: true })

document.addEventListener("trix-action-invoke", function (event) {
  if (event.actionName == "x-horizontal-rule") insertHorizontalRule()

  function insertHorizontalRule() {
    event.target.editor.insertAttachment(buildHorizontalRule())
  }

  function buildHorizontalRule() {
    return new Trix.Attachment({ content: "<hr>", contentType: "vnd.rubyonrails.horizontal-rule.html" })
  }
})

class RichText {
  constructor(element) {
    this.element = element

    this.insertHeadingElements()
    this.insertDividerElements()
    this.insertColorElements()
  }

  insertHeadingElements() {
    this.removeOriginalHeadingButton()
    this.insertNewHeadingButton()
    this.insertHeadingDialog()
  }

  removeOriginalHeadingButton() {
    this.buttonGroupBlockTools.removeChild(this.originalHeadingButton)
  }

  insertNewHeadingButton() {
    this.buttonGroupBlockTools.insertAdjacentHTML("afterbegin", this.headingButtonTemplate)
  }

  insertHeadingDialog() {
    this.dialogsElement.insertAdjacentHTML("beforeend", this.dialogHeadingTemplate)
  }

  insertDividerElements() {
    this.quoteButton.insertAdjacentHTML("afterend", this.horizontalButtonTemplate)
  }

  insertColorElements() {
    this.insertColorButton()
    this.insertDialogColor()
  }

  insertColorButton() {
    this.buttonGroupTextTools.insertAdjacentHTML("beforeend", this.colorButtonTemplate)
  }

  insertDialogColor() {
    this.dialogsElement.insertAdjacentHTML("beforeend", this.dialogColorTemplate)
  }

  get buttonGroupBlockTools() {
    return this.toolbarElement.querySelector("[data-trix-button-group=block-tools]")
  }

  get buttonGroupTextTools() {
    return this.toolbarElement.querySelector("[data-trix-button-group=text-tools]")
  }

  get dialogsElement() {
    return this.toolbarElement.querySelector("[data-trix-dialogs]")
  }

  get originalHeadingButton() {
    return this.toolbarElement.querySelector("[data-trix-attribute=heading1]")
  }

  get quoteButton() {
    return this.toolbarElement.querySelector("[data-trix-attribute=quote]")
  }

  get toolbarElement() {
    return this.element.toolbarElement
  }

  get horizontalButtonTemplate() {
    return '<button type="button" class="trix-button trix-button--icon trix-button--icon-horizontal-rule" data-trix-action="x-horizontal-rule" tabindex="-1" title="Divider">Divider</button>'
  }

  get headingButtonTemplate() {
    return '<button type="button" class="trix-button trix-button--icon trix-button--icon-heading-1" data-trix-action="x-heading" title="Heading" tabindex="-1">Heading</button>'
  }

  get colorButtonTemplate() {
    return '<button type="button" class="trix-button trix-button--icon trix-button--icon-color" data-trix-action="x-color" title="Color" tabindex="-1">Color</button>'
  }

  get dialogHeadingTemplate() {
    return `
      <div class="trix-dialog trix-dialog--heading" data-trix-dialog="x-heading" data-trix-dialog-attribute="x-heading">
        <div class="trix-dialog__link-fields">
          <input type="text" name="x-heading" class="trix-dialog-hidden__input" data-trix-input>
          <div class="trix-button-group">
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading1">H1</button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading2">H2</button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading3">H3</button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading4">H4</button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading5">H5</button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading6">H6</button>
          </div>
        </div>
      </div>
    `
  }

  get dialogColorTemplate() {
    return `
      <div class="trix-dialog trix-dialog--color" data-trix-dialog="x-color" data-trix-dialog-attribute="x-color">
        <div class="trix-dialog__link-fields">
          <input type="text" name="x-color" class="trix-dialog-hidden__input" data-trix-input>
          <div class="trix-button-group">
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="fgColor1" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="fgColor2" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="fgColor3" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="fgColor4" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="fgColor5" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="fgColor6" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="fgColor7" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="fgColor8" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="fgColor9" data-trix-method="hideDialog"></button>
          </div>
          <div class="trix-button-group">
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="bgColor1" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="bgColor2" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="bgColor3" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="bgColor4" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="bgColor5" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="bgColor6" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="bgColor7" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="bgColor8" data-trix-method="hideDialog"></button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="bgColor9" data-trix-method="hideDialog"></button>
          </div>
        </div>
      </div>
    `
  }
}

function addHeadingAttributes() {
  Array.from(["h1", "h2", "h3", "h4", "h5", "h6"]).forEach((tagName, i) => {
    Trix.config.blockAttributes[`heading${(i + 1)}`] = { tagName: tagName, terminal: true, breakOnReturn: true, group: false }
  })
}

function addForegroundColorAttributes() {
  Array.from(["rgb(136, 118, 38)", "rgb(185, 94, 6)", "rgb(207, 0, 0)", "rgb(216, 28, 170)", "rgb(144, 19, 254)", "rgb(5, 98, 185)", "rgb(17, 138, 15)", "rgb(148, 82, 22)", "rgb(102, 102, 102)"]).forEach((color, i) => {
    Trix.config.textAttributes[`fgColor${(i + 1)}`] = { style: { color: color }, inheritable: true, parser: e => e.style.color == color }
  })
}

function addBackgroundColorAttributes() {
  Array.from(["rgb(250, 247, 133)", "rgb(255, 240, 219)", "rgb(255, 229, 229)", "rgb(255, 228, 247)", "rgb(242, 237, 255)", "rgb(225, 239, 252)", "rgb(228, 248, 226)", "rgb(238, 226, 215)", "rgb(242, 242, 242)"]).forEach((color, i) => {
    Trix.config.textAttributes[`bgColor${(i + 1)}`] = { style: { backgroundColor: color }, inheritable: true, parser: e => e.style.backgroundColor == color }
  })
}