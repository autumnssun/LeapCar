 
#include <Servo.h>
// Declare some global variables
String stack;
boolean stacking=false, //this is used to read the serial, and do string procesing
        carShouldStop=true;

int const stableSpeed=1000; // 1000 is the begining value for your motor speed, which will not turn the wheel 
          
Servo motor[4];              // we can manage 4 motors, but in this case we only use 2
int const pins[4]={3,5,7,8}; // plug your esc signal wires to pin 3, and 5
int speeds[4];               // Speed of the motors is stored in a seperated array
float easing = 0.05;

int commaIndex;              // used in string processing

void setup() {
  Serial.begin(115200);
  setup_rotors(); // Set up the rotor, by arming the esc;
}


void setup_rotors(){  
  for (int i=0;i<4;i++){
    motor[i].attach(pins[i]);
    motor[i].write(30); // Check your esc's document to know the value, mine is 30
  }
  delay(2000);   // wait for 2 sec make sure that the esc is armed properly
}


void loop() { // doing the main activities here
  rx();       // Listen to the Xbee, this function will manipulate the speed array according to what we are sending from the processing code
  if (carShouldStop){
    stopTheCar();
  }else{
    setRotorSpeed();
  }

}

//package listener is called by the main loop
// string format sended by processing (host) "{<1stMotorSpeed>,<2ndMotorSpeed>,<3rdMotorSpeed>,<4thMotorSpeed> }"
// it shoudl look like: {1200,1300,0,0} 

void rx(){
  while (Serial.available()){
    char chr=(char) Serial.read();

    if (chr=='{'){ // "{" indicate Start of a new package
      stack="";    //reset the stack
      stacking=true; // start stacking
    }
    if(chr=='}'){ //"}" indicate end of the packages
      stacking=false;  // stop stacking
      speeds[3]=stack.toInt(); // record the last stack to the speeds[3]
      commaIndex=0;        // reset the comma index
      //print out the result
      prt();
      break;
    }else{
      if (chr==','){ // if there is a new seperator ','
       commaIndex++;  // next speed  motor value
       switch (commaIndex) { //save the stack to the according speed array
          case 1:
            speeds[0]=stack.toInt();
            break;
          case 2:
            speeds[1]=stack.toInt();
            break;
          default: 
            speeds[2]=stack.toInt();
        }
        stack=""; // then reset the stack
      }else
      if (chr!='{'){
        if(chr=='A'){carShouldStop=true;}
        else{
          carShouldStop=false;
          stack+=chr;   /*read the character and add it in the stack*/
        }
      }
    }
  }
}

void stopTheCar(){
  //autoPilot
  //Serial.print("auto - ");
  for (int i=0;i<4;i++){
    speeds[i]=stableSpeed;
  }
  setRotorSpeed();
  prt();//for debuging comment it out if you dont nee it
}



void prt(){
  Serial.print(speeds[0]);
  Serial.print(" ");
  Serial.print(speeds[1]);
  Serial.print(" ");
  Serial.print(speeds[2]);
  Serial.print(" ");
  Serial.println(speeds[3]);
}


void setRotorSpeed(){
  //speeds array contains 4 values each should range from 1000-1500 // depend on your processing mapping numbers
  for (int i=0;i<4;i++){
    motor[i].writeMicroseconds(speeds[i]);
  }
}
