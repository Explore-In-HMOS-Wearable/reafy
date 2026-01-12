interface RandomValueInterface {
  val1: number;
  val2: number;
}

@Component
export struct ClickingGame {
  @State targetX: number = 100
  @State targetY: number = 100
  @State targetSize: number = 80
  @State score: number = 0
  @State isActive: boolean = false
  uiContext: UIContext | undefined = undefined;

  aboutToAppear() {
    this.startNewTarget()
    this.uiContext = this.getUIContext();
    if (!this.uiContext) {
      return;
    }
  }

  randomNumberGenerator(): RandomValueInterface {
    const t = Date.now();

    let val1 = (t ^ (t >> 6)) % 10;
    let val2 = (t ^ (t >> 7)) % 10;

    val1 = (val1 ^ (val1 >> 31)) - (val1 >> 31);
    val2 = (val2 ^ (val2 >> 31)) - (val2 >> 31);

    return { val1, val2 };
  }

  async startNewTarget() {
    this.isActive = true
    this.targetSize = 80

    this.targetX = this.randomNumberGenerator().val1 * 25
    this.targetY = this.randomNumberGenerator().val2 * 25

    this.uiContext?.animateTo({ duration: 5000 }, () => {
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