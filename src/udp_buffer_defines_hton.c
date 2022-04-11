#include "udp_buffer_defines.h"

#ifdef __clang__
#pragma clang diagnostic ignored "-Wunreachable-code-return"
#endif

#include <math.h>


/* -------------------------------------------------- */

uint32_t
int8_to_buffer( int8_t in, uint8_t buffer[1] ) {
  buffer[0] = (uint8_t)in;
  return sizeof(int8_t);
}

uint32_t
uint8_to_buffer( uint8_t in, uint8_t buffer[1] ) {
  buffer[0] = in;
  return sizeof(uint8_t);
}

uint32_t
uint16_to_buffer( uint16_t in, uint8_t buffer[2] ) {
  buffer[0] = (uint8_t)(in & 0xFF); in >>= 8;
  buffer[1] = (uint8_t)(in & 0xFF);
  return 2;
}

uint32_t
int16_to_buffer( int16_t in, uint8_t buffer[2] ) {
  return uint16_to_buffer( *((uint16_t*)&in), buffer );
}

uint32_t
uint32_to_buffer( uint32_t in, uint8_t buffer[4] ) {
  buffer[0] = (uint8_t)(in & 0xFF); in >>= 8;
  buffer[1] = (uint8_t)(in & 0xFF); in >>= 8;
  buffer[2] = (uint8_t)(in & 0xFF); in >>= 8;
  buffer[3] = (uint8_t)(in & 0xFF);
  return 4;
}

uint32_t
int32_to_buffer( int32_t in, uint8_t buffer[4] ) {
  return uint32_to_buffer( (*(uint32_t*)&in), buffer );
}

uint32_t
uint64_to_buffer( uint64_t in, uint8_t buffer[8] ) {
  buffer[0] = (uint8_t)(in & 0xFF); in >>= 8;
  buffer[1] = (uint8_t)(in & 0xFF); in >>= 8;
  buffer[2] = (uint8_t)(in & 0xFF); in >>= 8;
  buffer[3] = (uint8_t)(in & 0xFF); in >>= 8;
  buffer[4] = (uint8_t)(in & 0xFF); in >>= 8;
  buffer[5] = (uint8_t)(in & 0xFF); in >>= 8;
  buffer[6] = (uint8_t)(in & 0xFF); in >>= 8;
  buffer[7] = (uint8_t)(in & 0xFF);
  return 8;
}

uint32_t
int64_to_buffer( int64_t in, uint8_t buffer[8] ) {
  return uint64_to_buffer( (*(uint64_t*)&in), buffer );
}

uint32_t
float_to_buffer( float in, uint8_t buffer[4] ) {
  union FloatInt {
    float    f;
    uint32_t i;
  } tmp;
  tmp.f = in;
  return uint32_to_buffer( tmp.i, buffer );
}

uint32_t
double_to_buffer( double in, uint8_t buffer[8] ) {
  union DoubleInt {
    double   d;
    uint64_t i;
  } tmp;
  tmp.d = in;
  return uint64_to_buffer( tmp.i, buffer );
}

uint32_t
float_to_buffer_portable( float in, uint8_t buffer[4+2] ) {
  int   i;
  float f = frexpf(in, &i);
  int32_t one = 1;
  int32_t m   = (int32_t)(f*(one<<30));
  int16_t e   = (int16_t)i;
  return int32_to_buffer( m, buffer ) +
         int16_to_buffer( e, buffer+4 );
}

uint32_t
double_to_buffer_portable( double in, uint8_t buffer[8+2] ) {
  int i;
  double f = frexp(in, &i);
  int64_t one = 1;
  int64_t m   = (int64_t)(f*(one<<62));
  int16_t e = (int16_t)i;
  return int64_to_buffer( m, buffer ) +
         int16_to_buffer( e, buffer+8 );
}

