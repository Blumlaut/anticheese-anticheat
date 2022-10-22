
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(30000)
		TriggerServerEvent("anticheese:timer")
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)
		local curPed = PlayerPedId()
		local curHealth = GetEntityHealth( curPed )
		SetEntityHealth( curPed, curHealth-2)
		local curWait = math.random(10,150)
		-- this will substract 2hp from the current player, wait 50ms and then add it back, this is to check for hacks that force HP at 200
		Citizen.Wait(curWait)
		
		if not IsPlayerDead(PlayerId()) then
			if PlayerPedId() == curPed and GetEntityHealth(curPed) == curHealth and GetEntityHealth(curPed) ~= 0 then
				TriggerServerEvent("AntiCheese:HealthFlag", false, curHealth-2, GetEntityHealth( curPed ),curWait )
			elseif GetEntityHealth(curPed) == curHealth-2 then
				SetEntityHealth(curPed, GetEntityHealth(curPed)+2)
			end
		end
		if GetEntityHealth(curPed) > 400 then
			TriggerServerEvent("AntiCheese:HealthFlag", false, GetEntityHealth( curPed )-200, GetEntityHealth( curPed ),curWait )
		end
		
		if GetPlayerInvincible( PlayerId() ) then -- if the player is invincible, flag him as a cheater and then disable their invincibility
			TriggerServerEvent("AntiCheese:HealthFlag", true, curHealth-2, GetEntityHealth( curPed ),curWait )
			SetPlayerInvincible( PlayerId(), false )
		end
	end
end)

