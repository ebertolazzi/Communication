
/* ============================================================================
 UDP communication with limited packed size
 ============================================================================ */

#ifndef __UDP_CLASS_HH
#define __UDP_CLASS_HH

#include "udp_C_class.h"

#include <cmath>
#include <cstdlib>
#include <string>
#include <sstream>
#include <iostream>
#include <exception>

#if __cplusplus >= 201103L
  #define NORETURN [[ noreturn ]]
#else
  #define NORETURN
#endif

class InterruptException : public std::exception {
public:
  InterruptException( char const s[] ) : S(s) {}
  InterruptException( std::string const & s ) : S(s) {}
  std::string S;
};

class Socket {

  SocketData data;

  #ifndef _MSC_VER
  NORETURN
  static
  void
  sig_to_exception( int s ) {
    std::stringstream ss;
    ss << "signal number " << s << " found";
    throw InterruptException(ss.str());
  }
  #endif

public:

  Socket();

  void
  open_as_client( char const addr[], int port )
  { Socket_open_as_client( &data, addr, port ); }

  void
  open_as_server( int port )
  { Socket_open_as_server( &data, port ); }

  int
  open_multicast_as_client(
    char const local_address[],
    char const group_address[],
    int        group_port
  ) {
    return MultiCast_open_as_client(
      &data, local_address, group_address, group_port
    );
  }

  int
  open_multicast_as_server(
    char const local_address[],
    char const group_address[],
    int        group_port
  ) {
    return MultiCast_open_as_server(
      &data, local_address, group_address, group_port
    );
  }

  void
  server_start()
  { data.server_run = UDP_TRUE; }

  void
  server_stop()
  { data.server_run = UDP_FALSE; }

  bool
  server_running() const
  { return data.server_run == UDP_TRUE; }

  void
  set_timeout_ms( uint64_t tout_ms )
  { data.timeout_ms = tout_ms; }

  bool
  close() {
    int ok = Socket_close( &data );
    return ok == UDP_TRUE;
  }

  void
  check() {
    if ( data.socket_id == -1 ) {
      exit(-1);
    } else {
      std::cerr << "Opened socket id = " << data.socket_id << '\n';
    }
  }

  // Send message function
  int
  send(
    int32_t  buffer_id,
    uint8_t  buffer[],
    uint32_t buffer_size
  ) {
    return Socket_send( &data, buffer_id, buffer, buffer_size );
  }

  // Receive message function
  int
  receive(
    int32_t & buffer_id,
    uint8_t   buffer[],
    uint32_t  buffer_size,
    uint64_t  start_time
  ) {
    return Socket_receive( &data,
                           &buffer_id,
                           buffer,
                           buffer_size,
                           start_time );
  }

};

#endif
