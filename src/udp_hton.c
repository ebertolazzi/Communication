#include "buffer_defines.h"
#include <string.h>

#if defined(_WIN32)
#include <Ws2tcpip.h>
#elif defined(__MACH__) || defined(__linux__)
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#endif

static
uint64_t
htonll_local( uint64_t n ) {
  uint64_t lo, hi;
  if ( 1 == htonl(1) ) return n;
  hi = (uint64_t)htonl( *((uint32_t*)&n) );
  n = n>>32;
  lo = (uint64_t)htonl( *((uint32_t*)&n) );
  return (hi << 32) + lo;
}

// --------------------------------------------------

void
uint16_to_buffer( uint16_t in, uint8_t buffer[2] ) {
  uint16_t tmp = htons( in );
  memcpy( buffer, &tmp, 2 );
}

void
int16_to_buffer( int16_t in, uint8_t buffer[2] ) {
  uint16_t tmp = htons( (uint16_t) in );
  memcpy( buffer, &tmp, 2 );
}

void
int32_to_buffer( int32_t in, uint8_t buffer[4] ) {
  uint32_t tmp = htonl( (uint32_t) in );
  memcpy( buffer, &tmp, 4 );
}

void
uint32_to_buffer( uint32_t in, uint8_t buffer[4] ) {
  uint32_t tmp = htonl( in );
  memcpy( buffer, &tmp, 4 );
}

void
int64_to_buffer( int64_t in, uint8_t buffer[8] ) {
  uint64_t tmp = htonll_local( (uint64_t) in );
  memcpy( buffer, &tmp, 8 );
}

void
uint64_to_buffer( uint64_t in, uint8_t buffer[8] ) {
  uint64_t tmp = htonll_local( in );
  memcpy( buffer, &tmp, 8 );
}

#ifdef PACK_FLOAT

  #ifndef maskOfBits
    #define maskOfBits(NBITS) ((uint64_t(1)<<NBITS)-uint64_t(1))
  #endif

  static
  uint64_t
  pack754( double f, uint32_t bits, uint32_t expbits ) {
    double   fnorm;
    uint64_t sign;
    uint32_t significandbits = bits - expbits - 1 ; /* -1 for sign bit */
    /* special case NaN and INF */
    if ( f != f ) { // NaN
      return ~uint64_t(0);
      return ;
    }
    if ( f*0.0 != 0.0 ) { // INF
      return maskOfBits(expbits)<<significandbits;
    }
    if ( f == 0.0 ) return uint64_t(0); /* get this special case out of the way */
    /* check sign and begin normalization */
    fnorm = f ;
    sign  = 0 ;
    if ( f < 0 ) { sign = uint64_t(1)<<(bits-1); fnorm = -f; }

    /* get the normalized form of f and track the exponent
       get the biased exponent */
    uint64_t exp = maskOfBits(expbits-1); /* bias */
    while ( fnorm >= 2.0 ) { fnorm /= 2.0; ++exp; }
    while ( fnorm <  1.0 ) { fnorm *= 2.0; --exp; }
    fnorm -= 1.0 ;
    /* calculate the binary form (non-float) of the significand data */
    uint64_t significand = fnorm * ((uint64_t(1)<<significandbits) + 0.5f);
    /* return the final answer */
    return sign | (exp<<significandbits) | significand ;
  }

  void
  float_to_buffer( float in, uint8_t buffer[4] ) {
    uint64_t res64 = pack754( f, 32, 8 );
    uint32_t res32 = (uint32_t)res64;
    uint32_to_buffer( res32, buffer );
  }

  void
  double_to_buffer( double in, uint8_t buffer[8] ) {
    uint64_t res64 = pack754( f, 64, 11 );
    uint32_t res32 = (uint32_t)res64;
    uint32_to_buffer( res32, buffer );
  }

#else

  void
  float_to_buffer( float in, uint8_t buffer[4] ) {
    union FloatInt {
      float    f;
      uint32_t i;
    } tmp;
    tmp.f = in;
    uint32_to_buffer( tmp.i, buffer );
  }

  void
  double_to_buffer( double in, uint8_t buffer[8] ) {
    union DoubleInt {
      double   d;
      uint64_t i;
    } tmp;
    tmp.d = in;
    uint64_to_buffer( tmp.i, buffer );
  }

#endif
