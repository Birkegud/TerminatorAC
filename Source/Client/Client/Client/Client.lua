local Terminator = {}

TriggerServerEvent("TopSecretEvent")

Citizen.CreateThread(function()
    while true do
        Wait(3000)
        TriggerServerEvent("AnotherSecretEvent", 0)
    end
end)

Terminator.types = {
    ['Object'] = {
        FindFirstObject,
        FindNextObject,
        EndFindObject
    },
    ['Ped'] = {
        FindFirstPed,
        FindNextPed,
        EndFindPed
    },
    ['Vehicle'] = {
        FindFirstVehicle,
        FindNextVehicle,
        EndFindVehicle
    }
}

function Terminator:has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

Terminator.entityEnumerator = {
    __gc = function(enum)
    if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
    end
        enum.destructor = nil
        enum.handle = nil
    end
}

function Terminator:EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
        
            return
        end

        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, Terminator.entityEnumerator)

        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function Terminator:EnumerateVehicles()
    return Terminator:EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function Terminator:EnumerateObjects()
    return Terminator:EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function Terminator:EnumeratePeds()
    return Terminator:EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function Terminator:checkGlobalVariable()
    for _i in pairs(Term.GlobalFunctionDetection) do
        if (_G[Term.GlobalFunctionDetection[_i] ] ~= nil) then
            return true
        else
            return false
        end
    end
end

function Terminator:GetStuff(type)
    local data = {}
    local funcs = Terminator.types[type]
    local handle, ent, success = funcs[1]()

    repeat
        success, entity = funcs[2](handle)
        if DoesEntityExist(entity) then
            table.insert(data, entity)
        end
    until not success

    funcs[3](handle)
    print(data)
    return data
end

RegisterNetEvent("Terminator:DeleteAttach")
AddEventHandler('Terminator:DeleteAttach', function()
    for k, v in pairs(Terminator:GetStuff('Object')) do
        if IsEntityAttachedToEntity(v, PlayerPedId()) then
            CreateThread(function()
                while DoesEntityExist(v) do
                    Wait(0)
                    DetachEntity(v, false, false)
                    while not NetworkHasControlOfEntity(v) do
                        NetworkRequestControlOfEntity(v)
                        Wait(0)
                    end
                    SetEntityAsMissionEntity(v, true, true)
                    DeleteEntity(v)
                    Wait(100)
                end
            end)
        end
    end
end)

RegisterNetEvent("Terminator:DeleteEntity")
AddEventHandler('Terminator:DeleteEntity', function(Entity)
    local object = NetworkGetEntityFromNetworkId(Entity)
    if DoesEntityExist(object) then
        DeleteObject(object)
    end
end)

RegisterNetEvent("Terminator:DeleteCars")
AddEventHandler('Terminator:DeleteCars', function(vehicle)
	local vehicle = NetworkGetEntityFromNetworkId(vehicle)
	if DoesEntityExist(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local timeout = 2000
        while timeout > 0 and not NetworkHasControlOfEntity(vehicle) do
            Wait(100)
            timeout = timeout - 100
        end
        SetEntityAsMissionEntity(vehicle, true, true)
        local timeout = 2000
        while timeout > 0 and not IsEntityAMissionEntity(vehicle) do
            Wait(100)
            timeout = timeout - 100
        end
        Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle) )
    end
end)

RegisterNetEvent("Terminator:DeletePeds")
AddEventHandler('Terminator:DeletePeds', function(Ped)
    local ped = NetworkGetEntityFromNetworkId(Ped)
    if DoesEntityExist(ped) then
        if not IsPedAPlayer(ped) then
            local model = GetEntityModel(ped)
            if model ~= GetHashKey('mp_f_freemode_01') and model ~= GetHashKey('mp_m_freemode_01') then
                if IsPedInAnyVehicle(ped) then

                    -- vehicle delete
                    local vehicle = GetVehiclePedIsIn(ped)
                    NetworkRequestControlOfEntity(vehicle)
                    local timeout = 2000
                    while timeout > 0 and not NetworkHasControlOfEntity(vehicle) do
                        Wait(100)
                        timeout = timeout - 100
                    end
                    SetEntityAsMissionEntity(vehicle, true, true)
                    local timeout = 2000
                    while timeout > 0 and not IsEntityAMissionEntity(vehicle) do
                        Wait(100)
                        timeout = timeout - 100
                    end
                    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle) )
                    DeleteEntity(vehicle)

                    -- ped delete
                    NetworkRequestControlOfEntity(ped)
                    local timeout = 2000
                    while timeout > 0 and not NetworkHasControlOfEntity(ped) do
                        Wait(100)
                        timeout = timeout - 100
                    end
                    DeleteEntity(ped)
                else
                    NetworkRequestControlOfEntity(ped)
                    local timeout = 2000
                    while timeout > 0 and not NetworkHasControlOfEntity(ped) do
                        Wait(100)
                        timeout = timeout - 100
                    end 
                    DeleteEntity(ped)
                end
            end
        end
    end
