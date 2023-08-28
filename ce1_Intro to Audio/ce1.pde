import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions


ControlP5 p5;
SamplePlayer buttonSound;
Gain gain;
Glide gainGlide;
Glide reverseGlide;


//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
  p5 = new ControlP5(this);
  
  buttonSound = getSamplePlayer("colorscrimsontears__demonic-voice.wav");
  buttonSound.pause(true);
  gain = new Gain(ac, 1, .5);
  reverseGlide = new Glide(ac, 1300, 400);
  
  gain.addInput(buttonSound);
  
  ac.out.addInput(gain);
  
  p5.addSlider("GainSlider")
  .setPosition(40,10)
  .setSize(40,100)
  .setRange(0,100)
  .setValue(50);
  
  p5.addSlider("ReverseSlider")
  .setPosition(100,10)
  .setSize(40,100)
  .setRange(70,10000)
  .setValue(50);
  
  
  p5.addButton("Play")
  .setPosition(200,5)
  .setSize(40,20);
  //.activateBy((ControlP5.RELEASE));
  
  
  ac.start();
}

public void GainSlider(int value) {
  gain.setGain(((float) value) / 10);
}

public void ReverseSlider(int value) {
  reverseGlide.setValue(value);
 
}

public void Play(int val){
  //reseint sound when the button is clicked
  buttonSound.setToLoopStart();
  buttonSound.start();
  //below code works for restarting loop but won't work to start music
  //buttonSound.reset();
}


void draw() {
  background(0);  //fills the canvas with black (0) each frame
  
}
