local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/vortigaunt_doctor.mdl"}
NPC.StartHealth = 250

-- Health regen
NPC.HealthRegenAmount = 1
NPC.HealthCooldown = 0.2