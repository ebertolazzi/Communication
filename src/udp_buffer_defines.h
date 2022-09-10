
/* ============================================================================
 Utilities for a SERIALIZER FOR STANDARD C type
 Author: Enrico Bertolazzi, Francesco Biral
 ============================================================================ */

#ifndef __UDP_BUFFER_DEFINES_HH
#define __UDP_BUFFER_DEFINES_HH

#if defined(_WIN32) || defined(WIN32) || defined(_WIN64) || defined(WIN64)
  #define UDP_ON_WINDOWS
#endif

#if defined(UDP_ON_WINDOWS)
  #ifdef __cplusplus
  extern "C" {
  #endif
  #include <Winsock2.h>
  #include <Ws2tcpip.h>
  #include <iptypes.h>
  #include <Iphlpapi.h>
  #include <signal.h>
  /*
  #include <Assert.h>
  #include <sys/stat.h>
  */
  #ifdef __cplusplus
  };
  #endif
  typedef int socklen_t;
#else
  #include <unistd.h>
  #include <arpa/inet.h>
  #include <netinet/in.h>
  /*
  DA INGARE SE SERVE
  #if ! ( defined(__APPLE__) || defined(__MACH__) )
    #include <linux/in.h>
  #endif
  */
  #include <sys/socket.h>
  #include <sys/types.h>
  #include <sys/time.h>
  #include <unistd.h>
  #include <time.h>
  #include <signal.h>
#endif

#ifdef __cplusplus
  #include <cstdint>
  using std::int32_t;
  using std::int64_t;
  using std::uint32_t;
  using std::uint64_t;
  extern "C" {
#else
  #include <stdint.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>

extern uint32_t uint8_to_buffer ( uint8_t  in, uint8_t buffer[1] );
extern uint32_t int8_to_buffer  ( int8_t   in, uint8_t buffer[1] );
extern uint32_t uint16_to_buffer( uint16_t in, uint8_t buffer[2] );
extern uint32_t int16_to_buffer ( int16_t  in, uint8_t buffer[2] );
extern uint32_t int32_to_buffer ( int32_t  in, uint8_t buffer[4] );
extern uint32_t uint32_to_buffer( uint32_t in, uint8_t buffer[4] );
extern uint32_t int64_to_buffer ( int64_t  in, uint8_t buffer[8] );
extern uint32_t uint64_to_buffer( uint64_t in, uint8_t buffer[8] );
extern uint32_t float_to_buffer ( float    in, uint8_t buffer[4] );
extern uint32_t double_to_buffer( double   in, uint8_t buffer[8] );

extern uint32_t float_to_buffer_portable ( float  in, uint8_t buffer[4+2] );
extern uint32_t double_to_buffer_portable( double in, uint8_t buffer[8+2] );

extern uint32_t buffer_to_uint8 ( uint8_t const buffer[1], uint8_t  * out );
extern uint32_t buffer_to_int8  ( uint8_t const buffer[1], int8_t   * out );
extern uint32_t buffer_to_uint16( uint8_t const buffer[2], uint16_t * out );
extern uint32_t buffer_to_int16 ( uint8_t const buffer[2], int16_t  * out );
extern uint32_t buffer_to_uint32( uint8_t const buffer[4], uint32_t * out );
extern uint32_t buffer_to_int32 ( uint8_t const buffer[4], int32_t  * out );
extern uint32_t buffer_to_uint64( uint8_t const buffer[8], uint64_t * out );
extern uint32_t buffer_to_int64 ( uint8_t const buffer[8], int64_t  * out );
extern uint32_t buffer_to_float ( uint8_t const buffer[4], float    * out );
extern uint32_t buffer_to_double( uint8_t const buffer[8], double   * out );

extern uint32_t buffer_to_float_portable ( uint8_t const buffer[4+2], float  * out );
extern uint32_t buffer_to_double_portable( uint8_t const buffer[8+2], double * out );

extern void buffer_to_string( uint8_t const buffer[], uint32_t buffer_size, char out[], uint32_t out_max_size );

#ifdef __cplusplus
}
#endif

#ifdef UDP_MATLAB_MEX_FILE_USE_SIMULINK
  #ifdef MATLAB_MEX_FILE
    #include <simulink/include/simstruc.h>
    #ifdef SS_STDIO_AVAILABLE
      #ifndef UDP_printf
        #define UDP_printf ssPrintf
      #endif
    #endif
  #endif
#endif

#ifndef UDP_printf
  #define UDP_printf printf
#endif

#endif
