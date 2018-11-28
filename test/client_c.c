#include "udp_C_class.h"
#include "codriver_interfaces_data_structs.h" // include with defined data structure

/*
#if defined(_WIN32)
  #include <Ws2tcpip.h>
#elif defined(__MACH__) || defined(__linux__)
  #include <string.h>
  #include <unistd.h>
  #include <arpa/inet.h>
  #include <sys/socket.h>
#endif
*/

#include <stdio.h>
#include <math.h>

int
main() {

  uint8_t  buffer[10];
  uint32_t buffer_size = sizeof(buffer)/sizeof(buffer[0]);
  uint32_t partSize    = UDP_SUB_PACKET_SIZE;
  uint32_t n_packets;
  uint32_t remaining_bytes;
  uint64_t start_time;
  int32_t  message_id;

  //=====================

  input_data_struct input_msg;
  input_msg.ID            = 1;
  input_msg.Version       = 1;
  input_msg.CycleNumber   = 1;
  input_msg.ECUupTime     = get_time_ms()*1000;
  input_msg.TimeStamp     = get_time_ms()*1000;
  input_msg.Status        = 1;
  input_msg.vel           = 10;
  input_msg.x             = 1;
  input_msg.y             = 2;
  input_msg.z             = 3;
  input_msg.yaw           = 0;
  input_msg.yaw_rate      = 0;
  input_msg.ax            = 1.5;
  input_msg.ay            = -1.5;
  input_msg.delta         = 0.1;
  input_msg.mode          = 3;
  input_msg.thresholds[0] = 1;
  input_msg.thresholds[1] = 2;
  input_msg.thresholds[2] = 3;
  input_msg.thresholds[3] = 4;

  message_id = 12;

  /*=====================*/

  n_packets       = buffer_size / partSize;
  remaining_bytes = buffer_size % partSize;
  if ( remaining_bytes != 0 ) ++n_packets;

  buffer[0] = '1';
  buffer[1] = '1';
  buffer[2] = '2';
  buffer[3] = '3';
  buffer[4] = '3';
  buffer[5] = '4';
  buffer[6] = '5';
  buffer[7] = '6';
  buffer[8] = '7';
  buffer[9] = '9';

  // Create and set UDP
  SocketData socket;
  Socket_new( &socket );
  Socket_open_as_client( &socket, UDP_DEFAULT_SERVER_IP, UDP_SERVER_PORT );
  //Socket_check( &socket );

  start_time = get_time_ms();

  uint8_t input_data_buffer[input_data_struct_size];
  input_data_struct_to_buffer( &input_msg, input_data_buffer );

  // First message --------------------------
  printf("\n\nSocket_send ...\n");
  socket.server_run = UDP_TRUE;
  if ( Socket_send( &socket,
                    message_id,
                    input_data_buffer,
                    input_data_struct_size ) == UDP_FALSE ) {
    printf( "Warning! Couldn't send the message with ID %d\n", message_id );
    printf( "Output message: manoeuvre not calculated\n");
  } else {
    printf( "Socket_send, done\n" );
    // Clear the buffer: this is to receive data
    printf( "\n\nSocket_receive ...\n" );
    memset(buffer, '\0', buffer_size);
    if ( Socket_receive( &socket,
                         &message_id,
                         buffer,
                         buffer_size,
                         start_time ) == UDP_FALSE ) {
      printf("Output message: manoeuvre not calculated\n");
    }
  }

  // Close socket
  if ( Socket_close(&socket) == UDP_FALSE ) {
    printf("Socket_close, failed\n");
    return -1;
  }
  printf("Done\n");
  return 0;
}
