#include "udp_C_class.h"
#include "codriver_interfaces_data_structs.h" // include with defined data structure

#include <stdio.h>
#include <math.h>

int
main() {

  #define NSIZE 256
  uint8_t  buffer[NSIZE];
  uint32_t buffer_size = NSIZE;

  for ( int i = 0; i < NSIZE; ++i )
    buffer[i] = (i%0x100);

  /*=====================*/
  // Create and set UDP
  SocketData socket;
  Socket_new( &socket );
  Socket_open_as_client( &socket, "127.0.0.1", 25000 );
  //Socket_check( &socket );

  uint64_t start_time = get_time_ms();

  // First message --------------------------
  UDP_printf("\n\nSocket_send ...\n");
  socket.server_run = UDP_TRUE;

  for ( int32_t message_id = 1; message_id <= 10; ++message_id ) {
    int ret = Socket_send(
      &socket,
      message_id,
      buffer,
      buffer_size
    );
    printf("ret = %d\n", ret );
  }

  // Close socket
  if ( Socket_close(&socket) == UDP_FALSE ) {
    UDP_printf("Socket_close, failed\n");
    return -1;
  }
  UDP_printf("Done\n");
  return 0;
}
