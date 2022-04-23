
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


Users = {}


recentExplosions = {}
recentEvents = {}

RegisterCommand("ac_scramble", function()
	Citizen.CreateThread(function()
		local clientScript = LoadResourceFile(GetCurrentResourceName(), "ac_c.lua")
		local configScript = LoadResourceFile(GetCurrentResourceName(), "ac_config.lua")
		local serverScript = LoadResourceFile(GetCurrentResourceName(), "ac_s.lua")
		if not clientScript or not configScript or not serverScript then
			print("Could not find ac_c.lua, ac_config.lua and/or ac_s.lua, please make sure they exist!")
			return
		end
		print("Scrambling anticheese events..")
		
		local anticheeseEventsTable = {
			"anticheese:kick",
			"anticheese:timer",
			"AntiCheese:SpeedFlag",
			"AntiCheese:NoclipFlag",
			"AntiCheese:CustomFlag",
			"AntiCheese:HealthFlag",
			"AntiCheese:JumpFlag",
			"AntiCheese:WeaponFlag",
			"AntiCheese:CarFlag",
			"AntiCheese:DuiFlag",
			"AntiCheese:GenericFlag",
			"AntiCheese:BypassFlag",
			"AntiCheese:paySpam",
			"AntiCheese:gcphoneFlag",
			"anticheeseEventsTable",
			"maliciousBillings",
			"maliciousMessages",
			"jailerEvents",
			"spammedEvents",
			"BlacklistedWeapons",
			"CageObjs",
			"blacklistedCars",
			"negativePayEvents"
		}
		
		--- random event name algo
		local charset = {}
		for i = 65,  90 do table.insert(charset, string.char(i)) end
		for i = 97, 122 do table.insert(charset, string.char(i)) end
		
		local function randomThing(length, i)
			math.randomseed(GetGameTimer()^2+(os.clock()^2)+(i or 1)+os.time())
			Citizen.Wait(1)
			
			if length > 0 then
				return randomThing(length - 1) .. charset[math.random(1, #charset)]
			else
				return ""
			end
		end
		
		
		local scrambledEvents = {}
		for i, event in pairs(anticheeseEventsTable) do
			local randomized = randomThing(32, i^5)
			scrambledEvents[i] = randomized
			
			--Wait(math.random(500,2000))
		end
		local collision = false
		repeat 
			collision = false
			for i, event in pairs(scrambledEvents) do
				for o, event2 in pairs(scrambledEvents) do
					if i~=o and event==event2 then
						print("collision detected between "..anticheeseEventsTable[i].." and "..anticheeseEventsTable[o].." ("..event.."), regenerating. (if this message shows multiple times, restart your server and try again)")
						collision = true
						Citizen.Wait(1000)
						for i, event in pairs(anticheeseEventsTable) do
							Citizen.Wait(200)
							scrambledEvents[i] = randomThing(32, i^5)
						end
					end
				end
			end
			Citizen.Wait(1)
		until (not collision)
		for i, event in pairs(anticheeseEventsTable) do
			clientScript = string.gsub(clientScript, event, scrambledEvents[i])
			configScript = string.gsub(configScript, event, scrambledEvents[i])
			serverScript = string.gsub(serverScript, event, scrambledEvents[i])					
		end
		
		SaveResourceFile(GetCurrentResourceName(), "ac_c.lua", clientScript, -1)
		SaveResourceFile(GetCurrentResourceName(), "ac_config.lua", configScript, -1)
		SaveResourceFile(GetCurrentResourceName(), "ac_s.lua", serverScript, -1)
		
		print("Finished scrambing anticheese events, run command again to scramble again.")
		print("Please restart anticheese using the following command: ^3ensure "..GetCurrentResourceName().."^7")
	end)
	
end, true)


-- checks server for malware infection
Citizen.CreateThread(function()
	local infectedStrings = {"luwOyroAEjA", "HFuKXKYHZq", "'68', '74', '74', '70', '73', '3a'", "AddEventHandler('helpCode'", "Enchanced_Tabs"}
	local infectedResources = {
		{resource="rconlog", file="rconlog_server.lua"},
		{resource="sessionmanager", file="/server/host_lock.lua"},
		{resource="sessionmanager", file="/client/empty.lua"}
	}
	for i, k in pairs(infectedResources) do 
		local text = LoadResourceFile(k.resource, k.file)
		if text then
			for i,string in pairs(infectedStrings) do
				if text:find(string) then
					for i=1,30 do
						print("\n^1Your server is infected with malware!^7\nWe found malware in the following resource: ^1"..k.resource.."^7, in file ^1"..k.file.."^7\n\nYou *must* take appropriate steps to remove this malware, your server is vulnerable.\n")
						Wait(1000)
					end
				end 
			end
		end
	end
end)

RegisterServerEvent("anticheese:timer")
AddEventHandler("anticheese:timer", function()
	if Users[source] then
		if (os.time() - Users[source].time) < 15 and Components["client.speedhack"] then -- prevent the player from doing a good old cheat engine speedhack
			DropPlayer(source, "Speedhacking")
		else
			Users[source].time = os.time()
		end
	else
		Users[source] = {violations = 1,time = os.time()}
	end
end)

AddEventHandler('playerDropped', function()
	local p = source
	if(Users[p])then
		Citizen.CreateThread(function()
			Citizen.Wait(10000)
			Users[p] = nil
		end)
	end
end)

RegisterServerEvent("anticheese:kick")
AddEventHandler("anticheese:kick", function(reason)
	DropPlayer(source, reason)
end)

RegisterServerEvent("anticheese:SetComponentStatus")
AddEventHandler("anticheese:SetComponentStatus", function(component, state)
	if type(tonumber(source)) == "number" then
		local license, steam = GetPlayerNeededIdentifiers(source)
		local name = GetPlayerName(source)
		
		local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Attempting Anticheese Bypass", true)
		
		if not alreadyBanned then
			SendWebhookMessage(webhook, "**Anticheese Bypass!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nAttempted to meddle with Anticheese Components. \nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
		return
	end
	
	if type(component) == "string" and type(state) == "boolean" then
		Components[component] = state -- changes the component to the wished status
	end
end)

RegisterServerEvent("anticheese:ToggleComponent")
AddEventHandler("anticheese:ToggleComponent", function(component)
	if type(tonumber(source)) == "number" then
		local license, steam = GetPlayerNeededIdentifiers(source)
		local name = GetPlayerName(source)
		
		local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Attempting Anticheese Bypass", true)
		
		if not alreadyBanned then
			SendWebhookMessage(webhook, "**Anticheese Bypass!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nAttempted to meddle with Anticheese Components. \nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
		return
	end
	
	if type(component) == "string" then
		Components[component] = not Components[component]
	end
end)

RegisterServerEvent("anticheese:SetAllComponents")
AddEventHandler("anticheese:SetAllComponents", function(state)
	if type(tonumber(source)) == "number" then
		local license, steam = GetPlayerNeededIdentifiers(source)
		local name = GetPlayerName(source)
		
		local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Attempting Anticheese Bypass", true)
		
		if not alreadyBanned then
			SendWebhookMessage(webhook, "**Anticheese Bypass!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nAttempted to meddle with Anticheese Components. \nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
		return
	end
	
	if type(state) == "boolean" then
		for i,theComponent in pairs(Components) do
			Components[i] = state
		end
	end
end)

Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(2000)
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
				
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(c,"Explosion Spawning", true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook, "**Explosion Spawner!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nSpawned "..count.." Explosions in <2s. \nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
		clientEventCount = {}
		for i, event in ipairs(recentEvents) do 
			if not clientEventCount[event.sender] then clientEventCount[event.sender] = 0 end
			clientEventCount[event.sender] = clientEventCount[event.sender]+1
			table.remove(recentEvents,i)
		end 
		recentEvents = {}
		for c, count in pairs(clientEventCount) do 
			if count >= 8 then
				local license, steam = GetPlayerNeededIdentifiers(c)
				local name = GetPlayerName(c)
				
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(c,"Event Spamming", true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook, "**Event Spammer!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nSpammed "..count.." Commonly-Abused Events in <2s. \nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end
end)


function SendWebhookMessage(wh,message)
	webhook = GetConvar("ac_webhook", "none")
	if webhook ~= "none" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end

function WarnPlayer(playerId, reason, banInstantly)
	local isKnownCount = 1
	local isKnownExtraText = ""
	local ourUser = Users[playerId]
	if ourUser then
		if ourUser.alreadyBanned then return false, -1, "Player was no longer on the server(already banned?)", true end
		local violations = ourUser.violations
		if banInstantly then
			TriggerEvent("EasyAdmin:addBan", playerId,"Cheating")
			isKnownExtraText = ", was banned instantly."
			ourUser.alreadyBanned = true 
			return true, isKnownCount,isKnownExtraText
		else
			if ourUser.violations == 1 then
				TriggerEvent("EasyAdmin:TakeScreenshot", playerId)
				ourUser.violations = ourUser.violations+1
			elseif ourUser.violations == 3 then
				TriggerEvent("EasyAdmin:addBan", pid or source,"Cheating")
				isKnownExtraText = ", was banned."
				ourUser.alreadyBanned = true 
			else
				ourUser.violations = ourUser.violations+1
			end
		end
		isKnownCount = ourUser.violations
	else
		Users[playerId] = {violations = 1,time = os.time()}
		ourUser = Users[playerId]
		local violations = ourUser.violations
		isKnownCount = violations
		if banInstantly then
			TriggerEvent("EasyAdmin:addBan", playerId,"Cheating")
			isKnownExtraText = ", was banned instantly."
			ourUser.alreadyBanned = true 
			return true, isKnownCount,isKnownExtraText
		end
	end
	return true, isKnownCount,isKnownExtraText
end

Citizen.CreateThread(function()
	
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
		if Components["client.speedhack"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Speed Hacking")
			
			if not alreadyBanned then
				SendWebhookMessage(webhook, "**Speed Hacker!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nWas travelling "..rounds.. " units. That's "..roundm.." more than normal! \nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	
	RegisterServerEvent('AntiCheese:CustomFlag')
	AddEventHandler('AntiCheese:CustomFlag', function(reason,extrainfo, banInstantly)
		if Components["customflag"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			if not extrainfo then extrainfo = "no extra informations provided" end
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,reason, banInstantly)
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**"..reason.."** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\n"..extrainfo.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:HealthFlag')
	AddEventHandler('AntiCheese:HealthFlag', function(invincible,oldHealth, newHealth, curWait)
		if Components["client.godmode"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Health Hacking")
			
			if not alreadyBanned then
				if invincible then
					SendWebhookMessage(webhook,"**Health Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nRegenerated "..newHealth-oldHealth.."hp ( to reach "..newHealth.."hp ) in "..curWait.."ms! ( PlayerPed was invincible )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				else
					SendWebhookMessage(webhook,"**Health Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nRegenerated "..newHealth-oldHealth.."hp ( to reach "..newHealth.."hp ) in "..curWait.."ms! ( Health was Forced )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:JumpFlag')
	AddEventHandler('AntiCheese:JumpFlag', function(jumplength)
		if Components["client.superjump"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"SuperJump Hacking")
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**SuperJump Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nJumped "..jumplength.."ms long\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:WeaponFlag')
	AddEventHandler('AntiCheese:WeaponFlag', function(weapon)
		if Components["client.weaponblacklist"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Inventory Cheating")
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Inventory Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nGot Weapon: "..weapon.."( Blacklisted )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				TriggerClientEvent("AntiCheese:RemoveInventoryWeapons", source) 
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:CarFlag')
	AddEventHandler('AntiCheese:CarFlag', function(car)
		if Components["client.carblacklist"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Car Spawning Cheating")
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Spawn Car Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nGot Vehicle: "..car.."( Blacklisted )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:Spectate')
	AddEventHandler('AntiCheese:Spectate', function()
		if Components["client.spectate"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Spectating Players")
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Spectating Players!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:Damage')
	AddEventHandler('AntiCheese:Damage', function()
		if Components["client.multidamage"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Damage Multiplication")
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Damage Multiplication!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:Thermal')
	AddEventHandler('AntiCheese:Thermal', function()
		if Components["client.thermal"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Thermal Vision")
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Thermal Vision!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:Night')
	AddEventHandler('AntiCheese:Night', function()
		if Components["client.night"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Night Vision")
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Night Vision!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent('AntiCheese:CarVisible')
	AddEventHandler('AntiCheese:CarVisible', function()
		if Components["client.carvisible"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Car Invisibility")
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Car Invisibility!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	AddEventHandler('explosionEvent', function(sender, ev)
		if Components["server.explosions"] and ev.damageScale ~= 0.0 and ev.ownerNetId == 0 then -- make sure component is enabled, damage isnt 0 and owner is the sender
			ev.time = os.time()
			table.insert(recentExplosions, {sender = sender, data=ev})
		end
	end)
end)

-- resource-specific detections
-- TODO: Scan resources for event names

Citizen.CreateThread(function()
	RegisterServerEvent("esx_billing:sendBill")
	AddEventHandler("esx_billing:sendBill", function(_,sender,reason)
		if Components["server.esx.billings"] then
			for i, msg in pairs(maliciousBillings) do
				if (string.find(sender or "", msg) or -1) > -1 or (string.find(reason or "", msg) or -1) > -1 then
					local license, steam = GetPlayerNeededIdentifiers(source)
					local name = GetPlayerName(source)
					local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
					
					if not alreadyBanned then
						SendWebhookMessage(webhook,"**esx_billing exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried Modding bills\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
					end
				end
			end
		end
	end)
	
	RegisterServerEvent("esx:onPickup")
	AddEventHandler("esx:onPickup", function(pickup)
		if Components["server.esx.pickup"] then
			if type(pickup) ~= "number" then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**es_extended exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried breaking 'onPickup' event\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end	
		end
	end)
	
	
	RegisterServerEvent("_chat:messageEntered")
	AddEventHandler("_chat:messageEntered", function(title,_,reason)
		if Components["server.chat.spam"] then
			for i, msg in pairs(maliciousMessages) do
				if (string.find(title or "", msg) or -1) > -1 or (string.find(reason or "", msg) or -1) > -1 then
					local license, steam = GetPlayerNeededIdentifiers(source)
					local name = GetPlayerName(source)
					local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
					
					if not alreadyBanned then
						SendWebhookMessage(webhook,"**Chat Spam!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried spamming chat with hack\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
					end	
				end
			end
		end
	end)
	
	
	RegisterServerEvent("gcPhone:twitter_createAccount")
	AddEventHandler("gcPhone:twitter_createAccount", function(user, pw)
		if Components["server.esx.gcphone"] then
			for i, msg in pairs(maliciousMessages) do
				if (string.find(user or "", msg) or -1) > -1 or (string.find(pw or "", msg) or -1) > -1 or (user or "") == "Absolute" or ((user or "") == "Lumia" and (pw or "") == "Lumia123") then
					local license, steam = GetPlayerNeededIdentifiers(source)
					local name = GetPlayerName(source)
					local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
					
					if not alreadyBanned then
						SendWebhookMessage(webhook,"**twitter hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried spamming twitter with hack\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
					end
				end
			end
		end
	end)
	
	RegisterServerEvent("esx_phone:send")
	AddEventHandler("esx_phone:send", function(_, message)
		if Components["server.esx.gcphone"] then
			for i, msg in pairs(maliciousMessages) do
				if (string.find(message or "", msg) or -1) > -1 or (string.find(pw or "", msg) or -1) > -1 or (message or "") == "Absolute" or (message or "") == "Lumia" then
					local license, steam = GetPlayerNeededIdentifiers(source)
					local name = GetPlayerName(source)
					local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
					
					if not alreadyBanned then
						SendWebhookMessage(webhook,"**esx_phone hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried spamming esx_phone with hack\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
					end
				end
			end
		end
	end)
	
	RegisterServerEvent("esx_addons_gcphone:startCall")
	AddEventHandler("esx_addons_gcphone:startCall", function(_, message)
		if Components["server.esx.gcphone"] then
			for i, msg in pairs(maliciousMessages) do
				if (string.find(message or "", msg) or -1) > -1 or (string.find(pw or "", msg) or -1) > -1 or (message or "") == "Absolute" or (message or "") == "Lumia" then
					local license, steam = GetPlayerNeededIdentifiers(source)
					local name = GetPlayerName(source)
					local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
					
					if not alreadyBanned then
						SendWebhookMessage(webhook,"**gcphone hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried spamming gcphone with hack\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
					end
				end
			end
		end
	end)
	
	
	RegisterServerEvent("esx:triggerServerCallback") -- hook triggerServerCallback and check the event name for known nasties
	AddEventHandler("esx:triggerServerCallback", function(name)
		if Components["server.esx.callback"] then
			for i, msg in pairs(maliciousMessages) do
				if (string.find(name or "", msg) or -1) > -1 then
					local license, steam = GetPlayerNeededIdentifiers(source)
					local name = GetPlayerName(source)
					local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
					
					if not alreadyBanned then
						SendWebhookMessage(webhook,"**esx exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried spamming invalid ESX Callbacks\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
					end
				end
			end
		end
	end)
	
	
	RegisterServerEvent("esx_license:addLicense")
	AddEventHandler("esx_license:addLicense", function(_,license)
		if Components["server.esx.license"] then
			local texts = {
				"YARRAĞI YEDİNNNN",
				"YAGO SIKER!!!",
				"SUCK MY DICK!",
				"RIP Your SQL Faggot",
				"Make sure to wipe all tables ;)",
				"YAGO Was Here"
			}
			for i, text in pairs(texts) do 
				if license == text then
					local license, steam = GetPlayerNeededIdentifiers(source)
					local name = GetPlayerName(source)
					local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
					
					if not alreadyBanned then
						SendWebhookMessage(webhook,"**esx_license sql injection!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried SQL Injection\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
					end
				end
			end
		end
	end)
	
	RegisterServerEvent("kashactersS:DeleteCharacter")
	AddEventHandler("kashactersS:DeleteCharacter", function(query)
		if Components["server.esx.kashacter"] then
			if (string.find(query or "","permission_level") or -1 > -1) or (string.find(query or "","TRUNCATE TABLE") or -1 > -1) or (string.find(query or "","DROP TABLE") or -1 > -1) or (string.find(query or "","UPDATE users") or -1 > -1) then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**SQL Injection!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried SQL Injection\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)
	
	
	
	
	function handleJailEvent(_,_,reason)
		local texts = {
			"www.unknowncheats.me",
			"FalloutMenu",
			"BRUTAN ON YOUTUBE",
			"Ja jsem z CK Gangu mrdky ****CK Gang****",
			"FREE PALESTINE",
			"youtube.com/c/Cat98",
			"Kolorek#1396"
		}
		for i, msg in pairs(texts) do
			if (string.find(reason or "", msg) or -1) > -1 then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**Jailer Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried Jailing Everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end
	if Components["server.jail"] then
		for i, event in pairs(jailerEvents) do
			RegisterServerEvent(event)
			AddEventHandler(event, handleJailEvent)
		end
	end
	
	
	-- absolute menu
	
	RegisterServerEvent("DiscordBot:playerDied")
	AddEventHandler("DiscordBot:playerDied", function(name,reason)
		if Components["server.discordbot"] then
			if name == "Absolute Menu" or reason == "1337" then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**Discordbot Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried sending a message via DiscordBot\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)
	
	
	
	-- generic triggers
	
	RegisterServerEvent("CarryPeople:sync")
	AddEventHandler("CarryPeople:sync", function(players)
		if Components["server.carrypeople"] then
			if players == -1 then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**Carry Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried Carrying Everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)
	
	RegisterServerEvent("esx_kekke_tackle:tryTackle")
	AddEventHandler("esx_kekke_tackle:tryTackle", function(players)
		if Components["server.esx.tackle"] then
			if players == -1 then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**Tackle Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried Tackling Everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)
	
	RegisterServerEvent("ServerEmoteRequest")
	AddEventHandler("ServerEmoteRequest", function(players)
		if Components["server.dpemotes"] then
			if players == -1 then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**dp-emotes Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried forcing emotes on Everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)
	
	RegisterServerEvent("esx_policejob:handcuff")
	AddEventHandler("esx_policejob:handcuff", function(players)
		if Components["server.esx.policejob"] then
			if players == -1 then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**esx_policejob Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried handcuffing Everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)
	
	RegisterServerEvent("esx_policejob:drag")
	AddEventHandler("esx_policejob:drag", function(players)
		if Components["server.esx.policejob"] then
			if players == -1 then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**esx_policejob Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried dragging everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)
	
	RegisterServerEvent("esx_policejob:putInVehicle")
	AddEventHandler("esx_policejob:putInVehicle", function(players)
		if Components["server.esx.policejob"] then
			if players == -1 then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**esx_policejob Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried putting everyone in a vehicle\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)
	
	RegisterServerEvent("esx_policejob:OutVehicle")
	AddEventHandler("esx_policejob:OutVehicle", function(players)
		if Components["server.esx.policejob"] then
			if players == -1 then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**esx_policejob Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried removing everyone from their vehicle\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)
	
	
	RegisterServerEvent("SEM_InteractionMenu:Backup")
	AddEventHandler("SEM_InteractionMenu:Backup", function(_,message)
		if Components["server.interactionmenu"] then
			if (string.find(message or "","Hydro Menu") or -1 > -1) then
				local license, steam = GetPlayerNeededIdentifiers(source)
				local name = GetPlayerName(source)
				local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
				
				if not alreadyBanned then
					SendWebhookMessage(webhook,"**SEM_InteractionMenu Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried Spamming Calls\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)
	
	
	RegisterServerEvent("RunCode:RunStringRemotelly")
	AddEventHandler("RunCode:RunStringRemotelly", function(_,message)
		if Components["server.vrp.runstring"] then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**RunString Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried using vrp_basic_menu runcode exploit!\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	
	function handleSpammedEvents(event)
		local source = source
		local event = event
		
		local eventData = {name=event, sender = source, time = os.time()}
		table.insert(recentEvents, eventData)
	end
	
	if Components["server.esx.eventspam"] then
		for i, event in pairs(spammedEvents) do
			RegisterServerEvent(event)
			AddEventHandler(event, handleSpammedEvents)
		end
	end
	
	
	RegisterServerEvent('AntiCheese:GenericFlag')
	AddEventHandler('AntiCheese:GenericFlag', function(reason,extrainfo, banInstantly)
		if Components["generic"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			if not extrainfo then extrainfo = "no extra informations provided" end
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,reason, banInstantly)
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**"..reason.."** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\n"..extrainfo.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:BypassFlag')
	AddEventHandler('AntiCheese:BypassFlag', function(reason,extrainfo, banInstantly)
		if Components["client.bypasshacks"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			if not extrainfo then extrainfo = "no extra informations provided" end
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,reason, banInstantly)
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**"..reason.."** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\n"..extrainfo.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:paySpam')
	AddEventHandler('AntiCheese:paySpam', function(reason,extrainfo, banInstantly)
		if Components["server.esx.billings"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			if not extrainfo then extrainfo = "no extra informations provided" end
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,reason, banInstantly)
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**"..reason.."** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\n"..extrainfo.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:gcphoneFlag')
	AddEventHandler('AntiCheese:gcphoneFlag', function(reason,extrainfo, banInstantly)
		if Components["client.esx.gcphone"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			if not extrainfo then extrainfo = "no extra informations provided" end
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,reason, banInstantly)
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**"..reason.."** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\n"..extrainfo.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	AddEventHandler("clearPedTasksEvent", function(source, data)
		source = tonumber(source)
		local entity = NetworkGetEntityFromNetworkId(data.pedId)
		if DoesEntityExist(entity) then
			local owner = NetworkGetEntityOwner(entity)
			if owner ~= source then
				if Components["server.cleartask"] then
					CancelEvent()
					local license, steam = GetPlayerNeededIdentifiers(source)
					local name = GetPlayerName(source)
					local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
					
					if not alreadyBanned then
						SendWebhookMessage(webhook,"**Clear Ped Tasks!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried to kick someone from vehicle\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
					end
				end
			end
		end
	end)
	
	AddEventHandler("giveWeaponEvent", function(source, data)
		source = tonumber(source)
		local entity = NetworkGetEntityFromNetworkId(data.pedId)
		if DoesEntityExist(entity) then
			local owner = NetworkGetEntityOwner(entity)
			if owner ~= source then
				if Components["server.giveweapon"] then
					CancelEvent()
					local license, steam = GetPlayerNeededIdentifiers(source)
					local name = GetPlayerName(source)
					local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)
					
					if not alreadyBanned then
						SendWebhookMessage(webhook,"**Give Ped Weapon!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried to add someone weapon\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
					end
				end
			end
		end
	end)
	
	RegisterServerEvent('AntiCheese:DuiFlag')
	AddEventHandler('AntiCheese:DuiFlag', function(reason,extrainfo, banInstantly)
		if Components["client.duiblacklist"] and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			if not extrainfo then extrainfo = "no extra informations provided" end
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,reason, banInstantly)
			
			if not alreadyBanned then
				SendWebhookMessage(webhook,"**"..reason.."** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\n"..extrainfo.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	
	if Components["server.blockClientEntities"] then
		for i=0, 1000 do 
			SetRoutingBucketEntityLockdownMode(i, Components["server.blockClientEntities"])
		end
	end
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
