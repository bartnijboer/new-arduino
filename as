#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <ESP8266HTTPClient.h>
#include <Timer.h> //https://github.com/JChristensen/Timer/archive/master.zip
#include <ArduinoJson.h> //https://github.com/bblanchon/ArduinoJson


int Relay1 = 5;
int Relay2 = 4;
int Relay3 = 0;
int Relay4 ;
const char* ssid = "BananenBoot";
const char* password = "tp0Afvj7QxaASGa52cnZsfg25x3";
//bool loop_bool = false;

const int led = LED_BUILTIN;

boolean previousButtonState = LOW;
boolean buttonStartState = LOW;
boolean workingState = 0;

//long danstime1 = 1000;
//long duration = 0;
//const long interval = 1000;


int ipnr = 103;

int  values_relay_1  [1000];
std::vector<int> values_relay_2;
std::vector<int> values_relay_3;
std::vector<int> values_relay_4;

int state_relay_1 = 1;
int state_relay_2 = 1;
int state_relay_3 = 1;
int state_relay_4 = 1;


ESP8266WebServer server(80);
IPAddress ip(192, 168, 1, ipnr);
IPAddress gateway(192, 168, 1, 254);
IPAddress subnet(255, 255, 255, 0);

Timer t0;

Timer t1;
Timer t2;
Timer t3;
Timer t4;

//Timer t5;

int event_relay_1;
int event_relay_2;
int event_relay_3;
int event_relay_4;

void handleNotFound() {
  String message = "File Not Found\n\n";
  message += "URI: ";
  message += server.uri();
  message += "\nMethod: ";
  message += (server.method() == HTTP_GET) ? "GET" : "POST";
  message += "\nArguments: ";
  message += server.args();
  message += "\n";
  for (uint8_t i = 0; i < server.args(); i++) {
    message += " " + server.argName(i) + ": " + server.arg(i) + "\n";
  }
  server.send(404, "text/plain", message);
}

void setup(void) {
  pinMode(Relay1, OUTPUT);
  pinMode(Relay2, OUTPUT);
  pinMode(Relay3, OUTPUT);

  digitalWrite(Relay1, HIGH );
  digitalWrite(Relay2, HIGH );
  digitalWrite(Relay3, HIGH );

  Serial.begin(115200);

  WiFi.config(ip, gateway, subnet);
  WiFi.begin(ssid, password);

  Serial.println();

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(5);
    Serial.print(".");
  }

  Serial.println();
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  if (MDNS.begin("esp8266")) {
    Serial.println("MDNS responder started");
  }

  server.on("/start", starten);
  server.on("/stop", stoppen);
  server.on("/actief", activeren);

  server.on("/info", info);
  server.on("/test-settings", testSettings);

  server.on("/status", []() {
    Serial.println("status aangeroepen");
    server.send(200, "text/plain", "ik ben wakker");
  });

  server.onNotFound(handleNotFound);

  server.begin();
  Serial.println("HTTP server started");

  aanmelden();
  t0.every(10000, aanmelden);

/*  int start_over_after_minutes = 10;
  long start_over_after_millis = 1000 * 60 * start_over_after_minutes;
  t5.every(start_over_after_millis, startOver);
*/
}

void info() {
  String state = "Relay 1:";
  state_relay_1 = digitalRead(Relay1);
  state +=   state_relay_1;

  state = "Relay 2:";
  state_relay_2 = digitalRead(Relay2);
  state +=   state_relay_2;

  state = "Relay 3:";
  state_relay_3 = digitalRead(Relay3);
  state +=   state_relay_3;
  Serial.println(state);


  server.send(200, "text/plain", state);

}

void aanmelden() {
  HTTPClient http;
  http.begin("http://192.168.1.101/aanmelden"); //HTTP
  http.addHeader("Content-Type", "text/plain"); //Specify content-type header

  String copyIp = "192.168.1.";
  copyIp += ipnr;
  Serial.println("aanmelden");
  Serial.println(copyIp);
  int httpCode = http.POST(copyIp);
  http.end();
}

void loop(void) {
  server.handleClient();
  t0.update();

  t1.update();
  t2.update();
  t3.update();
  t4.update();

 // t5.update();


}



