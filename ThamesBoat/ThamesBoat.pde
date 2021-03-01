import processing.serial.*;

int numPics = 52;

Serial myPort;  // Create object from Serial class
String val;
String delim = "[, ]";
String[] tokens;
int[] values = new int[6];

int view = 1;
int oldview = 1;
int orientation = 1; //1 forward / downriver; -1 backward
boolean redStateChange = true;
int loopIterations = 0;

PImage pics[] = new PImage[numPics+1];
StringBuilder base;
String ending = ".jpg";

PImage boat;
PImage aliens;
int lx, ly, rx, ry, alienChance, alienON;


//HELPER FUNCTIONS--------------------------
void correctView() {
  if(view <= 0) {
    view = (orientation > 0) ? 1 : 2;
  } else if(view > numPics) {
    view = (orientation > 0) ? (numPics-1) : numPics;
  }
}

void prettyPrint(int[] nums) {
  System.out.print("\tVals:");
  for(int item : nums) {
    System.out.print(" " + item + ",");
  }
  System.out.print("_\n");
}

void prettyPrint(String[] tokens) {
  System.out.print("\tVals:");
  for(String item : tokens) {
    System.out.print(" " + item + ",");
  }
  System.out.print("_\n");
}

void prettyPrint(int view, int orient, boolean change) {
  String direction = (orient == 1) ? "Forward" : "Backward";
  System.out.print("\tView: " + view);
  System.out.print(", Orientation: " + orient + ", Dir: " + direction);
  System.out.print(", Change: " + change + "\n");
}

//This looks ridic, but doing this for readability and only doing one draw
//function that draws arcs
void bowLight() {
  glowingAlt(590, 460, 60, 60, HALF_PI, PI+HALF_PI, #E74C3C, #E74C3C, true);
  glowingAlt(590, 460, 60, 60, PI+HALF_PI, TWO_PI+HALF_PI, #2ECC71, #2ECC71, true);
}

void sternLight() {
  glowingAlt(590, 460, 60, 60, 0, TWO_PI, #FFFFFF, #FFFFFF, true);
}

void glowingAlt(float x, float y, float w, float h, float start, float stop, color shapeColor, color glowColor, boolean effectOn) {
  noFill();
  if (effectOn) {
    for (int i=0; i<5; i++) {
      strokeWeight((2+i)*(2+i));
      stroke(glowColor, 30);
      arc(x, y, w, h, start, stop);
    }
  }

  noStroke();
  fill(shapeColor);
  arc(x, y, w, h, start, stop);
}

void showAliens(int side) {
 
  pushMatrix();
  
  if(side == 3) {
    translate(lx, ly);
    rotate(-PI/24);
  } else if(side == 4) {
    translate(rx, ry);
    rotate(PI/24.0);
  }
  
  image(aliens, 0, 0, aliens.width/2, aliens.height/2); 
  popMatrix();
  
}

//BEGIN PROCESSING SCRIPT----------------------------
void setup() {
  size(1220, 600);
  
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[2]; //usually 4
  
  myPort = new Serial(this, portName, 115200);
  
  for(int i = 1; i < pics.length; i++) { // Using indices 1-52 
    base  = new StringBuilder("../Assets/00");
    
    if(i < 10) {
      base.append("0");
    }
    
    base.append(Integer.toString(i));
    base.append(ending);
    
    pics[i] = loadImage(base.toString());
    pics[i].resize(1220, 600);
  }
  
  boat = loadImage("../Assets/Extras/bowTransparentTest.png");
  boat.resize(1220,600);
  aliens = loadImage("../Assets/Extras/aliens.png");
  lx = -40;
  ly = 95;
  rx = 942;
  ry = 95;
  //alienON = 0;
}

// Serial line:
// X,Y,Z,R,G,S: 1878, 1859, 1, 0, 0, 0
// Red changes orientation

void draw() {
  
  //DRAWING VIEW-------------------------------------
  //background(pics[view]);
  imageMode(CORNER);
  image(pics[view],0,0);
  image(boat, 0, 25);
  if(orientation > 0) {
    bowLight();
  } else {
    sternLight();
  }
  
  if(oldview != view) {
    alienChance = int(random(5));
    //if(alienChance == 7) {
    //  alienON = 1;
    //} else if(alienChance > 9) {
    //  alienON = 2;
    //} else {
    //  alienON = 0;
    //}
  }
  
  if(alienChance >= 3) {
    showAliens(alienChance);
  }
  
  oldview = view;
  
  //READING FROM PORT----------------------------------
  if ( myPort.available() > 0) {  // If data is available,
    //val = myPort.read();         // read it and store it in val
    val = myPort.readStringUntil('\n');
  }
  val = trim(val);
  System.out.println(val);
  
  //FINDING STATE FOR NEXT ITERATION--------------------
  if (val != null && val.length() > 12) {    //parse Serial line into tokens
    tokens = val.substring(13).split(delim); //starts parsing after colon+space    
    if(tokens.length == 6) {
      for(int i = 0; i < 6; i++) { //len established above
        tokens[i] = trim(tokens[i]);
        values[i] = Integer.parseInt(tokens[i]);
      }
      
      //prettyPrint(values); // For testing
      prettyPrint(view, orientation, redStateChange);
      
      // Red button reverses view and orientation
      if((redStateChange == true) && (values[3] == 1)) {
        orientation *= -1; // earlier error from +=
        redStateChange = false;
        if((view % 2) == 0) {
          view -= 1;
        } else {
          view += 1;
        }
      } else if((redStateChange == false) && (values[3] == 0)) {
        redStateChange = true;
      }
      
      // this block depends on values[] having valid data
      // A HACK
      if((loopIterations % 30) == 0) {
        if(values[1] > 1900) {    //go forward or backward depending on joystick
          view += (2 * orientation);  //not quite right bc need to check orientation
        } else if(values[1] < 1700) {
          view -= (2 * orientation);
        }
      }
    } 
  } 
  
  
  loopIterations++;
  //delay(75);
  correctView();
}
