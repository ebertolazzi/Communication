#include "udp_C_class.h"
#include "codriver_interfaces_data_structs.h" // include with defined data structure

#include <stdio.h>

int
main() {

  uint8_t  buffer[10];
  uint32_t buffer_size = sizeof(buffer)/sizeof(buffer[0]);
  int32_t  message_id = 0;
  int      ret;

  input_data_struct input_msg;
  uint8_t           input_data_buffer[input_data_struct_size];

  // Create and set UDP socket
  // Create and set UDP

  SocketData socket;
  Socket_new( &socket );
  Socket_open_as_server( &socket, UDP_SERVER_PORT );

  // Start server
  UDP_printf("Server ready\n");

  socket.server_run = 1;
  while( socket.server_run == UDP_TRUE ) {

    // Clear the buffer
    UDP_printf( "Wait Socket_receive\n" );
    memset(buffer, '\0', buffer_size);
    ret = Socket_receive(
      &socket,
      &message_id,
      input_data_buffer,
      input_data_struct_size,
      0
    );
    if ( ret == UDP_TRUE ) {
      ret = Socket_send( &socket, message_id, buffer, buffer_size );
      if ( ret == UDP_FALSE ) {
        perror("error send_message()");
        exit(EXIT_FAILURE);
        return -1;
      }
      // Print the buffer
      buffer_to_input_data_struct( input_data_buffer, &input_msg );

      UDP_printf( "Printing received message\n" );
      UDP_printf( "ID            = %d\n",    input_msg.ID            );
      UDP_printf( "Version       = %d\n",    input_msg.Version       );
      UDP_printf( "CycleNumber   = %d\n",    input_msg.CycleNumber   );
      UDP_printf( "ECUupTime     = %g(s)\n", input_msg.ECUupTime     );
      UDP_printf( "TimeStamp     = %g(s)\n", input_msg.TimeStamp     );
      UDP_printf( "Status        = %d\n",    input_msg.Status        );
      UDP_printf( "vel           = %g\n",    input_msg.vel           );
      UDP_printf( "x             = %g\n",    input_msg.x             );
      UDP_printf( "y             = %g\n",    input_msg.y             );
      UDP_printf( "z             = %g\n",    input_msg.z             );
      UDP_printf( "yaw           = %g\n",    input_msg.yaw           );
      UDP_printf( "yaw_rate      = %g\n",    input_msg.yaw_rate      );
      UDP_printf( "ax            = %g\n",    input_msg.ax            );
      UDP_printf( "ay            = %g\n",    input_msg.ay            );
      UDP_printf( "delta         = %g\n",    input_msg.delta         );
      UDP_printf( "mode          = %d\n",    input_msg.mode          );
      UDP_printf( "thresholds[0] = %g\n",    input_msg.thresholds[0] );
      UDP_printf( "thresholds[1] = %g\n",    input_msg.thresholds[1] );
      UDP_printf( "thresholds[2] = %g\n",    input_msg.thresholds[2] );
      UDP_printf( "thresholds[3] = %g\n",    input_msg.thresholds[3] );
    } else {
      UDP_printf( "Socket_receive failed\n" );
    }
  }

  UDP_printf("Stopping server..\n");
  if ( Socket_close( &socket ) == -1 ) return -1;
  UDP_printf("Done\n");
  return 0;
}
