
local object = {}
Citizen.CreateThread(function()
    while true do
        object = {}
        for v in EnumerateObjects() do
            table.insert(object, v)
        end
        Wait(3000)
    end
end)

Citizen.CreateThread(function()
    DecorRegister("CivilProps", 3)
    local attente = 150
    local count = 0
    while true do
        Wait(attente)
        local pPed = GetPlayerPed(-1)
        local pCoords = GetEntityCoords(pPed)
        for k,v in pairs(object) do
            local oCoords = GetEntityCoords(v)
            local dst = GetDistanceBetweenCoords(pCoords, oCoords, true)
            if dst <= 2.0 then
                if DecorExistOn(v, "CivilProps") then
                    SetEntityCollision(v, 1, 1)
                    FreezeEntityPosition(v, true)
                    SetEntityInvincible(v, true)
                    attente = 1
                    ShowHelpNotification("Appuyer sur ~INPUT_PICKUP~ pour enlever l'objets.")
                    if IsControlJustReleased(1, 38) then
                        TriggerServerEvent("DeleteEntity", NetworkGetNetworkIdFromEntity(v))
                    end
                    break
                end
            else
                attente = 150
            end
        end
    end
end)


function SpawnObj(obj)
    local playerPed = PlayerPedId()
	local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
    local objectCoords = (coords + forward * 1.0)
    local Ent = nil

    SpawnObject(obj, objectCoords, function(obj)
        SetEntityCoords(obj, objectCoords, 0.0, 0.0, 0.0, 0)
        SetEntityHeading(obj, GetEntityHeading(playerPed))
        PlaceObjectOnGroundProperly(obj)
        Ent = obj
        Wait(1)
    end)
    Wait(1)
    while Ent == nil do Wait(1) end
    SetEntityHeading(Ent, GetEntityHeading(playerPed))
    PlaceObjectOnGroundProperly(Ent)
    local placed = false
    while not placed do
        Citizen.Wait(1)
        local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
        local objectCoords = (coords + forward * 2.0)
        SetEntityCoords(Ent, objectCoords, 0.0, 0.0, 0.0, 0)
        SetEntityHeading(Ent, GetEntityHeading(playerPed))
        PlaceObjectOnGroundProperly(Ent)
		SetEntityAlpha(Ent, 170, 170)
		SetEntityCollision(Ent, 0, 0)
		
		RageUI.Text({
			message = string.format("Appuyer sur CLIQUE MOLETTE pour poser l'objets")
		})

        if IsControlJustReleased(1, 348) then
            placed = true
        end
    end

	SetEntityCollision(Ent, 1, 1)
    FreezeEntityPosition(Ent, true)
    SetEntityInvincible(Ent, true)
    ResetEntityAlpha(Ent)
    local NetId = NetworkGetNetworkIdFromEntity(Ent)
    if NetId == 0 then
        DeleteEntity(Ent)
    end
	SetNetworkIdCanMigrate(NetId, true)
    DecorSetInt(NetworkGetEntityFromNetworkId(NetId), "CivilProps", 1)
end

function SpawnObject(model, coords, cb)
	local model = GetHashKey(model)

	Citizen.CreateThread(function()
		RequestModels(model)
        Wait(1)
		local obj = CreateObject(model, coords.x, coords.y, coords.z, true, false, true)

		if cb then
			cb(obj)
		end
	end)
end

function RequestModels(modelHash)
	if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
		RequestModel(modelHash)

        while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
		end
	end
end