PImage battleShip;
float cx, cy, radius;
PFont f;

// ======================= TEXT TARGET =======================
class TextTarget {
  String word;
  PVector pos;
  PVector vel;
  float speed;

  TextTarget(String w) {
    word = w;
    
    float a = random(TWO_PI);
    pos = new PVector(cos(a) * radius, sin(a) * radius);

    PVector dir = PVector.sub(new PVector(0,0), pos);
    dir.normalize();

    speed = 1.0f;
    vel = dir.copy().mult(speed);
  }

  boolean update() {
    pos.add(vel);
    if (pos.mag() < 6) return true;
    return false;
  }

  void display() {
    fill(255, 255, 0);
    textAlign(CENTER, CENTER);
    textSize(22);
    textFont(f);
    text(word, pos.x, pos.y);
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
    stroke(0,255,120, alpha);
    strokeWeight(2);
    ellipse(0,0,r*2,r*2);
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

// ======================= TYPING =======================
String typedText = "";

// ======================= SETUP =======================
void settings() { fullScreen(); }

void setup() {
  frameRate(60);
  noCursor();
  calcLayout();
  background(0);
  battleShip = loadImage("BattleShip.png");

  f = createFont("Malgun Gothic", 24, true);
  textFont(f);
}

// ======================= DRAW =======================
void draw() {
  noStroke();
  fill(0,0,0,45);
  rect(0,0,width,height);

  calcLayout();
  pushMatrix();
  translate(cx,cy);

  // 소나 파동
  for (int i = sonars.size()-1; i >= 0; i--) {
    Sonar s = sonars.get(i);
    s.update();
    if (!s.active) sonars.remove(i);
  }

  // 레이더 원
  stroke(0,255,120,160);
  noFill();
  strokeWeight(2);
  int rings = 6;
  for (int i = 1; i <= rings; i++) {
    float r = (radius / rings) * i * 1.15;
    ellipse(0,0,r*2,r*2);
  }

  // 십자선
  stroke(0,255,120,120);
  float cross = radius * 1.15;
  line(-cross, 0, cross, 0);
  line(0, -cross, 0, cross);

  // 타겟 이동
  for (int i = targets.size()-1; i >= 0; i--) {
    TextTarget t = targets.get(i);
    if (t.update()) targets.remove(i);
    else t.display();
  }

  // 배 이미지
  imageMode(CENTER);
  float scale = radius * 0.35 / battleShip.height;
  image(battleShip, 0,0, battleShip.width*scale, battleShip.height*scale);

  popMatrix();

  // 단어 생성
  if (frameCount % 40 == 0) {
    String w = vocabulary[int(random(vocabulary.length))];
    targets.add(new TextTarget(w));
  }

  // 입력 HUD
  fill(0,255,120,240);
  textAlign(LEFT, CENTER);
  textSize(30);
  text("입력: " + typedText, width * 0.1, height * 0.9);
}

// ======================= 정답 체크 =======================
void checkTypedWord() {
  for (int i = targets.size()-1; i >= 0; i--) {
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
  cx = width/2.0;
  cy = height/2.0;
  radius = min(width,height)*0.4;
}
