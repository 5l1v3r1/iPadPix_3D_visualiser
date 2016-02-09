import org.apache.avro.util.Utf8; //<>// //<>//
import java.nio.ByteBuffer;
import java.nio.Buffer;
import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;


public class Clusters {
  UDP udp;
  Schema schema; 
  List<Cluster> tpx_clusters; // CopyOnWriteArrayList
  boolean firstPacket;
  int connectionPort;
  boolean lock;

  Clusters (int port) { 

    connectionPort = port;
    tpx_clusters = new ArrayList<Cluster>(); //CopyOnWriteArrayList<Cluster>(); 
    udp= new UDP(this, port);
    lock=false;
    //udp.log(true);
    udp.listen(false);
    firstPacket = true;
    try {
      schema = new Schema.Parser().parse(new File("/Users/ozel/Documents/Processing/iPadPix_3D_visualiser/data/tpx.json"));
    } 
    catch (IOException e) {
      System.err.println(e);
    }
  }
  void addCluster(Cluster newCluster) {
    while (lock == true) {
    };
    tpx_clusters.add(newCluster);
  }
  Cluster randomCluster() {
    Cluster newCluster = new Cluster((float)random(0, 255), (float)random(0, 255), (float)random(4, 1000*1000)); 
    newCluster.type = round(random(0, 4));
    //println(newCluster.type);
    return newCluster;
  }
  void receive(byte[] data) {
    //skip first packet here to prevent strange hangups 
    if (firstPacket && connectionPort == 0) {
      firstPacket=false;
      return;
    }
    print("packet size: ");
    println(data.length);

    try {
      ByteArrayInputStream inputStream =  new ByteArrayInputStream(data);
      Decoder decoder = DecoderFactory.get().binaryDecoder(inputStream, null);
      if (decoder == null) return;
      GenericDatumReader<GenericRecord> reader = new GenericDatumReader<GenericRecord>(schema);
      GenericRecord result = reader.read(null, decoder);
      //println(result);
      GenericData.Array<GenericRecord> crs = (GenericData.Array)result.get("clusterArray");
      if (crs !=  null) {
        print("clusters: ");
        println(crs.size());
        //println(clusters);
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

          //loop through all pixel data of one cluster
          for (int i = 0; i < energy_array.size(); i++) {
            //print( (int) bresult[i] & 0xff); print(" ");
            cluster.addPixel((int) (bx[i] & 0xff), (int) (by[i] & 0xff), (int)energy_array.get(i));
          }
          cluster.type=cluster.clusterType();
          addCluster(cluster);

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
  void startListening() {
    if(connectionPort > 0)  udp.listen(true);
  }
  void stopListening() {
    udp.listen(false);
  }
} 