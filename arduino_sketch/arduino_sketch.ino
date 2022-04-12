#include "SerialManager.h"

SerialManager serial;

void setup() {
  // put your setup code here, to run once:
  serial.start();

  for (int i=2; i<14; i++) {
    pinMode(i, OUTPUT);
  }
}

void loop() {
  
  if (serial.onReceive()){
    if (serial.getCmd() == "whois") {
      serial.println("controller");
    } else {
      digitalWrite(serial.getCmd().toInt(), serial.getParam().toInt());
    }
  }
}
