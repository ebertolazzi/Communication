#include "udp_class.hh"
#include "codriver_interfaces_data_structs.h"

using namespace std;

int
main() {

  uint8_t  buffer[10];
  uint32_t buffer_size = sizeof(buffer)/sizeof(buffer[0]);

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
  input_msg.yaw_rate      = 0.1;
  input_msg.ax            = 1.5;
  input_msg.ay            = -1.5;
  input_msg.delta         = 0.1;
  input_msg.mode          = 3;
  input_msg.thresholds[0] = 1;
  input_msg.thresholds[1] = 2;
  input_msg.thresholds[2] = 3;
  input_msg.thresholds[3] = 4;

  // Calculate message sizes
  uint64_t start_time = get_time_ms();
  int32_t  message_id = 12;

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
  Socket socket;
  socket.open_as_client( UDP_DEFAULT_SERVER_IP, UDP_SERVER_PORT );
  socket.check();

  start_time = get_time_ms();

  uint8_t input_data_buffer[input_data_struct_size];
  input_data_struct_to_buffer( &input_msg, input_data_buffer );

  cout
    << "Sending message\n"
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
  socket.server_start();
  cout << "\n\nsocket.send ...\n";
  if ( socket.send( message_id,
                    input_data_buffer,
                    input_data_struct_size ) == -1 ) {
    cerr
      << "Warning! Couldn't send the message with ID " << message_id
      << "\nOutput message: manoeuvre not calculated\n";
  } else {
    // Clear the buffer: this is to receive data
    cout << "\n\nsocket.receive ...\n";
    memset(buffer, '\0', buffer_size);
    if ( socket.receive( message_id,
                         buffer,
                         buffer_size,
                         start_time ) == -1 ) {
      cerr << "Output message: manoeuvre not calculated\n";
    }
    cout << "\n\nsocket.receive done\n";
  }
  
  // Close socket
  if( socket.close() ) return -1;
  std::cout << "Done\n";
  return 0;
}
