local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.ZBaseStartFaction = "combine"


NPC.DeathAnimations = {"doddgeright"} -- Death animations to use, leave empty to disable the base death animation
NPC.DeathAnimationSpeed = 1 -- Speed of the death animation
NPC.DeathAnimationChance = 1 --  Death animation chance 1/x
NPC.DeathAnimation_StopAttackingMe = false -- Stop other NPCs from attacking this NPC when it is doing its death animation

-- Duration of death animation, set to false to use the default duration (note that doing so may cause issues with some models/npcs so be careful)
NPC.DeathAnimationDuration = false


function NPC:CustomThink()
    if self.FiringBeam then
        self.CurrentBeamDir = LerpVector(0.1, self.CurrentBeamDir, self.BeamTargetVec)
        local tr = util.TraceLine({
            start = self.BeamStartPos,
            endpos = self.BeamStartPos+self.CurrentBeamDir*10000,
            mask = MASK_SHOT,
            filter = self,
        })

        local splashRadius = 50
        local damage = 15
        local dmginfo = DamageInfo()
        dmginfo:SetAttacker(self)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamage(damage)
        dmginfo:SetDamagePosition(tr.HitPos)
        dmginfo:SetDamageType(bit.bor(DMG_DISSOLVE, DMG_SHOCK)) -- Dissolves and makes cool electric effects yayoooooo
        util.BlastDamageInfo(dmginfo, tr.HitPos, splashRadius)

        local attIdx = self:LookupAttachment("MiniGun")
        util.ParticleTracerEx("Weapon_Combine_Ion_Cannon", self:GetAttachment( attIdx ).Pos, tr.HitPos, false, self:EntIndex(), attIdx)

        local effdata = EffectData()
        effdata:SetEntity(self)
        effdata:SetOrigin(self:GetAttachment( attIdx ).Pos)
        effdata:SetStart(self:GetAttachment( attIdx ).Pos)
        effdata:SetAttachment(attIdx)
        util.Effect("StriderMuzzleFlash", effdata, true, true)
    end
end


function NPC:OnFireBullet( bulletData )
    self.BeamStartPos = bulletData.Src
    self.CurrentBeamDir = self.CurrentBeamDir or bulletData.Dir
    self.BeamTargetVec = bulletData.Dir

    if !self.FiringBeam then
        self:EmitSound("Phx.Afterburner3")
    end

    self:CONV_TempVar("FiringBeam", true, 0.5)
    self:CONV_TimerCreate("StopBeamSound", 0.5, 1, self.StopSound, self, "Phx.Afterburner3") 

    return false 
end


function NPC:BeforeEmitSound( data, var )

    if data.OriginalSoundName == "NPC_Strider.FireMinigun" then
        return false -- No pew pew sound
    end

end


function NPC:OnRemove()
    self:StopSound("Phx.Afterburner3")
end