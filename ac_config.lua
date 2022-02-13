-- configure active components here (for now)
Components = {
	
	-- these MIGHT trigger in legitimate circumstances, beware before enabling
	["client.godmode"] = false, -- protect against force-setting health and SetEntityInvincible
	["client.speedhack"] = false, -- Protect against Cheat Engine Speedhack
	["client.superjump"] = false, -- protect against super jump cheats
	["client.weaponblacklist"] = false, -- blacklist certain weapons in ac_c.lua
	["client.carblacklist"] = false, -- blacklist certain cars in ac_c.lua
	["client.carvisible"] = true, -- anti car invisibility
	["client.multidamage"] = true, -- anti multi damage, blocks damage multiplication
	["client.spectate"] = true, -- detects if cheater is spectating other players
	["server.cleartask"] = true, -- detects clearing player tasks, e.g.kicking from car
	["server.giveweapon"] = false, -- anti weapon giver (detects when player add weapon into other player inventory)
	["server.explosions"] = true, -- detect abnormal explosion amount, against "blow up server" cheats
	
	-- these will NEVER trigger under legitimate circumstances
	["generic"] = true, -- generic event detection for cheats exposing themselves on purpose
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
	["server.vrp.runstring"] = true, -- detect and ban users using a Remote Code Execution function in vrp_basic_menu 
	["client.night"] = true, -- anti night vision
	["client.thermal"] = true, -- anti thermal vision
	
	["customflag"] = true, -- resources can trigger this one themselves if they detected something
	
	
	
	-- ONLY TOUCH THESE IF YOU KNOW WHAT YOU ARE DOING!!!!
	["server.blockClientEntities"] = false, -- ONESYNC REQUIRED it blocks **ALL** Clientside Entities, including vehicles, from spawning, they NEED to be spawned serverside.
	-- can either be false, "strict" (no traffic), "relaxed" (traffic will spawn, script spawning blocked) or "inactive" (normal behaviour, clients can spawn entities)
	-- resource-created Vehicles & Entities WILL NOT SPAWN! this needs to be adjusted accordingly for all resources that do this
	
	
	-- found an exploit we dont know yet? found a cheat we can take a look at? dont hesitate, help anticheese development.. TODAY!
	-- discord.gg/GugyRU8
}


-- Blacklist Tables
BlacklistedWeapons = {
	`WEAPON_BALL`,
	`WEAPON_RAILGUN`,
	`WEAPON_GARBAGEBAG`,
}


-- Anticheese will attempt to delete these objects when possible, even if they are legitimate
CageObjs = {
	`prop_gold_cont_01`,
	`p_cablecar_s`,
	`stt_prop_stunt_tube_l`,
	`stt_prop_stunt_track_dwuturn`,
	`hei_prop_carrier_cargo_02a`,
	`p_ferris_car_01`,
	`prop_cj_big_boat`,
	`prop_rock_4_big2`,
	`prop_steps_big_01`,
	`v_ilev_lest_bigscreen`,
	`prop_carcreeper`,
	`apa_mp_h_bed_double_09`,
	`apa_mp_h_bed_wide_05`,
	`prop_cattlecrush`,
	`prop_cs_documents_01`,
	
}

-- list of cars that cannot be spawned
blacklistedCars = {
	-- `khanjali`,
}


-- events which will trigger a ban when they are triggered with a negative amount
negativePayEvents = {
	"neweden_garage:pay",
	"projektsantos:mandathajs",
	"esx_dmvschool:pay"
}


-- text banned from esx_billing, esx_phone and similar inputs
maliciousBillings = {
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


-- messages that may get sent in chat or through other resources which will then broadcast it
-- content warning: may contain racist, sexist or similar sentences and phrases, these are taken directly from cheats
maliciousMessages = {
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
	"RAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
	"lutfen bankana bak. Sana para gonderdik, bu parayi Alien Menu sayesinde yaptik"
}

-- events which can be used to jail everyone
jailerEvents = {
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


-- events which are often spammed and abused by cheats
spammedEvents = {
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
	"AdminMenu:giveCash",
	"esx-qalle-hunting:reward",
	"esx-qalle-hunting:sell",
	"esx_vangelico_robbery:gioielli1",
	"lester:vendita",
	"houseRobberies:giveMoney",
	"lh-bankrobbery:server:recieveItem",
	"esx_uber:pay",
	"99kr-burglary:Add",
	"99kr-shops:Cashier",
	"esx-ecobottles:retrieveBottle",
	"loffe_carthief:questFinished",
	"loffe_fishing:caught",
	"esx_loffe_fangelse:Pay",
	"loffe_robbery:pickUp",
	"hospital:client:Revive",
	"cylex:startSellSarap",
	"cylex:startTransformSarap",
	"cylex:startHarvestSarap",
	"cylex:startSellMelon",
	"cylex:startTransformMelon",
	"cylex:startHarvestMelon",
	"sp_admin:menuv",
	"sp_admin:giveCash",
	"sp_admin:giveDirtyMoney",
	"sp_admin:giveCash"
}