end)

if Term.CommandDetection then
    AddEventHandler("playerSpawned", function()
        Terminator.OriginalCommands = #GetRegisteredCommands()
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(10000)
            Terminator.NewCommands = #GetRegisteredCommands()
            if Terminator.NewCommands ~= Terminator.OriginalCommands then
                TriggerServerEvent("Terminator:Detected", "Ban", "CommandInjection #12")
            end
        end
    end)
end

if Term.DamageModifierDetection then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(2500)
            local Weapon = GetPlayerWeaponDamageModifier(PlayerId())
            local Vehicle = GetPlayerVehicleDamageModifier(PlayerId())
            local Defence2 = GetPlayerWeaponDefenseModifier_2(PlayerId())
            local Defence = GetPlayerWeaponDefenseModifier(PlayerId())
            local VehicleDefense = GetPlayerVehicleDefenseModifier(PlayerId())
            local Meele = GetPlayerMeleeWeaponDefenseModifier(PlayerId())
            if Weapon > 1 and Weapon ~= 0 then
                TriggerServerEvent("Terminator:Detected", "Ban", "DamageModifier #13")
            elseif Defence > 1 and Defence ~= 0 then
                TriggerServerEvent("Terminator:Detected", "Ban", "DamageModifier #14")
            elseif Defence2 > 1 and Defence ~= 0 then
                TriggerServerEvent("Terminator:Detected", "Ban", "DamageModifier #15")
            elseif Vehicle > 1 and Vehicle ~= 0 then
                TriggerServerEvent("Terminator:Detected", "Ban", "DamageModifier #16")
            elseif VehicleDefense > 1 and VehicleDefense ~= 0 then
                TriggerServerEvent("Terminator:Detected", "Ban", "DamageModifier #17")
            elseif Meele > 1 and VehicleDefense ~= 0 then
                TriggerServerEvent("Terminator:Detected", "Ban", "DamageModifier #18")
            end
        end
    end)
end

if Term.AntiGodmode then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            local PlayerHealth = GetEntityHealth(PlayerPedId())
            SetEntityHealth(PlayerPedId(), PlayerHealth - 2)
            Citizen.Wait(50)
            if GetEntityHealth(PlayerPedId()) > Term.MaxHealth then
                TriggerServerEvent("Terminator:Detected", "Ban", "GodMode #19")
            end
            if GetPlayerInvincible(PlayerId()) then
                TriggerServerEvent("Terminator:Detected", "Ban", "GodMode #20")
                SetPlayerInvincible(PlayerId(), false)
            end
        end
    end)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            local ignore, b, f, e, c, m = GetEntityProofs(GetPlayerPed(-1))
            if (b and f and e and c and m) == 1 then
                TriggerServerEvent("Terminator:Detected", "Ban", "Spectate #42")
            end
        end
    end)
end

-- if Term.VDMDetection then
--     Citizen.CreateThread(function()
--         while true do
--             SetWeaponDamageModifier(-1553120962, 0.0)
--             Wait(0)
--         end
--     end)
-- end

if Term.InvisibilityDetection then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(100)
            SetEntityVisible(GetPlayerPed(-1), true, 0)
         end
    end)
end

if Term.SpectateDetection then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if NetworkIsInSpectatorMode() then
                TriggerServerEvent("Terminator:Detected", "Ban", "Spectate #21")
            end
        end
    end)
end

if Term.ThermalVisionDetection then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(10000)
            if SetSeethrough() ~= false then
                TriggerServerEvent("Terminator:Detected", "Ban", "ThermalVision #22")
            end
        end
    end)
end

if #Term.BlacklistedWeapons ~= 0 then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(3000)
            for v, r in ipairs(Term.BlacklistedWeapons) do
                Wait(1)
                if HasPedGotWeapon(PlayerPedId(), GetHashKey(r), false) == 1 then
                    RemoveAllPedWeapons(PlayerPedId(), true)
                    TriggerServerEvent("Terminator:Detected", "Ban", "BlacklistedWeapon #23")
                end
            end
        end
    end)
end

if Term.GeneralStuffDetection then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            SetPedInfiniteAmmoClip(PlayerPedId(), false)
            SetPlayerInvincible(PlayerId(), false)
            SetEntityInvincible(PlayerPedId(), false)
            SetEntityCanBeDamaged(PlayerPedId(), true)
            ResetEntityAlpha(PlayerPedId())
        end
    end)
end

