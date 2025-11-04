PImage battleShip;  // ✅ 중심 이미지 변수 추가
float angle = 0;
float sweepSpeed = 0.05;
float cx, cy, radius;

void settings() {
  fullScreen();  // 전체화면
}

void setup() {
  frameRate(60);
  noCursor();
  calcLayout();
  background(0);

  // ✅ 이미지 불러오기 (data 폴더 안에 radar_center.png 넣기)
  battleShip = loadImage("BattleShip.png");
}

void draw() {
  // 잔상 효과
  noStroke();
  fill(0, 0, 0, 45);
  rect(0, 0, width, height);

  // 레이더 중심 위치 계산
  calcLayout();

  pushMatrix();
  translate(cx, cy);

  // 원형 그리드
  stroke(0, 255, 120, 160);
  noFill();
  strokeWeight(2);
  int rings = 5;
  for (int i = 1; i <= rings; i++) {
    ellipse(0, 0, (radius * 2 / rings) * i, (radius * 2 / rings) * i);
  }

  // 방위선
  stroke(0, 255, 120, 120);
  line(-radius, 0, radius, 0);
  line(0, -radius, 0, radius);

  // ✅ 스윕 라인 (한 줄만)
  stroke(0, 255, 160);
  strokeWeight(3);
  line(0, 0, cos(angle) * radius, sin(angle) * radius);

  // ✅ 중심 이미지 표시
  imageMode(CENTER); // 중심 좌표 기준
  image(battleShip, 0, 0, 80, 80); // 이미지 크기 (80x80)

  popMatrix();

  // 각도 증가
  angle += sweepSpeed;
  if (angle > TWO_PI) angle -= TWO_PI;
}

void calcLayout() {
  cx = width / 2.0;
  cy = height / 2.0;   // 화면 정중앙
  radius = min(width, height) * 0.4;
}
