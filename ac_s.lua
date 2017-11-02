
-- with this you can turn on/off specific anticheese components, note: you can also turn these off while the script is running by using events, see examples for such below
Components = {
	Teleport = true,
	GodMode = true,
	Speedhack = true
}


--[[ 
event examples are:

anticheese:SetComponentStatus( component, state ) 
	enables or disables specific components
		component:
			an AntiCheese component, such as the ones listed aboth, must be a string
		state:
			the state to what the component should be set to, accepts booleans such as "true" for enabled and "false" for disabled


anticheese:ToggleComponent( component ) 
	sets a component to the opposite mode ( e.g. enabled becomes disabled ), there is no reason to use this.
		component:
			an AntiCheese component, such as the ones listed aboth, must be a string

anticheese:SetAllComponents( state ) 
	enables or disables **all** components
		state:
			the state to what the components should be set to, accepts booleans such as "true" for enabled and "false" for disabled

			
These can be used by triggering them like following:
	TriggerEvent("anticheese:SetComponentStatus", "Teleport", false)
	
Triggering these events from the clientside is not recommended as these get disabled globally and not just for one player.


]]


Users = {}
violations = {}


useWebhook = false -- do you want to have discord announce when there is a cheater? put this to true and add your webhook below!
webhook = "https://discordapp.com/api/webhooks/your/webhook-here"

RegisterServerEvent("anticheese:timer")
AddEventHandler("anticheese:timer", function()
	if Users[source] then
		if (os.time() - Users[source]) < 15 and Components.Speedhack then -- prevent the player from doing a good old cheat engine speedhack
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

RegisterServerEvent("anticheese:SetComponentStatus")
AddEventHandler("anticheese:SetComponentStatus", function(component, state)	
	if type(component) == "string" and type(state) == "boolean" then
		Components[component] = state -- changes the component to the wished status
	end
end)

RegisterServerEvent("anticheese:ToggleComponent")
AddEventHandler("anticheese:ToggleComponent", function(component)
	if type(component) == "string" then
		Components[component] = not Components[component] 
	end
end)

RegisterServerEvent("anticheese:SetAllComponents")
AddEventHandler("anticheese:SetAllComponents", function(state)	
	if type(state) == "boolean" then
		for i,theComponent in pairs(Components) do
			Components[i] = state
		end
	end
end)

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
					TriggerEvent("banCheater", source)
					isKnownCount = violations[i].count
					table.remove(violations,i)
					isKnownExtraText = ", was banned."
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
		if Components.Speedhack then
			license, steam = GetPlayerNeededIdentifiers(source)
			
			name = GetPlayerName(source)
			
			isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Speed Hacking")
			

			SendWebhookMessage(webhook, "**Speed Hacker!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nWas travelling "..rounds.. " units. That's "..roundm.." more than normal! \nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
	end)
	
	
	
	RegisterNetEvent('RottenV:NoclipFlag')
	AddEventHandler('RottenV:NoclipFlag', function(distance)
		if Components.Speedhack then
			license, steam = GetPlayerNeededIdentifiers(source)
			name = GetPlayerName(source)
			
			isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Noclip/Teleport")

			

			SendWebhookMessage(webhook,"**Noclip/Teleport!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nCaught with "..distance.." units between last checked location\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
	end)
	
	RegisterNetEvent('RottenV:HealthFlag')
	AddEventHandler('RottenV:HealthFlag', function(invincible,oldHealth, newHealth)
		if Components.GodMode then
			license, steam = GetPlayerNeededIdentifiers(source)
			name = GetPlayerName(source)
			
			isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Health Hacking")

			if invincible then
				SendWebhookMessage(webhook,"**Health Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nRegenerated "..newHealth-oldHealth.."hp ( to reach "..newHealth.."hp ) in 50ms! ( PlayerPed was invincible )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			else 
				SendWebhookMessage(webhook,"**Health Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nRegenerated "..newHealth-oldHealth.."hp ( to reach "..newHealth.."hp ) in 50ms! ( Health was Forced )\nAnticheat Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end	
		end
	end)
end)


-- {content = "**Noclipper!** \n```Markdown \nUser:"..name.."\n"..license.."\n"..steam.."\nCaught with "..distance.." units between last checked location```"}