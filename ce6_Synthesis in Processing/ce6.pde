import controlP5.*;
import beads.*;
import java.util.Arrays; 

AudioContext ac;
ControlP5 p5;

int waveCount = 10;
float baseFrequency = 440.0;

// Custom WavePlayer buffer used to produce triangle waves
Buffer CosineBuffer = new CosineBuffer().getDefault();

// Array of Glide UGens for series of harmonic frequencies for each wave type (fundamental wave, square, triangle, sawtooth)
Glide[] waveFrequency = new Glide[waveCount];

// Array of Gain UGens for harmonic frequency series amplitudes (i.e. baseFrequency + (1/3)*(baseFrequency*3) + (1/5)*(baseFrequency*5) + ...)
Gain[] waveGain = new Gain[waveCount];

Gain masterGain;
Glide masterGainGlide;
// Array of wave wave generator UGens - will be summed by masterGain to additively synthesize square, triangle, sawtooth waves
WavePlayer[] waveTone = new WavePlayer[waveCount];

Button b1, b2, b3, b4;
Slider[] s = new Slider[10];

void setup() {
  size(600,400);
  
  float waveIntensity = 1.0;
  ac = new AudioContext();
  p5 = new ControlP5(this);
  
  masterGainGlide = new Glide(ac, .2, 200);  
  masterGain = new Gain(ac, 1, masterGainGlide);
  ac.out.addInput(masterGain);

  // create a UGen graph to synthesize a square wave from a base/fundamental frequency and 9 odd harmonics with amplitudes = 1/n
  // square wave = base freq. and odd harmonics with intensity decreasing as 1/n
  // square wave = baseFrequency + (1/3)*(baseFrequency*3) + (1/5)*(baseFrequency*5) + ...
    
  for( int i = 0, n = 1; i < waveCount; i++, n++) {
    // create the glide that will control this WavePlayer's frequency
    // create an array of Glides in anticipation of connecting them with ControlP5 sliders
    waveFrequency[i] = new Glide(ac, baseFrequency * n, 200);
    
    // Create harmonic frequency WavePlayer - i.e. baseFrequency * 3, baseFrequency * 5, ...
    //waveTone[i] = new WavePlayer(ac, waveFrequency[i], CosineBuffer);
    waveTone[i] = new WavePlayer(ac, waveFrequency[i], Buffer.SINE);
    
    // Create gain coefficients for each harmonic - i.e. 1/3, 1/5, 1/7, ...
    waveIntensity = n == 1 ? 1.0 : 0; // fundamental only
    // For a square wave, we only want odd harmonics, so set all even harmonics to 0 gain/intensity
    //waveIntensity = (n % 2 == 1) ? (float) (1.0 / n) : 0; // square
    //waveIntensity = (n % 2 == 1) ? 1.0 / sq(n) : 0; // triangle
    //waveIntensity = 1.0 / n; // sawtooth
        
    waveGain[i] = new Gain(ac, 1, waveIntensity); // create the gain object
    waveGain[i].addInput(waveTone[i]); // then connect the waveplayer to the gain
  
    // finally, connect the gain to the master gain
    // masterGain will sum all of the wave waves, additively synthesizing a square wave tone
    masterGain.addInput(waveGain[i]);
  }
  
  p5.addButton("modeSwitch").setPosition(410, 10).setSize(180, 30).setLabel("Mode").activateBy((ControlP5.RELEASE));
  b1 = p5.addButton("sineButton").setPosition(410, 50).setSize(180, 30).setLabel("Sine").activateBy((ControlP5.RELEASE));
  b2 = p5.addButton("squareButton").setPosition(410, 90).setSize(180, 30).setLabel("Square").activateBy((ControlP5.RELEASE));
  b3 = p5.addButton("triangleButton").setPosition(410, 130).setSize(180, 30).setLabel("Triangle").activateBy((ControlP5.RELEASE));
  b4 = p5.addButton("sawtoothButton").setPosition(410, 170).setSize(180, 30).setLabel("Sawtooth").activateBy((ControlP5.RELEASE));
 
  s[0] = p5.addSlider("gainSlider0").setPosition(410, 50).setSize(180, 15).setRange(55, 3520).setValue(420);
  s[1] = p5.addSlider("gainSlider1").setPosition(410, 70).setSize(180, 15).setRange(0, 1).setValue(0);
  s[2] = p5.addSlider("gainSlider2").setPosition(410, 90).setSize(180, 15).setRange(0, 1).setValue(0);
  s[3] = p5.addSlider("gainSlider3").setPosition(410, 110).setSize(180, 15).setRange(0, 1).setValue(0);
  s[4] = p5.addSlider("gainSlider4").setPosition(410, 130).setSize(180, 15).setRange(0, 1).setValue(0);
  s[5] = p5.addSlider("gainSlider5").setPosition(410, 150).setSize(180, 15).setRange(0, 1).setValue(0);
  s[6] = p5.addSlider("gainSlider6").setPosition(410, 170).setSize(180, 15).setRange(0, 1).setValue(0);
  s[7] = p5.addSlider("gainSlider7").setPosition(410, 190).setSize(180, 15).setRange(0, 1).setValue(0);
  s[8] = p5.addSlider("gainSlider8").setPosition(410, 210).setSize(180, 15).setRange(0, 1).setValue(0);
  s[9] = p5.addSlider("gainSlider9").setPosition(410, 230).setSize(180, 15).setRange(0, 1).setValue(0);
  
  // Reset WavePlayers and Gain coefficients to play triangle wave
  //triangleWave(); 
  ac.start();
}

