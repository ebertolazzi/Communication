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
Socket_open(
  SocketData * pS,
  int          bind_port
) {

  unsigned int   opt_buflen;
  struct timeval timeout;
  int            ret;

  /* Create UDP socket */
  pS->socket_id = (int32_t)socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if ( pS->socket_id == -1 ) {
    perror("error socket()");
    return UDP_FALSE;
  }

  /* Set send buffer size limit */
  opt_buflen = UDP_PACKET_BYTES;
  ret = setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_SNDBUF,
    (char *)&opt_buflen,
    sizeof(opt_buflen)
  );
  if ( ret == SOCKET_ERROR ) {
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
  ret = setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_SNDTIMEO,
    (char *)&timeout,
    sizeof(timeout)
  );
  if ( ret == SOCKET_ERROR ) {
    perror("error setsockopt()");
    return UDP_FALSE;
  }
  ret = setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_RCVTIMEO,
    (char *)&timeout,
    sizeof(timeout)
  );
  if ( ret == SOCKET_ERROR ) {
    perror("error setsockopt()");
    return UDP_FALSE;
  }

  /*\
   | If it is a server, bind socket to port
  \*/

  if ( bind_port == UDP_TRUE ) {
    ret = bind(
      pS->socket_id,
      (const struct sockaddr *) &pS->sock_addr,
      sizeof(pS->sock_addr)
    );
    if ( ret == SOCKET_ERROR ) {
      perror("error bind()");
      return UDP_FALSE;
    }
  }

  printf("======================================\n");
  char ipAddress[INET_ADDRSTRLEN];
  if ( bind_port == UDP_TRUE ) {
    printf("SERVER\n");
    printf("Server port:%d\n",pS->sock_addr.sin_port);
  } else {
    inet_ntop(
      AF_INET,
      &(pS->sock_addr.sin_addr.s_addr),
      ipAddress,
      INET_ADDRSTRLEN
    );
    printf("CLIENT\n");
    printf("Server address: %s\n", ipAddress);
    printf("Server port:    %d\n", pS->sock_addr.sin_port);
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

int
MultiCast_open(
  SocketData * pS,
  char const   local_address[],
  char const   group_address[],
  long         group_port
) {

  int            ret, reuse;
  struct in_addr localInterface;

  //unsigned int   opt_buflen;
  //struct timeval timeout;

  /* Create UDP socket */
  pS->socket_id = (int32_t)socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if ( pS->socket_id == -1 ) {
    perror("UDP STREAMING Opening datagram socket error");
    return UDP_FALSE;
  } else {
    printf("UDP STREAMING Opening the datagram socket...OK.\n");
  }

  reuse = 1;
  ret = setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_REUSEADDR,
    (char *)&reuse,
    sizeof(reuse)
  );
  if ( ret < 0 ) {
    printf("Setting SO_REUSEADDR error %s\n",strerror(errno));
    close( pS->socket_id );
    return UDP_FALSE;
  } else {
    printf("Setting SO_REUSEADDR...OK.\n");
  }

  /* Initialize the group sockaddr structure  */
  memset(
    (char *) &(pS->sock_addr), 0,
    sizeof(pS->sock_addr)
  );
  pS->sock_addr.sin_family      = AF_INET;
  pS->sock_addr.sin_addr.s_addr = inet_addr( group_address );
  pS->sock_addr.sin_port        = htons( group_port );
    
  // Enable loopback so you do  receive your own datagrams.

  char loopch = 1;
  ret = setsockopt(
    pS->socket_id,
    IPPROTO_IP,
    IP_MULTICAST_LOOP,
    (char *)&loopch,
    sizeof(loopch)
  );
  if ( ret < 0 ) {
    printf(
      "UDP STREAMING Setting IP_MULTICAST_LOOP error %i %s\n",
      ret, strerror(errno)
    );
  } else {
    printf("UDP STREAMING enabling the loopback...OK.\n" );
  }
  printf(
    "Adding multicast group %s:%li on %s...OK.\n",
    group_address, group_port, local_address
  );

  /* Set local interface for outbound multicast datagrams. */
  /* The IP address specified must be associated with a local, */
  /* multicast capable interface. */
  localInterface.s_addr = inet_addr(local_address);
  ret = setsockopt(
    pS->socket_id,
    IPPROTO_IP,
    IP_MULTICAST_IF,
    (char *)&localInterface,
    sizeof(localInterface)
  );
  if ( ret < 0 ) {
    printf(
      "UDP STREAMING Setting local interface(%s) error(%i) : %s\n",
      local_address, ret, strerror(errno)
    );
  } else {
    printf(
      "UDP STREAMING Setting the local interface: %s...OK\n",
      local_address
    );
  }
  return UDP_TRUE;
}
