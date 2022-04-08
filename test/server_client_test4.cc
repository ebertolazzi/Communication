#include "udp_class.hh"
#include <iostream>
#include <iomanip>
#include <stdlib.h>     /* atof */
#include <thread>

using namespace std;

#define MSG_ERROR \
"Usage:\n" \
"  server_client_test [wait for data]\n" \
"  server_client_test data1 data2 [send data]\n"

static
int
send( char const address[], int port, double a, double b ) {

  uint32_t buffer_size = sizeof(double) * 2;
  uint8_t buffer[sizeof(double) * 2];

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
  double_to_buffer(a, buffer);
  double_to_buffer(b, buffer + sizeof(a));

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

  uint32_t buffer_size = sizeof(double) * 2;
  uint8_t buffer[sizeof(double) * 2];

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
    double a, b;
    buffer_to_double(buffer, &a);
    buffer_to_double(buffer+sizeof(a), &b);
    cout << "Received: a = " << a << " b = " << b << '\n';
  }
  cout << "Stopping server..\n";
  if (socket.close()) return -1;
  return 0;
}

static
int
receive_send( int port_in, char const address[], int port_out ) {

  uint32_t buffer_size = sizeof(double) * 2;
  uint8_t buffer[sizeof(double) * 2];

  /* Create and set UDP socket */
  Socket socket;
  socket.open_as_server(port_in);
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
    double a, b;
    buffer_to_double(buffer, &a);
    buffer_to_double(buffer+sizeof(a), &b);
    cout << "Received: a = " << a << " b = " << b << '\n';

    // resend data
    ret = send( address, port_out, a, b );
  }
  cout << "Stopping server..\n";
  if (socket.close()) return -1;
  return 0;
}

int
main( int argc, char const * argv[] ) {

  //int  const port_in   = 25000;
  //char const address[] = "127.0.0.1";
  //int  const  port_out  = 25001;
  char  address[] = "127.0.0.1";
  int   port_in   = 25000;
  int   port_out  = 25001;

  std::cout << argc << '\n';

  if (argc == 4){
     strcpy(address, argv[1]);
     port_in  = std::atoi(argv[2]);
     port_out = std::atoi(argv[3]);
     std::cout << "Input argument received:\n";
     std::cout << "address  = " << address  << '\n';
     std::cout << "port_in  = " << port_in  << '\n';
     std::cout << "port_out = " << port_out << '\n';
  } 

  if (argc != 1 && argc != 3 && argc != 4 ) {
    cerr << MSG_ERROR;
    exit(0);
  }

  std::thread t1 = std::thread([port_out]{ receive( port_out );});
  receive_send( port_in, address, port_out );
  t1.join();

  cout << "All Done Folks\n";
  return 0;
}
