#include "udp_C_class.h"
#include "codriver_interfaces_data_structs.h" // include with defined data structure

#include <stdio.h>

int
main() {

  uint8_t  buffer[10];
  uint32_t buffer_size = sizeof(buffer)/sizeof(buffer[0]) ;

  input_data_struct input_msg;
  uint8_t           input_data_buffer[input_data_struct_size];

  int32_t message_id = 0;
  
  // Create and set UDP socket
  // Create and set UDP

  SocketData socket;
  Socket_new( &socket );
  Socket_open_as_server( &socket, UDP_SERVER_PORT );

  // Start server
  printf("Server ready\n");

  socket.server_run = 1;
  while( socket.server_run == UDP_TRUE ) {
    
    // Clear the buffer
    memset(buffer, '\0', buffer_size);

    if ( Socket_receive( &socket,
                         &message_id,
                         input_data_buffer,
                         input_data_struct_size,
                         0 ) == UDP_TRUE ) {

      if ( Socket_send( &socket,
                        message_id,
                        buffer,
                        buffer_size ) == UDP_FALSE ) {
        perror("error send_message()");
        exit(EXIT_FAILURE);
        return -1;
      }
      // Print the buffer
      buffer_to_input_data_struct( input_data_buffer, &input_msg );
      
      printf( "Printing received message\n" );
      printf( "ID            = %d\n",    input_msg.ID            );
      printf( "Version       = %d\n",    input_msg.Version       );
      printf( "CycleNumber   = %d\n",    input_msg.CycleNumber   );
      printf( "ECUupTime     = %g(s)\n", input_msg.ECUupTime     );
      printf( "TimeStamp     = %g(s)\n", input_msg.TimeStamp     );
      printf( "Status        = %d\n",    input_msg.Status        );
      printf( "vel           = %g\n",    input_msg.vel           );
      printf( "x             = %g\n",    input_msg.x             );
      printf( "y             = %g\n",    input_msg.y             );
      printf( "z             = %g\n",    input_msg.z             );
      printf( "yaw           = %g\n",    input_msg.yaw           );
      printf( "yaw_rate      = %g\n",    input_msg.yaw_rate      );
      printf( "ax            = %g\n",    input_msg.ax            );
      printf( "ay            = %g\n",    input_msg.ay            );
      printf( "delta         = %g\n",    input_msg.delta         );
      printf( "mode          = %d\n",    input_msg.mode          );
      printf( "thresholds[0] = %g\n",    input_msg.thresholds[0] );
      printf( "thresholds[1] = %g\n",    input_msg.thresholds[1] );
      printf( "thresholds[2] = %g\n",    input_msg.thresholds[2] );
      printf( "thresholds[3] = %g\n",    input_msg.thresholds[3] );
    }
  }
  
  printf("Stopping server..\n");
  if ( Socket_close( &socket ) == -1 ) return -1;
  printf("Done\n");
  return 0;
}
