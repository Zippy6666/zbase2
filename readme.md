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
- [x] Autorefresh for ZBase legacy addons
- [x] Shrink filesize
- [x] Make following better
- [x] Fix issues with multiple NPCs firing acting weird
- [x] Encourage mfs to install hearing system and dynamic squads on boot
- [x] Improve Aerial AI movement
- [ ] Revamp static/stationary into more of a guard mode
- [ ] More tools (faction, guard, bullseye, smart debugger (show cond, profficiency, etc))
- [ ] Fix issues with facing when playing animations (facing for too long or too short?)
- [ ] NPC weapon suppressing