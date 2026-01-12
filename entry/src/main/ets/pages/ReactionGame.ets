@Component
export struct ReactionGame {
  @State stage: 'idle' | 'waiting' | 'ready' | 'result' = 'idle';
  startTime: number = 0;
  reaction: number = 0;
  timeoutId: number = 0;

  startGame() {
    this.stage = 'waiting';
    this.timeoutId = setTimeout(() => {
      this.stage = 'ready';
      this.startTime = Date.now();
    }, 3000);
  }

  tap() {
    if (this.stage === 'ready') {
      this.reaction = Date.now() - this.startTime;
      this.stage = 'result';
    } else if (this.stage === 'waiting') {
      clearTimeout(this.timeoutId);
      this.stage = 'idle';
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.stage === 'idle') {
          Button('Start')
            .fontSize(16)
            .onClick(() => this.startGame());
        }
        if (this.stage === 'waiting') {
          Text('Get Ready…')
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold);
        }
        if (this.stage === 'ready') {
          Text('Tap!')
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold);
        }
        if (this.stage === 'result') {
          Text(`Reaction Time: ${this.reaction} ms`)
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold);

          Button('Try Again')
            .fontSize(16)
            .margin({ top: 20 })
            .onClick(() => this.stage = 'idle');
        }

      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(
        this.stage === 'waiting'
          ? '#6FB6FF'
          : this.stage === 'ready'
          ? '#1E90FF'
          : this.stage === 'result'
            ? '#4A90E2'
            : '#BFDFFF'
      )
      .onClick(() => this.tap())
      .padding(20);
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
