import java.util.Iterator;
import java.util.*;
import  java.lang.Object;
// Example of Reading from JSON and Visualisation of Visitor Tracks
// 1.2 / p3.3

String filename="19o.json";                    // temp. filename
Boolean isInit = false;
JSONObject json;

JSONObject moment;

//Array of json arrays
JSONArray[] tracks;


float[][] interp_array;
 

float h;
int i0=0;int i1=0;
int[] count;

PImage bg;
PImage destination;

float[][] x_coord;
float[][] y_coord;
float[][] h_height;
String[][] timestamps;

int[] lenght;
float[] h_mid;

String start_time, end_time;                    // Starting and ending time of all tracks in the file

int text_oX = 20;
int text_oY = 100;

int oX =900;
int oY = 850;

int room_oX = 250;
int room_oY = 30;
int wd = 1110;
int ht = 615;


int rectX = 10, rectY = 30;      // Position of square button
int circleX, circleY;  // Position of circle button
int rectSizeW = 65;     // Diameter of rect
int rectSizeH = 25;     // Diameter of rect
color rectColor = color(222);
color rectHighlight = color(51);
color currentColor;
boolean rectOver = false;

void setup(){
 
  loadData();
  
  bg = loadImage("bplan.jpg");
  
  fullScreen(); 

  reset();
}

void reset(){
  
  fill(255);
  rect(room_oX,room_oY,wd,ht);
  bg = loadImage("bplan.jpg");
  
  
  background(bg);
  

  for (int i = 0; i < lenght.length; i++) {
    color trkColor = color( (i%3)* 255, ((i+1)%3) * 255, ((i+2)%3) * 255 );
    
    // Text information
    fill(trkColor); text("Height:",text_oX,text_oY+i*50); fill(trkColor); text(h_mid[i],text_oX+90,text_oY+i*50);
    fill(trkColor); text("Steps: ",text_oX,text_oY+20+i*50); fill(trkColor); text(lenght[i],text_oX+90,text_oY+20+i*50);
  }
   loadData();
   
  interp_array = new float[wd][ht];
  makeArray();
  applyColor();
}
void update(int x, int y) {
if ( overRect(rectX, rectY, rectSizeW, rectSizeH) ) {
    rectOver = true;
  } else {
    rectOver = false;
  }
  //applyColor();
}

void mousePressed() {
  if (rectOver) {
    currentColor = rectColor;
    reset();
  }
}

boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}


void draw() {
  update(mouseX, mouseY);
  background(bg);
  
  
   if (rectOver) {
      fill(rectHighlight);
    } else {
      fill(rectColor);
    }
    
  stroke(255);
  rect(rectX, rectY, rectSizeW, rectSizeH);
  fill(0); text("Replay", rectX+15,rectY+17);
      
      
  

  for (int i = 0; i < lenght.length; i++) {
      
    color trkColor = color( (i%3)* 255, ((i+1)%3) * 255, ((i+2)%3) * 255 );
    
    fill(trkColor);
    if (count[i]<lenght[i]) {
   
    stroke(trkColor);
      
    if (count[i]<lenght[i]-1) 
      line(oX+y_coord[i][count[i]],oY-x_coord[i][count[i]],oX+y_coord[i][count[i]+1],oY-x_coord[i][count[i]+1]);
    
    ellipse(oX+y_coord[i][count[i]],oY-x_coord[i][count[i]],10,10);
  
    count[i]++;
    }
    delay(50);
  }
  applyColor();
}  

void init(int noTracks, int no_elements) {
   //int no_elements = 250;
   
  x_coord=new float[noTracks][no_elements];
  y_coord=new float[noTracks][no_elements];
  h_height=new float[noTracks][no_elements];
  timestamps=new String[noTracks][no_elements];
  
  lenght=new int[noTracks];
  h_mid=new float[noTracks]; 
}

void loadData() {
   
  json = loadJSONObject(filename);
 
  int noTracks = json.size();
  tracks = new JSONArray[noTracks];
  
  count=new int[noTracks];
  
  JSONObject o = (JSONObject) json;
  
  Set keyset = o.keys();
  Iterator<String> keys = keyset.iterator();
  int j = 0;
  

  
  
  
  while( keys.hasNext() ) {
    
      String key = (String)keys.next();
      
      tracks[j] = o.getJSONArray(key);      
      
      if (!isInit){ init(noTracks, 1000); isInit = true;}
      
      
      lenght[j]=tracks[j].size();                                   // Size of the dataset
      
      for (int i = 0; i < lenght[j]; i++) {
  //    println("key: ",key);
        JSONObject item = tracks[j].getJSONObject(i);
      moment = tracks[j].getJSONObject(i);                         

       // fist and last time stamps
       if ((i==0) & (j==0)) start_time=moment.getString("time").substring(0,11);                 
       if ((i==lenght[j]-1) & (j==0)) end_time=moment.getString("time").substring(0,11);
     
       if((i==lenght[j]-1) & (j!=0)) println ("!!");
                    
       float x=moment.getFloat("x");                                  
       float y=moment.getFloat("y");
       
       timestamps[j][i]=moment.getString("time").substring(0,11);
       
       h_height[j][i]=moment.getFloat("height");

       h=h+h_height[j][i];                                           

       x_coord[j][i]=x*140;                                            
       y_coord[j][i]=y*140;  
  
     // println(item);
      
    }
    
     h_mid[j]=h/lenght[j]; h=0;                                      

     //println("Track "+j+" time: "+timestamps[j][0]);
     
     //println("Track "+j+" end time: "+timestamps[j][lenght[j]-1]);

     println();

     //println(start_time);
     //println(end_time);
  //ids = json.keys();
  j++;
}



}  //loadData()




 
// Fill array with Perlin noise (smooth random) values
void makeArray() {
  for (int r = 0; r < ht; r++) {
    for (int c = 0; c < wd; c++) {
      // Range is 24.8 - 30.8
      interp_array[c][r] = 24.8 + 6.0 * noise(r * 0.02, c * 0.02);
    }
  }
}
 
void applyColor() {  // Generate the heat map
  pushStyle(); // Save current drawing style
  // Set drawing mode to HSB instead of RGB
  colorMode(HSB, 1, 1, 1);
  bg.loadPixels();
  int p = 0;
  
  for (int r = 0; r < ht; r++) {
    for (int c = 0; c < wd; c++) {
      // Get the heat map value 
      float value = interp_array[c][r];
      // Constrain value to acceptable range.
      value = constrain(value, 25, 30);
      // Map the value to the hue
      // 0.2 blue
      // 1.0 red
      value = map(value, 25, 30, 0.2, 1.0);
      
      //p = r + c* wd ;
      //println(p);
      bg.pixels[p++] = color(value, 0.9, 1);
      //bg.pixels[r + c* wd] = color(value, 0.9, 1);
      //fill(color(value, 0.9, 1));
      //point(r,c);
    }
  }
  bg.updatePixels();
  background(bg);
  popStyle(); // Restore original drawing style
}