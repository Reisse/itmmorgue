// vim: sw=4 ts=4 et :
#include "itmmorgue.h"
#include "client.h"
#include "config.h"
#include "keyboard.h"
#include "server.h"

/* 
 * To add a menu you have to:
 *
 * 1. Define a signature of menu handler function
 * 2. Modify menus[]
 * 3. Write menu handler function
 * 4. Ensure that you have smth calling the menu
 */

void m_main(int id, WINDOW *win);
void m_options(int id, WINDOW *win);
void m_newgame(int id, WINDOW *win);

void m_null() {
    return;
}

void m_exit_game() {
    exit(0);
    return;
}

menu_t menus[M_SIZE] = {
    { m_main, "Main menu" },
    { m_newgame, "New game" },
    { m_null, "Connect to existing game" },
    { m_options, "Options" },
    { m_null, "Help" },
    { m_exit_game, "Exit to Windows" },
};

void m_newgame(int id, WINDOW *win) {
    int items[] = { M_EXIT_GAME };

    size_t items_len = sizeof(items) / sizeof(int);

    char *caption = _(menus[id].caption);
    size_t caption_len = anystrlen(caption);

    wclear(win);

    // Start of menu render code

    mvwprintw(win,
            max_y / 2 - items_len - 3,
            max_x / 2 - caption_len / 2,
            caption);
    for (size_t i = 0; i < caption_len; i++) {
        mvwprintw(win,
                max_y / 2 - items_len - 2,
                max_x / 2 - caption_len / 2 + i,
                "=");
    }

    for (size_t i = 0; i < items_len; i++) {
        char *item = _(menus[items[i]].caption);
        mvwprintw(win,
                max_y / 2 - items_len + i,
                max_x / 2 - anystrlen(item) / 2 - 2,
                "%d. %s",
                i + 1,
                item);
    }

    server_start();

    do {
        server_connected = connect_to_server("127.0.0.1");
    } while (server_connected == 0);

    return;
}

void m_options(int id, WINDOW *win) {
    // TODO implement functions for stuff
    int items[] = { M_EXIT_GAME };

    size_t items_len = sizeof(items) / sizeof(int);

    char *caption = _(menus[id].caption);
    size_t caption_len = anystrlen(caption);

    wclear(win);

    // Start of menu render code

    mvwprintw(win,
            max_y / 2 - items_len - 3,
            max_x / 2 - caption_len / 2,
            caption);
    for (size_t i = 0; i < caption_len; i++) {
        mvwprintw(win,
                max_y / 2 - items_len - 2,
                max_x / 2 - caption_len / 2 + i,
                "=");
    }

    for (size_t i = 0; i < items_len; i++) {
        char *item = _(menus[items[i]].caption);
        mvwprintw(win,
                max_y / 2 - items_len + i,
                max_x / 2 - anystrlen(item) / 2 - 2,
                "%d. %s",
                i + 1,
                item);
    }

    do {
        // TODO check if we wanna menus with 10+ elements
        last_key = wgetch(win);
        if (last_key > '0' && last_key <= (int)('0' + items_len)) {
            int item_id = last_key - '0' - 1;

            menus[items[item_id]].f(item_id, win);
            return;
        }
    } while (last_key != ERR && last_key != K[K_EXIT]);

    return;
}

void m_main(int id, WINDOW *win) {
    // TODO implement functions for stuff
    int items[] = {
        M_NEW_GAME, M_CONNECT_GAME, M_OPTIONS, M_HELP, M_EXIT_GAME
    };

    size_t items_len = sizeof(items) / sizeof(int);

    char *caption = _(menus[id].caption);
    size_t caption_len = anystrlen(caption);

    wclear(win);

    // Start of menu render code

    mvwprintw(win,
            max_y / 2 - items_len - 3,
            max_x / 2 - caption_len / 2,
            caption);
    for (size_t i = 0; i < caption_len; i++) {
        mvwprintw(win,
                max_y / 2 - items_len - 2,
                max_x / 2 - caption_len / 2 + i,
                "=");
    }

    for (size_t i = 0; i < items_len; i++) {
        char *item = _(menus[items[i]].caption);
        mvwprintw(win,
                max_y / 2 - items_len + i,
                max_x / 2 - anystrlen(item) / 2 - 2,
                "%d. %s",
                i + 1,
                item);
    }

    do {
        // TODO check if we wanna menus with 10+ elements
        last_key = wgetch(win);
        if (last_key > '0' && last_key <= (int)('0' + items_len)) {
            int item_id = last_key - '0' - 1;

            menus[items[item_id]].f(items[item_id], win);
            return;
        }
    } while (last_key != ERR && last_key != K[K_EXIT]);

    return;
}

void menu(size_t menu_id) {
    WINDOW *w_menu;

    if (menu_id >= sizeof(menus) / sizeof(menu_t)) {
        return;
    }

    if ((w_menu = newwin(0, 0, 0, 0)) == NULL) {
        panic("Unable to create menu window!");
    }

    wtimeout(w_menu, -1);

    menus[menu_id].f(menu_id, w_menu);

    delwin(w_menu);

    return;
}
