#include "udp_class.hh"
#include <iostream>
#include <iomanip>
#include <stdlib.h>     /* atof */
#include <thread>

using namespace std;

#define MSG_ERROR \
"Usage:\n" \
"  dspace_send_test data_int32 data_double [port=25000] [address=127.0.0.1]\n"

static
int
send( char const address[], int port, int32_t a, double b ) {

  uint8_t  buffer[100];

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
  uint32_t buffer_size = int32_to_buffer(a, buffer);
  buffer_size += double_to_buffer(b, buffer + buffer_size);

  int ret = socket.send_raw( buffer, buffer_size );
  // check if send is OK
  if (ret == UDP_FALSE) {
    perror("error send_message()");
    exit(EXIT_FAILURE);
    //return -1;
  }

  /* Close socket */
  if (socket.close()) return -1;
  return 0;
}

int
main( int argc, char const * argv[] ) {

  int          port         = 25000;
  char         address[100] = "127.0.0.1";
  char const * paddress     = address;

  if ( argc < 3 ) { cerr << MSG_ERROR; exit(0); }

  int32_t a = std::atoi(argv[1]);
  double  b = std::atof(argv[2]);
  if ( argc >= 4 ) port     = std::atoi(argv[3]);
  if ( argc >= 5 ) paddress = argv[4];

  std::cout << "Sending:\n";
  std::cout << "address  = " << paddress << '\n';
  std::cout << "port     = " << port     << '\n';
  std::cout << "a        = " << a        << '\n';
  std::cout << "b        = " << b        << '\n';

  send( paddress, port, a, b );

  cout << "All Done Folks\n";
  return 0;
}
