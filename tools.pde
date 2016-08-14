void parsePacketHere(byte[] data) {
  print("packet size: ");
  println(data.length);
  try {
    ByteArrayInputStream inputStream =  new ByteArrayInputStream(data);
    Decoder decoder = DecoderFactory.get().binaryDecoder(inputStream, null); 
    if (decoder == null) return;
    GenericDatumReader<GenericRecord> reader = new GenericDatumReader<GenericRecord>(schema2);
  
    GenericRecord result = reader.read(null, decoder);
    println(result);
    GenericData.Array<GenericRecord> crs = (GenericData.Array)result.get("clusterArray");


    println(crs);
    if (crs !=  null) {
      print("clusters: ");
      println(crs.size());
      //println(crs);
      ByteBuffer bbx, bby = null;
      //ByteBuffer b = ByteBuffer.allocate(2000);

      //loop through all clusters in the received packet
      for (GenericRecord cr : crs) {
        //Object xi = .toString;

        //new cluster
        Cluster cluster = new Cluster((float)cr.get("center_x"), (float)cr.get("center_y"), (float)cr.get("energy"));

        bbx = (ByteBuffer)cr.get("xi");
        byte[] bx = new byte[bbx.remaining()];
        bbx.get(bx);
        bby = (ByteBuffer)cr.get("yi");
        byte[] by = new byte[bby.remaining()];
        bby.get(by);
        GenericData.Array energy_array = (GenericData.Array)cr.get("ei");
        println("bx length, by lentgh:" + bx.length + " " + by.length);  
        //loop through all pixel data of one cluster
        for (int i = 0; i < bx.length; i++) {
          print( (int) (bx[i] & 0xff)); 
          print(" "); 
          print( (int) (by[i] & 0xff));
          cluster.addPixel((int) (bx[i] & 0xff), (int) (by[i] & 0xff), 1); // (int)energy_array.get(i));
          //cluster.addPixel(1,1,1);
        }
        println();
        cluster.type=cluster.clusterType();
        tpx.addCluster(cluster);

        //println(cluster);
        //println(cluster.get("yi"));
        //println(cr.get("ei"));
      }
    }
  } 
  catch(Exception ex) {
    ex.printStackTrace();
  }
}