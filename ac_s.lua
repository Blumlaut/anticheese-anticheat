-- with this you can turn on/off specific anticheese components, note: you can also turn these off while the script is running by using events, see examples for such below
Components = {
	Teleport = true,
	GodMode = true,
	Speedhack = true,
	WeaponBlacklist = true,
	CustomFlag = true,
	Explosions = true,
	CarBlacklist = true,
}



-- AllowedSources defines which resources can call anticheese events externally, leave empty for any
AllowedSources = {
	-- "anticheese-anticheat"
	-- "LemonMenu"
}

-- table[PlayerId].Component = true or false
-- dont touch this if you dont want to test something
PlayerRules = {}



--[[
event examples are:

anticheese:SetComponentStatus( component, state )
	enables or disables specific components
		component:
			an AntiCheese component, such as the ones listed above, must be a string
		state:
			the state to what the component should be set to, accepts booleans such as "true" for enabled and "false" for disabled


anticheese:ToggleComponent( component )
	sets a component to the opposite mode ( e.g. enabled becomes disabled ), there is no reason to use this.
		component:
			an AntiCheese component, such as the ones listed above, must be a string

anticheese:SetAllComponents( state )
	enables or disables **all** components
		state:
			the state to what the components should be set to, accepts booleans such as "true" for enabled and "false" for disabled


These can be used by triggering them like following:
	TriggerEvent("anticheese:SetComponentStatus", "Teleport", false)

These Events CAN NOT be called from the clientside

]]


TimerUsers = {}
violations = {}


recentExplosions = {}


function CanResourceInvoke(resource)
	if #AllowedSources == 0 then
		return true
	else
		for i, r in pairs(AllowedSources) do
			if r == resource then
				return true 
			end
		end
		return false
	end
end


function GetPlayerComponentStatus(player,component)
	local pl = PlayerRules[player]
	if not pl then return Components[component] end
	return pl[component]
end


AddEventHandler('playerDropped', function()
	if(TimerUsers[source])then
		TimerUsers[source] = nil
	end
	if(PlayerRules[source])then
		PlayerRules[source] = nil
	end
end)

RegisterServerEvent("anticheese:kick")
AddEventHandler("anticheese:kick", function(reason)
	if not CanResourceInvoke(GetInvokingResource()) then return end
	DropPlayer(source, reason)
end)


function SetComponentStatus(component, state)
	if not CanResourceInvoke(GetInvokingResource()) then return end
	if type(component) == "string" and type(state) == "boolean" then
		Components[component] = state -- changes the component to the wished status
	end
end
AddEventHandler("anticheese:SetComponentStatus", SetComponentStatus)

function GetComponentStatus(component, state)
	if not CanResourceInvoke(GetInvokingResource()) then return end
	return Components[component]
end
AddEventHandler("anticheese:GetComponentStatus", GetComponentStatus)

function SetPlayerComponentStatus(player, component, state)
	if not CanResourceInvoke(GetInvokingResource()) then return end
	if not PlayerRules[player] then PlayerRules[player] = {} end
	PlayerRules[player].component = state
end
AddEventHandler("anticheese:SetPlayerComponentStatus", SetPlayerComponentStatus)
	
function ToggleComponent(component)
	if not CanResourceInvoke(GetInvokingResource()) then return end
	if type(component) == "string" then
		Components[component] = not Components[component]
	end
end
AddEventHandler("anticheese:ToggleComponent", ToggleComponent)

function SetAllComponents(state)
	if not CanResourceInvoke(GetInvokingResource()) then return end
	if type(state) == "boolean" then
		for i,theComponent in pairs(Components) do
			Components[i] = state
		end
	end
end
AddEventHandler("anticheese:SetAllComponents", SetAllComponents)


function GetPlayerWarnings(id)
	local playername = GetPlayerName(id)
	for i,thePlayer in ipairs(violations) do
		if thePlayer.name == playername then
			return violations[i].count
		end
	end
	return 0
end

RegisterServerEvent("anticheese:timer")
AddEventHandler("anticheese:timer", function()
	if TimerUsers[source] then
		if (os.time() - TimerUsers[source]) < 15 and (Components.Speedhack and GetPlayerComponentStatus(source, "Speedhack")) then -- prevent the player from doing a good old cheat engine speedhack
			DropPlayer(source, "Speedhacking")
		else
			TimerUsers[source] = os.time()
		end
	else
		TimerUsers[source] = os.time()
	end
end)


