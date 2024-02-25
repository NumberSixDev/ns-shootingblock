local isFreeAiming = false

local function processScope(freeAiming)
    if isFreeAiming ~= freeAiming then
        isFreeAiming = freeAiming
        SendNUIMessage({
            display = isFreeAiming,
        })
    end
end

local blockShotActive = false

local function blockShooting()
    if blockShotActive then return end
    blockShotActive = true
    CreateThread(function()
        while true do
            local ply = PlayerId()
            local ped = PlayerPedId()
            if not HasPedGotWeapon(ped, GetHashKey("WEAPON_SNIPERRIFLE"), false) then
                blockShotActive = false
                processScope(false)
                return
            end
            local ent = nil
            local aiming, aimedEntity = GetEntityPlayerIsFreeAimingAt(ply)
            local freeAiming = IsPlayerFreeAiming(ply)
            processScope(freeAiming)
            local entType = GetEntityType(aimedEntity)
            if not freeAiming or IsPedAPlayer(aimedEntity) or entType == 2 or (entType == 1 and IsPedInAnyVehicle(aimedEntity)) then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 47, true)
                DisableControlAction(0, 58, true)
                DisablePlayerFiring(ped, true)
            end
            Wait(0)
        end
    end)
end

CreateThread(function()
    while true do
        if HasPedGotWeapon(PlayerPedId(), GetHashKey("WEAPON_SNIPERRIFLE"), false) then
            blockShooting()
            Wait(1000)
        else
            blockShotActive = false
            processScope(false)
            Wait(500)
        end
    end
end)
