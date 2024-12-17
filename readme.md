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
- [ ] Improve Aerial AI movement
- [ ] Make following better
- [ ] Fix issues with multiple NPCs firing acting weird
- [ ] Fix issues with NPCs getting stuck and doing nothing when they should should/attack