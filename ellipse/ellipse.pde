/**
 * Radial Gradient. 
 * 
 * Draws a series of concentric circles to create a gradient 
 * from one color to another.
 */

int size;
int x1;
int x2;
int y;
int saturation;
int brightness;

void setup() {
  size(640, 360);
  x1 = width / 4;
  x2 = x1 * 3;
  y = height / 2;
  size = width/3;
  saturation = (int) (size * 0.8);
  brightness = (int) (size * 0.8);
  background(0);
  colorMode(HSB, size, size, size);
  noStroke();
  ellipseMode(RADIUS);
  frameRate(1);
}

void draw() {
  background(0);
  drawGradient(x1, y);
  drawGradient(x2, y);
}

void drawGradient(float x, float y) {
  int radius = size/2;
  for (int r = radius; r > 0; --r) {
    fill(r + radius, saturation, brightness);
    ellipse(x, y, r, r);
  }
}
