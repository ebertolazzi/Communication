#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <time.h>

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
      pS->sock_addr_len
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
MultiCast_open_as_client(
  SocketData * pS,
  char const   local_address[],
  char const   group_address[],
  int          group_port
) {

  int            ret;
  struct in_addr localInterface;

  /* Create UDP socket */
  pS->socket_id = (int32_t)socket(AF_INET, SOCK_DGRAM, 0);// IPPROTO_UDP);
  if ( pS->socket_id == -1 ) {
    perror("UDP STREAMING Opening datagram socket error");
    return UDP_FALSE;
  } else {
    printf("UDP STREAMING Opening the datagram socket...OK.\n");
  }

  bzero((char *)&pS->sock_addr, sizeof(pS->sock_addr));
  pS->sock_addr.sin_family      = AF_INET;
  pS->sock_addr.sin_addr.s_addr = inet_addr(group_address);
  pS->sock_addr.sin_port        = htons(group_port);
  pS->sock_addr_len             = sizeof(pS->sock_addr);

  // Enable loopback so you do  receive your own datagrams.
#if 0
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
    "Adding multicast group %s:%i on %s...OK.\n",
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

#endif

  return UDP_TRUE;
}

int
MultiCast_open_as_server(
  SocketData * pS,
  char const   local_address[],
  char const   group_address[],
  int          group_port
) {

  int            ret, yes;
  struct in_addr localInterface;
  struct ip_mreq mreq;

  /* Create UDP socket */
  pS->socket_id = (int32_t)socket(AF_INET, SOCK_DGRAM, 0);// IPPROTO_UDP);
  if ( pS->socket_id == -1 ) {
    perror("UDP STREAMING Opening datagram socket error");
    return UDP_FALSE;
  } else {
    printf("UDP STREAMING Opening the datagram socket...OK.\n");
  }
  
  /* allow multiple sockets to use the same PORT number */
  yes = 1;
  ret = setsockopt( pS->socket_id, SOL_SOCKET, SO_REUSEADDR, (char*) &yes, sizeof(yes) );
  if ( ret < 0 ) {
    perror("UDP STREAMING Reusing failed");
    return UDP_FALSE;
  }

  bzero((char *)&pS->sock_addr, sizeof(pS->sock_addr));
  pS->sock_addr.sin_family      = AF_INET;
  pS->sock_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  pS->sock_addr.sin_port        = htons(group_port);
  pS->sock_addr_len             = sizeof(pS->sock_addr);

  /* bind to receive address */
  ret = bind( pS->socket_id, (struct sockaddr *) &pS->sock_addr, sizeof(pS->sock_addr) );
  if ( ret < 0 ) {
    perror("UDP STREAMING bind socket error");
    return UDP_FALSE;
  }

  /* Preparatios for using Multicast */ 
  mreq.imr_multiaddr.s_addr = inet_addr(group_address);
  mreq.imr_interface.s_addr = htonl(INADDR_ANY);         
  ret = setsockopt(pS->socket_id, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq));
  if ( ret < 0 ) {
    perror("UDP STREAMING setsockopt mreq");
    return UDP_FALSE;
  }
  return UDP_TRUE;
}
