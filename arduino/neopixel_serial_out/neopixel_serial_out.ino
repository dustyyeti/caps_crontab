
//to be used with Processing serial GUI

//https://www.hackster.io/hardikrathod/control-arduino-using-gui-arduino-processing-2c9c6c
//https://www.youtube.com/watch?v=5WjEQSMiqMQ

//** serial character help
//https://stackoverflow.com/questions/8960087/how-to-convert-a-char-array-to-a-string

#include <Adafruit_NeoPixel.h>

//define NeoPixel Pin and Number of LEDs
#define PIN 5
#define NUM_LEDS 18

//create a NeoPixel strip
Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, PIN, NEO_GRB + NEO_KHZ800);

// the setup function runs once when you press reset or power the board

const byte numChars = 32;
char receivedChars[numChars];

boolean newData = false;

void setup() {
  // open the serial port:
  Serial.begin(9600);
  Serial.println("<Arduino is ready>");

  // start the strip and blank it out
  strip.begin();
  strip.show();
}

void loop() {
  recvWithStartEndMarkers();
  showNewData();
}

// Example 3 - Receive with start- and end-markers


void recvWithStartEndMarkers() {
  static boolean recvInProgress = false;
  static byte ndx = 0;
  char startMarker = '<';
  char endMarker = '>';
  char rc;
  String msg;

  while (Serial.available() > 0 && newData == false) {
    rc = Serial.read();
    int L; //the light index on the chain

    if (recvInProgress == true) {
      if (rc != endMarker) {
        receivedChars[ndx] = rc;
        ndx++;
        if (ndx >= numChars) {
          ndx = numChars - 1;
        }
      }
      else {
        receivedChars[ndx] = '\0'; // terminate the string
        msg = receivedChars;
        Serial.print("here's the msg:");
        Serial.println(msg);
        if (msg[0] == '+') { // turn light on
          Serial.println("we're in");
          L = findL(msg);
          String cMsg = msg.substring(msg.length() - 7);
          Serial.print("cMsg: ");
          Serial.println(cMsg);
          byte LR = colorConverter(cMsg,1);
          byte LG = colorConverter(cMsg,2);
          byte LB = colorConverter(cMsg,3);
          Serial.print("Light: ");
          Serial.println(L);
          strip.setPixelColor(L, LR, LG, LB);
          strip.show();
        }
        if (msg[0] == '-') {
          L = findL(msg);
          strip.setPixelColor(L, 0, 0, 0);
          strip.show();
        }

        recvInProgress = false;
        ndx = 0;
        newData = true;
      }
    }

    else if (rc == startMarker) {
      recvInProgress = true;
    }
  }
}

int findL(String msg) {
  int iStar = msg.indexOf('*');
  int L = msg.substring(1, iStar).toInt();
  return L;
}

String findRGB(String msg, int i) {
  int start = i * 2;
  int finish = start + 2;
  String cMsg = msg.substring(msg.length() - 6);
  Serial.print("cMsg: ");
  Serial.println(cMsg);
  String result = cMsg.substring(start, finish);

  return result;
}
void showNewData() {
  if (newData == true) {
    Serial.print("This just in ... ");
    Serial.println(receivedChars);
    newData = false;
  }
}

byte colorConverter(String hexValue, int comp) {

    //String hexstring = "#B787B7";
    long number = (long) strtol( &hexValue[1], NULL, 16);
    int r = number >> 16;
    int g = number >> 8 & 0xFF;
    int b = number & 0xFF;

    Serial.print("red is ");
    Serial.println(r);
    Serial.print("green is ");
    Serial.println(g);
    Serial.print("blue is ");
    Serial.println(b);
  

  if (comp == 1){
    return r;
  }
  if (comp == 2){
    return g;
  }
  if (comp == 3){
    return b;
  }  
}
