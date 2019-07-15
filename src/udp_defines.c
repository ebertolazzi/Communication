#include "udp_defines.h"

#ifdef __cplusplus
  extern "C" {
#endif

#ifndef UDP_TRUE
  #define UDP_TRUE 1
#endif

#ifndef UDP_FALSE
  #define UDP_FALSE -1
#endif

#include <string.h>
#include <stdio.h>

#if defined(_WIN32) || defined(WIN32) || defined(_WIN64) || defined(WIN64)
  #include <Winsock2.h>
#else
  #include <arpa/inet.h>
#endif

#if defined(_WIN32) || defined(WIN32) || defined(_WIN64) || defined(WIN64)
  #include "udp_defines_win.hxx"
  typedef int ssize_t;
#else
  #include "udp_defines_unix.hxx"
#endif

void
Packet_Init( packet_info_t * pi, uint64_t start_time_ms ) {
  pi->server_run        = UDP_FALSE;
  pi->datagram_id       = -1;
  pi->total_packet_size = 0;
  pi->sub_packet_size   = 0;
  pi->received_packets  = 0;
  pi->n_packets         = 0;
  pi->start_time_ms     = start_time_ms;
}

void
Packet_Add_to_buffer(
  packet_info_t  * pi,
  packet_t const * pk,
  uint8_t          buffer[],
  uint32_t         buffer_size
) {

  int32_t datagram_id;

  uint32_t pos,
           total_packet_size,
           sub_packet_size,
           true_sub_packet_size;

  datagram_part_t const * ds = &pk->data_struct;

  int32_t ok = UDP_TRUE;
  datagram_id       = (int32_t)ntohl( (uint32_t)ds->datagram_id );
  total_packet_size = ntohl( ds->total_packet_size );
  sub_packet_size   = ntohl( ds->sub_packet_size);
  if ( pi->received_packets > 0 ) {
    /* check that datagram_id is not changed */
    if ( pi->datagram_id       != datagram_id ||
         pi->total_packet_size != total_packet_size ||
         pi->sub_packet_size   != sub_packet_size ) {
      ok = UDP_FALSE;
    }
  } else {
    pi->datagram_id       = datagram_id;
    pi->total_packet_size = total_packet_size;
    pi->sub_packet_size   = sub_packet_size;
    pi->n_packets         = total_packet_size / sub_packet_size;
    if ( (total_packet_size % sub_packet_size) != 0 ) ++pi->n_packets;
  }

  pi->server_run = (int32_t)ntohl( (uint32_t)ds->server_run );

  pos = ntohl( ds->sub_packet_position );
  true_sub_packet_size = sub_packet_size;
  if ( pos+1 == pi->n_packets ) /* ultimo pacchetto */
    true_sub_packet_size = total_packet_size - pos * sub_packet_size;

  if ( ok == UDP_TRUE ) {
    memcpy( buffer + pos * pi->sub_packet_size,
            &ds->datagram_part,
            true_sub_packet_size );
    ++(pi->received_packets);
  } else if ( datagram_id > pi->datagram_id ) {
    UDP_printf("------- Packet lost! --------\n");
    UDP_printf("------- message id %6d ---------\n",pi->datagram_id);
    pi->datagram_id = (int32_t)ntohl((uint32_t)ds->datagram_id);
    memset( buffer, '0', buffer_size );
    memcpy( buffer + pos * sub_packet_size,
            &ds->datagram_part,
            true_sub_packet_size );
    pi->received_packets = 1;
  } else {
    UDP_printf("------- Old Packet received! -------\n");
    UDP_printf("------- message id %6d -------\n", datagram_id );
  }

  #ifdef DEBUG_UDP
  UDP_printf("Packet received!\n");
  UDP_printf("server_run            = %s\n", ( pi->server_run == UDP_TRUE ?"TRUE":"FALSE" ) );
  UDP_printf("sub_packet_position   = %d\n", pos);
  UDP_printf("sub_packet_size       = %d\n", sub_packet_size);
  UDP_printf("n_packets             = %d\n", pi->n_packets);
  UDP_printf("datagram_id           = %d\n", datagram_id);
  UDP_printf("size of data received = %d\n", true_sub_packet_size);
  #endif
}

void
Packet_Build_from_buffer(
  uint8_t const buffer[],
  uint32_t      packet_size,
  uint32_t      pos,
  int32_t       datagram_id,
  int32_t       run,
  packet_t    * pk
) {
  uint32_t true_sub_packet_size = UDP_SUB_PACKET_SIZE;
  datagram_part_t * ds = &pk->data_struct;
  memcpy( &ds->datagram_part,
          buffer + pos * UDP_SUB_PACKET_SIZE,
          true_sub_packet_size );
  ds->server_run          = (int32_t)htonl((uint32_t)run);
  ds->total_packet_size   = htonl(packet_size);
  ds->sub_packet_position = htonl(pos);
  ds->sub_packet_size     = htonl(UDP_SUB_PACKET_SIZE);
  ds->datagram_id         = (int32_t)htonl((uint32_t)datagram_id);
}

extern
uint32_t
Packet_Number( uint32_t message_size ) {
  uint32_t n_packets = message_size / UDP_SUB_PACKET_SIZE;
  if ( (message_size % UDP_SUB_PACKET_SIZE) != 0 ) ++n_packets;
  return n_packets;
}


#ifdef __cplusplus
}
#endif
