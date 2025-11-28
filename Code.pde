import ddf.minim.*;   // Minim 라이브러리 추가

Minim minim;
AudioPlayer bgm;
AudioPlayer dieSound;  // 단어 맞출 때 재생

PImage battleShip;
float cx, cy, radius;
PFont f;

// ======================= 체력 =======================
int maxHealth = 100;
int health = 100;

// ======================= 점수 =======================
int score = 0;

// ======================= 게임 상태 =======================
boolean isGameOver = false;

// ======================= TEXT TARGET =======================
class TextTarget {
  String word;
  PVector pos;
  PVector vel;
  float speed;

  boolean isVisible = false;
  int visibleUntilFrame = 0;
  boolean hitOnce = false; // 중앙 도달 시 체력 감소 여부

  TextTarget(String w) {
    word = w;

    float a = random(TWO_PI);
    pos = new PVector(cos(a) * radius, sin(a) * radius);

    PVector dir = PVector.sub(new PVector(0, 0), pos);
    dir.normalize();

    speed = 0.5f;  // 단어 속도
    vel = dir.copy().mult(speed);
  }

  boolean update() {
    pos.add(vel);

    // 중앙 도달 체크
    if (pos.mag() < 20 && !hitOnce) {
      health -= 10;
      if (health < 0) health = 0;
      hitOnce = true;
    }

    if (pos.mag() < 6) return true;
    return false;
  }

  void display() {
    if (isVisible) fill(255, 255, 0, 255);
    else fill(255, 255, 0, 0);

    textAlign(CENTER, CENTER);
    textSize(22);
    textFont(f);
    text(word, pos.x, pos.y);

    if (isVisible && frameCount > visibleUntilFrame) {
      isVisible = false;
    }
  }
}

// ======================= SONAR WAVE =======================
class Sonar {
  float startFrame;
  float maxRadius;
  boolean active = true;

  Sonar(float startFrame, float maxRadius) {
    this.startFrame = startFrame;
    this.maxRadius = maxRadius;
  }

  void update() {
    float age = frameCount - startFrame;
    float growT = 60;
    float fadeT = 120;

    float progress = min(1, age / growT);
    float r = maxRadius * progress * 1.15;
    float alpha = map(age, growT, growT + fadeT, 255, 0);

    if (alpha <= 0) active = false;

    noFill();
    stroke(0, 255, 120, alpha);
    strokeWeight(2);
    ellipse(0, 0, r * 2, r * 2);
  }
}

// ======================= GLOBAL LISTS =======================
ArrayList<TextTarget> targets = new ArrayList<TextTarget>();
ArrayList<Sonar> sonars = new ArrayList<Sonar>();

String[] vocabulary = {
  // 미국 (USN)
  "iowa", "wasp", "texas", "essex", "salem", "gato", "sims",

  // 영국 (Royal Navy)
  "hood", "dido", "ajax", "york", "howe", "eagle", "tiger",

  // 일본 (IJN)
  "yamato", "mutsu", "kaga", "akagi", "kongo", "ise", "fuso", "maya",

  // 독일 (Kriegsmarine)
  "emden", "koln",

  // 기타 (러시아, 이탈리아, 프랑스)
  "kirov", "kiev", "roma", "zara", "pola", "foch"
};


String typedText = "";

// ======================= SPAWN CONTROL =======================
int spawnInterval = 120;   // 처음엔 2초마다 단어 생성

// ======================= SETUP =======================
void settings() { fullScreen(); }

void setup() {
  frameRate(60);
  noCursor();
  calcLayout();
  background(0);

  // BGM 시작
  minim = new Minim(this);
  bgm = minim.loadFile("SuddenAttack.mp3");
  bgm.loop();
  bgm.setGain(-5);

  dieSound = minim.loadFile("DieSound.mp3"); // 단어 맞출 때 재생

  battleShip = loadImage("BattleShip.png");

  f = createFont("Malgun Gothic", 24, true);
  textFont(f);
}

