import { BackButton } from '../components/BackButton';
import { preferences } from '@kit.ArkData';
import { cryptoRandInt } from '../utils/random';

const PREFS_NAME = 'reafy_reaction';
const KEY_PERSONAL_BEST = 'personal_best';

@Component
export struct ReactionGame {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State stage: 'idle' | 'waiting' | 'ready' | 'result' = 'idle';
  @State tapTextScale: number = 1.0;
  @State sessionBest: number = -1;
  @State personalBest: number = -1;
  startTime: number = 0;
  reaction: number = 0;
  timeoutId: number = 0;
  private prefs: preferences.Preferences | undefined = undefined;

  aboutToAppear() {
    this.loadPersonalBest();
  }

  aboutToDisappear() {
    clearTimeout(this.timeoutId);
  }

  private loadPersonalBest() {
    const ctx = this.getUIContext().getHostContext();
    if (!ctx) {
      return;
    }
    preferences.getPreferences(ctx, PREFS_NAME).then((prefs) => {
      this.prefs = prefs;
      return prefs.get(KEY_PERSONAL_BEST, -1);
    }).then((val) => {
      this.personalBest = val as number;
    }).catch(() => {
      this.personalBest = -1;
    });
  }

  private savePersonalBest(ms: number) {
    if (!this.prefs) {
      return;
    }
    this.prefs.put(KEY_PERSONAL_BEST, ms).then(() => {
      return this.prefs!.flush();
    }).catch(() => {
    });
  }

  private ratingLabel(ms: number): Resource {
    if (ms <= 200) {
      return $r('app.string.rating_excellent');
    }
    if (ms <= 300) {
      return $r('app.string.rating_good');
    }
    if (ms <= 450) {
      return $r('app.string.rating_average');
    }
    return $r('app.string.rating_slow');
  }

  private randomDelay(): number {
    // Random delay between 2000 and 5000 ms to prevent anticipation tapping
    return 2000 + cryptoRandInt(3000);
  }

  startGame() {
    this.stage = 'waiting';
    this.timeoutId = setTimeout(() => {
      this.stage = 'ready';
      this.startTime = Date.now();
      // Animate the "Tap!" text scaling in from small to full size
      this.tapTextScale = 0.5;
      this.getUIContext()?.animateTo(
        { duration: 200, curve: Curve.EaseOut },
        () => {
          this.tapTextScale = 1.0;
        }
      );
    }, this.randomDelay());
  }

  tap() {
    if (this.stage === 'ready') {
      this.reaction = Date.now() - this.startTime;
      // Update session best
      if (this.sessionBest < 0 || this.reaction < this.sessionBest) {
        this.sessionBest = this.reaction;
      }
      // Update and persist all-time personal best
      if (this.personalBest < 0 || this.reaction < this.personalBest) {
        this.personalBest = this.reaction;
        this.savePersonalBest(this.personalBest);
      }
      this.stage = 'result';
    } else if (this.stage === 'waiting') {
      clearTimeout(this.timeoutId);
      this.stage = 'idle';
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        // Main game area (full-screen tap target)
        Column() {
          if (this.stage === 'idle') {
            Button($r('app.string.btn_start'))
              .fontSize(16)
              .onClick(() => this.startGame());
            if (this.personalBest >= 0) {
              Row() {
                Text($r('app.string.label_best'))
                  .fontColor($r('app.color.color_primary_dark'))
                  .fontSize(12)

                Text(`: ${this.personalBest} ms`)
                  .fontSize(12)
                  .fontColor($r('app.color.color_primary_dark'))
              }
              .margin({ top: 10 })
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
            }
          }
          if (this.stage === 'waiting') {
            Text($r('app.string.reaction_get_ready'))
              .fontSize(16)
              .fontColor($r('app.color.color_on_primary'))
              .fontWeight(FontWeight.Bold);
          }
          if (this.stage === 'ready') {
            Text($r('app.string.reaction_tap_now'))
              .fontSize(24)
              .fontColor($r('app.color.color_on_primary'))
              .fontWeight(FontWeight.Bold)
              .scale({ x: this.tapTextScale, y: this.tapTextScale });
          }
          if (this.stage === 'result') {
            Text(`${this.reaction} ms`)
              .fontSize(20)
              .fontColor($r('app.color.color_on_primary'))
              .fontWeight(FontWeight.Bold);
            Text(this.ratingLabel(this.reaction))
              .fontSize(14)
              .fontColor($r('app.color.color_on_primary'))
              .margin({ top: 4 });
            if (this.sessionBest >= 0) {
              Row() {
                Text($r('app.string.label_session_best'))
                  .fontSize(12)
                  .fontColor($r('app.color.color_reaction_best_text'))
                Text(`: ${this.sessionBest} ms`)
                  .fontSize(12)
                  .fontColor($r('app.color.color_reaction_best_text'))
              }
              .margin({ top: 6 });
            }
            if (this.personalBest >= 0) {
              Row() {
                Text($r('app.string.label_best'))
                  .fontSize(12)
                  .fontColor($r('app.color.color_reaction_best_text'))
                Text(`: ${this.personalBest} ms`)
                  .fontSize(12)
                  .fontColor($r('app.color.color_reaction_best_text'))
              }
              .margin({ top: 2 });
            }
            Button($r('app.string.btn_try_again'))
              .fontSize(16)
              .margin({ top: 16 })
              .onClick(() => this.stage = 'idle');
          }
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => this.tap())

        // Back button (top-left, above tap area)
        BackButton({
          onBack: () => {
            clearTimeout(this.timeoutId);
            this.pageStack.pop();
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(
        this.stage === 'waiting'
          ? $r('app.color.color_reaction_waiting')
          : this.stage === 'ready'
          ? $r('app.color.color_reaction_ready')
          : this.stage === 'result'
            ? $r('app.color.color_reaction_result')
            : $r('app.color.color_reaction_idle')
      )
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
