# Controllers

This directory contains scripts that act as auto-loaded root nodes for some
(usually unique) aspect of the game world. This includes things like the
primary camera, the level, the player, etc. The important part is that these
controllers should have counterpart nodes that either already exist (such as
the player) or are created by the controller (such as the death screen).

These scripts are available from `/root/` and can be used to reference and use
these nodes without having to look them up yourself.
