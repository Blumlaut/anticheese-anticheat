-- configure active components here (for now)
Components = {

	-- these MIGHT trigger in legitimate circumstances, beware before enabling
	["client.godmode"] = false, -- protect against force-setting health and SetEntityInvincible
	["client.speedhack"] = false, -- Protect against Cheat Engine Speedhack
	["client.superjump"] = false, -- protect against super jump cheats
	["client.weaponblacklist"] = false, -- blacklist certain weapons in ac_c.lua
	["client.carblacklist"] = false, -- blacklist certain cars in ac_c.lua
	["server.explosions"] = true, -- detect abnormal explosion amount, against "blow up server" cheats

	-- these will NEVER trigger under legitimate circumstances
	["client.duiblacklist"] = true, -- checks for certain runtime textures being created which are used in cheat menus
	["client.bypasshacks"] = true, -- checks if their cheats try to disable certain anticheat components, not exclusive to anticheese
	["client.esx.gcphone"] = true, -- various detections for gcphone crashers/abuse
	["server.esx.eventspam"] = true, -- detects certain esx events being spammed for fast money
	["server.esx.billings"] = true, -- detects certain billing events that include cheat text
	["server.esx.pickup"] = true, -- detects esx crasher via pickup exploit
	["server.chat.spam"] = true, -- detect certain cheats spamming chat
	["server.esx.gcphone"] = true, -- detect gcphone twitter, sms exploits
	["server.esx.callback"] = true, -- detect esx:triggerServerCallback being crashed with malicious messages
	["server.esx.license"] = true, -- detect esx_license SQL Injection exploit
	["server.esx.kashacter"] = true, -- detect kashacters SQL Injection exploit
	["server.jail"] = true, -- detect various jailer exploits
	["server.discordbot"] = true, -- detect a discordbot spam event
	["server.carrypeople"] = true, -- detect a "carrypeople" exploit
	["server.esx.tackle"] = true, -- same as above except for tackling
	["server.dpemotes"] = true, -- detect an emote request spam in dp-emotes
	["server.esx.policejob"] = true, -- detect a ton of exploits in esx_policejob (cuff,drag,putinvehicle,outvehicle..)
	["server.interactionmenu"] = true, -- detect an exploit of SEM_InteractionMenu 

	["customflag"] = true, -- resources can trigger this one themselves if they detected something



	-- ONLY TOUCH THESE IF YOU KNOW WHAT YOU ARE DOING!!!!
	["server.blockClientsideVehicles"] = false, -- ONESYNC REQUIRED it blocks **ALL** Clientside vehicles from spawning, they NEED to be spawned serverside.
	-- can either be false, "strict" (no traffic) or "relaxed" (traffic will spawn)
	-- resource-created cars WILL NOT SPAWN! this needs to be adjusted accordingly for all resources that do this


	-- found an exploit we dont know yet? found a cheat we can take a look at? dont hesitate, help anticheese development.. TODAY!
	-- discord.gg/GugyRU8
}

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
	CreateThread(function()
		local clientScript = LoadResourceFile(GetCurrentResourceName(), "ac_c.lua")
		local serverScript = LoadResourceFile(GetCurrentResourceName(), "ac_s.lua")
		if not clientScript or not serverScript then
			print("Could not find ac_c.lua or ac_s.lua, please make sure both exist!")
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
			"anticheeseEventsTable",
			"maliciousBillings",
			"maliciousMessages",
			"jailerEvents",
			"spammedEvents"
		}

		--- random event name algo
		local charset = {}
		for i = 65,  90 do table.insert(charset, string.char(i)) end
		for i = 97, 122 do table.insert(charset, string.char(i)) end
		
		local function randomThing(length, i)
			math.randomseed(GetGameTimer()^2+(os.clock()^2)+(i or 1)+os.time())
			Wait(1)
		
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
						Wait(1000)
						for i, event in pairs(anticheeseEventsTable) do
							Wait(200)
							scrambledEvents[i] = randomThing(32, i^5)
						end
					end
				end
			end
			Wait(1)
		until (not collision)
		for i, event in pairs(anticheeseEventsTable) do
			clientScript = string.gsub(clientScript, event, scrambledEvents[i])
			serverScript = string.gsub(serverScript, event, scrambledEvents[i])					
		end

		SaveResourceFile(GetCurrentResourceName(), "ac_c.lua", clientScript, -1)
		SaveResourceFile(GetCurrentResourceName(), "ac_s.lua", serverScript, -1)

		print("Finished scrambing anticheese events, run command again to scramble again.")
		print("Please restart anticheese using the following command: ^3ensure "..GetCurrentResourceName().."^7")
	end)