Citizen.CreateThread(function()
	while true do 
		Wait(2000)
		clientExplosionCount = {}
		for i, expl in ipairs(recentExplosions) do 
			if not clientExplosionCount[expl.sender] then clientExplosionCount[expl.sender] = 0 end
			clientExplosionCount[expl.sender] = clientExplosionCount[expl.sender]+1
			table.remove(recentExplosions,i)
		end 
		recentExplosions = {}
		for c, count in pairs(clientExplosionCount) do 
			if count > 20 then
				local license, steam = GetPlayerNeededIdentifiers(c)
				local name = GetPlayerName(c)

				local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Explosion Spawning", true, c)

				SendWebhookMessage(webhook, "**Explosion Spawner!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nSpawned "..count.." Explosions in <2s. \nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end
end)

Citizen.CreateThread(function()

	function SendWebhookMessage(wh,message)
		webhook = GetConvar("ac_webhook", "none")
		if wh ~= "none" then
			PerformHttpRequest(wh, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
		end
	end
	
	function WarnPlayer(playername, reason,banInstantly,pid)
		if not CanResourceInvoke(GetInvokingResource()) then return end
		local isKnown = false
		local isKnownCount = 1
		local isKnownExtraText = ""
		for i,thePlayer in ipairs(violations) do
			if thePlayer.name == playername then
				isKnown = true
				if banInstantly then
					TriggerEvent("banCheater", pid or source,"Cheating")
					isKnownCount = violations[i].count
					table.remove(violations,i)
					isKnownExtraText = ", was banned instantly."
				else
					if violations[i].count == 1 then
						TriggerEvent("EasyAdmin:TakeScreenshot", source)
					end
					if violations[i].count == 3 then
						TriggerEvent("banCheater", pid or source,"Cheating")
						isKnownCount = violations[i].count
						table.remove(violations,i)
						isKnownExtraText = ", was banned."
					else
						violations[i].count = violations[i].count+1
						isKnownCount = violations[i].count
					end
				end
			end
		end

		if not isKnown then
			if banInstantly then
				TriggerEvent("banCheater", pid or source,"Cheating")
				isKnownExtraText = ", was banned instantly."
			else
				table.insert(violations, { name = playername, count = 1 })
			end
		end

		return isKnown, isKnownCount,isKnownExtraText
	end

	function GetPlayerNeededIdentifiers(player)
		local ids = GetPlayerIdentifiers(player)
		for i,theIdentifier in ipairs(ids) do
			if string.find(theIdentifier,"license:") or -1 > -1 then
				license = theIdentifier
			elseif string.find(theIdentifier,"steam:") or -1 > -1 then
				steam = theIdentifier
			end
		end
		if not steam then
			steam = "steam: missing"
		end
		return license, steam
	end

	RegisterServerEvent('AntiCheese:SpeedFlag')
	AddEventHandler('AntiCheese:SpeedFlag', function(rounds, roundm)
		if (Components.Speedhack and GetPlayerComponentStatus(source, "Speedhack")) and not IsPlayerAceAllowed(source,"anticheese.bypass") and CanResourceInvoke(GetInvokingResource()) then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Speed Hacking")

			SendWebhookMessage(webhook, "**Speed Hacker!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nWas travelling "..rounds.. " units. That's "..roundm.." more than normal! \nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
	end)



	RegisterServerEvent('AntiCheese:NoclipFlag')
	AddEventHandler('AntiCheese:NoclipFlag', function(distance)
		if (Components.Speedhack and GetPlayerComponentStatus(source, "Speedhack")) and not IsPlayerAceAllowed(source,"anticheese.bypass") and CanResourceInvoke(GetInvokingResource()) then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Noclip/Teleport Hacking")


			SendWebhookMessage(webhook,"**Noclip/Teleport!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nCaught with "..distance.." units between last checked location\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
	end)

	
	
	RegisterServerEvent('AntiCheese:CustomFlag')
	AddEventHandler('AntiCheese:CustomFlag', function(reason,extrainfo)
		if (Components.CustomFlag and GetPlayerComponentStatus(source, "CustomFlag")) and not IsPlayerAceAllowed(source,"anticheese.bypass") and CanResourceInvoke(GetInvokingResource()) then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			if not extrainfo then extrainfo = "no extra informations provided" end
			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,reason)


			SendWebhookMessage(webhook,"**"..reason.."** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\n"..extrainfo.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
	end)

	RegisterServerEvent('AntiCheese:HealthFlag')
	AddEventHandler('AntiCheese:HealthFlag', function(invincible,oldHealth, newHealth, curWait)
		if (Components.GodMode and GetPlayerComponentStatus(source, "GodMode")) and not IsPlayerAceAllowed(source,"anticheese.bypass") and CanResourceInvoke(GetInvokingResource()) then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Health Hacking")

			if invincible then
				SendWebhookMessage(webhook,"**Health Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nRegenerated "..newHealth-oldHealth.."hp ( to reach "..newHealth.."hp ) in "..curWait.."ms! ( PlayerPed was invincible )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			else
				SendWebhookMessage(webhook,"**Health Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nRegenerated "..newHealth-oldHealth.."hp ( to reach "..newHealth.."hp ) in "..curWait.."ms! ( Health was Forced )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent('AntiCheese:JumpFlag')
	AddEventHandler('AntiCheese:JumpFlag', function(jumplength)
		if (Components.SuperJump and GetPlayerComponentStatus(source, "SuperJump")) and not IsPlayerAceAllowed(source,"anticheese.bypass") and CanResourceInvoke(GetInvokingResource()) then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"SuperJump Hacking")

			SendWebhookMessage(webhook,"**SuperJump Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nJumped "..jumplength.."ms long\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
	end)

	RegisterServerEvent('AntiCheese:WeaponFlag')
	AddEventHandler('AntiCheese:WeaponFlag', function(weapon)
		if (Components.WeaponBlacklist and GetPlayerComponentStatus(source, "WeaponBlacklist")) and not IsPlayerAceAllowed(source,"anticheese.bypass") and CanResourceInvoke(GetInvokingResource()) then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Inventory Cheating")

			SendWebhookMessage(webhook,"**Inventory Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nGot Weapon: "..weapon.."( Blacklisted )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			TriggerClientEvent("AntiCheese:RemoveInventoryWeapons", source) 
		end
	end)

	RegisterServerEvent('AntiCheese:CarFlag')
	AddEventHandler('AntiCheese:CarFlag', function(car)
		if (Components.CarBlacklist and GetPlayerComponentStatus(source, "CarBlacklist")) and not IsPlayerAceAllowed(source,"anticheese.bypass") and CanResourceInvoke(GetInvokingResource()) then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Car Spawning Cheating")

			SendWebhookMessage(webhook,"**Spawn Car Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nGot Vehicle: "..car.."( Blacklisted )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
	end)
		
	AddEventHandler('explosionEvent', function(sender, ev)
		if (Components.Explosions and GetPlayerComponentStatus(sender, "Explosions")) and ev.damageScale ~= 0.0 and ev.ownerNetId == 0 then -- make sure component is enabled, damage isnt 0 and owner is the sender
			ev.time = os.time()
			table.insert(recentExplosions, {sender = sender, data=ev})
		end
	end)
end)

local verFile = LoadResourceFile(GetCurrentResourceName(), "version.json")
local curVersion = json.decode(verFile).version
Citizen.CreateThread( function()
	local updatePath = "/Blumlaut/anticheese-anticheat"
	local resourceName = "AntiCheese ("..GetCurrentResourceName()..")"
	PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version.json", function(err, response, headers)
		local data = json.decode(response)


		if curVersion ~= data.version and tonumber(curVersion) < tonumber(data.version) then
			print("\n--------------------------------------------------------------------------")
			print("\n"..resourceName.." is outdated.\nCurrent Version: "..data.version.."\nYour Version: "..curVersion.."\nPlease update it from https://github.com"..updatePath.."")
			print("\nUpdate Changelog:\n"..data.changelog)
			print("\n--------------------------------------------------------------------------")
		elseif tonumber(curVersion) > tonumber(data.version) then
			print("Your version of "..resourceName.." seems to be higher than the current version.")
		else
			print(resourceName.." is up to date!")
		end
	end, "GET", "", {version = 'this'})
end)
