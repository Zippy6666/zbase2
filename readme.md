███████╗██████╗░░█████╗░░██████╗███████╗
╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝
░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░
██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░
███████╗██████╦╝██║░░██║██████╔╝███████╗
╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝
### By Zippy.

# Create a ZBase addon:
### Templates:
- ZBase Dummy Addon: https://github.com/Zippy6666/zbase2/tree/dummy. Put that in your addon's folder, and go wild. It works similiarly to any other SNPC/NPC/NextBot base. NPCs are stored in "lua/zbase/entities".

### Base variables and functions:
- Init: https://github.com/Zippy6666/zbase2/blob/main/lua/zbase/npc_base_init.lua
- Shared: https://github.com/Zippy6666/zbase2/blob/main/lua/zbase/npc_base_shared.lua

### Callable functions:
- NPC Utilities: https://github.com/Zippy6666/zbase2/blob/main/lua/zbase/npc_base_util.lua
- Globals: https://github.com/Zippy6666/zbase2/blob/main/lua/zbase/sh_globals_pub.lua

### Weapon base: 
- Shared: https://github.com/Zippy6666/zbase2/blob/main/lua/weapons/weapon_zbase/shared.lua

### Projectile base
- Shared: https://github.com/Zippy6666/zbase2/blob/main/lua/entities/zb_projectile.lua

# TODO
- [ ] NPC weapon suppressing
- [ ] Autorefresh for ZBase legacy addons
- [ ] Revamp static/stationary into more of a guard mode
- [ ] Make so that the NPC has time to try execute move before jump when doing ZBaseMove (to reduce amount of jumping and give the NPC a chance to traverse on foot)
- [ ] Try improve AI when enemy is lost (so that they don't spam enemy lost sounds)
- [ ] Revamp aerial AI?
- [ ] Increase frequency of facing check when using weapons (so that they don't fire at enemies they aren't facing...)
- [ ] Make AI less retarded in any way possible
    - [ ] Stop metrocops from thowing grenades when they are in an arrest state (hell of an arrest to toss a frag at the suspect..)
- [ ] SNPC:ify hunter and d0g