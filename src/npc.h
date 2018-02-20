#pragma once

/* This is fucked up -- headers are not independent, so in order
   to get all the dependencies we should include 'itmmorgue.h',
   should be fixed */
#include "itmmorgue.h"

#include "connection.h"
#include "stuff.h"

struct npc;

typedef void (*npc_event_handler_t)(struct npc * npc, void * ctx);

typedef struct npc {
    uint32_t id;

    enum stuff tile;
    enum colors color;

    uint16_t x;
    uint16_t y;

    /* npc stats (hp, mp, atk, def, (de)buffs, speed...) */

    npc_event_handler_t event_handler;
} npc_t;

/* currently, the only difference between partial and full
   NPC update is tile, so every update is full */
typedef struct npc_mbuf {
    uint32_t id;

    enum stuff tile;
    enum colors color;

    uint16_t x;
    uint16_t y;
} npc_mbuf_t;

void s_send_npc(connection_t * connection, npc_t * npc);
void c_receive_npc(npc_mbuf_t * mbuf);

/* should use some data structure with ability to query
   by coords (x, y) */
extern npc_t npcs[];
extern size_t npcs_len;
