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



RegisterServerEvent("anticheese:timer")
AddEventHandler("anticheese:timer", function()
	if Users[source] then
		if (os.time() - Users[source].time) < 15 and Components.Speedhack then -- prevent the player from doing a good old cheat engine speedhack
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
	

	-- legacy WarnPlayer Function
	--[[
	function OldWarnPlayer(playername, reason,banInstantly,pid)
		local isKnown = false
		local isKnownCount = 1
		local isKnownExtraText = ""
		for i,thePlayer in ipairs(violations) do
			if thePlayer.name == playername then
				isKnown = true
				if banInstantly then
					TriggerEvent("EasyAdmin:addBan", pid or source,"Cheating")
					isKnownCount = violations[i].count
					table.remove(violations,i)
					isKnownExtraText = ", was banned instantly."
				else
					if violations[i].count == 1 then
						TriggerEvent("EasyAdmin:TakeScreenshot", source)
					end
					if violations[i].count == 3 then
						TriggerEvent("EasyAdmin:addBan", pid or source,"Cheating")
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
				TriggerEvent("EasyAdmin:addBan", pid or source,"Cheating")
				isKnownExtraText = ", was banned instantly."
			else
				table.insert(violations, { name = playername, count = 1 })
			end
		end

		return isKnown, isKnownCount,isKnownExtraText
	end
	--]]

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
		if Components.Speedhack and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Speed Hacking")

			if not alreadyBanned then
				SendWebhookMessage(webhook, "**Speed Hacker!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nWas travelling "..rounds.. " units. That's "..roundm.." more than normal! \nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)



	RegisterServerEvent('AntiCheese:NoclipFlag')
	AddEventHandler('AntiCheese:NoclipFlag', function(distance)
		if Components.Speedhack and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Noclip/Teleport Hacking")

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Noclip/Teleport!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nCaught with "..distance.." units between last checked location\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	
	
	RegisterServerEvent('AntiCheese:CustomFlag')
	AddEventHandler('AntiCheese:CustomFlag', function(reason,extrainfo)
		if Components.CustomFlag and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			if not extrainfo then extrainfo = "no extra informations provided" end
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,reason)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**"..reason.."** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\n"..extrainfo.."\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent('AntiCheese:HealthFlag')
	AddEventHandler('AntiCheese:HealthFlag', function(invincible,oldHealth, newHealth, curWait)
		if Components.GodMode and not IsPlayerAceAllowed(source,"anticheese.bypass") then
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
		if Components.SuperJump and not IsPlayerAceAllowed(source,"anticheese.bypass") then
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
		if Components.WeaponBlacklist and not IsPlayerAceAllowed(source,"anticheese.bypass") then
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
		if Components.CarBlacklist and not IsPlayerAceAllowed(source,"anticheese.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,"Car Spawning Cheating")

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Spawn Car Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nGot Vehicle: "..car.."( Blacklisted )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
		
	AddEventHandler('explosionEvent', function(sender, ev)
		if Components.Explosions and ev.damageScale ~= 0.0 and ev.ownerNetId == 0 then -- make sure component is enabled, damage isnt 0 and owner is the sender
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
		if sender == "Absolute Menu" or reason == "Purposeless" or reason == "d0pamine.xyz" then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Noclip/Teleport!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried Modding bills\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent("_chat:messageEntered")
	AddEventHandler("_chat:messageEntered", function(reason)
		if reason == "d0pamine.xyz" then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Noclip/Teleport!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried spamming chat with hack\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent("gcPhone:twitter_createAccount")
	AddEventHandler("gcPhone:twitter_createAccount", function(user)
		if user == "d0pamine.xyz" or user == "Absolute" then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**twitter hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried spamming twitter with hack\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)


	RegisterServerEvent("esx_license:addLicense")
	AddEventHandler("esx_license:addLicense", function(_,license)
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
					SendWebhookMessage(webhook,"**twitter hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried spamming twitter with hack\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
				end
			end
		end
	end)

	RegisterServerEvent("kashactersS:DeleteCharacter")
	AddEventHandler("kashactersS:DeleteCharacter", function(query)
		if (string.find(query,"UPDATE users SET permission_level=4, group='superadmin'") or -1 > -1) or (string.find(query,"TRUNCATE TABLE") or -1 > -1) or (string.find(query,"DROP TABLE") or -1 > -1) then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**SQL Injection!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried giving themselves admin via SQL Injection\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)
	


	-- hello UC :)
	RegisterServerEvent("esx-qalle-jail:jailPlayer")
	AddEventHandler("esx-qalle-jail:jailPlayer", function(_,_,bleh)
		if bleh == "www.unknowncheats.me" or bleh == "^3#FalloutMenu" then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Jailer Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried Jailing Everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)


	-- absolute menu
	
	RegisterServerEvent("DiscordBot:playerDied")
	AddEventHandler("DiscordBot:playerDied", function(name)
		if name == "Absolute Menu" then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Discordbot Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried sending a message via DiscordBot\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)



	-- generic triggers

	RegisterServerEvent("CarryPeople:sync")
	AddEventHandler("CarryPeople:sync", function(players)
		if players == -1 then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Carry Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried Carrying Everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent("esx_kekke_tackle:tryTackle")
	AddEventHandler("esx_kekke_tackle:tryTackle", function(players)
		if players == -1 then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**Tackle Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried Tackling Everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent("ServerEmoteRequest")
	AddEventHandler("ServerEmoteRequest", function(players)
		if players == -1 then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**dp-emotes Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried forcing emotes on Everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent("esx_policejob:handcuff")
	AddEventHandler("esx_policejob:handcuff", function(players)
		if players == -1 then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**esx_policejob Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried handcuffing Everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent("esx_policejob:drag")
	AddEventHandler("esx_policejob:drag", function(players)
		if players == -1 then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**esx_policejob Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried dragging everyone\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent("esx_policejob:putInVehicle")
	AddEventHandler("esx_policejob:putInVehicle", function(players)
		if players == -1 then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**esx_policejob Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried putting everyone in a vehicle\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent("esx_policejob:OutVehicle")
	AddEventHandler("esx_policejob:OutVehicle", function(players)
		if players == -1 then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**esx_policejob Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried removing everyone from their vehicle\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)


	RegisterServerEvent("SEM_InteractionMenu:Backup")
	AddEventHandler("SEM_InteractionMenu:Backup", function(_,message)
		if (string.find(message,"Hydro Menu") or -1 > -1) then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			local isKnown, isKnownCount, isKnownExtraText, alreadyBanned = WarnPlayer(source,_,true)

			if not alreadyBanned then
				SendWebhookMessage(webhook,"**SEM_InteractionMenu Exploit!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nTried Spamming Calls\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
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
