/* ============================================================================
  UDP communication with limited packed size
 ============================================================================ */

#include "udp_C_class.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32) || defined(WIN32) || defined(_WIN64) || defined(WIN64)
  #include "udp_C_win.hxx"
  #include <Ws2tcpip.h>
  typedef int ssize_t;
#else
  #include "udp_C_unix.hxx"
#endif

/*\
 |   ____             _        _
 |  / ___|  ___   ___| | _____| |_
 |  \___ \ / _ \ / __| |/ / _ \ __|
 |   ___) | (_) | (__|   <  __/ |_
 |  |____/ \___/ \___|_|\_\___|\__|
\*/

void
Socket_new( SocketData * pS ) {
  pS->socket_id  = -1;
  pS->server_run = UDP_FALSE;
  pS->timeout_ms = UDP_APP_TIMEOUT_MS;
}

void
Socket_check( SocketData * pS ) {
  if ( pS->socket_id >= 0 ) {
    printf( "Opened socket id = %d\n", pS->socket_id );
  } else {
    printf( "Socket not opened\n" );
    exit(-1);
  }
}

void
Socket_open_as_client(
  SocketData * pS,
  char const   addr[],
  int          port
) {
  Socket_open_addr( pS, addr, port );
  Socket_open( pS, UDP_FALSE );
}

void
Socket_open_as_server( SocketData * pS, int port ) {
  Socket_open_addr( pS, nullptr, port );
  Socket_open( pS, UDP_TRUE );
}

void
Socket_open_addr(
  SocketData * pS,
  char const   addr[],
  int          port
) {
  /* Clear the address structures */
  memset( &pS->sock_addr, 0, sizeof(pS->sock_addr) );
  pS->sock_addr_len = sizeof(pS->sock_addr);
  /* Set the address structures */
  pS->sock_addr.sin_family = AF_INET;
  pS->sock_addr.sin_port   = (in_port_t)port;
  if ( addr == nullptr ) {
    pS->sock_addr.sin_addr.s_addr = INADDR_ANY;
  } else {
    #if defined(_WIN32) || defined(WIN32) || defined(_WIN64) || defined(WIN64)
    InetPton( AF_INET, addr, pS->sock_addr.sin_addr.s_addr );
    #else
    pS->sock_addr.sin_addr.s_addr = inet_addr(addr);
    #endif
  }
}

/*\
 | Send message function
\*/

int
Socket_send(
  SocketData * pS,
  int32_t      message_id,
  uint8_t      message[],
  uint32_t     message_size
) {

  uint32_t n_packets;
  packet_t packet;
  uint32_t ipos;
  ssize_t  isend;

  #if defined(WIN_NONBLOCK)
	uint64_t socket_start_time;
	uint64_t socket_elapsed_time;
  #endif

  n_packets = Packet_Number( message_size );

  /* Send packets */
  for ( ipos = 0; ipos < n_packets; ++ipos ) {

    Packet_Build_from_buffer(
      message, message_size, ipos, message_id,
      pS->server_run, &packet
    );

    #if defined(WIN_NONBLOCK)
    socket_start_time = get_time_ms();
    while ( 1 ) {
      isend = sendto(
        pS->socket_id,
        packet.data_buffer,
        (size_t) UDP_PACKET_BYTES,
        0,
        (struct sockaddr *) &pS->sock_addr,
        pS->sock_addr_len
      );
      if ( isend == SOCKET_ERROR ) {
        socket_elapsed_time = get_time_ms() - socket_start_time;
        if ( WSAGetLastError() != WSAEWOULDBLOCK ||
             socket_elapsed_time >= UDP_RECV_SND_TIMEOUT_MS ) {
          printf(
            "sendto() failed. Error Code: %d\n", WSAGetLastError()
          );
          return UDP_FALSE;
        }
      } else {
        break;
      }
    }
    #elif defined(_WIN32) || defined(WIN32) || defined(_WIN64) || defined(WIN64)
    isend = sendto(
      socket_id,
      packet.data_buffer,
      (size_t) UDP_PACKET_BYTES,
      0,
      (struct sockaddr *) &pS->sock_addr,
      pS->sock_addr_len
    );
    if ( isend == SOCKET_ERROR ) {
      printf( "sendto() failed. Error Code: %d\n", WSAGetLastError() );
      return UDP_FALSE;
    }
    #elif defined(__MACH__) || defined(__linux__)
    isend = sendto(
      pS->socket_id,
      packet.data_buffer,
      (size_t) UDP_PACKET_BYTES,
      0,
      (struct sockaddr *) &pS->sock_addr,
      pS->sock_addr_len
    );
    if ( isend == SOCKET_ERROR ) {
      perror("error sendto()");
      return UDP_FALSE;
    }
    #endif
  }

  #ifdef DEBUG_UDP
  printf(
    "Sent message of %d packets to %s:%d\n",
     n_packets, inet_ntoa(pS->sock_addr.sin_addr),
     pS->sock_addr.sin_port
  );
  #endif
  return UDP_TRUE;
}

