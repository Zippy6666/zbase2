local NPC = FindZBaseTable(debug.getinfo(1,'S'))



function NPC:CustomInitialize()
    local animations = {
        self:GetSequenceActivity( self:LookupSequence("walk_all") ),
        self:GetSequenceActivity( self:LookupSequence("crouch_walk_all") ),
        self:GetSequenceActivity( self:LookupSequence("run_protected_all") ),
        self:GetSequenceActivity( self:LookupSequence("run_panicked_all") ),
    }
    self.ZombieMoveAct = animations[math.random(1, #animations)]
    print(self.ZombieMoveAct)
end


    -- Tries to override the movement activity
    -- Return any activity to override the movement activity with said activity
    -- Return false to not override
function NPC:OverrideMovementAct()
    return self.ZombieMoveAct
end