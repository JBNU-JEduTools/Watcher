#include<stdio.h>
#include<stdlib.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<string.h>
#include <arpa/inet.h>
#include <fcntl.h> // for open
#include <unistd.h> // for close
#include<pthread.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <libgen.h>
#include <errno.h>

#define MAX_LINE 4096
#define BUFFSIZE 4096
#define SERVERPORT  7799

char client_message[2000];
char buffer[1024];
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

FILE *logfp, *errfp;

void createDir(char* dir) {
  char dirpath[80] = "0";
  sprintf(dirpath, "mkdir -p %s", dir);
  system(dirpath);
}


long writefile(int sockfd, FILE *fp)
{
    ssize_t n;
    long total = 0;
    char buff[MAX_LINE] = {0};
    while ((n = recv(sockfd, buff, MAX_LINE, 0)) > 0) 
    {
	    total+=n;
        if (n == -1)
        {
            fprintf(errfp, "%s %s\tReceive File Error\n", __DATE__, __TIME__);
            exit(1);
        }
        
        if (fwrite(buff, sizeof(char), n, fp) != n)
        {
            fprintf(errfp, "%s %s\tWrite File Error\n", __DATE__, __TIME__);
            exit(1);
        }
        memset(buff, 0, MAX_LINE);
    }
    return total;
}


void * socketThread(void *arg)
{
  int newSocket = *((int *)arg);
  long received;

  char hostname[BUFFSIZE] = {0}; 
    char filename[BUFFSIZE] = {0}; 
    char dname[BUFFSIZE] = {0}; 
    if (recv(newSocket, hostname, BUFFSIZE, 0) == -1) 
    {
        fprintf(errfp, "%s %s\tCan't receive hostname\n", __DATE__, __TIME__);
        exit(1);
    }


    if (recv(newSocket, filename, BUFFSIZE, 0) == -1) 
    {
        fprintf(errfp, "%s %s\tCan't receive filename\n", __DATE__, __TIME__);
        exit(1);
    }

    strcpy(dname, filename);

    //fprintf(logfp, "** check filename: %s\n", filename);
    createDir(dirname(dname));
    //fprintf(logfp, "** check dirname: %s\n", dname);    

    FILE *fp = fopen(filename, "wb");
    if (fp == NULL) 
    {
        fprintf(errfp, "%s %s\tCan't open file\n", __DATE__, __TIME__);
        exit(1);
    }
    
    char addr[INET_ADDRSTRLEN];
    //fprintf(logfp, "Start receive file: %s from %s\n", filename, inet_ntop(AF_INET, &clientaddr.sin_addr, addr, INET_ADDRSTRLEN));
    fprintf(logfp, "%s %s\tStart receive file: %s from %s\n", __DATE__, __TIME__, filename, hostname);
    received=writefile(newSocket, fp);
    fprintf(logfp, "%s %s\tReceive Success, NumBytes = %ld\n", __DATE__, __TIME__, received);

    fclose(fp);   

  close(newSocket);

  pthread_exit(NULL);
}

int main(){
  int serverSocket, newSocket;
  struct sockaddr_in serverAddr;
  struct sockaddr_storage serverStorage;
  socklen_t addr_size;

  
  logfp = fopen("/var/log/Couch-server.log", "a+");
  if (logfp == NULL) 
  {
      fprintf(errfp, "%s %s\tCan't open LOG file %s\n", __DATE__, __TIME__, strerror(errno));
      exit(1);
  }

  fprintf(logfp, "\n%s %s\tStarting\n", __DATE__, __TIME__);

  
  errfp = fopen("/var/log/Couch-server-error.log", "a+");
  if (logfp == NULL) 
  {
      fprintf(errfp, "%s %s\tCan't open ERROR LOG file %s\n", __DATE__, __TIME__, strerror(errno));
      exit(1);
  }

  fprintf(errfp, "\n%s %s\tStarting\n", __DATE__, __TIME__);

  setvbuf(logfp,NULL,_IONBF,0);
  setvbuf(errfp,NULL,_IONBF,0);
  //fflush(logfp);
  //fflush(errfp);
  //reateDir("/var/log/Couch/41983");

  //Create the socket. 
  serverSocket = socket(PF_INET, SOCK_STREAM, 0);
  // Configure settings of the server address struct
  // Address family = Internet 
  serverAddr.sin_family = AF_INET;
  //Set port number, using htons function to use proper byte order 
  serverAddr.sin_port = htons(SERVERPORT);
  //Set IP address to localhost 
  serverAddr.sin_addr.s_addr = inet_addr("10.0.0.150");
  //serverAddr.sin_addr.s_addr = inet_addr("127.0.0.1");
  //Set all bits of the padding field to 0 
  memset(serverAddr.sin_zero, '\0', sizeof serverAddr.sin_zero);
  //Bind the address struct to the socket 
  bind(serverSocket, (struct sockaddr *) &serverAddr, sizeof(serverAddr));
  //Listen on the socket, with 40 max connection requests queued
  //
  //
  pthread_attr_t attr;
  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr,1);

  if(listen(serverSocket,50)==0)
    fprintf(logfp, "%s %s\tListening\n", __DATE__, __TIME__);
  else
    fprintf(logfp, "%s %s\tError\n", __DATE__, __TIME__);
    pthread_t tid[60];
    int i = 0;
    while(1)
    {
        //Accept call creates a new socket for the incoming connection
        addr_size = sizeof serverStorage;
        newSocket = accept(serverSocket, (struct sockaddr *) &serverStorage, &addr_size);
        //for each client request creates a thread and assign the client request to it to process
       //so the main thread can entertain next request
        if( pthread_create(&tid[i++], &attr, socketThread, &newSocket) != 0 )
	      //if( pthread_create(&tid[i++], NULL, socketThread, &newSocket) != 0 )
           fprintf(logfp, "%s %s\tFailed to create thread\n", __DATE__, __TIME__);
        if( i >= 50)
        {
          i = 0;
          while(i < 50)
          {
            pthread_join(tid[i++],NULL);
          }
          i = 0;
        }
    }
  return 0;
}
