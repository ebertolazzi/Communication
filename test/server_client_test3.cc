#include "udp_class.hh"
#include <iostream>
#include <iomanip>
#include <stdlib.h>     /* atof */

using namespace std;

#define MSG_ERROR \
"Usage:\n" \
"  server_client_test [wait for data]\n" \
"  server_client_test data1 data2 [send data]\n"

static
int
send( char const address[], int port, int32_t a, double b ) {

  uint32_t buffer_size = sizeof(double) +sizeof(int32_t);
  uint8_t buffer[sizeof(double) +sizeof(int32_t)];

  /*\
   |   ___ ___ _  _ ___
   |  / __| __| \| |   \
   |  \__ \ _|| .` | |) |
   |  |___/___|_|\_|___/
  \*/

  /* Create and set UDP */
  Socket socket;
  socket.open_as_client(address, port, false);
  socket.check();

  // serialize data
  int32_t off =int32_to_buffer(a, buffer);
  double_to_buffer(b, buffer + off);

  int ret = socket.send_raw( buffer, buffer_size );
  // check if send is OK
  if (ret == UDP_FALSE) {
    perror("error send_message()");
    exit(EXIT_FAILURE);
    return -1;
  }

  /* Close socket */
  if (socket.close())
    return -1;
  return 0;
}

static
int
receive( int port ) {

 uint32_t buffer_size = sizeof(double) +sizeof(int32_t);
  uint8_t buffer[sizeof(double) +sizeof(int32_t)];
  char  str[2*buffer_size+1];

  /*\
   |   ___ ___ ___ ___ _____   _____
   |  | _ \ __/ __| __|_ _\ \ / / __|
   |  |   / _| (__| _| | | \ V /| _|
   |  |_|_\___\___|___|___| \_/ |___|
  \*/

  /* Create and set UDP socket */
  Socket socket;
  socket.open_as_server(port);
  socket.check();

  /* Start server */
  cout << "Server ready\n";

  socket.server_start();
  while (socket.server_running()) {
    /* Clear the buffer */
    memset(buffer, '\0', buffer_size);
    cout << "Wait socket.receive\n";
    int32_t received_bytes;
    int ret = socket.receive_raw( received_bytes, buffer, buffer_size );
    if (ret == UDP_FALSE) {
      perror("error send_message()");
      exit(EXIT_FAILURE);
      return -1;
    }
    if (received_bytes != buffer_size) {
      cerr << "received " << received_bytes << " expected " << buffer_size << "\n";
      exit(EXIT_FAILURE);
      return -1;
    }

    // de-serialize data
    int32_t a;
    double b;
    buffer_to_int32(buffer, &a);
    buffer_to_double(buffer+sizeof(a), &b);
    buffer_to_string( buffer, buffer_size, str, 2*buffer_size+1 );
    cout
      << "Received: a = " << ((int)a) << " b = " << b << '\n'
      << "Raw buffer = " << str << '\n';
  }
  cout << "Stopping server..\n";
  if (socket.close()) return -1;
  return 0;
}

int
main( int argc, char const * argv[] ) {

  char const address[] = "127.0.0.1";
  int  const port      = 25000;

  if (argc != 1 && argc != 3) {
    cerr << MSG_ERROR;
    exit(0);
  }

  if (argc == 3) { // SEND
    /*\
     |   ___ ___ _  _ ___
     |  / __| __| \| |   \
     |  \__ \ _|| .` | |) |
     |  |___/___|_|\_|___/
    \*/
    int32_t a = std::atoi(argv[1]);
    double  b = std::atof(argv[2]);
    send( address, port, a, b );

  } else {

    /*\
     |   ___ ___ ___ ___ _____   _____
     |  | _ \ __/ __| __|_ _\ \ / / __|
     |  |   / _| (__| _| | | \ V /| _|
     |  |_|_\___\___|___|___| \_/ |___|
    \*/

    receive( port );
  }

  cout << "All Done Folks\n";
  return 0;
}
