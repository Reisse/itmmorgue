#!/bin/sh
# Made by: KorG

perl gen_surface.pl -w256 -h64                        |
perl gen_castle.pl                                    |
perl gen_placeholders.pl                              |
less -S
