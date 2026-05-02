/**
 * Shared back button used by all game screens.
 * Renders a circular '←' button in the top-left corner.
 *
 * Usage:
 *   BackButton({ onBack: () => { this.pageStack.pop(); } })
 */
@Component
export struct BackButton {
  onBack: () => void = () => {};

  build() {
    Button('←')
      .width(32)
      .height(32)
      .fontSize(16)
      .backgroundColor($r('app.color.color_primary_light'))
      .fontColor($r('app.color.color_on_primary'))
      .borderRadius(16)
      .margin({ top: 8, left: 8 })
      .onClick(() => this.onBack())
  }
}
