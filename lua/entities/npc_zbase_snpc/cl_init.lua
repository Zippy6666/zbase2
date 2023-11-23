include("shared.lua")
net.Receive("base_ai_zbase_client_ragdoll", function() net.ReadEntity():ClientRagdoll( net.ReadVector() ) end)

--------------------------------------------------------------------------------=#
function ENT:ClientRagdoll( force )

    local rag = self:BecomeRagdollOnClient()
    local phys = rag:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(force)
    end

end
--------------------------------------------------------------------------------=#