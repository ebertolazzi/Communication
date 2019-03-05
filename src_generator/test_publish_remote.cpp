#include "SafeStrip.hpp"
#include <iostream>
#include <chrono>
#include <thread>
#include <openssl/ssl.h>
#include <openssl/err.h>

using namespace std;

int
main() {

  MQTT_SafeStrip_publisher  mqtt_publisher("publisher");

  int return_code, debug;

  cout << "Connect ... \n";

  // Set the security options
  // Set the security options
  const char* server_address = "93.62.253.212";
  const char* username       = "safestrip";
  const char* password       = "S@f3str1p";
  const char* protocol       = "tlsv1.2";

  debug = mqtt_publisher.tls_opts_set( 1 , protocol );
  mqtt_publisher.tls_set("ca.crt"); // return 0 no problem
  mqtt_publisher.tls_insecure_set( true );
  mqtt_publisher.username_pw_set( username , password );
  

  return_code = mqtt_publisher.connect( server_address , 8883 , 60 );
  cout << "publish return code: " << return_code << "and debug: " << debug << "\n"; //DEBUG

  cout << "Starting ... \n";
  for ( int j = 0; j < 1000; j++) {

    cout << "j = " << j << '\n';

    // trigger mosquitto callbacks
    mqtt_publisher.loop(1, 1);

    // Sending
    AutomationLevel al;
    al.Automation_Level = j;
    mqtt_publisher.publish( al );
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
  }
  cout << "> Clean exit\n";
  return 0;
}
