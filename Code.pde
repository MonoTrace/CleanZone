import ddf.minim.*;   // 🔥 Minim 라이브러리 추가

Minim minim;
AudioPlayer bgm;

PImage battleShip;
float cx, cy, radius;
PFont f;

// ======================= TEXT TARGET =======================
class TextTarget {
  String word;
  PVector pos;
  PVector vel;
  float speed;

  boolean isVisible = false;
  int visibleUntilFrame = 0;

  TextTarget(String w) {
    word = w;

    float a = random(TWO_PI);
    pos = new PVector(cos(a) * radius, sin(a) * radius);

    PVector dir = PVector.sub(new PVector(0, 0), pos);
    dir.normalize();

    speed = 0.5f;  // 속도 줄여서 난이도 낮춤
    vel = dir.copy().mult(speed);
  }

  boolean update() {
    pos.add(vel);
    if (pos.mag() < 6) return true;
    return false;
  }

  void display() {
    if (isVisible) fill(255, 255, 0, 255);
    else fill(255, 255, 0, 0); // 완전 투명

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
  "radar", "signal", "target", "echo", "sonar",
  "ocean", "shadow", "phantom", "pirate", "voyager",
  "rocket", "missile", "enemy", "vector", "horizon",
  "storm", "danger", "system", "rescue", "engine"
};

String typedText = "";

// ======================= SETUP =======================
void settings() { fullScreen(); }

void setup() {
  frameRate(60);
  noCursor();
  calcLayout();
  background(0);

  // 🔥 BGM 시작
  minim = new Minim(this);
  bgm = minim.loadFile("SuddenAttack.mp3");   // data 폴더 안에 넣기
  bgm.loop();
  bgm.setGain(-5);          // 볼륨 (dB) -5는 약 60~70% 정도

  battleShip = loadImage("BattleShip.png");

  f = createFont("Malgun Gothic", 24, true);
  textFont(f);
}

// ======================= DRAW =======================
void draw() {
  noStroke();
  fill(0, 0, 0, 45);
  rect(0, 0, width, height);

  calcLayout();
  pushMatrix();
  translate(cx, cy);

  for (int i = sonars.size() - 1; i >= 0; i--) {
    Sonar s = sonars.get(i);
    s.update();
    if (!s.active) sonars.remove(i);
  }

  // 🔥 소나와 단어 충돌 체크
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

  for (int i = targets.size() - 1; i >= 0; i--) {
    TextTarget t = targets.get(i);
    if (t.update()) targets.remove(i);
    else t.display();
  }

  imageMode(CENTER);
  float scale = radius * 0.35 / battleShip.height;
  image(battleShip, 0, 0, battleShip.width * scale, battleShip.height * scale);

  popMatrix();

  if (frameCount % 80 == 0) {
    String w = vocabulary[int(random(vocabulary.length))];
    targets.add(new TextTarget(w));
  }

  fill(0, 255, 120, 240);
  textAlign(LEFT, CENTER);
  textSize(30);
  text("입력: " + typedText, width * 0.1, height * 0.9);
}

// ======================= 정답 체크 =======================
void checkTypedWord() {
  for (int i = targets.size() - 1; i >= 0; i--) {
    if (targets.get(i).word.equals(typedText)) {
      targets.remove(i);
    }
  }
}

// ======================= KEY INPUT =======================
void keyPressed() {

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

// ======================= LAYOUT =======================
void calcLayout() {
  cx = width / 2.0;
  cy = height / 2.0;
  radius = min(width, height) * 0.4;
}
