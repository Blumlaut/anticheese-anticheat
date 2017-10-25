Users = {}
violations = {}


useWebhook = false -- do you want to have discord announce when there is a cheater? put this to true and add your webhook below!
webhook = "https://discordapp.com/api/webhooks/your/webhook-here"

RegisterServerEvent("anticheese:timer")
AddEventHandler("anticheese:timer", function()
	if Users[source] then
		if (os.time() - Users[source]) < 15 then -- prevent the player from doing a good old cheat engine speedhack
			DropPlayer(source, "Speedhacking")
		else
			Users[source] = os.time()
		end
	else
		Users[source] = os.time()
	end
end)

AddEventHandler('playerDropped', function()
	if(Users[source])then
		Users[source] = nil
	end
end)

RegisterServerEvent("anticheese:kick")
AddEventHandler("anticheese:kick", function(reason)
	DropPlayer(source, reason)
end)



local ver = LoadResourceFile('EasyAdmin', 'version')

if ver ~= nil and tonumber(ver) < 3.65 then
	print("\n###############################")
	print("\nEasyAdmin is outdated or missing and will not work with AntiCheese\nplease update it from https://github.com/Bluethefurry/EasyAdmin")
	print("\n###############################")
end


Citizen.CreateThread(function()
	
	function SendWebhookMessage(webhook,message)
		if useWebhook then
			PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
		end
	end
	
	function WarnPlayer(playername, reason)
		local isKnown = false
		local isKnownCount = 1
		local isKnownExtraText = ""
		for i,thePlayer in ipairs(violations) do
			if thePlayer.name == name then
				isKnown = true
				if violations[i].count == 3 then
					for i,identifier in ipairs(GetPlayerIdentifiers(source)) do
						if string.find(identifier, "license:") then
							exports.EasyAdmin.BanIdentifier(identifier, "Cheating ( Nickname: "..GetPlayerName(source).. " )")
						end
					end
					isKnownCount = violations[i].count
					table.remove(violations,i)
					isKnownExtraText = ", was banned."
					DropPlayer(source,"Cheating")
				else
					violations[i].count = violations[i].count+1
					isKnownCount = violations[i].count
				end
			end
		end
		
		if not isKnown then 
			table.insert(violations, { name = name, count = 1 }) 
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
	
	RegisterNetEvent('RottenV:SpeedFlag')
	AddEventHandler('RottenV:SpeedFlag', function(rounds, roundm)
		license, steam = GetPlayerNeededIdentifiers(source)
		
		name = GetPlayerName(source)
		
		isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Speed Hacking")
		

		SendWebhookMessage(webhook, "**Speed Hacker!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nWas travelling "..rounds.. " units. That's "..roundm.." more than normal! \nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
	end)
	
	
	
	RegisterNetEvent('RottenV:NoclipFlag')
	AddEventHandler('RottenV:NoclipFlag', function(distance)
		license, steam = GetPlayerNeededIdentifiers(source)
		name = GetPlayerName(source)
		
		isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Noclip/Teleport")

		

		SendWebhookMessage(webhook,"**Noclip/Teleport!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nCaught with "..distance.." units between last checked location\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
	end)
	
	RegisterNetEvent('RottenV:HealthFlag')
	AddEventHandler('RottenV:HealthFlag', function(invincible,oldHealth, newHealth)
		license, steam = GetPlayerNeededIdentifiers(source)
		name = GetPlayerName(source)
		
		isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Health Hacking")

		if invincible then
			SendWebhookMessage(webhook,"**Health Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nRegenerated "..newHealth-oldHealth.."hp ( to reach "..newHealth.."hp ) in 50ms! ( PlayerPed was invincible )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		else 
			SendWebhookMessage(webhook,"**Health Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nRegenerated "..newHealth-oldHealth.."hp ( to reach "..newHealth.."hp ) in 50ms! ( Health was Forced )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end	
	end)
end)


-- {content = "**Noclipper!** \n```Markdown \nUser:"..name.."\n"..license.."\n"..steam.."\nCaught with "..distance.." units between last checked location```"}