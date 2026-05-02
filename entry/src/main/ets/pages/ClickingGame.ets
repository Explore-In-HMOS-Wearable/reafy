import { BackButton } from '../components/BackButton';
import { preferences } from '@kit.ArkData';
import { cryptoRandInt } from '../utils/random';

// Maximum axis bound (px) for target placement on a wearable screen.
// Keeps the target fully inside a ~390 px circular display.
const PLAY_AREA = 200;
const PREFS_NAME = 'reafy_clicking';
const KEY_HIGH_SCORE = 'high_score';

type Difficulty = 'Easy' | 'Normal' | 'Hard';

interface DifficultyConfig {
  shrinkMs: number;
  gameSeconds: number;
}

const DIFFICULTY_CONFIG: Record<Difficulty, DifficultyConfig> = {
  'Easy': { shrinkMs: 7000, gameSeconds: 45 },
  'Normal': { shrinkMs: 5000, gameSeconds: 30 },
  'Hard': { shrinkMs: 3000, gameSeconds: 20 }
};

@Component
export struct ClickingGame {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State targetX: number = 100
  @State targetY: number = 100
  @State targetSize: number = 80
  @State score: number = 0
  @State isActive: boolean = false
  @State timeLeft: number = 30
  @State gameOver: boolean = false
  @State highScore: number = 0
  @State difficulty: Difficulty = 'Normal'
  @State showDifficultyPicker: boolean = false
  uiContext: UIContext | undefined = undefined;
  private gameTimerId: number = -1;
  private targetTimerId: number = -1;
  private prefs: preferences.Preferences | undefined = undefined;

  aboutToAppear() {
    this.uiContext = this.getUIContext();
    this.loadHighScore();
    // Show difficulty picker before starting
    this.showDifficultyPicker = true;
  }

  aboutToDisappear() {
    clearInterval(this.gameTimerId);
    clearTimeout(this.targetTimerId);
  }

  private loadHighScore() {
    const ctx = this.getUIContext().getHostContext();
    if (!ctx) {
      return;
    }
    preferences.getPreferences(ctx, PREFS_NAME).then((prefs) => {
      this.prefs = prefs;
      return prefs.get(KEY_HIGH_SCORE, 0);
    }).then((val) => {
      this.highScore = val as number;
    }).catch(() => {
      this.highScore = 0;
    });
  }

  private saveHighScore(score: number) {
    if (!this.prefs) {
      return;
    }
    this.prefs.put(KEY_HIGH_SCORE, score).then(() => {
      return this.prefs!.flush();
    }).catch(() => {
    });
  }

  private startGame(diff: Difficulty) {
    this.difficulty = diff;
    this.showDifficultyPicker = false;
    this.score = 0;
    this.gameOver = false;
    this.startGameTimer();
    this.startNewTarget();
  }

  private startGameTimer() {
    const cfg = DIFFICULTY_CONFIG[this.difficulty];
    this.timeLeft = cfg.gameSeconds;
    this.gameTimerId = setInterval(() => {
      this.timeLeft--;
      if (this.timeLeft <= 0) {
        clearInterval(this.gameTimerId);
        this.isActive = false;
        clearTimeout(this.targetTimerId);
        if (this.score > this.highScore) {
          this.highScore = this.score;
          this.saveHighScore(this.highScore);
        }
        this.gameOver = true;
      }
    }, 1000);
  }

  private randomPos(): number {
    return cryptoRandInt(PLAY_AREA - this.targetSize);
  }

  async startNewTarget() {
    if (this.gameOver) {
      return;
    }
    this.isActive = true;
    this.targetSize = 80;

    this.targetX = this.randomPos();
    this.targetY = this.randomPos();

    const shrinkMs = DIFFICULTY_CONFIG[this.difficulty].shrinkMs;
    this.uiContext?.animateTo({ duration: shrinkMs }, () => {
      this.targetSize = 20;
    });

    this.targetTimerId = setTimeout(() => {
      if (this.isActive) {
        this.isActive = false;
        this.startNewTarget();
      }
    }, shrinkMs);
  }

  onTargetTapped() {
    if (!this.isActive || this.gameOver) {
      return;
    }
    this.isActive = false;
    this.score++;
    clearTimeout(this.targetTimerId);
    this.startNewTarget();
  }

