import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions
ControlP5 p5;
SamplePlayer music;
SamplePlayer gps1;
SamplePlayer gps2;

//Gain Ugen controls the SamplePlayer volume
Gain masterGain;
Gain musicGain;

//Glide Ugens control the SamplePlayer gain and filter cutoff frequency
Glide masterGainGlide;
Glide musicGainGlide;
Glide filterGlide;

//Filter will swap between ducking and not ducking
BiquadFilter duckFilter;
float HP_CUTOFF = 5000.0;

//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
  
  p5 = new ControlP5(this);
  
  //EndListener to un-duck the music when gps guidance is finished
  Bead endListener = new Bead() {
    public void messageReceived(Bead message) {
      SamplePlayer sp = (SamplePlayer) message;
      // minimize effect of high-pass filtering by setting cutoff frequency 
      //to very low value
      filterGlide.setValue(10.0);
      //duckFilter.setType(BiquadFilter.AP)
      //set gain to 100%
      musicGainGlide.setValue(1.0);
      sp.pause(true);
    }
  };
  music = getSamplePlayer("intermission.wav");
  gps1 = getSamplePlayer("service1.wav");
  gps2 = getSamplePlayer("forKoreanService.wav");
  
  gps1.setEndListener(endListener);
  gps2.setEndListener(endListener);
  
  //configute music to loop
  music.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  
  gps1.pause(true);
  gps2.pause(true);
  // Gain & Glide used to duck music by decreasing Gain/Volume
  musicGainGlide = new Glide(ac, 1.0, 500);
  musicGain = new Gain(ac, 1, musicGainGlide);
  //create the maseter Gain & Glide Ugens
  masterGainGlide = new Glide(ac, 10.0, 500);
  masterGain = new Gain(ac, 1, masterGainGlide);
  
  //BiquadFilter & cutoff filter Glide to duxk music by filtering
  filterGlide = new Glide(ac, 10.0, 500);
  duckFilter =new BiquadFilter(ac, BiquadFilter.HP, filterGlide, 0.6);
  
  //create the Ugen graph
  //connect the music to the filter
  duckFilter.addInput(music);
  //connect the filter to the musicGain
  musicGain.addInput(duckFilter);
  
  //connect musicGain to masterGain
  masterGain.addInput(musicGain);
  //connect voice1/voice2 to materGain
  masterGain.addInput(gps1);
  masterGain.addInput(gps2);
  //output the final sound
  ac.out.addInput(masterGain);
  
  //create the GainSlider(must named the method to run on it)
  p5.addSlider("GainSlider")
    .setPosition(20,20)
    .setSize(20,200)
    .setValue(30.0)
    .setLabel("Master Gain");
  //creates play button, the sound played, once the onClick in active
  p5.addButton("PlayGPS1")
    .setPosition(width/2 -20, 110)
    .setSize(width/2 - 20, 20)
    .setLabel("Play GPS 1");
  p5.addButton("PlayGPS2")
  .setPosition(width/2 - 20, 140)
  .setSize(width/2 - 20, 20)
  .setLabel("Play GPS 2");
  //start the audio contect
  ac.start();
                  
}

//create the Play method
public void PlayGPS1() {
  // pause gps2 in case it is playing
  gps2.pause(true);
  //duck audio with high-pass filtering and lowering gain
  filterGlide.setValue(HP_CUTOFF);
  //duckFilter.setType(BiquadFilter.HP);
  musicGainGlide.setValue(1.0);
  //reset play head to start of sample
  gps1.setToLoopStart();
  //start playing gps1 sample
  gps1.start();
}
public void PlayGPS2() {
  //pause gps1 in case it is playing
  gps1.pause(true);
  //duck audio w/ high-pass filtering& lowering gain
  filterGlide.setValue(HP_CUTOFF);
  //duckFilter.setType(BiquadFilter.HP);
  musicGainGlide.setValue(1.0);
  //reset play head to start of sample
  gps2.setToLoopStart();
  //start playing gps2 sample
  gps2.start();
}
// master gain slider
public void GainSlider(float value) {
  masterGainGlide.setValue(value/100.0);
}
  

void draw() {
  background(0);  //fills the canvas with black (0) each frame
  
}
