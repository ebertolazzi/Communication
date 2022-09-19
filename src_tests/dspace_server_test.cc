#include "udp_class.hh"
#include <iostream>
#include <iomanip>
#include <stdlib.h>     /* atof */
#include <thread>

using namespace std;

#define MSG_ERROR \
"Usage:\n" \
"  dspace_server_test [port]\n"

static
int
receive( int port ) {

  uint8_t buffer[100];
  char    str[1000];
  memset(str, '\0', 1000);

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
    memset(buffer, '\0', 100);
    cout << "Wait socket.receive\n";
    int32_t received_bytes;
    int ret = socket.receive_raw( received_bytes, buffer, 100 );
    if (ret == UDP_FALSE) {
      perror("error send_message()");
      exit(EXIT_FAILURE);
      //return -1;
    }
    cerr << "received " << received_bytes << "\n";
    buffer_to_string( buffer, received_bytes, str, 3*received_bytes );
    cout << "Raw buffer = " << str << '\n';

    int32_t a;
    double  b;
    int32_t off = buffer_to_int32(buffer, &a);
    buffer_to_double(buffer+off, &b);
    cout << "a = " << a << '\n';
    cout << "b = " << b << '\n';
  }
  cout << "Stopping server..\n";
  if (socket.close()) return -1;
  return 0;
}

int
main( int argc, char const * argv[] ) {

  int port = 25000;

  if ( argc != 1 && argc != 2 ) {
    cerr << MSG_ERROR;
    exit(0);
  }

  if ( argc == 2 ) port = std::atoi( argv[1] );
  receive( port );

  cout << "All Done Folks\n";
  return 0;
}
