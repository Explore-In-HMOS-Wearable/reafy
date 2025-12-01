@Component
export struct ClickingGame {
  @State targetX: number = 100
  @State targetY: number = 100
  @State targetSize: number = 80
  @State score: number = 0
  @State isActive: boolean = false

  aboutToAppear() {
    this.startNewTarget()
  }

  startNewTarget() {
    this.isActive = true
    this.targetSize = 80

    this.targetX = Math.random() * 250
    this.targetY = Math.random() * 250

    animateTo({ duration: 5000 }, () => {
      this.targetSize = 20
    })

    setTimeout(() => {
      if (this.isActive) {
        this.isActive = false
        this.startNewTarget()
      }
    }, 1000)
  }

  onTargetTapped() {
    if (!this.isActive) {
      return
    }

    this.isActive = false
    this.score++

    this.startNewTarget()
  }

  build() {
    NavDestination() {
      Column() {
        Text(`Score: ${this.score}`)
          .fontSize(16)
          .fontColor('#8B8000')
          .margin({
            top: 10
          })
        Stack({ alignContent: Alignment.TopStart }) {
          Circle()
            .width(this.targetSize)
            .height(this.targetSize)
            .backgroundColor('#FFF7D6')
            .borderRadius(this.targetSize / 2)
            .position({ x: this.targetX, y: this.targetY })
            .onClick(() => this.onTargetTapped())
        }
        .width('100%')
        .height('100%')
      }
      .backgroundColor('#FFF7D6')
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