end, true)

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
			Wait(10000)
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
		
	AddEventHandler('explosionEvent', function(sender, ev)
		if Components["server.explosions"] and ev.damageScale ~= 0.0 and ev.ownerNetId == 0 then -- make sure component is enabled, damage isnt 0 and owner is the sender
			ev.time = os.time()
			table.insert(recentExplosions, {sender = sender, data=ev})
		end
	end)
end)

-- resource-specific detections
-- TODO: Scan resources for event names
local maliciousBillings = {
	"Absolute Menu",
	"d0pamine.xyz",
	"d0pamine_xyz",
	"discord.gg/fjBp55t",
	"RocMenu",
	"Blood-X Menu",
	"Brutan#7799",
	"BRUTAN menu",
	"Lynx10",
	"lynxmenu",
	"Nertigel#5391",
	"Kolorek#1396",
	"https://discord.gg/rMFtEFK",
	"https://discord.gg/kgUtDrC",
	"You've been sent to jail by Cat and Flacko",
	"https://discord.gg/DAhzN6q",
	"Melon#1379",
	"Desudo Executor",
	"ahezu#6666",
	"HamMafia on YOUTUBE",
	"Skrobek on YOUTUBE",
	"https://discord.gg/yJb3qKG",
	"ZAPRASZAM NA KANAŁ THEULAN",
	"https://discord.gg/BEcQrjC"
}

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


	local maliciousMessages = {
		"~r~You just got fucked by Falcon",
		"https://discord.gg/y7xyNeG",
		"d0pamine.xyz",
		"d0pamine_xyz",
		"www.d0pamine",
		"discord.gg/fjBp55t",
		"oFlaqme#1325",
		"RocMenu",
		"https://discord.gg/NdzS3Qxa",
		"~g~Brutan#7799",
		"Brutan Premium",
		"Brutan#3927",
		"www.Brutan",
		"https://discordapp.com/invite/tCEajtn",
		"discord.gg/TVxy6HwNSg",
		"^13^24^3B^4y^5T^6e ^1C^2o^3m^4m^5u^6n^7i^1t^2y",
		"https://discord.gg/6wNar8g",
		"discord.gg/eCAZveXq7X",
		"^1L^2y^3n^4x ^5R^6e^7v^8o^9l^1u^2t^3i^5o^4n",
		"Nertigel#5391",
		"MALOSSIHOSTING",
		"https://discord.gg/qyVE4WW",
		"DarkSide-Gang",
		"^13^24^3B^4R^5U^6TAN",
		"discord.gg/DXQvMEzKSd",
		"MalossiHosting",
		"Get Fucked By ^1SugarMafia",
		"Absolute Menu on top",
		"https://discord.gg/GbsQxN",
		"foriv#0002",
		"xAries on YOUTUBE",
		"https://discord.gg/u9CxU33",
		"dc.xaries",
		"Darmowe cheaty na Fivem",
		"BRUTAN ON YOUTUBE",
		"xCat on YOUTUBE",
		"oFlaqme#1149",
		"SHADOW MENU | KOCHAM WAS",
		"Kolorek#1396",
		"https://discord.gg/rMFtEFK",
		"japierdole jak jestescie w wiezienu to ten serwer ssie pale elo",
		"https://discord.gg/kgUtDrC",
		"You've been sent to jail by Cat and Flacko",
		"https://discord.gg/DAhzN6q",
		"Melon#1379",
		"Desudo Executor",
		"ahezu#6666",
		"HamMafia on YOUTUBE",
		"Skrobek on YOUTUBE",
		"https://discord.gg/yJb3qKG",
		"ZAPRASZAM NA KANAŁ THEULAN",
		"https://discord.gg/BEcQrjC",
		"RAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
	}

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
	

	local jailerEvents = {
		"esx_jailer:sendToJail",
		"esx_jailler:sendToJail",
		"esx-qalle-jail:jailPlayer",
		"esx-qalle-jail:jailPlayerNew",
		"esx_jail:sendToJail",
		"esx_jailer:sendToJailCatfrajerze",
		"js:jailuser",
		"wyspa_jail:jailPlayer",
		"wyspa_jail:jail",
		"esx-qalle-jail:updateJailTime",
		"esx-qalle-jail:updateJailTime_n96nDDU@X?@zpf8"
	}



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


	local spammedEvents = {
		"esx_pilot:success",
		"esx_taxijob:success",
		"esx_mugging:giveMoney",
		"paycheck:salary",
		"esx_godirtyjob:pay",
		"esx_pizza:pay",
		"esx_slotmachine:sv:2",
		"esx_banksecurity:pay",
		"esx_gopostaljob:pay",
		"esx_truckerjob:pay",
		"esx_carthief:pay",
		"esx_garbagejob:pay",
		"esx_ranger:pay",
		"esx_truckersjob:payy",
		"PayForRepairNow",
		"reanimar:pagamento",
		"salario:pagamento",
		"offred:salar",
		"gcPhone:sendMessage",
		"esx_jailer:sendToJail",
		"esx_jailler:sendToJail",
		"esx-qalle-jail:jailPlayer",
		"esx-qalle-jail:jailPlayerNew",
		"esx_jail:sendToJail",
		"8321hiue89js",
		"esx_jailer:sendToJailCatfrajerze",
		"js:jailuser",
		"wyspa_jail:jailPlayer",
		"wyspa_jail:jail",
		"esx_policejob:billPlayer",
		"esx-qalle-jail:updateJailTime",
		"esx-qalle-jail:updateJailTime_n96nDDU@X?@zpf8",
		"::{korioz#0110}::jobs_civil:pay",
		"esx_drugs:startHarvestOpium",
		"esx_drugs:startTransformOpium",
		"esx_drugs:startSellOpium",
		"esx_drugs:startHarvestWeed",
		"esx_drugs:startTransformWeed",
		"esx_drugs:startSellWeed",
		"::{korioz#0110}::esx_billing:sendBill",
		"esx_billing:sendBill",
		"esx_mechanicjob:startHarvest",
		"esx_mechanicjob:startHarvest2",
		"esx_mechanicjob:startHarvest3",
		"esx_mechanicjob:startHarvest4",
		"esx_mechanicjob:startCraft",
		"esx_mechanicjob:startCraft2",
		"esx_mechanicjob:startCraft3",
		"esx_bitcoin:startHarvestKoda",
		"esx_bitcoin:startSellKoda",
		"esx_blanchisseur:startWhitening",
		"trip_adminmenu:addMoney",
		"esx_reprogjob:onNPCJobMissionCompleted",
		"esx_ambulancejob:revive",
		"Impulsionjobs_civil:pay",
		"SEM_InteractionMenu:CuffNear",
		"esx_fueldelivery:pay",
		"AdminMenu:giveBank",
		"AdminMenu:giveCash"
	}


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

	if Components["server.blockClientsideVehicles"] then
		for i=0, 1000 do 
			SetRoutingBucketEntityLockdownMode(i, Components["server.blockClientsideVehicles"])
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
