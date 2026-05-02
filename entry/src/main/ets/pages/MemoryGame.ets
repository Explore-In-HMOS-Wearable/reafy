import { BackButton } from '../components/BackButton';
import { cryptoRandInt } from '../utils/random';

/**
 * Memory Tap game.
 *
 * The game presents a sequence of 3–5 colored circles one at a time
 * (each shown for 800 ms with a 300 ms gap).  After the sequence the
 * player must tap them back in order.  Score = number of correctly
 * ordered taps in the sequence.
 */

const COLORS: string[] = ['#FF6B6B', '#FFD93D', '#6BCB77', '#4D96FF', '#C77DFF'];
const SHOW_DURATION_MS = 800;
const GAP_DURATION_MS = 300;

type GameStage = 'idle' | 'showing' | 'input' | 'result';

@Component
export struct MemoryGame {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State stage: GameStage = 'idle';
  @State sequence: number[] = [];
  @State highlightIndex: number = -1;
  @State playerIndex: number = 0;
  @State score: number = 0;
  @State lastWasCorrect: boolean = true;
  private showTimerId: number = -1;

  aboutToDisappear() {
    clearTimeout(this.showTimerId);
  }

  private generateSequence(): number[] {
    const len = 3 + cryptoRandInt(3); // 3, 4, or 5
    const seq: number[] = [];
    for (let i = 0; i < len; i++) {
      seq.push(cryptoRandInt(COLORS.length));
    }
    return seq;
  }

  startGame() {
    this.sequence = this.generateSequence();
    this.playerIndex = 0;
    this.score = 0;
    this.stage = 'showing';
    this.playSequence(0);
  }

  private playSequence(idx: number) {
    if (idx >= this.sequence.length) {
      // Sequence finished — let player input
      this.highlightIndex = -1;
      this.stage = 'input';
      return;
    }
    // Show the circle for this step
    this.highlightIndex = this.sequence[idx];
    this.showTimerId = setTimeout(() => {
      // Hide briefly
      this.highlightIndex = -1;
      this.showTimerId = setTimeout(() => {
        this.playSequence(idx + 1);
      }, GAP_DURATION_MS);
    }, SHOW_DURATION_MS);
  }

  onCircleTap(colorIdx: number) {
    if (this.stage !== 'input') {
      return;
    }

    if (colorIdx === this.sequence[this.playerIndex]) {
      this.score++;
      this.playerIndex++;
      if (this.playerIndex >= this.sequence.length) {
        // All tapped correctly
        this.lastWasCorrect = true;
        this.stage = 'result';
      }
    } else {
      // Wrong tap — end round
      this.lastWasCorrect = false;
      this.stage = 'result';
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          if (this.stage === 'idle') {
            Text($r('app.string.memory_game_title'))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.color_primary'))
              .margin({ bottom: 12 })
            Button($r('app.string.btn_start'))
              .fontSize(16)
              .backgroundColor($r('app.color.color_primary'))
              .fontColor($r('app.color.color_on_primary'))
              .borderRadius(20)
              .onClick(() => this.startGame())
          }

          if (this.stage === 'showing') {
            Text($r('app.string.memory_watch_sequence'))
              .fontSize(14)
              .fontColor($r('app.color.color_primary_dark'))
              .margin({ bottom: 12 })
            this.ColorGrid(false)
          }

          if (this.stage === 'input') {
            Row() {
              Text($r('app.string.memory_tap_sequence'))
                .fontSize(13)
                .fontColor($r('app.color.color_primary_dark'))
              Text(` (${this.playerIndex + 1}/${this.sequence.length})`)
                .fontSize(13)
                .fontColor($r('app.color.color_primary_dark'))
            }
            .margin({ bottom: 12 })

            this.ColorGrid(true)
          }

          if (this.stage === 'result') {
            Text(this.lastWasCorrect
              ? $r('app.string.memory_perfect')
              : $r('app.string.memory_wrong'))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.lastWasCorrect
                ? $r('app.color.color_primary')
                : $r('app.color.color_error'))
              .margin({ bottom: 8 })
            Row() {
              Text($r('app.string.label_score'))
                .fontSize(14)
                .fontColor($r('app.color.color_primary_dark'))
              Text(`: ${this.score} / ${this.sequence.length}`)
                .fontSize(14)
                .fontColor($r('app.color.color_primary_dark'))
            }
            .margin({ bottom: 20 })

            Button($r('app.string.btn_play_again'))
              .fontSize(14)
              .backgroundColor($r('app.color.color_primary'))
              .fontColor($r('app.color.color_on_primary'))
              .borderRadius(20)
              .onClick(() => this.startGame())
          }

        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('app.color.color_surface_home'))

        BackButton({
          onBack: () => {
            clearTimeout(this.showTimerId);
            this.pageStack.pop();
          }
        })
      }
      .width('100%')
      .height('100%')
    }

    .hideTitleBar(true)

    .hideBackButton(true)
  }

  @Builder
  ColorGrid(tappable:
    boolean
  ) {
    Grid() {
      ForEach(COLORS, (color: string, idx: number) => {
        GridItem() {
          Circle()
            .width(44)
            .height(44)
            .backgroundColor(color)
            .opacity(this.highlightIndex === idx ? 1.0 : (this.stage === 'showing' ? 0.3 : 1.0))
            .onClick(() => {
              if (tappable) {
                this.onCircleTap(idx);
              }
            })
        }
      }, (item: string, idx: number) => {
        return item;
      })
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(8)
    .columnsGap(8)
    .width(160)
    .height(120)
  }
}
