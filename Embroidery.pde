import processing.svg.*;
import java.util.*;

PImage img;
PGraphics reference;
PVector v = new PVector(300, 400), prev = new PVector(300, 390);
PShape path;
float heading = 0;
int max_stitches = 20000, stitch_count;
float max_length = 20;
boolean record = false;


void setup (){
    size(700, 700);
    img = loadImage("data/shades3.png");
    img.resize(width, height);
    
    reference = createGraphics(width, height);
    reference.beginDraw();
    reference.image(img, 0, 0);
    reference.endDraw();
    reference.stroke(255, 128);
    // reference.blendMode(ADD)

    background(255);
    // image(img, 0, 0);

    path = createShape();
    path.beginShape();
    path.noFill();
    path.stroke(0);
    
    img.loadPixels();
}

void draw () {

    if (stitch_count < max_stitches) {
        float heading = PVector.sub(prev, v).heading();
        prev = v;
        v = next_v(v, heading);

        reference.beginDraw();
        // reference.strokeWeight(reading / 32 + 2);
        reference.line(v.x, v.y, prev.x, prev.y);
        reference.endDraw();
        // point(next.x, next.y);
        // v = next;
        path.vertex(v.x, v.y);
        stitch_count ++;
    }
    // image(reference, 0, 0)
    // max_length = map(i, 0, n_stitches, 10, 30)
    
    if (record) beginRecord(SVG, "frame-####.svg");
        
    background(255);
    shape(path, 0, 0);
    
    if (record) {
        endRecord();
        record = false;
    }
    
    noFill();
    rect(100, 0, 500, 20);
    float x = map(stitch_count, 0, max_stitches, 0, 500);
    fill(0);
    rect(100, 0, x, 20);
    text(str(stitch_count) + '/' + str(max_stitches), 10, 10);
}
    
PVector next_v (PVector current_v, float heading) {
    if (mousePressed) return new PVector(mouseX, mouseY);
    
    float l = random(5, max_length);
    float a = heading + PI;
    
    int n_choices = 16;
    float incr = TWO_PI / n_choices;
    float darkest = 255;
    PVector best = PVector.add(current_v, PVector.fromAngle(heading).mult(l));
    for (int i = 1; i < n_choices; i ++) {
        PVector d = PVector.fromAngle(a + i*incr).mult(l);
        PVector c = PVector.add(current_v, d);
        if (valid(c)) {
            int x = floor(c.x);
            int y = floor(c.y);
            int loc = x + y * width;
            color sample = reference.pixels[loc];
            float b = brightness(sample);
            if (b <= darkest) {
                darkest = b;
                best = c;
            }
        }
    }
    return best;
}
        
boolean valid(PVector w){
    if ((w.x <= 2) || (w.y <= 2) || (w.x >= width) || (w.y >= height)) return false; 
    int x = floor(w.x);
    int y = floor(w.y);
    int loc = x + y * width;
    color c = img.pixels[loc];
    if (c == color(0, 0, 255)) return false;
    return true;
}
    
void keyPressed() {
    record = true;
}
