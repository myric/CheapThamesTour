import processing.serial.*;

int numPics = 52;

Serial myPort;  // Create object from Serial class
String val;
String delim = "[, ]";
String[] tokens;
int[] values = new int[6];

int view = 1;
int orientation = 1;
boolean redStateChange = true;
int loopIterations = 0;

PImage pics[] = new PImage[numPics+1];
StringBuilder base;
String ending = ".jpg";

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

void setup() {
  size(1220, 600);
  
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[4];
  
  myPort = new Serial(this, portName, 115200);
  
  for(int i = 1; i < pics.length; i++) { // Using indices 1-52 
    base  = new StringBuilder("../TestOutput/00");
    
    if(i < 10) {
      base.append("0");
    }
    
    base.append(Integer.toString(i));
    base.append(ending);
    
    pics[i] = loadImage(base.toString());
    pics[i].resize(1220, 600);
  }
}

// Serial line:
// X,Y,Z,R,G,S: 1878, 1859, 1, 0, 0, 0
// Red changes orientation

void draw() {
  //background(pics[view]);
  imageMode(CORNER);
  image(pics[view],0,0);
  
  if ( myPort.available() > 0) {  // If data is available,
    //val = myPort.read();         // read it and store it in val
    val = myPort.readStringUntil('\n');
  }
  val = trim(val);
  System.out.println(val);
  
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
