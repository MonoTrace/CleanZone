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

  // 스윕 빔
  float beamWidth = radians(24);
  float a1 = angle - beamWidth / 2.0;
  float a2 = angle + beamWidth / 2.0;

  noStroke();
  fill(0, 255, 120, 50);
  beginShape();
  vertex(0, 0);
  vertex(cos(a1) * radius, sin(a1) * radius);
  vertex(cos(a2) * radius, sin(a2) * radius);
  endShape(CLOSE);

  // 스윕 라인
  stroke(0, 255, 160);
  strokeWeight(3);
  line(0, 0, cos(angle) * radius, sin(angle) * radius);

  popMatrix();

  // 중심점 표시
  noStroke();
  fill(0, 255, 120);
  circle(cx, cy, 8);

  // 각도 증가
  angle += sweepSpeed;
  if (angle > TWO_PI) angle -= TWO_PI;
}

void calcLayout() {
  cx = width / 2.0;
  cy = height / 2.0;   // ✅ 화면 정중앙
  radius = min(width, height) * 0.4;
}
