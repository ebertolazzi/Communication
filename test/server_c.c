#include "udp_C_class.h"
#include "codriver_interfaces_data_structs.h" // include with defined data structure

#include <stdio.h>

int
main() {

  uint8_t  buffer[100000];
  uint32_t buffer_size = sizeof(buffer)/sizeof(buffer[0]);
  int32_t  message_id = 0, message_len;
  int      ret;

  // Create and set UDP socket
  // Create and set UDP

  SocketData socket;
  Socket_new( &socket );
  Socket_open_as_server( &socket, 25000 );

  // Start server
  UDP_printf("Server ready\n");

  while( 1 ) {

    // Clear the buffer
    UDP_printf( "Wait Socket_receive\n" );
    memset(buffer, '\0', buffer_size);
    ret = Socket_receive(
      &socket,
      &message_id,
      &message_len,
      buffer,
      buffer_size,
      0
    );
    if ( ret == UDP_TRUE ) {
      printf("RECEIVED: [id=%d,size=%d]", message_id, message_len);
      for ( int i = 0; i < message_len; ++i )
        printf("%02X", (int)buffer[i] );
      printf("\n" );
    } else {
      UDP_printf( "Socket_receive failed\n" );
    }
  }

  UDP_printf("Stopping server..\n");
  if ( Socket_close( &socket ) == -1 ) return -1;
  UDP_printf("Done\n");
  return 0;
}