// ======================= DRAW =======================
void draw() {
  noStroke();
  fill(0, 0, 0, 45);
  rect(0, 0, width, height);

  if (!isGameOver) {
    calcLayout();
    pushMatrix();
    translate(cx, cy);

    // ------------------- 소나 업데이트 -------------------
    for (int i = sonars.size() - 1; i >= 0; i--) {
      Sonar s = sonars.get(i);
      s.update();
      if (!s.active) sonars.remove(i);
    }

    // ------------------- 소나와 단어 충돌 체크 -------------------
    for (Sonar s : sonars) {
      float age = frameCount - s.startFrame;
      float r = s.maxRadius * min(1, age / 60.0) * 1.15;

      for (TextTarget t : targets) {
        float d = dist(0, 0, t.pos.x, t.pos.y);
        if (d < r && !t.isVisible) {
          t.isVisible = true;
          t.visibleUntilFrame = frameCount + 120; // 2초간 보임
        }
      }
    }

    // ------------------- 소나 원 표시 -------------------
    stroke(0, 255, 120, 160);
    noFill();
    strokeWeight(2);
    int rings = 6;
    for (int i = 1; i <= rings; i++) {
      float r = (radius / rings) * i * 1.15;
      ellipse(0, 0, r * 2, r * 2);
    }

    stroke(0, 255, 120, 120);
    float cross = radius * 1.15;
    line(-cross, 0, cross, 0);
    line(0, -cross, 0, cross);

    // ------------------- 단어 업데이트 -------------------
    for (int i = targets.size() - 1; i >= 0; i--) {
      TextTarget t = targets.get(i);
      if (t.update()) targets.remove(i);
      else t.display();
    }

    // ------------------- 배틀쉽 표시 -------------------
    imageMode(CENTER);
    float scale = radius * 0.35 / battleShip.height;
    image(battleShip, 0, 0, battleShip.width * scale, battleShip.height * scale);

    popMatrix();

    // ------------------- 단어 생성 -------------------
    if (frameCount == 900) spawnInterval = 80;
    if (frameCount == 1800) spawnInterval = 50;

    if (frameCount % spawnInterval == 0) {
      String w = vocabulary[int(random(vocabulary.length))];
      targets.add(new TextTarget(w));
    }

    // ------------------- 입력창 바로 위 체력 바 -------------------
    float barWidth = width * 0.1;
    float barHeight = 20;
    float barX = width * 0.1;   
    float barY = height * 0.85 - 50; // 입력창 바로 위

    // 배경
    fill(50);
    rect(barX, barY, barWidth, barHeight, 5);
    // 체력 게이지
    fill(0, 255, 0);
    rect(barX, barY, barWidth * (health / float(maxHealth)), barHeight, 5);

    // ------------------- 점수 표시 -------------------
    fill(0, 255, 120);
    textAlign(LEFT, CENTER);
    textSize(24);
    text("점수: " + score, width * 0.1, height * 0.05);

    // ------------------- 게임오버 체크 -------------------
    if (health <= 0) {
      isGameOver = true;
    }

    // ------------------- 오른쪽 하단 난이도 표시 -------------------
    int seconds = frameCount / 60;
    String difficulty = "Easy";
    color difficultyColor = color(0, 200, 255); // 기본 하늘색

    if (seconds < 15) {
      difficulty = "Easy  ";
      difficultyColor = color(0, 200, 255);
    } else if (seconds < 30) {
      difficulty = "Medium";
      difficultyColor = color(255, 165, 0);
    } else {
      difficulty = "Difficult";
      difficultyColor = color(255, 0, 0);
    }

    textAlign(RIGHT, BOTTOM);
    textSize(20);

    fill(0, 255, 120);
    text("난이도:", width - 100, height - 50);

    fill(difficultyColor);
    text(difficulty, width - 20, height - 50);

    // ------------------- 오른쪽 하단 시간 표시 -------------------
    fill(0, 255, 120, 255);
    textAlign(RIGHT, BOTTOM);
    textSize(24);
    text("시간: " + seconds + "초", width - 20, height - 20);

    // ------------------- 입력 표시 -------------------
    fill(0, 255, 120, 240);
    textAlign(LEFT, CENTER);
    textSize(30);
    text("입력: " + typedText, width * 0.1, height * 0.85);

  } else {
    // 게임오버 화면
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(60);
    text("GAME OVER", width / 2, height / 2);

    textSize(30);
    fill(255);
    text("최종 점수: " + score, width / 2, height / 2 + 50);

    textSize(24);
    text("아무 키나 눌러 재시작", width / 2, height / 2 + 100);
  }
}

// ======================= 정답 체크 =======================
void checkTypedWord() {
  for (int i = targets.size() - 1; i >= 0; i--) {
    if (targets.get(i).word.equals(typedText)) {
      targets.remove(i);
      dieSound.rewind();
      dieSound.play();
      score += 100; // 점수 100 증가
    }
  }
}

// ======================= 키 입력 =======================
void keyPressed() {
  if (isGameOver) {
    restartGame();
    return;
  }

  if (key == ' ') {
    sonars.add(new Sonar(frameCount, radius));
    return;
  }

  if (key == BACKSPACE) {
    if (typedText.length() > 0) {
      typedText = typedText.substring(0, typedText.length() - 1);
    }
    return;
  }

  if (key == ENTER || key == RETURN) {
    checkTypedWord();
    typedText = "";
    return;
  }

  if (key != CODED) {
    typedText += key;
  }
}

// ======================= 게임 재시작 =======================
void restartGame() {
  health = maxHealth;
  score = 0;
  targets.clear();
  sonars.clear();
  typedText = "";
  frameCount = 0;
  isGameOver = false;
}

// ======================= 레이아웃 계산 =======================
void calcLayout() {
  cx = width / 2.0;
  cy = height / 2.0;
  radius = min(width, height) * 0.4;
}
