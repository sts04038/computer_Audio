import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

SamplePlayer music;
// store the length, in ms, of the music SamplePlayer
double musicLength;
// endListener to detect beginning/end of music playback, rewind, FF
Bead musicEndListener;

ControlP5 p5;

SamplePlayer tapePlay;
SamplePlayer tapeStop;
SamplePlayer tapeFastForward;
SamplePlayer tapeRewind;
SamplePlayer tapeReset;

Glide musicRateGlide;


void setup()
{
  size(300,150);
  ac = new AudioContext(); //it's declared in helper_functions
  p5 = new ControlP5(this);
  
  music = getSamplePlayer("fantasyOrchestra.wav");

  // get the length of the music sample to use in tape deck function button callbacks
  musicLength = music.getSample().getLength();
  
  tapePlay = getSamplePlayer("playSound.wav");
  tapePlay.pause(true);
  tapeStop = getSamplePlayer("stopSound.wav");
  tapeStop.pause(true);
  tapeReset = getSamplePlayer("resetSound.wav");
  tapeReset.pause(true);
  tapeFastForward = getSamplePlayer("fastForwardSound.wav");
  tapeFastForward.pause(true);
  tapeRewind = getSamplePlayer("rewindSound.wav");
  tapeRewind.pause(true);

  // create music playback rate Glide, set to 0 initially or music will play on startup
  musicRateGlide = new Glide(ac, 0, 500);
  // use rateGlide to control music playback rate
  // notice that music.pause(true) is not needed since
  // we set the initial playback rate to 0
  music.setRate(musicRateGlide);

  // create all of your button sound effect SamplePlayers
  // and connect them into a UGen graph to ac.out
  ac.out.addInput(music);
  ac.out.addInput(tapePlay);
  ac.out.addInput(tapeStop);
  ac.out.addInput(tapeReset);
  ac.out.addInput(tapeFastForward);
  ac.out.addInput(tapeRewind);

  // create a reusable endListener Bead to detect end/beginning of music playback
  musicEndListener = new Bead()
  {
    public void messageReceived(Bead message)
    {
      println("End & Beginning of tape");
      
      // Get handle to the SamplePlayer which received this endListener message
      SamplePlayer sp = (SamplePlayer) message;

      // remove this endListener to prevent its firing over and over
      // due to playback position bugs in Beads
      sp.setEndListener(null);
      
      // The playback head has reached either the end or beginning of the tape.
      // Stop playing music by setting the playback rate to 0 immediately
      setPlaybackRate(0, true);
      
      //play stop sound to simulate reaching end of tape in forward or reverse
      tapeStop.start(0);
      
    }
  };

  // Create the UI
  
  p5.addButton("Play")
    .setPosition(width / 2 - 50, 10)
    .setSize(width / 2, 20)
    .activateBy((ControlP5.RELEASE));
    
  p5.addButton("Rewind")
    .setPosition(width / 2 - 50, 35)
    .setSize(width / 2, 20)
    .activateBy((ControlP5.RELEASE));
  p5.addButton("FastForward")
    .setCaptionLabel("FastForward")
    .setPosition(width / 2 - 50, 60)
    .setSize(width / 2, 20)
    .activateBy((ControlP5.RELEASE));
    
  p5.addButton("Stop")
    .setPosition(width / 2 - 50, 85)
    .setSize(width / 2, 20)
    .activateBy((ControlP5.RELEASE));
  
  p5.addButton("Reset")
    .setPosition(width / 2 - 50, 110)
    .setSize(width / 2, 20)
    .activateBy((ControlP5.RELEASE));
    
    
  ac.start();
}

public boolean IsAtEndOfTape() {
  return(music.getPosition() >= musicLength);
}

public boolean IsAtStartOfTape() {
  return (music.getPosition() <= 0);
}

// Add endListener to the music SamplePlayer if one doesn't already exist
public void addEndListener() {
  if (music.getEndListener() == null) {
    music.setEndListener(musicEndListener);
  }
}

// Set music playback rate using a Glide
public void setPlaybackRate(float rate, boolean immediately) {
  // Make sure playback head position isn't past end or beginning of the sample 
  if (music.getPosition() >= musicLength) {
    println("End of tape");
    // reset playback head position to end of sample (tape)
    music.setToEnd();
  }

  if (music.getPosition() < 0) {
    println("Beggining of tape");
    // reset playback head position to beginning of sample (tape)
    music.reset();
  }
  
  if (immediately) {
    musicRateGlide.setValueImmediately(rate);
  }
  else {
    musicRateGlide.setValue(rate);
  }
}

// Assuming you have a ControlP5 button called ‘Play’
public void Play(int value)
{
  // if playback head isn't at the end of tape, set rate to 1
  if (music.getPosition() < musicLength) {
    setPlaybackRate(1, false);
    addEndListener();
  }
  
  // always play the button sound
  tapePlay.start(0);
}

// Create similar button handlers for fast-forward, rewind, stop and reset
public void FastForward(int value) {
  println("FF Pressed");
  // if playback head isn't at the end of tape, set rate to 3x
  if (music.getPosition() < musicLength) {
    setPlaybackRate(3, false);
    addEndListener();
  }
  //always play the button sound
  tapeFastForward.start(0);
}

public void Stop(int value) {
  tapeStop.start(0);
  setPlaybackRate(0, false);
}

public void Rewind(int value) {
  println("RWD pressed");
  //if playback head isn't at beginning of tape, set rate to -4
  if (music.getPosition() > 0) {
    setPlaybackRate(-4, false);
    addEndListener();
  }
  //always play the button sound
  tapeRewind.start(0);
}

public void Reset(int value) {
  tapeReset.start(0);
  music.reset();
  setPlaybackRate(0, true);
}

void draw() {
  background(0);  //fills the canvas with black (0) each frame
  
}
