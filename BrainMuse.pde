/*
  Processing sketches referenced:
  https://www.openprocessing.org/sketch/611317
  https://www.openprocessing.org/sketch/635808
  https://www.openprocessing.org/sketch/621094
  
  This project uses a Muse headset and Processing to create a visual 
  and audio representation of brain waves. The height of the ocean waves
  correlates to delta waves. The waves in the sky relate to alpha and 
  beta waves. Going into a sleep state will cause the waves to rise.
  
  The music from the visual is the result of beta waves. The level of 
  excitement felt by the user will change the music being played.
*/

//import statements
import arb.soundcipher.*;
import oscP5.*;
import java.util.Arrays;
import java.util.List;


boolean debug = false;


List<Integer> wrong = Arrays.asList(22, 25, 27, 30, 32, 34, 37, 39, 42, 44, 46, 49, 52, 54, 56, 58, 61, 66, 73, 75, 78, 80, 82, 85, 87);

// wave values
float alpha;
float beta;
float delta;
float theta;

//OSC PARAMETERS & PORTS
int recvPort = 7000;
OscP5 oscP5;
SoundCipher sc = new SoundCipher(this);
// for the visuals
int step = 30;
int offset = 30;
int w;
int h;
void setup() {
  fullScreen();
  frameRate(60);
  w = width;
  h = height;
  //nice sounds: 0(piano), 8, 13(zylophone)
  sc.instrument(0);
  
  /* start oscP5, listening for incoming messages at recvPort */
  oscP5 = new OscP5(this, recvPort);
}
void draw() {
  background(0, 0, 100, 40);
  setGradient(0,0,width,height/2);
  
  /* 
  Waves in the sky
  They should help visualize the alpha and beta waves.
  */
  // alpha
  float mappedAlpha = map(alpha, 0, 1, 5, 10);
  strokeWeight(2);
  int ranges = 1;
  for (int i = 0; i < ranges; i++) {
    stroke(240, 62, 70);
    beginShape();
    for (int x = -10; x < width + 100; x += 20) {
      float n = noise(x * 0.001, i * 0.07, frameCount * 0.02);
      float ay = map(n, 0, 1, height/mappedAlpha, height/3);
      vertex(x, ay);
    }
    endShape();
  }
  
  // beta
  float mappedBeta = map(beta, 0, 1, 5, 10);
  strokeWeight(2);
  for (int i = 0; i < ranges; i++) {
    stroke(255,120,30);
    beginShape();
    for (int x = -10; x < width + 100; x += 20) {
      float m = noise(x * 0.001, i * 0.07, frameCount * 0.02);
      float by = map(m, 0, 1, height/mappedBeta, height/3);
      vertex(x, by);
    }
    endShape();
  }
  
  // draw the sun
  noStroke();
  fill(229,219,95,25);
  ellipse(w/2,h/2,700,700);
  fill(229,219,95,50);
  ellipse(w/2,h/2,400,400);
  fill(229,219,95,75);
  ellipse(w/2,h/2,275,275);
  fill(229,219,95,255);
  ellipse(w/2,h/2,200,200);
  
  /*
  Ocean waves.
  They should help visualize the delta and gamma waves.
  */
  float waveSpeed = 0.002;
  int counter = 0;
  for (float y = -offset; y <= height+offset; y = y + map(y,-offset,height+offset,step*2,step/2)) {
    counter++;
    stroke(4, 104, 157);
    strokeWeight(3);
    fill(3, 70, 107);
    beginShape();
    for (int x = -offset; x <= width+offset; x = x + step) {
      float n = noise(y*0.01, x*0.001, (y+frameCount)*(waveSpeed+(.003*counter)));
      float mappedDelta = map(delta, 0, 1, 0, -height/8);
      n = map(n, 0, 1, mappedDelta, height/8);
      float y2 = y + n;
      vertex(x, y2+height/1.8);
    }
    vertex(width+offset, height+offset);
    vertex(-offset, height+offset);
    endShape(CLOSE);
  }
}
void setGradient(int x, int y, int gw, int gh) {
  noFill();
  for (int i = y; i <= y+h; i++) {
    float inter = map(i, y, y+gh, 0, 1);
    color c1 = color(255, 156, 125);
    color c2 = color(194, 165, 172);
    int c = lerpColor(c1, c2, inter);
    stroke(c);
    line(x, i, x+gw, i);
  }
}

void oscEvent(OscMessage msg) {
  /* print the address path and the type string of the received OscMessage */
  if (debug) {
    print("---OSC Message Received---");
    println(msg);
  }
      // get beta value
    if(msg.checkAddrPattern("Person0/elements/beta_absolute") == true) {
      println("----- READING BETA WAVES -----");
      beta =  (float)msg.get(3).doubleValue(); //Reading from channel 3
      println("----- BETA VALUE ----- \n", beta);
      
      //play note
      int note = (int)map(beta, 0, 1, 60, 96);
      sc.playNote(note, 100, 3);
      
      //add random delay to make it sound more melodic
      int rand = (int)random(200,500);
      delay(rand);
      }
    
    // get delta value
    if(msg.checkAddrPattern("Person0/elements/beta_absolute") == true) {
      println("----- READING DELTA WAVES -----");
      delta =  (float)msg.get(3).doubleValue(); //Reading from channel 3
      println("----- DELTA VALUE ----- \n", delta);
    }
    
    // get theta value
    if(msg.checkAddrPattern("Person0/elements/theta_absolute") == true) {
      println("----- READING THETA WAVES -----");
      theta = (float) msg.get(3).doubleValue(); //Reading from channel 3
      println("----- THETA VALUE ----- \n", theta);
    }
    
  // get alpha value
    if(msg.checkAddrPattern("Person0/elements/alpha_absolute") == true) {
      println("----- READING ALPHA WAVES -----");
      alpha =  (float)msg.get(3).doubleValue(); //Reading from channel 3
      println("----- ALPHA VALUE ----- \n", alpha);
    }
}