if Term.ResourceDetection then
    Terminator.OriginalResources = GetNumResources()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(2000)
            Terminator.EditedResources = GetNumResources()
            if Terminator.OriginalResources ~= nil then
                if Terminator.OriginalResources ~= Terminator.EditedResources then
                    TriggerServerEvent("Terminator:Detected", "Ban", "ResourceInjection #24")
                end
            end
        end
    end)
end

if Term.BypassDetection then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(100)
            if _G == nil or _G == {} or _G == "" then
                TriggerServerEvent("Terminator:Detected", "Ban", "_G bypass #25")
                return
            else
                Wait(500)
            end
        end
    end)
    Citizen.CreateThread(function()
        while true do
            if ForceSocialClubUpdate == nil then
                TriggerServerEvent("Terminator:Detected", "Ban", "ForceSocialClubUpdate bypass #26")
            end
            if ShutdownAndLaunchSinglePlayerGame == nil then
                TriggerServerEvent("Terminator:Detected", "Ban", "ShutdownAndLaunchSinglePlayerGame bypass #27")
            end
            -- if ActivateRockstarEditor == nil then
            --     TriggerServerEvent("Terminator:Detected", "Ban", "ActivateRockstarEditor bypass #28")
            -- end
            Citizen.Wait(500)
        end
    end)
end

if Term.OldHamDetection then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(2000)
            local HamFinder = LoadResourceFile(GetCurrentResourceName(), "ham.lua")
                if HamFinder ~= nil then
                    TriggerServerEvent("Terminator:Detected", "Ban", "HamInjection #29")
                end
            Citizen.Wait(0)
        end
    end)
end

if #Term.GlobalFunctionDetection ~= 0 then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(20000)
            if Terminator:checkGlobalVariable() then
                TriggerServerEvent("Terminator:Detected", "Ban", "BlakclistedFunction #30")
            end
        end
    end)
end

if #Term.LocalDetection ~= 0 then
    local function test()
        local Found = {}
        local test = "im a local var"
        local i = 1
        while true do
            local name, value = debug.getlocal(2, i)
            if not name then break end
            -- print(name, i, value)
                if Terminator:has_value(Term.LocalDetection, name) then
                    TriggerServerEvent("Terminator:Detected", "Ban", "BlacklistedVar #31")
                end
                if Terminator:has_value(Term.LocalDetection, value) then
                    TriggerServerEvent("Terminator:Detected", "Ban", "BlacklistedFunction #32")
                end
            i = i + 1
        end
    end

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000)
            test()
        end
    end)
end

if #Term.PrintDetection ~= 0 then
    function print(text)
        Citizen.CreateThread(function()
            for i = 1, #Term.PrintDetection do
                if text == Term.PrintDetection[i] then
                    TriggerServerEvent("Terminator:Detected", "Ban", "BlacklistedPrint #33")
                end
            end
        end)
    end
end

if Term.DestroyDetection then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(15000)
            for i in Terminator:EnumerateVehicles() do
                if GetEntityHealth(i) == 0 then
                    SetEntityAsMissionEntity(i, false, false)
                    DeleteEntity(i)
                end
            end
        end
    end)
end

if Term.SpeedDetection then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1800)
			local speed = GetEntitySpeed(PlayerPedId())
			if not IsPedInAnyVehicle(GetPlayerPed(-1), 0) then
                if speed > 80 then
                    TriggerServerEvent("Terminator:Detected", "Ban", "Speed #34")
			    end
		    end
		end
	end)
end

if Term.PlayerProtection then
	SetEntityProofs(GetPlayerPed(-1), false, true, true, false, false, false, false, false)
end

if Term.BlipsDetection then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1000)
			local blipcount = 0
			local playerlist = GetActivePlayers()
			for i = 1, #playerlist do
				if i ~= PlayerId() then
				    if DoesBlipExist(GetBlipFromEntity(GetPlayerPed(i))) then
					    blipcount = blipcount + 1
				    end
			    end
                if blipcount > 0 then
					TriggerServerEvent("Terminator:Detected", "Ban", "Blips #35")
				end
			end
		end
	end)
end

if Term.LynxDetection then
    RegisterNetEvent("antilynx8:crashuser")
    AddEventHandler("antilynx8:crashuser", function(a, b)
        TriggerServerEvent("Terminator:Detected", "Ban", "Lynx #36")
    end)

    RegisterNetEvent("antilynxr4:crashuser")
    AddEventHandler("antilynxr4:crashuser", function(a, b)
        TriggerServerEvent("Terminator:Detected", "Ban", "Lynx #37")
    end)

    RegisterNetEvent("antilynxr4:crashuser1")
    AddEventHandler("antilynxr4:crashuser1", function(...)
        TriggerServerEvent("Terminator:Detected", "Ban", "Lynx #38")
    end)

    RegisterNetEvent("HCheat:TempDisableDetection")
    AddEventHandler("HCheat:TempDisableDetection", function(a, b)
        TriggerServerEvent("Terminator:Detected", "Ban", "Lynx #39")
    end)
