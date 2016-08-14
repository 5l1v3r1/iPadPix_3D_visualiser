class Cluster {
  //properties of eevery cluster object 
  List<Integer> x;
  List<Integer> y;
  List<Integer> e;
  float centerx; 
  float centery; 
  float totalEnergy;
  boolean alive;
  int creationTime;
  int age ;
  PVector dir;
  PVector pos;
  PVector finalPos;
  PVector velocity;
  PVector center;
  int type; //0 = electron, 1=photon, 2=e or photon 3=alpha particle 4=muon 5= unknown
  //SqrOsc square;
  boolean played;

  //create new cluster object
  Cluster(float cx, float cy, float te) {
    x = new ArrayList<Integer>();
    y = new ArrayList<Integer>();
    e = new ArrayList<Integer>();
    centerx = cx*width/255;
    centery =height-(cy*height/255);
    totalEnergy = te;
    alive = true;
    creationTime = millis();
    center = new PVector(width/2, height/2, 0);
    pos = center;
    velocity=new PVector(0, 0, 0);
    finalPos = new PVector(centerx, centery, 200.0); 
    dir = PVector.sub(finalPos, center); //dir = finalPos - center
    dir.normalize(); //
    //println(dir);
    played=false;
  }
  void addPixel(int xi, int yi, int ei ) {
    x.add(xi);
    y.add(yi);
    e.add(ei);
  }
  void draw() {

    pushMatrix();
    textFont(font);
    noStroke();
    if (type==0)
    {
      fill(255, 255-age/15, 255-age/15, 255-age/15);
    }
    if (type==1)
    {
      fill(255-age/15, 255-age/15, 255);
    }
    if (type==2)
    {
      fill(255-age/15, 255, 255-age/15);
    }
    if (type==3)
    {
      fill(255);
    }
    if (type==4)
    {
      fill(255);
    }


    stroke(255);
    line(width/2, height/2, 0.0, pos.x, pos.y, pos.z);
    noStroke();

    if (PVector.sub(pos, center).mag()+20 < PVector.sub(finalPos, center).mag() ) {
      if (type==0)
      {
        dir.mult(0.84);
      } else if (type==1)
      {
        dir.mult(0.90);
      } else if (type==2)
      {
        dir.mult(0.97);
      }//dir = dir * 0.94
      velocity.add(dir); //velocity = velocity + dir
      pos.add(velocity); //pos = pos + velocity
      translate(pos.x, pos.y, pos.z);
    } else {
      translate(finalPos.x, finalPos.y, finalPos.z);
    }
    //0 = electron, 1=photon, 2=e or photon 3=alpha particle 4=muon 5= unknown
    if (type ==0)
    {
      //          input, in_min,in_max,out_min,out_max 
      float size = map(totalEnergy, 4, 1000*1000, 5, 40); 
      sphere(size);
      text("electron", 0.0, 0.0, 0.0);
    } else if (type ==1)
    {
      sphere(10);
      text("photon", 0.0, 0.0, 0.0);
    } else if (type==2)
    {
      box(20);
      text("e-or-p", 0.0, 0.0, 0.0);
    } else if (type==3)
    {
      text("?=alpha", 0.0, 0.0, 0.0);//,pos.x,pos.y,pos.z
    } else if (type==4)
    {
      text("muon", 0.0, 0.0, 0.0);//,pos.x,pos.y,pos.z
    } else if (type==5)
    {
      text("?", 0.0, 0.0, 0.0);//,pos.x,pos.y,pos.z
    }
    popMatrix();
  }
  int clusterType() {
    int maxEnergy=0;
    int maxX = 0;
    int maxY = 0;
    int minX = 255;
    int minY = 255;
    int clusterSize=x.size(); //number of pixels in cluster
    int max_length = 0;
    int ratio = 0;

    for (int i = 0; i < clusterSize; i++) {
      if (e.get(i) > maxEnergy) {
        maxEnergy = e.get(i); //not used here...
      }
      if (x.get(i) > maxX)
        maxX = x.get(i);
      if (x.get(i)< minX)
        minX = x.get(i);
      if (y.get(i) > maxY)
        maxY = y.get(i);
      if (y.get(i)< minY)
        minY = y.get(i);
    }

    //cluster box size:
    int box_width = (maxX - minX)+1;
    int box_heigth = (maxY - minY)+1;
    if (box_width > box_heigth) {
      max_length = box_width;
      ratio = box_width/box_heigth;
    } else {
      max_length = box_heigth;
      ratio = box_heigth/box_width;
    }

    float occupancy = (clusterSize/(box_width*box_heigth*1.0));

    int beta_threshold = 200; //in keV
    //0 = electron, 1=photon, 2=e or photon 3=alpha particle 4=muon 5= unknown

    //simple cluster identfification
    // 1 and 2 pixel clusters
    if (clusterSize <= 2) {
      if (totalEnergy < 10) {
        //assmuming electrons would be stopped in the metal layer
        //gamma photon
        type=1;
      } else {
        //sprite.name=@"beta/gamma";
        //unknown e or photon
        type=2;
      }
    } else if (clusterSize <= 4) {
      //sprite.name=@"beta/gamma";
      //unknown e or photon
      type=2;
    } else {
      //                    if ( ratio < 1.5 ) {
      // squarish clusters
      //if (clusterSize > (2*max_length) ){
      if ( occupancy > 0.5 ) {
        if (totalEnergy > 1000) {
          //round heavy blob
          //sprite.name=@"alpha";
          type=3;
        } else if ( box_width==1 || box_heigth==1 ) {
          //most likely a straight muon track
          //sprite.name=@"muon";
          type=4;
        } else {
          //overlapping cluters?
          //sprite.name=[NSString stringWithFormat:@"%.1f", occupancy];;
          //unknown
          type=5;
        }
      } else {
        //curly track
        if (totalEnergy > beta_threshold) {
          //assumption on increased probability
          //sprite.name=@"beta";
          type=0;
        } else {
          //sprite.name=@"beta/gamma";
          //unknown e or photon
          type=2;
        }
      }
      //                    } else {
      //                        // longish clusters
      //                        if (energy>beta_threshold){
      //                            //assumption on increased probability
      //                            sprite.name=@"beta";
      //                            beta_cnt++;
      //                        } else {
      //                            sprite.name=@"beta/gamma";
      //                            unknown_cnt++;
      //                        }
      //                    }
    }
    return type;
  }
  void sound() {
    if (played == false) {
      int channel = 9;
      int velocity = 127;
      Note note = new Note(0, 0, 0);
      int partLevel=0;
  
      //types:
      int kick   = 36; 
      int kickL  = 40; 
      int snare  = 38; 
      int snareL = 41;
      
      int loTom  = 43; 
      int loTomL = 42;
      int hiTom  = 50;
      int hiTomL = 43;
      
      int clHat  = 42;
      int clHatL = 44;
      int opHat  = 46;
      int opHatL = 45;
      
      int clap   = 39; 
      int clapL  = 46; 
      int claves = 75; 
      int clavesL= 47;
      
      int agogo  = 67;
      int agogoL = 48;
      int crash  = 49;
      int crashL = 49;   
      int diff = 0;
            
      if (type == 0) {         //0 = electron
        note = new Note(channel, claves, 127); //crash
        partLevel = clavesL;
      } else if (type == 1 ) { //1=photon
        note = new Note(channel, clap, velocity);
        partLevel = clapL;
      } else if (type == 2 ) { //2=e or photon 
        note = new Note(channel, hiTom, velocity); //clHat
        partLevel = hiTomL;
      } else if (type == 3 ) { //3=alpha particle
        note = new Note(channel, kick, 70);
        diff = -10;
        partLevel = loTomL;
      } else if (type == 4 ) { //4=muon 
        note = new Note(channel, snare, velocity);
        partLevel = snareL;
      } else if (type == 5 ) { //5= unknown
        note = new Note(channel, loTom, velocity); //opHat
        partLevel = kickL;
      }
      //note = new Note(channel, 75, velocity);

      myBus.sendNoteOn(note);
      ControlChange change = new ControlChange(channel, partLevel, round(map(totalEnergy,4, 5*1000,40,127))+diff);
      //myBus.sendControllerChange(change); // Send a controllerChange
      played=true;
      delay(round(random(0, 100)));
      //delay(3000);
      //print("sound ");
    }
  }
}