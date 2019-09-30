-- Wallet Checker to catch people exploiting money for vRP v0.5/v1 by ChieF TroN

-----------------------------------------------------------------
-- Config
local moddedMoney = 25000000 	-- Amount of money greater than to trigger Kick/Ban (Wallet)
local moddedbMoney = 100000000 	-- Amount of money greater than to trigger Kick/Ban (Bank)
local BankCheck = false			-- Do the check on the bank as well?
local kickorban = "ban" 		-- Use "ban" or "kick"
local useDiscord = false 		-- Use Discord Webhook? Input your discord webook link where it says INPUT LINK HERE on line 35 and 42.
-----------------------------------------------------------------

local Proxy = module("vrp", "lib/Proxy")
local Tunnel =  module("vrp", "lib/Tunnel")

vRP = Proxy.getInterface("vRP")
Tunnel.bindInterface("vrp_banksecurity",vRPbs)

local useroldmoney = {}
local useroldbmoney = {}
local walletmoney = {}
local bankmoney = {}
local canGiveMoney = false

vRPbs = {}

function vRPbs.GetMoneyStatus(userid)
	local user_id = userid
	walletmoney[user_id] = vRP.getMoney({user_id})
	bankmoney[user_id] = vRP.getBankMoney({user_id})
	if useroldmoney[user_id] == nil then
		useroldmoney[user_id] = walletmoney[user_id]
	elseif useroldmoney[user_id] ~= nil then
		if walletmoney[user_id] ~= nil and canGiveMoney == false then
			local difference = walletmoney[user_id] - useroldmoney[user_id]
			if useroldmoney[user_id] ~= bankmoney[user_id] then
				if walletmoney[user_id] > (useroldmoney[user_id] + moddedMoney) then
					print("UserID: " ..user_id.. " Has received more than "..moddedMoney.." in <5 seconds. Old Wallet: " ..useroldmoney[user_id].. " New Wallet: " ..walletmoney[user_id].. " Value: $" ..difference)
					if useDiscord == true then
						if kickorban == "ban" then
							vRP.getUserIdentity({user_id, function(identity)
								local newmessage = "UserID: " ..user_id.. " Has received more than "..moddedMoney.." in Cash in <5 seconds. Old Wallet: $" ..useroldmoney[user_id].. " New Wallet: $" ..walletmoney[user_id].. " Value: $" ..difference.. " and was automatically banned. @everyone"
								PerformHttpRequest('INPUT LINK HERE', function(err, text, headers) end, 'POST', json.encode({username = identity.firstname.. " " ..identity.name , content = newmessage}), { ['Content-Type'] = 'application/json' })
								vRP.ban({source,"UserID: " ..user_id.. " was banned for modding money. Value: $" ..difference})
							end})
						end
						if kickorban == "kick" then
							vRP.getUserIdentity({user_id, function(identity)
								local newmessage = "UserID: " ..user_id.. " Has received more than "..moddedMoney.." in Cash in <5 seconds. Old Wallet: $" ..useroldmoney[user_id].. " New Wallet: $" ..walletmoney[user_id].. " Value: $" ..difference.. " and was automatically kicked. @everyone"
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
			end	
			useroldmoney[user_id] = walletmoney[user_id]
		end
	end
	if BankCheck == true then
		if useroldbmoney == nil then
			useroldbmoney = bankmoney
		elseif useroldbmoney ~= nil then
			if bankmoney ~= nil and canGiveMoney == false then
				local difference = bankmoney - useroldbmoney
				if useroldbmoney ~= walletmoney then
					if bankmoney > (useroldbmoney + moddedbMoney) then
						print("UserID: " ..user_id.. " Has received more than "..moddedbMoney.." in <5 seconds. Old Bank: " ..useroldbmoney.. " New Bank: " ..bankmoney.. " Value: $" ..difference)
						if useDiscord == true then
							if kickorban == "ban" then
								vRP.getUserIdentity({user_id, function(identity)
									local newmessage = "UserID: " ..user_id.. " Has received more than "..moddedbMoney.." in Bank Money in <5 seconds. Old Wallet: $" ..useroldbmoney.. " New Bank: $" ..bankmoney.. " Value: $" ..difference.. " and was automatically banned. @everyone"
									PerformHttpRequest('INPUT LINK HERE', function(err, text, headers) end, 'POST', json.encode({username = identity.firstname.. " " ..identity.name , content = newmessage}), { ['Content-Type'] = 'application/json' })
									vRP.ban({source,"UserID: " ..user_id.. " was banned for modding money. Value: $" ..difference})
								end})
							end
							if kickorban == "kick" then
								vRP.getUserIdentity({user_id, function(identity)
									local newmessage = "UserID: " ..user_id.. " Has received more than "..moddedbMoney.." in Bank Money in <5 seconds. Old Wallet: $" ..useroldbmoney.. " New Bank: $" ..bankmoney.. " Value: $" ..difference.. " and was automatically kicked. @everyone"
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
				end	
				useroldbmoney = bankmoney
			end
		end
	end
end

RegisterNetEvent("honestycheck")
AddEventHandler("honestycheck", function()
	local source = source
	if source then
		local user_id = vRP.getUserId({source})
		canGiveMoney = vRP.hasPermission({user_id,"player.givemoney"})
		vRPbs.GetMoneyStatus(user_id)
	end
end)