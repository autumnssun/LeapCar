import de.voidplus.leapmotion.*; 
// before you begin: make sure you have LEAP MOTION SDK installed
// go to https://github.com/nok/leap-motion-processing to install the the processing-leapmotion library.
import processing.serial.*;

LeapMotion leap; //LEAPMOTION
Serial port;// Serial port of the xbee object. // Set up xbee in AT mode
Hand rightHand; 
Hand leftHand;
float steerFactor=5;

void setup() {
  size(1500, 1000, OPENGL);
  background(255);
  leap = new LeapMotion(this);
  port = new Serial(this,"/dev/tty.usbserial-A901J1S5", 115200); 
  /* in terminal run  $ ls /dev/tty.*
      
      to list all the port and look for your Xbee adaptor
      more about xbee tutorial can be see at 
      https://www.youtube.com/watch?v=odekkumB3WQ 
      Make sure you check out the whole series by tunnelsup
      Or at least look at how to set up xbee in at mode and do a simple chat program
      
      
      Mac User: there are xctu software for you to download at:
      http://www.digi.com/support/kbase/kbaseresultdetl?id=2125
  */
}

void draw() {
  background(255);
  //print((leap.getHands()).size());
  // Check if there is no hand the leap, then send slow down command to arduino
  if(leap.getHands().size()>0)
  //loop through the Hands arraylist provided by the leap motion,  
  // THEN save the right hand and left hand for caculation

  for (Hand hand : leap.getHands ()) {
    if (hand.isLeft()){
      leftHand=hand;
    }
    if (hand.isRight()){
      rightHand=hand;
    }
    //Both hand need to be presened to stred
    if(rightHand!=null && leftHand!=null){
      //getMotorsSpeed- calculate the speed of 2 motors
      // tx ();
      tx(getMotorsSpeed(rightHand,leftHand));
      leftHand=null;
      rightHand=null;
    }
  }else{
    //send slowdowncommand;
    port.write("{A}");
    println("auto");
  }
}


public float[] getMotorsSpeed(Hand rightHand,Hand leftHand){
    float[] returnArray= new float[4];
    //
    float angle=getAngle(rightHand,leftHand);
    float speed=getSpeed(rightHand,leftHand);

    //callculate the speed differents base on the angle, and map it accordingly 
    float spA= map(speed+angle*steerFactor,500,1200,1400,1100);
    float spB= map(speed-angle*steerFactor,500,1200,1400,1100);
    //println(spA+"  "+ spB);
    
    returnArray[0]=spA;
    returnArray[1]=spB;
    returnArray[2]=0;
    returnArray[3]=0;
    
    return returnArray; 
}


public float getSpeed(Hand rightHand,Hand leftHand) {
      PVector rightHandStbPos=rightHand.getStabilizedPosition();
      PVector leftHandStbPos = leftHand.getStabilizedPosition();
      
      PVector right2D= new PVector(rightHandStbPos.x, rightHandStbPos.y);
      PVector left2D= new PVector(leftHandStbPos.x, leftHandStbPos.y);
      
      int returnSpeed=0;
      
      returnSpeed=int (right2D.x-left2D.x);
      //println(returnSpeed);
      return returnSpeed; //distance between two hands is caculated in mm
}

public float getAngle(Hand rightHand,Hand leftHand) {

      PVector rightHandStbPos=rightHand.getStabilizedPosition();
      PVector leftHandStbPos = leftHand.getStabilizedPosition();
      //print(leftHandStbPos) //uncomment this to see the values
      //Convert the 3D vector to new 2D vector, we dont need the z axis, simplify things
      PVector right2D= new PVector(rightHandStbPos.x, rightHandStbPos.y);
      PVector left2D= new PVector(leftHandStbPos.x, leftHandStbPos.y);
      
      // the ground vector is the vector along the x axis, why x axis?
      /* have a look at the leap motion documentation:
        https://developer.leapmotion.com/documentation/csharp/practices/Leap_Orientation_and_Tutorial_Guidelines.html
      */
      PVector groundVector = new PVector(1,0);
      PVector addedVec=(PVector.sub(right2D, left2D));

      //Visaulization draw the lines on the processing window canvas
      stroke(204, 0, 0);
      strokeWeight(2);
      line(right2D.x,right2D.y,left2D.x,left2D.y);
      
      if(right2D.y>left2D.y){
        return -degrees(PVector.angleBetween(addedVec,groundVector));
      }else{
        return degrees(PVector.angleBetween(addedVec,groundVector));
      }
      
}

//this function is used to send data using the xbee
public void tx(float []ar ){
  String sending=("{"+(int)ar[0]+","+(int)ar[1]+","+(int)ar[2]+","+(int)ar[3]+"}");
  port.write(sending);
  println(sending);
}

// ========= CALLBACKS =========
/*

void leapOnInit() {
  // println("Leap Motion Init");
}
void leapOnConnect() {
  // println("Leap Motion Connect");
}
void leapOnFrame() {
  // println("Leap Motion Frame");
}
void leapOnDisconnect() {
  // println("Leap Motion Disconnect");
}
void leapOnExit() {
  // println("Leap Motion Exit");
}
*/
