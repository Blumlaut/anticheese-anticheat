# anti🧀-anticheat
## Need Help or want to follow my releases? Join the Support Discord: https://discord.gg/GugyRU8

Anticheat system for FiveM, made in collaboration with EasyAdmin

# About Anti🧀-anticheat:
This Anticheat is designed to work with EasyAdmin, hence, it is a required resource to run Anti🧀. It’s based on a 3 ( well, 4 ) Strike system, if you get 3 ( well, 4 ) Strikes, the anticheat will ban you from the server using EasyAdmin’s ban system.
There are also smaller checks in place which will not ban you, such as Speedhacking checks.

# Requirement:
* EasyAdmin 5.6 or Higher
  * EasyAdmin => https://forum.fivem.net/t/release-easyadmin-its-as-easy-as-it-gets/42245

# Webhooks:
If you don't want these then you can ignore this part. You can also add a Discord webhook so Anti🧀 will alert you if someone was detected cheating on your server. Here is how to use it.

(You will need to add the below information to your server.cfg & replace addresshere with your Discord Webhook)
```
set ac_webhook "addresshere"
```

# Extra Security

To allow for some extra security, as some Injectors seemingly are able to block certain clientside events from executing, you can run `ac_scramble` in the Server Console after installing Anticheese-Anticheat, then simply follow the instructions.


# Enable/Disable Components
```
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
```

# Bypass Checks

```
add_ace group.admin anticheese.bypass allow
add_principal identifier.steam:[STEAM ID HERE] group.admin
```

© Blü and IllusiveTea, For Licensing see [License](https://github.com/Bluethefurry/anticheese-anticheat/blob/master/LICENSE)