  @Builder
  DifficultyButton(label: Difficulty, color: ResourceColor) {
    Button(label)
      .width('60%')
      .height('11%')
      .backgroundColor(color)
      .fontColor($r('app.color.color_on_primary'))
      .fontSize(14)
      .borderRadius(20)
      .onClick(() => this.startGame(label))
      .margin({ bottom: 8 })
  }

  build() {
    NavDestination() {
      if (this.showDifficultyPicker) {
        // Difficulty selection screen
        Column() {
          Text($r('app.string.clicking_game_title'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.color_primary'))
            .margin({ bottom: 16 })
          this.DifficultyButton('Easy', $r('app.color.color_primary_light'))
          this.DifficultyButton('Normal', $r('app.color.color_primary'))
          this.DifficultyButton('Hard', $r('app.color.color_primary_dark'))
          if (this.highScore > 0) {
            Row() {
              Text($r('app.string.label_best'))
                .fontSize(12)
                .fontColor($r('app.color.color_primary_dark'))
              Text(`: ${this.highScore}`)
                .fontSize(12)
                .fontColor($r('app.color.color_primary_dark'))
            }
            .margin({ top: 10 })
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('app.color.color_surface_clicking'))
      } else if (this.gameOver) {
        // Game-over screen
        Column() {
          Text($r('app.string.clicking_game_over'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.color_primary'))
            .margin({ bottom: 8 })
          Row() {
            Text($r('app.string.label_score'))
              .fontSize(18)
              .fontColor($r('app.color.color_primary_dark'))
            Text(`: ${this.score}`)
              .fontSize(18)
              .fontColor($r('app.color.color_primary_dark'))
          }
          .margin({ bottom: 4 })

          Row() {
            Text($r('app.string.label_best'))
              .fontSize(14)
              .fontColor($r('app.color.color_primary_dark'))
            Text(`: ${this.highScore}`)
              .fontSize(14)
              .fontColor($r('app.color.color_primary_dark'))

          }
          .margin({ bottom: 20 })

          Button($r('app.string.btn_play_again'))
            .width('60%')
            .height('12%')
            .backgroundColor($r('app.color.color_primary'))
            .fontColor($r('app.color.color_on_primary'))
            .fontSize(14)
            .borderRadius(20)
            .onClick(() => {
              this.showDifficultyPicker = true;
              clearInterval(this.gameTimerId);
              clearTimeout(this.targetTimerId);
            })
            .margin({ bottom: 10 })
          Button($r('app.string.btn_home'))
            .width('60%')
            .height('12%')
            .backgroundColor($r('app.color.color_primary_light'))
            .fontColor($r('app.color.color_on_primary'))
            .fontSize(14)
            .borderRadius(20)
            .onClick(() => this.pageStack.pop())
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('app.color.color_surface_clicking'))
      } else {
        // Active game screen
        Column() {
          Row() {
            BackButton({
              onBack: () => {
                clearInterval(this.gameTimerId);
                clearTimeout(this.targetTimerId);
                this.pageStack.pop();
              }
            })
            Blank().width(5)
            Row() {
              Text($r('app.string.label_score'))
                .fontSize(16)
                .fontColor($r('app.color.color_score_text'))
                .textAlign(TextAlign.Center)
              Text(`: ${this.score}`)
                .fontSize(16)
                .fontColor($r('app.color.color_score_text'))
                .textAlign(TextAlign.Center)
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)

            Text(`${this.timeLeft}s`)
              .fontSize(16)
              .fontColor($r('app.color.color_score_text'))
              .width(36)
              .textAlign(TextAlign.End)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .padding({ left: 8, right: 8, top: 6 })

          Stack({ alignContent: Alignment.TopStart }) {
            Circle()
              .width(this.targetSize)
              .height(this.targetSize)
              .backgroundColor($r('app.color.color_primary'))
              .borderRadius(this.targetSize / 2)
              .position({ x: this.targetX, y: this.targetY })
              .onClick(() => this.onTargetTapped())
          }
          .width('100%')
          .height('100%')
        }
        .backgroundColor($r('app.color.color_surface_clicking'))
        .width('100%')
        .height('100%')
      }
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
