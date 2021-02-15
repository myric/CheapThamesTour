import processing.serial.*;

int numPics = 10;

Serial myPort;  // Create object from Serial class
String val;
String delim = "[, ]";
String[] tokens;
int[] values = new int[6];

int view = 1;

PImage pics[] = new PImage[numPics];
StringBuilder base;
String ending = ".jpg";

void correctView() {
  if(view <= 0) {
    view = 1;
  } else if(view >= numPics) {
    view = numPics-1;
  }
}

void setup() {
  size(1220, 600);
  
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[4];
  
  myPort = new Serial(this, portName, 115200);
  
  for(int i = 1; i < pics.length; i++) {
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
  
  if (val != null && val.length() > 7) {    //parse Serial line into tokens
    tokens = val.substring(13).split(delim); //starts parsing after colon+space
    if(tokens.length == 6) {
      for(int i = 0; i < tokens.length; i++) {
        tokens[i] = trim(tokens[i]);
        values[i] = Integer.parseInt(tokens[i]);
      }
      
      // this block depends on values[] having valid data
      if(values[1] > 1900) {    //go forward or backward depending on joystick
        view += 2;  //not quite right bc need to check orientation
      } else if(values[1] < 1700) {
        view -= 2;
      }
    } 
  } 
  
  
  
  delay(75);
  correctView();
}