void parseData(bool test = 1) {
  std::vector<int> values_relay_1;
  std::vector<int> values_relay_2;
  std::vector<int> values_relay_3;
  std::vector<int> values_relay_4;


  String payload = "[{"\
  //                          1,   0,   1,   0,   1,   0,   1,   0,
  "\"id\": 102, \"loop\": true, \"relays\":"\
  "[{\"id\": 1, \"program\": [1, 480, 120, 480 ] },"\
  " {\"id\": 2, \"program\": [1, 480, 120, 480 ]},"\
  " {\"id\": 3, \"program\": [1, 480, 120, 480 ]}] }, "\
  
  //                          1,   0,   1,   0,   1,   0,   1,   0,
  " {\"id\": 103, \"loop\": true, \"relays\": "\
  "[{\"id\": 1, \"program\": [1, 5, 10, 4 ] },"\
  " {\"id\": 2, \"program\": [1, 6, 9, 4 ] },"\  
  \ poihio
  " {\"id\": 3, \"program\": [1, 7, 8, 4 ] }] },"\
  
  //                          1,   0,   1,   0,   1,   0,   1,   0,
  " {\"id\": 104, \"loop\": true, \"relays\": "\
  "[{\"id\": 1, \"program\": [1, 480, 120, 480 ] },"\
  " {\"id\": 2, \"program\": [1, 480, 120, 480 ] },"\
  " {\"id\": 3, \"program\": [1, 480, 120, 480 ] }] },"\

  //                          1,   0,   1,   0,   1,   0,   1,   0,
  " {\"id\": 105, \"loop\": true, \"relays\":"\
  "[{\"id\": 1, \"program\": [1, 480, 120, 480 ] }, "\
  " {\"id\": 2, \"program\": [1, 480, 120, 480 ] },"\
  " {\"id\": 3, \"program\": [1, 480, 120, 480 ] }] } ]";
  
  DynamicJsonDocument doc(10240);
  DeserializationError error = deserializeJson(doc, payload);
  if (error) {

    Serial.print(F("deserializeJson() failed: "));
    Serial.println(error.c_str());
    server.send(400, "text/plain", error.c_str());

    return;
  }
  for (uint8_t i = 0; i < 4; i++) {
    int id = doc[i]["id"];
    if (id == ipnr) {
      Serial.println(id);

     // loop_bool = doc[i]["loop"];

      for (uint8_t j = 0; j < 4; j++) {

        int relay = doc[i]["relays"][j]["id"];
        if (relay > 0) {

          //voor elk gevonden relay stop waarden in een lijstje
          for (uint8_t k = 0; k < 120; k++) {
            int value = doc[i]["relays"][j]["program"][k];
            if (value > 0) {
              //controleer in welk lijst hij moet komen
              switch (relay) {
                case 1 : values_relay_1.push_back(value); break;
                case 2 : values_relay_2.push_back(value); break;
                case 3 : values_relay_3.push_back(value); break;
                case 4 : values_relay_4.push_back(value); break;
                default : Serial.println(value); break;

              }
            }
          }
        }
      }

      int counter = 0;
      int sum = 0;
      for (int& i : values_relay_1) {
        if (test == 0) {
          sum += i;
          if ( counter % 2 == 1) {
            event_relay_1 = t1.after( (sum * 1000), Relay1High);
          }
          else {
            event_relay_1 = t1.after( (sum * 1000), Relay1Low);
          }
          counter += 1;
        }
      }

      counter = 0;
      sum = 0;
      for (int& i : values_relay_2) {
        if (test == 0) {
          sum += i;
          if ( counter % 2 == 1) {
            event_relay_2 = t2.after( (sum * 1000), Relay2High);
          }
          else {
            event_relay_2 = t2.after( (sum * 1000), Relay2Low);
          }
          counter += 1;
        }
      }

      counter = 0;

      sum = 0;

      for (int& i : values_relay_3) {
        if (test == 0) {
          sum += i;

          if ( counter % 2 == 1) {
            event_relay_3 = t3.after( (sum * 1000), Relay3High);
          }
          else {
            event_relay_3 = t3.after( (sum * 1000), Relay3Low);
          }
          counter += 1;
        }
      }

      counter = 0;
      sum = 0;

      for (int& i : values_relay_4) {
        if (test == 0) {
          sum += i;
          if ( counter % 2 == 1) {
            event_relay_4 = t4.after( (sum * 1000), Relay4High);
          }
          else {
            event_relay_4 = t4.after( (sum * 1000), Relay4Low);
          }
          counter += 1;
        }
      }
    }
  }

  String message = "Input\n\n";
  message += "URI: ";
  message += server.uri();
  message += "\nMethod: ";
  message += (server.method() == HTTP_GET) ? "GET" : "POST";
  message += "\nArguments: ";
  message += server.args();
  message += "\n";
  for (uint8_t i = 0; i < server.args(); i++) {
    message += " " + server.argName(i) + ": " + server.arg(i) + "\n";
  }
  server.send(200, "text/plain", message);


}


void programma() {

}
/*void startOver() {
  if (loop_bool) {
    Serial.println("Nog een keer!");
    stoppen();
    starten();
  }

}*/
void Relay1Low() {
  if (workingState > 0 ) {
    digitalWrite(Relay1, LOW );
  }
}
void Relay2Low() {
  if (workingState > 0 ) {
    digitalWrite(Relay2, LOW );
  }
}
void Relay3Low() {
  if (workingState > 0 ) {
    digitalWrite(Relay3, LOW );
  }
}
void Relay4Low() {
  if (workingState > 0 ) {
    digitalWrite(Relay4, LOW );
  }
}
void Relay1High() {
  digitalWrite(Relay1, HIGH );
}
void Relay2High() {
  digitalWrite(Relay2, HIGH );
}
void Relay3High() {
  digitalWrite(Relay3, HIGH );
}
void Relay4High() {
  digitalWrite(Relay4, HIGH );
}


void testSettings() {
  parseData();

}

void starten() {
  server.send(200, "text/plain", "starten");
  Serial.println("start");
  workingState = 1;

  parseData(0);
  //  programma();

}

void stoppen() {
  server.send(200, "text/plain", "stoppen");
  Serial.println("stop");
  workingState = 0;
  digitalWrite(Relay1, HIGH );
  digitalWrite(Relay2, HIGH );
  digitalWrite(Relay3, HIGH );
  digitalWrite(Relay4, HIGH );

  t1.stop(event_relay_1);
  t2.stop(event_relay_2);
  t3.stop(event_relay_3);
  t4.stop(event_relay_4);

}

void activeren() {
  server.send(200, "text/plain", "activeren");
  Serial.println("actief");
  workingState = 1;
  digitalWrite(Relay1, LOW );
  digitalWrite(Relay2, LOW );
  digitalWrite(Relay3, LOW );
  digitalWrite(Relay4, LOW );

}