end

if #Term.BlacklistedModels ~= 0 then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(2000)
            local PlayerPed = GetPlayerPed(-1)
            for k, v in pairs(Term.BlacklistedModels) do
                if IsPedModel(PlayerPed, v) then
                    TriggerServerEvent("Terminator:Detected", "Ban", "BlacklistedModel #40")
                end
            end
        end
    end)
end

if Term.PickupDetection then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            RemoveAllPickupsOfType(GetHashKey("PICKUP_ARMOUR_STANDARD"))
            RemoveAllPickupsOfType(GetHashKey("PICKUP_VEHICLE_ARMOUR_STANDARD"))
            RemoveAllPickupsOfType(GetHashKey("PICKUP_HEALTH_SNACK"))
            RemoveAllPickupsOfType(GetHashKey("PICKUP_HEALTH_STANDARD"))
            RemoveAllPickupsOfType(GetHashKey("PICKUP_VEHICLE_HEALTH_STANDARD"))
            RemoveAllPickupsOfType(GetHashKey("PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW"))
        end
    end)
end

if Term.DumpDetection then
    RegisterNUICallback("loadNuis", function(data, cb)
        TriggerServerEvent("Terminator:Detected", "Ban", "Dump #41")
    end)

    local oldLoadResourceFile = LoadResourceFile
    LoadResourceFile = function(_resourceName, _fileName)
        if (_resourceName ~= GetCurrentResourceName()) then
            TriggerServerEvent("Terminator:Detected", "Ban", "Dump #41")
        else
            oldLoadResourceFile(_resourceName, _fileName)
        end
    end
end

if Term.TeleportDetection then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            local playercoords = GetEntityCoords(GetPlayerPed(-1))
            local died = false
            if(playercoords.x > 0 or playercoords.x < 0) then
                newplayercoords = GetEntityCoords(GetPlayerPed(-1))
                if(died) then
                    playercoords = newplayercoords
                    died = false
                else
                    if(not IsPedInAnyVehicle(GetPlayerPed(-1), 0) and not IsPedOnVehicle(GetPlayerPed(-1)) and not IsPlayerRidingTrain(PlayerId())) then
                        --print(GetDistanceBetweenCoords(playercoords.x, playercoords.y, playercoords.z, newplayercoords.x, newplayercoords.y, newplayercoords.z, 0))
                        if(GetDistanceBetweenCoords(playercoords.x, playercoords.y, playercoords.z, newplayercoords.x, newplayercoords.y, newplayercoords.z, 0) > 0.5) then
                            TriggerServerEvent("Terminator:Detected", "Kick", "Teleport #43")
                        end
                    end
                    playercoords = newplayercoords
                end
            end
        end
    end)
end

if Term.SuperJumpDetection then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if IsPedJumping(PlayerPedId()) then
                local jumplength = 0
                repeat
                    Wait(0)
                    jumplength = jumplength + 1
                    local isStillJumping = IsPedJumping(PlayerPedId())
                until not isStillJumping
                if jumplength > 250 then
                    TriggerServerEvent("Terminator:Detected", "Ban", "SuperJump #43")
                end
            end
        end
    end)
end

if Term.PlankeCkDetection then
    RegisterNetEvent('showSprites')
    AddEventHandler('showSprites', function()
        TriggerServerEvent("Terminator:Detected", "Ban", "Planke Ck Commands #123")
    end)

    RegisterNetEvent('showBlipz')
    AddEventHandler('showBlipz', function()
        TriggerServerEvent("Terminator:Detected", "Ban", "Planke Ck Commands #123")
    end)
end

if Term.ExplosionDetection then
    function AddExplosion(...)
        TriggerServerEvent("Terminator:Detected", "Ban", "AddExplosion #421")
    end
end

if #Term.GlobalVarDetection ~= 0 then
    for i = 1, #Term.GlobalVarDetection do
        local Var = Term.GlobalVarDetection[i] .. " = 'Test'"
        local Base = [[
    Citizen.CreateThread(function()
        while true do
            Wait(5000)
        ]]
        local IfStatement = "    if " .. Term.GlobalVarDetection[i] .. ' ~= "Test" then'
    
        local Base2 = [[
                TriggerServerEvent("Terminator:Detected", "Ban", "GlobalVar: " .. Term.GlobalVarDetection[i] .. "#442")
            end
        end
    end)]]

        local Final = Var .. "\n" .. Base .. IfStatement .. "\n" .. Base2
        load(Final)()
    end
end

if Term.NuiDetection then
    RegisterNUICallback('callback', function()
        TriggerServerEvent("Terminator:Detected", "Ban", "Nui Detection #123219")
    end)
end