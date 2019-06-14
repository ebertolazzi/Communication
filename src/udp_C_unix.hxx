#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>

#ifndef SOCKET_ERROR
  #define SOCKET_ERROR (-1)
#endif

/*\
 |   ____             _        _
 |  / ___|  ___   ___| | _____| |_
 |  \___ \ / _ \ / __| |/ / _ \ __|
 |   ___) | (_) | (__|   <  __/ |_
 |  |____/ \___/ \___|_|\_\___|\__|
\*/

/*\
 | Open socket
\*/

int
Socket_open( SocketData * pS, int bind_port ) {

  unsigned int   opt_buflen;
  struct timeval timeout;

  /* Create UDP socket */
  pS->socket_id = (int32_t)socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if ( pS->socket_id == -1 ) {
    perror("error socket()");
    return UDP_FALSE;
  }

  /* Set send buffer size limit */
  opt_buflen = UDP_PACKET_BYTES;
  if ( setsockopt( pS->socket_id,
                   SOL_SOCKET,
                   SO_SNDBUF,
                   (char *)&opt_buflen,
                   sizeof(opt_buflen) ) == SOCKET_ERROR ) {
    perror("error setsockopt()");
    return UDP_FALSE;
  }

  /*\
   | Set send and receive time-outs
   | Windows: it is used a non-blocking
   | socket if defined time-out <= 400 ms
  \*/

  timeout.tv_sec = 0;
  timeout.tv_usec = UDP_RECV_SND_TIMEOUT_MS * 1000;
  if ( setsockopt( pS->socket_id,
                   SOL_SOCKET,
                   SO_SNDTIMEO,
                   (char *)&timeout,
                   sizeof(timeout) ) == SOCKET_ERROR ) {
    perror("error setsockopt()");
    return UDP_FALSE;
  }
  if ( setsockopt( pS->socket_id,
                   SOL_SOCKET,
                   SO_RCVTIMEO,
                   (char *)&timeout,
                   sizeof(timeout) ) == SOCKET_ERROR ) {
    perror("error setsockopt()");
    return UDP_FALSE;
  }

  /*\
   | If it is a server, bind socket to port
  \*/

  if ( bind_port == UDP_TRUE ) {
    if ( bind( pS->socket_id,
              (const struct sockaddr*) &pS->target_addr,
              sizeof(pS->target_addr) ) == SOCKET_ERROR ) {
      perror("error bind()");
      return UDP_FALSE;
    }
  }

  printf("======================================\n");
  char ipAddress[INET_ADDRSTRLEN];
  if ( bind_port == UDP_TRUE ) {
    printf("SERVER\n");
    printf("Server port:%d\n",pS->target_addr.sin_port);
  } else {
    inet_ntop( AF_INET,
               &(pS->target_addr.sin_addr.s_addr),
               ipAddress,
               INET_ADDRSTRLEN );
    printf("CLIENT\n");
    printf("Server address: %s\n", ipAddress);
    printf("Server port:    %d\n", pS->target_addr.sin_port);
  }
  printf("======================================\n");
  return UDP_FALSE;
}

/*\
 | Close socket
\*/

int
Socket_close( SocketData * pS ) {
  if ( close( pS->socket_id ) != 0 ) {
    perror("error shutdown(socket_id,...)");
    return UDP_FALSE;
  }
  return UDP_TRUE;
}

/*\
 |   __  __       _ _   _               _
 |  |  \/  |_   _| | |_(_) ___ __ _ ___| |_
 |  | |\/| | | | | | __| |/ __/ _` / __| __|
 |  | |  | | |_| | | |_| | (_| (_| \__ \ |_
 |  |_|  |_|\__,_|_|\__|_|\___\__,_|___/\__|
\*/
