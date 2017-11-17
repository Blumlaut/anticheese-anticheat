
BlacklistedWeapons = { -- weapons that will get people banned
	"WEAPON_BALL",
	"WEAPON_RAILGUN",
	"WEAPON_GARBAGEBAG",
}


Citizen.CreateThread(function()
	while true do
		Wait(30000)
		TriggerServerEvent("anticheese:timer")
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(60000)


	while true do
		Citizen.Wait(0)
		local ped = PlayerPedId()
		local posx,posy,posz = table.unpack(GetEntityCoords(ped,true))
		local still = IsPedStill(ped)
		local vel = GetEntitySpeed(ped)
		local ped = PlayerPedId()
		local veh = IsPedInAnyVehicle(ped, true)
		local speed = GetEntitySpeed(ped)
		local para = GetPedParachuteState(ped)
		local flyveh = IsPedInFlyingVehicle(ped)
		local rag = IsPedRagdoll(ped)
		local fall = IsPedFalling(ped)
		local parafall = IsPedInParachuteFreeFall(ped)
		SetEntityVisible(PlayerPedId(), true) -- make sure player is visible
		Wait(3000) -- wait 3 seconds and check again

		local more = speed - 9.0 -- avarage running speed is 7.06 so just incase someone runs a bit faster it wont trigger

		local rounds = tonumber(string.format("%.2f", speed))
		local roundm = tonumber(string.format("%.2f", more))


		if not IsEntityVisible(PlayerPedId()) then
			SetEntityHealth(PlayerPedId(), -100) -- if player is invisible kill him!
		end

		newx,newy,newz = table.unpack(GetEntityCoords(ped,true))
		newPed = PlayerPedId() -- make sure the peds are still the same, otherwise the player probably respawned
		if GetDistanceBetweenCoords(posx,posy,posz, newx,newy,newz) > 200 and still == IsPedStill(ped) and vel == GetEntitySpeed(ped) and ped == newPed then
			TriggerServerEvent("RottenV:NoclipFlag", GetDistanceBetweenCoords(posx,posy,posz, newx,newy,newz))
		end

		if speed > 9.0 and not veh and (para == -1 or para == 0) and not flyveh and not fall and not parafall and not rag then
			--dont activate this, its broken!
			--TriggerServerEvent("RottenV:SpeedFlag", rounds, roundm) -- send alert along with the rounded speed and how much faster they are
		end


	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)

		local curPed = PlayerPedId()
		local curHealth = GetEntityHealth( curPed )
		SetEntityHealth( curPed, curHealth-2)
		-- this will substract 2hp from the current player, wait 50ms and then add it back, this is to check for hacks that force HP at 200
		Citizen.Wait(50)

		if PlayerPedId() == curPed and GetEntityHealth(curPed) == curHealth and GetEntityHealth(curPed) ~= 0 then
			TriggerServerEvent("RottenV:HealthFlag", false, curHealth-2, GetEntityHealth( curPed ) )
		elseif GetEntityHealth(curPed) == curHealth-2 then
			SetEntityHealth(curPed, GetEntityHealth(curPed)+2)
		end

		if GetPlayerInvincible( PlayerId() ) then -- if the player is invincible, flag him as a cheater and then disable their invincibility
			TriggerServerEvent("RottenV:HealthFlag", true, curHealth-2, GetEntityHealth( curPed ) )
			SetPlayerInvincible( PlayerId(), false )
		end

	end
end)

-- prevent infinite ammo
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		SetPedInfiniteAmmoClip(PlayerPedId(), false)
    end
end)

-- prevent player from going invisible
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		ResetEntityAlpha(PlayerPedId())
	end
end)

Citizen.CreateThread(function()
		while true do
			Citizen.Wait(30000)
			for _,theWeapon in ipairs(BlacklistedWeapons) do
				if HasPedGotWeapon(PlayerPedId(),GetHashKey(theWeapon),false) == 1 then
						TriggerServerEvent("RottenV:WeaponFlag", theWeapon )
				end
			end
		end
end)

-- force max speed to be 7.1 so they can't magically run faster, only exclusion is when parachuting
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local fallin = IsPedFalling(PlayerPedId())
		local ragg = IsPedRagdoll(PlayerPedId())
		local parac = GetPedParachuteState(PlayerPedId())
		if parac >= 0 or ragg or fallin then
			SetEntityMaxSpeed(PlayerPedId(), 80.0)
		else
			SetEntityMaxSpeed(PlayerPedId(), 7.1)
		end
	end
end)