-- prevent infinite ammo, godmode, invisibility and ped speed hacks
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		SetPedInfiniteAmmoClip(PlayerPedId(), false)
		SetEntityInvincible(PlayerPedId(), false)
		SetEntityCanBeDamaged(PlayerPedId(), true)
		ResetEntityAlpha(PlayerPedId())
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

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)
		if NetworkIsInSpectatorMode() then
			TriggerServerEvent("AntiCheese:Spectate")
		end
		
		if GetPlayerWeaponDamageModifier(PlayerId()) > 1.0 then
			TriggerServerEvent("AntiCheese:Damage")
		end
		
		if GetUsingseethrough() then
			TriggerServerEvent("AntiCheese:Thermal")
		end
		
		if GetUsingnightvision() then
			TriggerServerEvent("AntiCheese:Night")
		end
		
		local playerPed = PlayerPedId()
		if IsPedSittingInAnyVehicle(playerPed) and IsVehicleVisible(GetVehiclePedIsIn(playerPed, false)) then
			TriggerServerEvent("AntiCheese:CarVisible")
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(30000)
		local DetectableTextures = {
			{txd = "HydroMenu", txt = "HydroMenuHeader", name = "HydroMenu"},
			{txd = "John", txt = "John2", name = "SugarMenu"},
			{txd = "darkside", txt = "logo", name = "Darkside"},
			{txd = "ISMMENU", txt = "ISMMENUHeader", name = "ISMMENU"},
			{txd = "dopatest", txt = "duiTex", name = "Copypaste Menu"},
			{txd = "fm", txt = "menu_bg", name = "Fallout"},
			{txd = "wave", txt = "logo", name ="Wave"},
			{txd = "wave1", txt = "logo1", name = "Wave (alt.)"},
			{txd = "meow2", txt = "woof2", name ="Alokas66", x = 1000, y = 1000},
			{txd = "adb831a7fdd83d_Guest_d1e2a309ce7591dff86", txt = "adb831a7fdd83d_Guest_d1e2a309ce7591dff8Header6", name ="Guest Menu"},
			{txd = "hugev_gif_DSGUHSDGISDG", txt = "duiTex_DSIOGJSDG", name="HugeV Menu"},
			{txd = "MM", txt = "menu_bg", name="MetrixFallout"},
			{txd = "wm", txt = "wm2", name="WM Menu"},
			{txd = "absoluteeulen", txt="Absolut", name="Absolut Menu"},
			{txd = "Dopamine", txt="Dopameme", name="Dopamine Menu"},
			{txd = "SkidMenu", txt="skidmenu", name="Skid Menu"},
			{txd = "tiago", txt="Tiago", name="Tiago Menu"},
			{txd = "lynxmenu", txt="lynxmenu", name="Lynx Menu"},
			{txd = "Reaper", txt="reaper", name="Reaper Menu"},
			{txd = "MM", txt = "menu_bg", name="Metrix Mehtods"},
			{txd = "NeekerMan", txt="NeekerMan1", name="Lumia Menu"},
			{txd = "Blood-X", txt="Blood-X", name="Blood-X Menu"},
			{txd = "Fallout", txt="FalloutMenu", name="Fallout Menu"},
			{txd = "Luxmenu", txt="Lux meme", name="LuxMenu"},
			{txd = "KekHack", txt="kekhack", name="KekHack Menu"},
			{txd = "Maestro", txt="maestro", name="Maestro Menu"},
			{txd = "Brutan", txt="brutan", name="Brutan Menu"},
			{txd = "FiveSense", txt="fivesense", name="Fivesense Menu"},
			{txd = "NeekerMan", txt="NeekerMan1", name="Lumia Menu"},
			{txd = "Auttaja", txt="auttaja", name="Auttaja Menu"},
			{txd = "BartowMenu", txt="bartowmenu", name="Bartow Menu"},
            		{txd = "Hoax", txt="hoaxmenu", name="Hoax Menu"},
            		{txd = "FendinX", txt="fendin", name="Fendinx Menu"},
           		{txd = "Hammenu", txt="Ham", name="Ham Menu"},
            		{txd = "Lynxmenu", txt="Lynx", name="Lynx Menu"},
			{txd = "Oblivious", txt="oblivious", name="Oblivious Menu"},
			{txd = "malossimenuv", txt="malossimenu", name="Malossi Menu"},
			{txd = "memeeee", txt="Memeeee", name="Memeeee Menu"},
			{txd = "Hydramenu", txt="hydramenu", name="Hydra Menu"},
            		{txd = "NMSS", txt="SMS", name="SMS Menu"},
            		{txd = "Sugä", txt="Sugo", name="Sugar Menu"},
			{txd = "Nekker", txt="Men", name="Fallout Menu"},
            		{txd = "https://asriel.dev/fm/blacklisted.gif", txt="fallout", name="Fallout Menu"},
			{txd = "Alien", txt="Ale", name="Alien Menu"},
            		{txd = "[<font color='#FFCD00'>Fallout Menu</font>~s~]", txt="Fallout", name="Fallout Menu"},
			{txd = "Hydramenu", txt="hydramenu", name="Hydra Menu"},
           		{txd = "FXMenu", txt="fxmenu", name="FXMenu Menu"},
            		{txd = "TAJNEMENUMenu", txt="TAJNEMENUMenu", name="TAJNEMENU Menu"},
            		{txd = "Genesis", txt="Genesis", name="Genesis Menu"},
            		{txd = "Atomic_Invoke_UGDIUGFHKDFSGFD", txt="Atomic", name="Atomic Menu"},
            		{txd = "utihHRBMwEmHSvGrcDCf", txt="utihHRBMwEmHSvGrcDCf", name="Unknown Menu"},
			{txd = "HugeV_KEYSHTRHRTHTRH", txt="Hugev", name="HugeV Menu"},
            		{txd = "LynxSeven", txt="lynx", name="Lynx Menu"},
            		{txd = "Deluxe", txt="deluxe", name="Deluxe Menu"},
            		{txd = "gcphonedestroy", txt="GCPHONEDESTROY", name="GCPHONE Menu"},
            		{txd = "Absolute", txt="absoluteulen", name="Absolute Menu"},
            		{txd = "https://i.ibb.co/0GhPPL7/Hydro-New-Header.png", txt="Hydro", name="Hydro Menu"},
            		{txd = "Watermalone", txt="watermalone", name="Watermalone Menu"},
            		{txd = "onionmenu", txt="ONION", name="Onion Menu"},
            		{txd = "Invisibility", txt="invisiblity", name="Menu function detected"},
            		{txd = "rape", txt="Rape Player", name="Menu function detected"},
            		{txd = "APIACTAJNEMENUMenu", txt="apiac", name="Apianticheat Menu"},
            		{txd = "xxmenu", txt="Menu", name="MenuXX Menu"},
            		{txd = "skidmenu", txt="Skid", name="Skid Menu"},
            		{txd = "lynxrevolution", txt="revolution", name="Lynx Menu"}
				
				
		}
		
		for i, data in pairs(DetectableTextures) do
			if data.x and data.y then
				if GetTextureResolution(data.txd, data.txt).x == data.x and GetTextureResolution(data.txd, data.txt).y == data.y then
					TriggerServerEvent("AntiCheese:DuiFlag", "Cheating", "Mod Menu Detected ("..data.name.." Detected via DUI Check)", true)
				end
			else 
				if GetTextureResolution(data.txd, data.txt).x ~= 4.0 then
					TriggerServerEvent("AntiCheese:DuiFlag", "Cheating", "Mod Menu Detected ("..data.name.." Detected via DUI Check)", true)
				end
			end
		end
	end
end)


RegisterNetEvent("AntiCheese:RemoveInventoryWeapons")
AddEventHandler('AntiCheese:RemoveInventoryWeapons', function()
	RemoveAllPedWeapons(PlayerPedId(),false)
end)