boolean sliders = false;
public void modeSwitch() {
  sliders = !sliders;
  if (sliders) {
    b1.hide();
    b2.hide();
    b3.hide();
    b4.hide();
    for (int i = 0; i < 10; i++) {
      s[i].show();
    }
  } else {
    b1.show();
    b2.show();
    b3.show();
    b4.show();
    for (int i = 0; i < 10; i ++) {
      s[i].hide();
    }
  }
}
  
public void gainSlider0(float v) {
  for(int i = 0, n = 1; i < waveCount; i++, n++) {
    waveFrequency[i].setValue(v * n);
  }
}


public void triangleWave() {
  float waveIntensity;

  for( int i = 0, n = 1; i < waveCount; i++, n++) {
    // triangle wave is a sum of Cosine WavePlayers
    waveTone[i].setBuffer(CosineBuffer);
    // fundamental, square and sawtooth should use Sine WavePlayers, so
    // waveTone[i].setBuffer(Buffer.SINE);
    
    // Create gain for each harmonic - i.e. 1/3, 1/5, 1/7, ...
    // For a triangle wave, we only want odd harmonics, so set all even harmonics to 0 gain/intensity
    waveIntensity = (n % 2 == 1) ? 1.0 / sq(n) : 0; // triangle
    
    println(n, ": ", waveIntensity, " * ", baseFrequency * n);
    
    waveGain[i].setGain(waveIntensity); // set gain for each harmonic
  }
}


public void gainSlider1(float v) { waveGain[1].setGain(v); }
public void gainSlider2(float v) { waveGain[2].setGain(v); }
public void gainSlider3(float v) { waveGain[3].setGain(v); }
public void gainSlider4(float v) { waveGain[4].setGain(v); }
public void gainSlider5(float v) { waveGain[5].setGain(v); }
public void gainSlider6(float v) { waveGain[6].setGain(v); }
public void gainSlider7(float v) { waveGain[7].setGain(v); }
public void gainSlider8(float v) { waveGain[8].setGain(v); }
public void gainSlider9(float v) { waveGain[9].setGain(v); }

public void sineButton() {
  for (int i = 0, n = 1; i < waveCount; i++, n++) {
    waveTone[i].setBuffer(Buffer.SINE);
    if (i > 0) {
      s[i].setValue(n == 1 ? 1.0 : 0);
    }
  }
}

public void squareButton() {
  for (int i = 0, n = 1; i < waveCount; i++, n++) {
    waveTone[i].setBuffer(Buffer.SINE);
    if (i > 0) {
      s[i].setValue((n % 2 == 1) ? (float) (1.0 / n) : 0);
    }
  }
}
//The triangle wave additive synthesis formula uses cosine harmonics
public void triangleButton() {
  for (int i = 0, n = 1; i < waveCount; i++, n++) {
    //Triangle wave is formed from sum of Cosine waves
    waveTone[i].setBuffer(CosineBuffer);
    if (i > 0) {
      s[i].setValue((n % 2 == 1) ? 1.0 / sq(n) : 0);
    }
  }
}
public void sawtoothButton() {
  for (int i = 0, n = 1; i < waveCount; i++, n++) {
    waveTone[i].setBuffer(Buffer.SINE);
    if (i > 0) {
      s[i].setValue(1.0 / n);
    }
  }
}

// Oscilliscope trace
void drawWaveform() {
  fill (0, 32, 0, 32);
  rect (0, 0, 400, 400);
  stroke (32);
  for (int i = 0; i < 11 ; i++){
    line (0, i*75, 400, i*75);
    line (i*75+25, 0, i*75+25, 400);
  }
  stroke (0);
  line (400/2, 0, 400/2, 400);
  line (0,400/2, 400, 400/2);
  stroke (128,255,128);
  int crossing=0;
  // draw the waveforms so we can see what we are monitoring
  for(int i = 0; i < ac.getBufferSize() - 1 && i<400+crossing; i++)
  {
    if (crossing==0 && ac.out.getValue(0, i) < 0 && ac.out.getValue(0, i+1) > 0) crossing=i;
    if (crossing!=0) {
      line( i-crossing, 400/2 + ac.out.getValue(0, i)*300, i+1-crossing, 400/2 + ac.out.getValue(0, i+1)*300 );
    }
  }
  fill (0);
  stroke (0);
  rect (400, 0, 200, 400);
}

void draw() {
  drawWaveform();
}
