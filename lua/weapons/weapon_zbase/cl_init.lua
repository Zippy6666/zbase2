include("shared.lua")

net.Receive("ZBASE_MuzzleFlash", function()
    local wep = net.ReadEntity()
    if !IsValid(wep) then return end

    wep:MainEffects()
end)