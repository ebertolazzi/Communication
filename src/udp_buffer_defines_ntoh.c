#include "udp_buffer_defines.h"

#ifdef __clang__
#pragma clang diagnostic ignored "-Wunreachable-code-return"
#endif

#include <math.h>

/* ---------------------------------------------------------------------------- */

uint32_t
buffer_to_uint8( uint8_t const buffer[1], uint8_t * out ) {
  *out = buffer[0];
  return sizeof(uint8_t);
}

uint32_t
buffer_to_int8( uint8_t const buffer[1], int8_t * out ) {
  *((uint8_t*)out) = buffer[0];
  return sizeof(int8_t);
}

uint32_t
buffer_to_uint16( uint8_t const buffer[2], uint16_t * out ) {
  uint16_t lo = (uint16_t)buffer[0];
  uint16_t hi = (uint16_t)buffer[1];
  *out = lo|(hi<<8);
  return 2;
}

uint32_t
buffer_to_int16( uint8_t const buffer[2], int16_t * out ) {
  return buffer_to_uint16( buffer, (uint16_t*)out);
}

uint32_t
buffer_to_uint32( uint8_t const buffer[4], uint32_t * out ) {
  uint32_t b0 = (uint32_t)buffer[0];
  uint32_t b1 = (uint32_t)buffer[1];
  uint32_t b2 = (uint32_t)buffer[2];
  uint32_t b3 = (uint32_t)buffer[3];
  *out = b0|(b1<<8)|(b2<<16)|(b3<<24);
  return 4;
}

uint32_t
buffer_to_int32( uint8_t const buffer[4], int32_t * out ) {
  return buffer_to_uint32( buffer, (uint32_t*)out);
}

uint32_t
buffer_to_uint64( uint8_t const buffer[8], uint64_t * out ) {
  uint64_t b0 = (uint64_t)buffer[0];
  uint64_t b1 = (uint64_t)buffer[1];
  uint64_t b2 = (uint64_t)buffer[2];
  uint64_t b3 = (uint64_t)buffer[3];
  uint64_t b4 = (uint64_t)buffer[4];
  uint64_t b5 = (uint64_t)buffer[5];
  uint64_t b6 = (uint64_t)buffer[6];
  uint64_t b7 = (uint64_t)buffer[7];
  *out = b0|(b1<<8)|(b2<<16)|(b3<<24)|(b4<<32)|(b5<<40)|(b6<<48)|(b7<<56);
  return 8;
}

uint32_t
buffer_to_int64( uint8_t const buffer[8], int64_t * out ) {
  return buffer_to_uint64( buffer, (uint64_t*)out);
}

uint32_t
buffer_to_float( uint8_t const buffer[8], float *out) {
  union FloatInt {
    float    f;
    uint32_t i;
  } tmp;
  uint32_t res = buffer_to_uint32( buffer, &tmp.i );
  *out = tmp.f;
  return res;
}

uint32_t
buffer_to_double( uint8_t const buffer[8], double *out ) {
  union DoubleInt {
    double   d;
    uint64_t i;
  } tmp;
  uint32_t res = buffer_to_uint64( buffer, &tmp.i );
  *out = tmp.d;
  return res;
}

uint32_t
buffer_to_float_portable( uint8_t const buffer[4+2], float *out ) {
  int32_t m;
  int16_t e;
  uint32_t res = buffer_to_int32( buffer,   &m )+
                 buffer_to_int16( buffer+4, &e );
  uint32_t one = 1;
  float    x   = (float)(m)/(float)(one<<30);
  *out = ldexpf(x, (int)e );
  return res;
}

uint32_t
buffer_to_double_portable( uint8_t const buffer[8+2], double *out ) {
  int64_t m;
  int16_t e;
  uint32_t res = buffer_to_int64( buffer,   &m )+
                 buffer_to_int16( buffer+8, &e );
  int64_t one = 1;
  double  x   = (double)(m)/(double)(one<<62);
  *out = ldexp(x, (int)e );
  return res;
}

void
buffer_to_string(
  uint8_t const buffer[],
  uint32_t      buffer_size,
  char          out[],
  uint32_t      out_max_size
) {
  char hex[] = {
     '0', '1', '2', '3', '4', '5', '6', '7',
     '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
  };
  int n = buffer_size;
  if ( 3*n >= out_max_size ) n = out_max_size/3; // NO CONTROLS
  for ( uint32_t i = 0; i < n; ++i ) {
    out[3*i+1] = hex[buffer[i]&0x0F];
    out[3*i]   = hex[buffer[i]>>4];
    out[3*i+2] = '-';
  }
  out[3*n-1] = '\0'; // fine stringa
}
