-- Check client honesty
Citizen.CreateThread(function()
    while true do
      Citizen.Wait(5000) 
	  TriggerServerEvent("honestycheck")
    end
end)
