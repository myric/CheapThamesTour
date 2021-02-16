/**********************************************************************
  Filename    : BoatController
  Description : Reads data from joystick for Processing
  Modification: 2020/02/14
**********************************************************************/

int xyzPins[] = {13, 12, 14};   //x,y,z pins
int red_button = 15;
int green_button = 0;
int spst = 4; //TO UPDATE

int red = 0, green = 0;
int switcher = 0;

void setup() {
  Serial.begin(115200);
  pinMode(xyzPins[2], INPUT_PULLUP);  //z axis is a button.
  pinMode(red_button, INPUT);
  pinMode(green_button, INPUT);
  pinMode(spst, INPUT);
}

void loop() {
//  red = 0;
//  green = 0;
  
  int xVal = analogRead(xyzPins[0]);
  int yVal = analogRead(xyzPins[1]);
  int zVal = digitalRead(xyzPins[2]);

  red = (digitalRead(red_button) == LOW) ? 1 : 0;
  green = (digitalRead(green_button) == LOW) ? 1 : 0;
  switcher = (digitalRead(spst) == LOW) ? 1 : 0;
  
  Serial.printf("X,Y,Z,R,G,S: %d,\t%d,\t%d,\t%d,\t%d,\t%d\n", xVal, yVal,
  zVal, red, green, switcher);

  delay(100);
}
