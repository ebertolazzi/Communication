
/* ============================================================================

 UDP communication with limited packed size

 Author: Enrico Bertolazzi, Francesco Biral, Gastone Pietro Rosati Papini

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

class InterruptException : public std::exception {
public:
  InterruptException( char const s[] ) : S(s) {}
  InterruptException( std::string const & s ) : S(s) {}
  virtual ~InterruptException() throw() {}
  std::string S;
};

class Socket {

  SocketData data;

  #ifndef _MSC_VER
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
  open_as_client( char const addr[], uint16_t port ) {
    Socket_open_as_client( &data, addr, port );
  }

  void
  open_as_server( uint16_t port ) {
    Socket_open_as_server( &data, port );
  }

  void
  server_start()
  { data.server_run = TRUE; }

  void
  server_stop()
  { data.server_run = FALSE; }

  bool
  server_running() const
  { return data.server_run == TRUE; }

  void
  set_timeout_ms( uint64_t tout_ms )
  { data.timeout_ms = tout_ms; }

  bool
  close() {
    int ok = Socket_close( &data );
    return ok == TRUE;
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
  send( uint32_t buffer_id,
        uint8_t  buffer[],
        uint32_t buffer_size ) {
    return Socket_send( &data, buffer_id, buffer, buffer_size );
  }

  // Receive message function
  int
  receive( uint32_t & buffer_id,
           uint8_t    buffer[],
           uint32_t   buffer_size,
           uint64_t   start_time ) {
    return Socket_receive( &data,
                           &buffer_id,
                           buffer,
                           buffer_size,
                           start_time );
  }

};

#endif
