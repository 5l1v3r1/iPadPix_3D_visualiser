import themidibus.*; //MIDI //<>//

//import processing.serial.*;
//import processing.sound.*; 

import hypermedia.net.UDP; //UDP
import java.io.File;
import java.io.IOException;

import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;

import java.io.EOFException;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
float rotX=0, rotY=0, rotZ=0, camX=0, camY=0, camZ=-300;
int udp_port; 
PFont font ;
Clusters tpx;
int lastTime;

MidiBus myBus;
boolean startedListening=false;

void setup() {
  size(255, 255, P3D);
  tpx = new Clusters(udp_port);
  myBus = new MidiBus(this, 0, 1); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  delay(1000);  //without this delay the program doesn't run!
  font = loadFont ("font.vlw");
  //arduino= new Serial(this , "/dev/tty.usbmodem14241" , 9600);
  //arduino.bufferUntil('\n'); //\r
  //tpx.stopListening();
  lastTime = millis();
  udp_port=0; //iPadPix port 8123
}



void update() {
  if (keyPressed)
  {
    if (key ==' ')
    {
      rotX=0;
      rotY=0;
      camX=0;
      camY=0;
      camZ=-300;
    }
  }
  if ( udp_port == 0  && (millis() - lastTime) > random(1*100, 3*1500)) {
    Cluster newCluster = tpx.randomCluster();  
    tpx.addCluster(newCluster); // the same: tpx.tpx_clusters.add(tpx.randomCluster());
    lastTime = millis();
  }
}

void draw() {
  update();
  if (startedListening == false && millis() > 4000 && udp_port != 0) {
    tpx.startListening();
    startedListening= true;
  }
  textFont(font);
  lights();
  background(0);
  //noStroke();
  translate(camX, camY, camZ);
  translate(width/2.0-camX, height/2.0-camY);
  rotateY(rotY);
  rotateX(rotX);
  rotateZ(rotZ);
  translate(-(width/2.0-camX), -(height/2.0-camY));
  drawCenterObject();

  List<Integer> ClustersToDelete = new ArrayList<Integer>();

  //if (tpx.tpx_clusters.size() > 0) {
  //for (Iterator<DrugStrength> it = aDrugStrengthList.iterator(); it.hasNext(); ) {
  //DrugStrength aDrugStrength = it.next();
  for (int i=tpx.tpx_clusters.size()-1; i>=0; i-- ) {
    Cluster myCluster = tpx.tpx_clusters.get(i);
    //for (Iterator<Cluster> it = tpx.tpx_clusters.iterator(); it.hasNext();) {
    //  Cluster myCluster = it.next();
    if ( myCluster.alive == true) {
      myCluster.sound();
      //myCluster.draw(); //[i]
      print("c ");
    }
    do {
      myCluster.age=(millis()-myCluster.creationTime);
    } while (myCluster.creationTime<3000);
    if ((millis() -  myCluster.creationTime) > 4*1000) {
      myCluster.alive = false;
      //tpx.lock = true;
      ClustersToDelete.add(i);
      //tpx.lock = false;
      myCluster=null;
    }
  }
  //clean up
  println();
  for (Integer num : ClustersToDelete) {
    tpx.tpx_clusters.remove(num);
  }
}




void mouseDragged()
{
  if (mouseButton == LEFT)
  {
    //navigation style 1
    rotY += (pmouseX - mouseX)*0.01;
    rotX += (pmouseY - mouseY)*0.01;
    //navigation style 2
    //    rotX += (mouseX - pmouseX)*0.01;
    //    rotY += (mouseY - pmouseY)*0.01;
  }
  if (mouseButton == RIGHT)
  {
    //navigation style 1
    camX -= (pmouseX - mouseX);
    camY -= (pmouseY - mouseY);
    //navigation style 2
    //    camX -= (mouseX - pmouseX);
    //    camY -= (mouseY - pmouseY);
  }
  if (mouseButton == CENTER)
  {
    //navigation style 1
    camZ += (pmouseY - mouseY);
    //navigation style 2
    //    camZ += (mouseY - pmouseY);
  }
}

void drawCenterObject()
{
  pushMatrix();
  noStroke();
  translate(width/2, height/2, 0);
  fill(255);
  sphere(50);
  textureMode(NORMAL);
  PImage img = loadImage("radioactive.png");
  translate(0, 0, 50);
  image(img, -15, -15, 30, 30);
  stroke(0);
  popMatrix();
} 

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}