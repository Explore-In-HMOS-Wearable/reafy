import { ClickingGame } from './ClickingGame'
import { ReactionGame } from './ReactionGame'
import { MemoryGame } from './MemoryGame'

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
    } else if (name === 'MemoryGame') {
      MemoryGame()
    }
  }

  build() {
    Navigation(this.pageStack) {
      RelativeContainer() {
        Column() {
          this.button($r('app.string.clicking_game_title'), this.clickingGame)
          this.button($r('app.string.reaction_game_title'), this.reactionGame)
          this.button($r('app.string.memory_game_title'), this.memoryGame)
        }
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      }
      .width('100%')
      .backgroundColor($r('app.color.color_surface_home'))
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
  private memoryGame = () => {
    this.pageStack.pushPathByName('MemoryGame', null);
  }

  @Builder
  button(text: ResourceStr, onClick: () => void) {
    Button({ type: ButtonType.Normal }) {
      Column() {
        Text(text)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.color_on_primary'))
        Rect()
          .radius(1)
          .fill($r('app.color.color_primary_light'))
          .height(2)
          .width(100)
      }
    }
    .width('70%')
    .height('15%')
    .backgroundColor($r('app.color.color_primary'))
    .borderRadius(24)
    .onClick(onClick)
    .margin({
      bottom: '5%'
    })
  }
}