function ReqAndDelete(object, detach)
	if DoesEntityExist(object) then
		NetworkRequestControlOfEntity(object)
		while not NetworkHasControlOfEntity(object) do
			Citizen.Wait(1)
		end
		if detach then
			DetachEntity(object, 0, false)
		end
		SetEntityCollision(object, false, false)
		SetEntityAlpha(object, 0.0, true)
		SetEntityAsMissionEntity(object, true, true)
		SetEntityAsNoLongerNeeded(object)
		DeleteEntity(object)
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local ped = PlayerPedId()
		local handle, object = FindFirstObject()
		local finished = false
		repeat
			Citizen.Wait(1)
			if IsEntityAttached(object) and DoesEntityExist(object) then
				if GetEntityModel(object) == `prop_acc_guitar_01` then
					ReqAndDelete(object, true)
				end
			end
			for i=1,#CageObjs do
				if GetEntityModel(object) == CageObjs[i] then
					ReqAndDelete(object, false)
				end
			end
			finished, object = FindNextObject(handle)
		until not finished
		EndFindObject(handle)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsPedJumping(PlayerPedId()) then
			local jumplength = 0
			repeat
				Citizen.Wait(0)
				jumplength=jumplength+1
				local isStillJumping = IsPedJumping(PlayerPedId())
			until not isStillJumping
			if jumplength > 250 then
				TriggerServerEvent("AntiCheese:JumpFlag", jumplength )
			end
		end
	end
end)

function isCarBlacklisted(model)
	for _, blacklistedCar in pairs(blacklistedCars) do
		if model == blacklistedCar then
			return true
		end
	end
	
	return false
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local playerPed = PlayerPedId()
		if IsPedInAnyVehicle(playerPed) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			
			if GetPedInVehicleSeat(vehicle, -1) == playerPed then
				local carModel = GetEntityModel(vehicle)
				local carName = GetDisplayNameFromVehicleModel(carModel)
				local carLabel = GetLabelText(carName)
				if isCarBlacklisted(carModel) then
					DeleteVehicle(vehicle)
					TriggerServerEvent('AntiCheese:CarFlag', carLabel)
				end
			end
		end
		for _,theWeapon in ipairs(BlacklistedWeapons) do
			Citizen.Wait(1)
			if HasPedGotWeapon(playerPed,theWeapon,false) == 1 then
				TriggerServerEvent("AntiCheese:WeaponFlag", theWeapon)
				RemoveWeaponFromPed(playerPed, theWeapon)
				break
			end
		end
	end
end)


-- generic cheat detections
RegisterNetEvent(GetCurrentResourceName().. ".verify")
AddEventHandler(GetCurrentResourceName().. ".verify", function()
	TriggerServerEvent("AntiCheese:GenericFlag", "Cheating", "Mod Menu Detected (recieved verify event)", true)
end)

RegisterNetEvent("HCheat:TempDisableDetection")
AddEventHandler("HCheat:TempDisableDetection", function()
	TriggerServerEvent("AntiCheese:BypassFlag", "Cheating", "Mod Menu Detected (recieved DisableDetection event)", true)
end)
RegisterNetEvent("antilynx8:crashuser")
    AddEventHandler("antilynx8:crashuser",function()
       TriggerServerEvent("AntiCheese:BypassFlag", "Cheating", "Mod Menu Detected (Try to use lynx menu)", true)
    end)

    RegisterNetEvent("shilling=yet5")
    AddEventHandler("shilling=yet5",function()
    TriggerServerEvent("AntiCheese:BypassFlag", "Cheating", "Mod Menu Detected", true)
    end)

    RegisterNetEvent("antilynxr4:crashuser")
    AddEventHandler("antilynxr4:crashuser",function()
       TriggerServerEvent("AntiCheese:BypassFlag", "Cheating", "Mod Menu Detected (Try to use lynx menu)", true)
    end)

    AddEventHandler("shilling=yet7",function()
     TriggerServerEvent("AntiCheese:BypassFlag", "Cheating", "Mod Menu Detected", true)
    end end)

    RegisterNetEvent("antilynxr4:crashuser1")
    AddEventHandler("antilynxr4:crashuser1",function()
     TriggerServerEvent("AntiCheese:BypassFlag", "Cheating", "Mod Menu Detected (Try to use lynx menu)", true)
    end)


function negativePayFunc(amount)
	if amount < 0 then
		TriggerServerEvent("AntiCheese:paySpam", "Cheating", "negative payment event.")
	end
end

for i, event in pairs(negativePayEvents) do
	RegisterNetEvent(event)
	AddEventHandler(event, negativePayFunc)
end


 



-- no longer generic cheat detections



-- specific resource detections


RegisterNetEvent("gcPhone:sendMessage")
AddEventHandler("gcPhone:sendMessage", function(message)
	if (string.find(message, "剎車剎車剎車剎車") or -1 > -1) then
		TriggerServerEvent("AntiCheese:gcphoneFlag", "Cheating", "GCPhone spam event.", true)
	end
	
end)
