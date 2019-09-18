-- Wallet Checker to catch people exploiting money for vRP v0.5/v1 by ChieF TroN

-----------------------------------------------------------------
-- Config
local moddedMoney = 25000000 -- Amount of money greater than to trigger Kick/Ban
local kickorban = "ban" -- Use "ban" or "kick"
local useDiscord = false -- Use Discord Webhook? Input your discord webook link where it says INPUT LINK HERE on line 35 and 42.
-----------------------------------------------------------------

local Proxy = module("vrp", "lib/Proxy")
local Tunnel =  module("vrp", "lib/Tunnel")

vRP = Proxy.getInterface("vRP")
Tunnel.bindInterface("vrp_banksecurity",vRPbs)

local usercurrentmoney = nil
local useroldmoney = nil
local canGiveMoney = false

vRPbs = {}
function vRPbs.GetWallet(source)
	local user_id = vRP.getUserId({source})
	usercurrentmoney = vRP.getMoney({user_id})
	if useroldmoney == nil then
		useroldmoney = usercurrentmoney
	elseif useroldmoney ~= nil then
		if usercurrentmoney ~= nil and canGiveMoney == false then
			local difference = usercurrentmoney - useroldmoney
			if usercurrentmoney > (useroldmoney + moddedMoney) then
				print("UserID: " ..user_id.. " Has received more than "..moddedMoney.." in <5 seconds. Old Wallet: " ..useroldmoney.. " New Wallet: " ..usercurrentmoney.. " Value: $" ..difference)
				if useDiscord == true then
					if kickorban == "ban" then
						vRP.getUserIdentity({user_id, function(identity)
							local newmessage = "UserID: " ..user_id.. " Has received more than "..moddedMoney.." in Cash in <5 seconds. Old Wallet: $" ..useroldmoney.. " New Wallet: $" ..usercurrentmoney.. " Value: $" ..difference.. " and was automatically banned. @everyone"
							PerformHttpRequest('INPUT LINK HERE', function(err, text, headers) end, 'POST', json.encode({username = identity.firstname.. " " ..identity.name , content = newmessage}), { ['Content-Type'] = 'application/json' })
							vRP.ban({source,"UserID: " ..user_id.. " was banned for modding money. Value: $" ..difference})
						end})
					end
					if kickorban == "kick" then
						vRP.getUserIdentity({user_id, function(identity)
							local newmessage = "UserID: " ..user_id.. " Has received more than "..moddedMoney.." in Cash in <5 seconds. Old Wallet: $" ..useroldmoney.. " New Wallet: $" ..usercurrentmoney.. " Value: $" ..difference.. " and was automatically kicked. @everyone"
							PerformHttpRequest('INPUT LINK HERE', function(err, text, headers) end, 'POST', json.encode({username = identity.firstname.. " " ..identity.name , content = newmessage}), { ['Content-Type'] = 'application/json' })
							vRP.kick({source,"UserID: " ..user_id.. " was kicked for modding money. Value: $" ..difference})
						end})
					end
				elseif useDiscord == false then
					if kickorban == "ban" then
						vRP.ban({source,"UserID: " ..user_id.. " was banned for modding money. Value: $" ..difference})
					elseif kickorban == "kick" then
						vRP.kick({source,"UserID: " ..user_id.. " was kicked for modding money. Value: $" ..difference})
					end
				end
			end
			useroldmoney = usercurrentmoney
		end
	end
end

RegisterNetEvent("honestycheck")
AddEventHandler("honestycheck", function()
	local source = source
    vRPbs.GetWallet(source)
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
	if user_id ~= nil then
		usercurrentmoney = vRP.getMoney({user_id})
		canGiveMoney = vRP.hasPermission({user_id,"player.givemoney"})
	end
end)