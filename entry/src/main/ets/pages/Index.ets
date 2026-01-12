import { ClickingGame } from './ClickingGame'
import { ReactionGame } from './ReactionGame'

@Entry
@Component
struct MainPage {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack()

  @Builder
  PagesMap(name: string) {
    if (name === 'ClickingGame') {
      ClickingGame()
    } else if (name === 'ReactionGame') {
      ReactionGame()
    }
  }

  build() {
    Navigation(this.pageStack) {
      RelativeContainer() {
        Column() {
          this.button('Clicking Game', this.clickingGame)
          this.button('Reaction Game', this.reactionGame)
        }
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      }
      .width('100%')
      .backgroundColor('#F7F4FF')
    }
    .hideTitleBar(true)
    .navDestination(this.PagesMap)
    .hideBackButton(true)
    .ignoreLayoutSafeArea()
  }

  private clickingGame = () => {
    this.pageStack.pushPathByName('ClickingGame', null);
  }
  private reactionGame = () => {
    this.pageStack.pushPathByName('ReactionGame', null);
  }

  @Builder
  button(text: string, onClick: () => void) {
    Button({ type: ButtonType.Normal }) {
      Column() {
        Text(text)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Rect()
          .radius(1)
          .fill('#C5B3FF')
          .height(2)
          .width(100)
      }
    }
    .width('70%')
    .height('15%')
    .backgroundColor('#A78BFA')
    .borderRadius(24)
    .onClick(onClick)
    .margin({
      bottom: '5%'
    })
  }
}