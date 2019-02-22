#include "SafeStrip.hpp"
#include <iostream>
#include <chrono>
#include <thread>
#include <openssl/ssl.h>
#include <openssl/err.h>

using namespace std;

static bool _running = true;
void
clean_exit( int signum ) {
  cout << "Interrupt signal (" << signum << ") received.\n";
  // cleanup and close up stuff here
  // terminate program
  _running = false;
  exit(signum);
}

int
main() {

  MQTT_SafeStrip_subscriber mqtt_subscriber("subscriber");


  int debug;

  // Set the security options
  const char* server_address = "93.62.253.212";
  const char* username       = "safestrip";
  const char* password       = "S@f3str1p";
  //const char* protocol       = "TLSv1.2";

  mqtt_subscriber.tls_set("ca.crt"); // return 0 no problem
  mqtt_subscriber.tls_insecure_set( true );
  mqtt_subscriber.username_pw_set( username , password );
  //debug = mqtt_subscriber.tls_opts_set( 1 , protocol );
  

  
  //mqtt.connect( "192.168.0.106", 1883, 60 );
  debug = mqtt_subscriber.connect( server_address , 8883 , 60 );
  cout << "Connect ... \n" << debug << "\n";

  //  __
  // |  |   ___ ___ ___
  // |  |__| . | . | . |
  // |_____|___|___|  _|
  //               |_|
  cout << "Entering loop.\n";
  mqtt_subscriber.loop_start();
  cout << "Running\n";
  while (_running)
    std::this_thread::sleep_for(std::chrono::milliseconds(1));

  cout << "Clean exit\n";

  return 0;
}
