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

#### TODO:
- [ ] Fix subtitles when citizen follows player
- [ ] Fix issue with combines (and other?) not reloading weapons at times