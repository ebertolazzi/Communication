#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>

#ifndef SOCKET_ERROR
  #define SOCKET_ERROR (-1)
#endif

/*\
 | Open socket
\*/

int
Socket_open( SocketData * pS, int bind_port ) {
  pS->socket_id = 0;

  unsigned int   opt_buflen;
  struct timeval timeout;

  /* Create UDP socket */
  pS->socket_id = (int)socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if ( pS->socket_id == -1 ) {
    perror("error socket()");
    return FALSE;
  }

  /* Set send buffer size limit */
  opt_buflen = PACKET_BYTES;
  if ( setsockopt( pS->socket_id,
                   SOL_SOCKET,
                   SO_SNDBUF,
                   (char *)&opt_buflen,
                   sizeof(opt_buflen) ) == SOCKET_ERROR ) {
    perror("error setsockopt()");
    return FALSE;
  }

  /*\
   | Set send and receive time-outs
   | Windows: it is used a non-blocking
   | socket if defined time-out <= 400 ms
  \*/

  timeout.tv_sec = 0;
  timeout.tv_usec = RECV_SND_TIMEOUT_MS * 1000;
  if ( setsockopt( pS->socket_id,
                   SOL_SOCKET,
                   SO_SNDTIMEO,
                   (char *)&timeout,
                   sizeof(timeout) ) == SOCKET_ERROR ) {
    perror("error setsockopt()");
    return FALSE;
  }
  if ( setsockopt( pS->socket_id,
                   SOL_SOCKET,
                   SO_RCVTIMEO,
                   (char *)&timeout,
                   sizeof(timeout) ) == SOCKET_ERROR ) {
    perror("error setsockopt()");
    return FALSE;
  }

  /*\
   | If it is a server, bind socket to port
  \*/

  if ( bind_port == TRUE ) {
    if ( bind( pS->socket_id,
              (const struct sockaddr*) &pS->target_addr,
              sizeof(pS->target_addr) ) == SOCKET_ERROR ) {
      perror("error bind()");
      return FALSE;
    }
  }

  printf("======================================\n");
  char ipAddress[INET_ADDRSTRLEN];
  if ( bind_port == TRUE ) {
    printf("SERVER\n");
    printf("Server port:%d\n",ntohs(pS->target_addr.sin_port));
  } else {
    inet_ntop( AF_INET,
               &(pS->target_addr.sin_addr.s_addr),
               ipAddress,
               INET_ADDRSTRLEN );
    printf("CLIENT\n");
    printf("Server address: %s\n", ipAddress);
    printf("Server port:    %d\n", ntohs(pS->target_addr.sin_port));
  }
  printf("======================================\n") ;
  return FALSE;
}

/*\
 | Close socket
\*/

int
Socket_close( SocketData * pS ) {
  if ( shutdown( pS->socket_id, SHUT_RDWR ) == SOCKET_ERROR ) {
    perror("error shutdown(socket_id,...)");
    return FALSE;
  }
  return TRUE;
}
