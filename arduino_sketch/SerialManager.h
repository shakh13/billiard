// Arduino RBD Serial Manager Library v0.1 - A simple interface for serial communication.
// https://github.com/shakh13/SerialManager
// Shaxzod Saidmurodov
// MIT License

#ifndef SERIAL_MANAGER
#define SERIAL_MANAGER

#include <Arduino.h>

  class SerialManager {
    public:
      SerialManager();
      void start();
      void setFlag(char value);
      void setDelimiter(char value);
      bool onReceive();
      String getValue();
      String getCmd();
      String getParam();
      bool isCmd(String value);
      bool isParam(String value);
      template <typename T> void print(T value){Serial.print(value);}
      template <typename T> void println(T value){Serial.println(value); }
    private:
      int _position;
      char _char;
      char _flag      = '\n'; // you must set the serial monitor to include a newline with each command
      char _delimiter = ',';
      String _buffer  = "";
      String _value   = "";
  };

#endif
