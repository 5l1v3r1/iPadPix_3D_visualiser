import themidibus.*; //MIDI

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
Clusters tpx;
int lastTime;

MidiBus myBus;
boolean startedListening=false;

boolean DRAW = false;
PFont font ;
Schema schema2;
String[] filenames;
boolean useRecordedClusters;

void setup() {
  //size(512, 512, P3D);
  size(100, 100);
  if(DRAW){
    font = loadFont ("font.vlw");
  }
  //delay(3000);
  udp_port=8123; //iPadPix port 8123
  tpx = new Clusters(udp_port);
  myBus = new MidiBus(this, 0, 1); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  //myBus.list();
  delay(3000);  //FIXME: without this delay the program doesn't run!
  //tpx.stopListening();
  lastTime = millis();
  java.io.File folder= new java.io.File(dataPath("/Users/ozel/Documents/Processing/iPadPix_3D_visualiser/recordedClusters"));
  filenames = folder.list();
  println("found " + filenames.length + " recorded cluster packets");

  try {
    schema2 = new Schema.Parser().parse(new File("/Users/ozel/Documents/Processing/iPadPix_3D_visualiser/data/tpx.json"));
  } 
  catch (IOException e) {
    System.err.println(e);
  }
  useRecordedClusters = true;
  println("setup done");
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
      Note note = new Note(9, 36, 127);
      myBus.sendNoteOn(note);
    } else if (key == 's') {
      println("stored clusters: " + tpx.tpx_clusters.size());
    }
  }
  if ( udp_port == 0  && (millis() - lastTime) > random(1*100, 3*1500)) {
    if(useRecordedClusters){
      String randomFile = filenames[int(random(0,filenames.length-1))];
      parsePacketHere(loadBytes("recordedClusters/" + randomFile));
      lastTime = millis();
    } else {
      Cluster newCluster = tpx.randomCluster();  
      tpx.addCluster(newCluster); // the same: tpx.tpx_clusters.add(tpx.randomCluster()); 
      lastTime = millis();
    }
  } else if (startedListening == false && ((millis() - lastTime) > 4000) && udp_port != 0) {
    tpx.startListening();
    startedListening= true;
  }
}


void draw() {
  update();
  if(DRAW){
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
  }

  List<Integer> ClustersToDelete = new ArrayList<Integer>();

  //if (tpx.tpx_clusters.size() > 0) {
  //for (Iterator<DrugStrength> it = aDrugStrengthList.iterator(); it.hasNext(); ) {
  //DrugStrength aDrugStrength = it.next();
  if(tpx.tpx_clusters.size() > 0){
    for (int i=tpx.tpx_clusters.size()-1; i>=0; i-- ) {
      Cluster myCluster = tpx.tpx_clusters.get(i);
      //for (Iterator<Cluster> it = tpx.tpx_clusters.iterator(); it.hasNext();) {
      //  Cluster myCluster = it.next();
      if ( myCluster.alive == true) {
        myCluster.sound();
        if(DRAW){
          myCluster.draw(); //[i]
        }
        //print("c ");
      }
      do {
        myCluster.age=(millis()-myCluster.creationTime);
      } while (myCluster.creationTime<3000);
      if ((millis() -  myCluster.creationTime) > 4*1000) {
        myCluster.alive = false;
        //tpx.lock = true;
        ClustersToDelete.add(i);
        //println("queueing cluster for deletion " + i);
        //tpx.lock = false;
        myCluster=null;
      }
      //println();
    }
  }
  //clean up
  for (Integer num : ClustersToDelete) {
    tpx.lock = true;
    tpx.tpx_clusters.remove(int(num));
    //println("REMOVING cluster " + num);
    tpx.lock = false;
    //num = null;
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