
#if defined(_WIN32)
  #include <Ws2tcpip.h>
#elif defined(__MACH__) || defined(__linux__)
  #include <string.h>
  #include <unistd.h>
  #include <arpa/inet.h>
  #include <sys/socket.h>
#endif

#include <stdio.h>

#include "udp_class.hh"
#include "codriver_interfaces_data_structs.h"

#include <iostream>
#include <iomanip>

using namespace std;

int
main(void) {

  input_data_struct input_msg;
  uint8_t  buffer[10];
  uint32_t buffer_size = sizeof(buffer)/sizeof(buffer[0]);
  int32_t  message_id = 0;
  int      ret;
  
  // Create and set UDP socket
  // Create and set UDP

  Socket socket;
  socket.open_as_server( 25000 );
  socket.check();
  
  // Start server
  cout << "Server ready\n";

  socket.server_start();
  while( socket.server_running() ) {
    
    // Clear the buffer
    memset(buffer, '\0', buffer_size);
    uint8_t input_data_buffer[input_data_struct_size];

    cout << "Wait socket.receive\n";
    ret = socket.receive(
      message_id,
      input_data_buffer,
      input_data_struct_size,
      0
    );
    if ( ret == UDP_TRUE ) {
      ret = socket.send(
        message_id,
        input_data_buffer,
        input_data_struct_size
      );
      if ( ret == UDP_FALSE ) {
        perror("error send_message()");
        exit(EXIT_FAILURE);
        return -1;
      }

      buffer_to_input_data_struct( input_data_buffer, &input_msg );

      cout
        << "Printing received message\n"
        << "ID            = " << input_msg.ID            << '\n'
        << "Version       = " << input_msg.Version       << '\n'
        << "CycleNumber   = " << input_msg.CycleNumber   << '\n'
        << "ECUupTime     = " << input_msg.ECUupTime     << "(s)\n"
        << "TimeStamp     = " << input_msg.TimeStamp     << "(s)\n"
        << "Status        = " << input_msg.Status        << '\n'
        << "vel           = " << input_msg.vel           << '\n'
        << "x             = " << input_msg.x             << '\n'
        << "y             = " << input_msg.y             << '\n'
        << "z             = " << input_msg.z             << '\n'
        << "yaw           = " << input_msg.yaw           << '\n'
        << "yaw_rate      = " << input_msg.yaw_rate      << '\n'
        << "ax            = " << input_msg.ax            << '\n'
        << "ay            = " << input_msg.ay            << '\n'
        << "delta         = " << input_msg.delta         << '\n'
        << "mode          = " << input_msg.mode          << '\n'
        << "thresholds[0] = " << input_msg.thresholds[0] << '\n'
        << "thresholds[1] = " << input_msg.thresholds[1] << '\n'
        << "thresholds[2] = " << input_msg.thresholds[2] << '\n'
        << "thresholds[3] = " << input_msg.thresholds[3] << '\n'
        << "\n\n\n";
    } else {
      cout << "socket.receive failed\n\n";
    }
  }
  
  cout << "Stopping server..\n";
  if ( socket.close() ) return -1;
  cout << "Done\n";
  return 0;
}
