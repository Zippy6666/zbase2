local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/zippy/advisor_ep2.mdl"}
NPC.StartHealth = 5000 -- Max health

NPC.FlinchAnimations = {"flinchone"} -- Flinch animations to use, leave empty to disable the base flinch
NPC.FlinchAnimationSpeed = 1 -- Speed of the flinch animation
NPC.FlinchCooldown = {1, 1} -- Flinch cooldown in seconds
NPC.FlinchChance = 1 -- Flinch chance 1/x
NPC.CollisionBounds = {min=Vector(-26, -26, -26), max=Vector(26, 26, 26)}
NPC.HullType = HULL_SMALL_CENTERED -- The hull type, false = default, https://wiki.facepunch.com/gmod/Enums/HULL
NPC.SNPCType = ZBASE_SNPCTYPE_FLY -- ZBASE_SNPCTYPE_WALK || ZBASE_SNPCTYPE_FLY || ZBASE_SNPCTYPE_STATIONARY
NPC.FlinchIsGesture = true