/*\
 | Receive message function
\*/

int
Socket_receive(
  SocketData * pS,
  int32_t    * p_message_id,
  uint8_t      message[],
  uint32_t     message_size,
  uint64_t     start_time_ms
) {

  packet_t packet;
  ssize_t  buffer_bytes    = 0;
  ssize_t  recv_bytes      = 0;
  uint64_t elapsed_time_ms = 0;

  #if defined(WIN_NONBLOCK)
  uint64_t socket_start_time;
  uint64_t socket_elapsed_time;
  #endif

  packet_info_t pi;
  Packet_Init( &pi, start_time_ms );

  /* azzera pacchetto da ricevere */
  memset( packet.data_buffer, '\0', sizeof(packet.data_buffer) );

  /* Receive packets */
  elapsed_time_ms = start_time_ms == 0 ? 0 : get_time_ms() - start_time_ms;
  while ( elapsed_time_ms <= pS->timeout_ms && pS->server_run == UDP_TRUE ) {

    #if defined(WIN_NONBLOCK)
    socket_start_time = get_time_ms();
    while ( 1 ) {
      pS->sock_addr_len = sizeof(pS->sock_addr);
      recv_bytes = recvfrom(
        pS->socket_id,
        packet.data_buffer,
        (size_t) UDP_PACKET_BYTES,
        0,
        (struct sockaddr *) &pS->sock_addr,
        &pS->sock_addr_len
      );
      socket_elapsed_time = get_time_ms() - socket_start_time;

      if ( recv_bytes == SOCKET_ERROR ) {
        if ( WSAGetLastError() != WSAEWOULDBLOCK ||
             socket_elapsed_time >= UDP_RECV_SND_TIMEOUT_MS ) break;
      } else {
        break;
      }
    }
    #elif defined(_WIN32) || defined(WIN32) || defined(_WIN64) || defined(WIN64)
    pS->sock_addr_len = sizeof(pS->sock_addr);
    recv_bytes = recvfrom(
      pS->socket_id,
      packet.data_buffer,
      (size_t) UDP_PACKET_BYTES,
      0,
      (struct sockaddr *) &pS->sock_addr,
      &pS->sock_addr_len
    );
    #elif defined(__MACH__) || defined(__linux__)
    pS->sock_addr_len = sizeof(pS->sock_addr);
    recv_bytes = recvfrom(
      pS->socket_id,
      packet.data_buffer,
      (size_t) UDP_PACKET_BYTES,
      0,
      (struct sockaddr *) &pS->sock_addr,
      &pS->sock_addr_len
    );
    #endif

    #if defined(WIN_NONBLOCK)
    if ( recv_bytes != SOCKET_ERROR )
    #elif defined(_WIN32) || defined(WIN32) || defined(_WIN64) || defined(WIN64)
    if ( recv_bytes != SOCKET_ERROR)
    #elif defined(__MACH__) || defined(__linux__)
    if ( recv_bytes > 0 )
    #endif
    {
      buffer_bytes += recv_bytes;
      Packet_Add_to_buffer( &pi, &packet, message, message_size );
      pS->server_run = pi.server_run;
    } else {
      sleep_ms(UDP_SLEEP_MS);
    }

    if ( pi.received_packets == pi.n_packets && pi.n_packets > 0 ) break;

    // Calculate elapsed time
    if ( start_time_ms != 0 )
      elapsed_time_ms = get_time_ms() - start_time_ms;

  }

  if ( pi.received_packets == pi.n_packets ) {
    *p_message_id = pi.datagram_id;
    #ifdef DEBUG_UDP
    printf(
      "Received message of %d packets from %s:%d\n",
      pi.n_packets,
      inet_ntoa(pS->sock_addr.sin_addr),
      pS->sock_addr.sin_port
    );
    #endif
    return UDP_TRUE;
  } else if ( elapsed_time_ms >= pS->timeout_ms ) {
    printf(
      "Receive Warning: Time-out reached! Timeout is: %llu Time needed: %llu\n",
      pS->timeout_ms, elapsed_time_ms
    );
    return UDP_FALSE;
  } else {
    printf( "Receive Warning: Server not running'n" );
    return UDP_FALSE;
  }

}

/*\
 |   __  __       _ _   _               _
 |  |  \/  |_   _| | |_(_) ___ __ _ ___| |_
 |  | |\/| | | | | | __| |/ __/ _` / __| __|
 |  | |  | | |_| | | |_| | (_| (_| \__ \ |_
 |  |_|  |_|\__,_|_|\__|_|\___\__,_|___/\__|
\*/

#ifdef __cplusplus
}
#endif
