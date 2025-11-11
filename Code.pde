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
    fill(255, 255, 0); // 노란색
    textAlign(CENTER, CENTER);
    textSize(22);
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

String[] vocabulary = { "비행기", "바나나", "역삼역", "강남역", "카카오", "신세계", "아마존", "소화기" };

// ======================= SETUP =======================
void settings() { fullScreen(); }

void setup() {
  frameRate(60);
  noCursor();
  calcLayout();
  background(0);
  battleShip = loadImage("BattleShip.png");

  // ✅ 한글 폰트 로드
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

  // ✅ 소나 파동
  for (int i = sonars.size()-1; i >= 0; i--) {
    Sonar s = sonars.get(i);
    s.update();
    if (!s.active) sonars.remove(i);
  }

  // ✅ 레이더 원 (6개 + 넓은 간격)
  stroke(0,255,120,160);
  noFill();
  strokeWeight(2);
  int rings = 6;
  for (int i = 1; i <= rings; i++) {
    float r = (radius / rings) * i * 1.15;
    ellipse(0,0,r*2,r*2);
  }

  // ✅ 십자선 (가장 큰 원과 동일 비율)
  stroke(0,255,120,120);
  float cross = radius * 1.15;
  line(-cross, 0, cross, 0);
  line(0, -cross, 0, cross);

  // ✅ 단어 이동 및 출력
  for (int i = targets.size()-1; i >= 0; i--) {
    TextTarget t = targets.get(i);
    if (t.update()) targets.remove(i);
    else t.display();
  }

  // ✅ 배 이미지
  imageMode(CENTER);
  float scale = radius * 0.35 / battleShip.height;
  image(battleShip, 0,0, battleShip.width*scale, battleShip.height*scale);

  popMatrix();

  // ✅ 주기적으로 텍스트 생성
  if (frameCount % 40 == 0) {
    String w = vocabulary[int(random(vocabulary.length))];
    targets.add(new TextTarget(w));
  }
}

// ======================= LAYOUT =======================
void calcLayout() {
  cx = width/2.0;
  cy = height/2.0;
  radius = min(width,height)*0.4;
}

// ======================= SPACEBAR = SONAR =======================
void keyPressed() {
  if (key == ' ') {
    sonars.add(new Sonar(frameCount, radius));
  }
}
