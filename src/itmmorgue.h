// vim: sw=4 ts=4 et :
#ifndef ITMMORGUE_H
#define ITMMORGUE_H

#include <unistd.h>
#if defined(__FreeBSD__) || defined(__linux__)
#include <ncurses.h>
#else
#include <ncurses/ncurses.h>
#endif /* __FreeBSD__ || __linux__ */
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <wctype.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>
#include <signal.h>
#include <wchar.h>
#include <locale.h>
#include <errno.h>
#include <limits.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <errno.h>
#include <pthread.h>

#include "config.h"
#include "protocol.h"
#include "client.h"
#include "server.h"
#include "trie/trie.h"
#include "stuff.h"

int client(void);

int log_fd;
int client(void);
void logger(char *str);
int readall(int fd, void *buf, size_t size);

// Panic related definitions
void warn(char *msg);
void panic(char *msg);
#define warnf(fmt, ...)                             \
    do {                                            \
        char ___buf[BUFSIZ];                        \
        snprintf(___buf, BUFSIZ, fmt, __VA_ARGS__); \
        warn(___buf);                               \
    } while(0)
#define panicf(fmt, ...)                            \
    do {                                            \
        char ___buf[BUFSIZ];                        \
        snprintf(___buf, BUFSIZ, fmt, __VA_ARGS__); \
        panic(___buf);                              \
    } while(0)
#define loggerf(fmt, ...)                           \
    do {                                            \
        char ___buf[BUFSIZ];                        \
        snprintf(___buf, BUFSIZ, fmt, __VA_ARGS__); \
        logger(___buf);                             \
    } while(0)

// Wrapper for strtol(3) for int numbers
int strtoi(const char *nptr, char **endptr, int base);

// strlen() alternatives for UTF-8 strings
size_t anystrlen(char *str);
size_t anystrnlen(char *str, size_t maxlen);
size_t anystrnplen(char *str, size_t maxlen, char ** endp);
size_t anystrunplen(char *str, size_t maxlen, char ** endp);
#ifdef __sun
size_t strnlen(const char *str, size_t maxlen);
#endif /* __sun */

#endif /* ITMMORGUE_H */
