ESX = nil
maxErrors = 6 -- Change the amount of Errors allowed for the player to pass the driver test, any number above this will result in a failed test


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local options = {
    x = 0.1,
    y = 0.2,
    width = 0.2,
    height = 0.04,
    scale = 0.4,
    font = 0,
    menu_title = "NPC",
    menu_subtitle = "Categories",
    color_r = 0,
    color_g = 128,
    color_b = 255,
}

local dmvped = {
  {type=4, hash=0xc99f21c4, x=239.471, y=-1380.96, z=32.74176, a=3374176},
}

local dmvpedpos = {
	{ ['x'] = 239.471, ['y'] = -1380.96, ['z'] = 33.74176 },
}

--[[Locals]]--

local dmvschool_location = {232.054, -1389.98, 29.4812}

local kmh = 3.6
local VehSpeed = 0

local speed_limit_resi = 50.0
local speed_limit_town = 80.0
local speed_limit_freeway = 120
local speed = kmh

local DTutOpen = false

--[[Events]]--

AddEventHandler("playerSpawned", function()
	ESX.TriggerServerCallback('dmv:LicenseStatus', function(data)
    if (data == "Required") then
            TriggerEvent('dmv:CheckLicStatus')
        end
end)
end)

TestDone = 0

RegisterNetEvent('dmv:CheckLicStatus')
AddEventHandler('dmv:CheckLicStatus', function()
--Check if player has completed theory test
	TestDone = 1
end)

--[[Functions]]--

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function DrawMissionText2(m_text, showtime)
    ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end

function LocalPed()
	return GetPlayerPed(-1)
end

function GetCar() 
	return GetVehiclePedIsIn(GetPlayerPed(-1),false) 
end

function Chat(debugg)
    TriggerEvent("chatMessage", '', { 0, 0x99, 255 }, tostring(debugg))
end

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end

--[[Arrays]]--

onTestEvent = 0
onTtest = 0
testblock = 0
DamageControl = 0
SpeedControl = 0
CruiseControl = 0
Error = 0

function startttest()
        if TestDone == 0 or testblock == 1 then
			DrawMissionText2("~r~Locked", 5000)		
		else
			TriggerServerEvent('dmv:ttcharge')
			openGui()
			Menu.hidden = not Menu.hidden
		end
end

function startptest()
        if  TestDone == 1 then
			DrawMissionText2("~r~Locked", 5000)
		else
		    TriggerServerEvent('dmv:dtcharge')
			onTestBlipp = AddBlipForCoord(255.13990783691,-1400.7319335938,30.5374584198)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
		    onTestEvent = 1
			DamageControl = 1
			SpeedControl = 1
			onTtest = 3
			DTut()
		end
end

function EndDTest()
        if Error >= maxErrors then
			drawNotification("You failed\nYou accumulated ".. Error.." ~r~Error Points")
			EndTestTasks()
		else
			TriggerServerEvent('dmv:successconduite')
			drawNotification("You passed\nYou accumulated ".. Error.." ~r~Error Points")
			EndTestTasks()
		end
end

function EndTestTasks()
		onTestBlipp = nil
		onTestEvent = 0
		DamageControl = 0
		Error = 0
		TaskLeaveVehicle(GetPlayerPed(-1), veh, 0)
		Wait(1000)
		CarTargetForLock = GetPlayersLastVehicle(GetPlayerPed(-1))
		lockStatus = GetVehicleDoorLockStatus(CarTargetForLock)
		SetVehicleDoorsLocked(CarTargetForLock, 2)
		SetVehicleDoorsLockedForPlayer(CarTargetForLock, PlayerId(), false)
		SetEntityAsMissionEntity(CarTargetForLock, true, true)
		Wait(2000)
		Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( CarTargetForLock ) )
		

end


function SpawnTestCar()
	Citizen.Wait(0)
	local myPed = GetPlayerPed(-1)
	local player = PlayerId()
	local vehicle = GetHashKey('blista')

    RequestModel(vehicle)

while not HasModelLoaded(vehicle) do
	Wait(1)
end
colors = table.pack(GetVehicleColours(veh))
extra_colors = table.pack(GetVehicleExtraColours(veh))
plate = math.random(100, 900)
local spawned_car = CreateVehicle(vehicle, 249.40971374512,-1407.2303466797,30.409454345703, true, false)
SetVehicleColours(spawned_car,4,5)
SetVehicleExtraColours(spawned_car,extra_colors[1],extra_colors[2])
SetEntityHeading(spawned_car, 317.64)
SetVehicleOnGroundProperly(spawned_car)
SetPedIntoVehicle(myPed, spawned_car, - 1)
SetModelAsNoLongerNeeded(vehicle)
Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(spawned_car))
CruiseControl = 0
DTutOpen = false
SetEntityVisible(myPed, true)
SetVehicleDoorsLocked(GetCar(), 4)
FreezeEntityPosition(myPed, false)
end

function DTut()
	Citizen.Wait(0)
	local myPed = GetPlayerPed(-1)
	DTutOpen = true
		SetEntityCoords(myPed,238.70791625977, -1394.7208251953, -1394.7208251953,true, false, false,true)
	    SetEntityHeading(myPed, 314.39)
		TriggerEvent("pNotify:SendNotification",{
            text = "<b style='color:#1E90FF'>DMV Instructor:</b> <br /><br /> We are currently preparing your vehicle for the test, meanwhile you should read a few important lines.<br /><br /><b style='color:#87CEFA'>Speed limit:</b><br />- Pay attention to the traffic, and stay under the <b style='color:#A52A2A'>speed</b> limit<br /><br />- By now, you should know the basics, however we will try to remind you whenever you <b style='color:#DAA520'>enter/exit</b> an area with a posted speed limit",
            type = "alert",
            timeout = (15000),
            layout = "center",
            queue = "global"
        })
		Citizen.Wait(16500)
		TriggerEvent("pNotify:SendNotification",{
            text = "<b style='color:#1E90FF'>DMV Instructor:</b> <br /><br /> Use the <b style='color:#DAA520'>Cruise Control</b> feature to avoid <b style='color:#87CEFA'>speeding</b>, activate this during the test by pressing the <b style='color:#20B2AA'>X</b> button on your keyboard.<br /><br /><b style='color:#87CEFA'>Evaluation:</b><br />- Try not to crash the vehicle or go over the posted speed limit. You will receive <b style='color:#A52A2A'>Error Points</b> whenever you fail to follow these rules<br /><br />- Too many <b style='color:#A52A2A'>Error Points</b> accumulated will result in a <b style='color:#A52A2A'>Failed</b> test",
            type = "alert",
            timeout = (15000),
            layout = "center",
            queue = "global"
        })
		Citizen.Wait(16500)
		SpawnTestCar()
		DTutOpen = false
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local veh = GetVehiclePedIsUsing(GetPlayerPed(-1))
		local ped = GetPlayerPed(-1)
		if HasEntityCollidedWithAnything(veh) and DamageControl == 1 then
		TriggerEvent("pNotify:SendNotification",{
            text = "The vehicle was <b style='color:#B22222'>damaged!</b><br /><br />Watch it!",
            type = "alert",
            timeout = (2000),
            layout = "bottomCenter",
            queue = "global"
        })			
			Citizen.Wait(1000)
			Error = Error + 1	
		elseif(IsControlJustReleased(1, 23)) and DamageControl == 1 then
			drawNotification("You cannot leave the vehicle during the test")
    	end
		
	if onTestEvent == 1 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), 255.13990783691,-1400.7319335938,29.5374584198, true) > 4.0001 then
		   DrawMarker(1,255.13990783691,-1400.7319335938,29.5374584198,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(271.8747253418,-1370.5744628906,31.932783126831)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
		    DrawMissionText2("Head to the next point !", 5000)
			onTestEvent = 2
		end
	end
	
	if onTestEvent == 2 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),271.8747253418,-1370.5744628906,30.932783126831, true) > 4.0001 then
		   DrawMarker(1,271.8747253418,-1370.5744628906,30.932783126831,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(234.90780639648,-1345.3854980469, 30.542045593262)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
		    DrawMissionText2("Head over to the next point!", 5000)
			onTestEvent = 3		
		end
	end
	
	if onTestEvent == 3 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),234.90780639648,-1345.3854980469, 29.542045593262, true) > 4.0001 then
		   DrawMarker(1,234.90780639648,-1345.3854980469, 29.542045593262,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(217.82102966309,-1410.5201416016,29.292112350464)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
		    DrawMissionText2("Make a quick ~r~stop~s~ for pedastrian ~y~crossing", 5000)
			PlaySound(-1, "RACE_PLACED", "HUD_AWARDS", 0, 0, 1)
			FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)), true) -- Freeze Entity
			Citizen.Wait(4000)
			FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)), false) -- Freeze Entity
			DrawMissionText2("~g~Great!~s~ lets keep moving!", 5000)
			onTestEvent = 4
		end
	end	
	
		if onTestEvent == 4 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),217.82102966309,-1410.5201416016,28.292112350464, true) > 4.0001 then
		   DrawMarker(1,217.82102966309,-1410.5201416016,28.292112350464,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(178.55052185059,-1401.7551269531,28.725154876709)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
		    DrawMissionText2("Do a quick ~r~stop~s~ and watch your ~y~LEFT~s~ before entering traffic", 5000)
			PlaySound(-1, "RACE_PLACED", "HUD_AWARDS", 0, 0, 1)
			FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)), true) -- Freeze Entity
			Citizen.Wait(6000)
			FreezeEntityPosition(GetVehiclePedIsUsing(GetPlayerPed(-1)), false) -- Freeze Entity
			DrawMissionText2("~g~Great!~s~ now take a ~y~RIGHT~s~ and pick your lane", 5000)
			drawNotification("Area: ~y~Town\n~s~Speed limit: ~y~80 km/h\n~s~Error Points: ~y~".. Error.."/4")
			SpeedControl = 2
			onTestEvent = 5
			Citizen.Wait(4000)
		end
	end	
	
		if onTestEvent == 5 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),178.55052185059,-1401.7551269531,27.725154876709, true) > 4.0001 then
		   DrawMarker(1,178.55052185059,-1401.7551269531,27.725154876709,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(113.16044616699,-1365.2762451172,28.725179672241)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
		    DrawMissionText2("Watch the traffic ~y~lights~s~ !", 5000)
			onTestEvent = 6
		end
	end	

		if onTestEvent == 6 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),113.16044616699,-1365.2762451172,27.725179672241, true) > 4.0001 then
		   DrawMarker(1,113.16044616699,-1365.2762451172,27.725179672241,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(-73.542953491211,-1364.3355712891,27.789325714111)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
			onTestEvent = 7
		end
	end		
		
	
		if onTestEvent == 7 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),-73.542953491211,-1364.3355712891,27.789325714111, true) > 4.0001 then
		   DrawMarker(1,-73.542953491211,-1364.3355712891,27.789325714111,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(-355.14373779297,-1420.2822265625,27.868143081665)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
		    DrawMissionText2("Make sure to stop for passing vehicles !", 5000)
			onTestEvent = 8
		end
	end			
	
		if onTestEvent == 8 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),-355.14373779297,-1420.2822265625,27.868143081665, true) > 4.0001 then
		   DrawMarker(1,-355.14373779297,-1420.2822265625,27.868143081665,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(-439.14846801758,-1417.1004638672,27.704095840454)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
			onTestEvent = 9
		end
	end			
	
		if onTestEvent == 9 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),-439.14846801758,-1417.1004638672,27.704095840454, true) > 4.0001 then
		   DrawMarker(1,-439.14846801758,-1417.1004638672,27.704095840454,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(-453.79092407227,-1444.7265625,27.665870666504)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
			onTestEvent = 10
		end
	end		

		if onTestEvent == 10 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),-453.79092407227,-1444.7265625,27.665870666504, true) > 4.0001 then
		   DrawMarker(1,-453.79092407227,-1444.7265625,27.665870666504,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(-463.23712158203,-1592.1785888672,37.519771575928)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
		    DrawMissionText2("Time to hit the road, watch your speed and dont crash !", 5000)
			PlaySound(-1, "RACE_PLACED", "HUD_AWARDS", 0, 0, 1)
			drawNotification("Area: ~y~Freeway\n~s~Speed limit: ~y~120 km/h\n~s~Error Points: ~y~".. Error.."/4")
			onTestEvent = 11
			SpeedControl = 3
			Citizen.Wait(4000)
		end
	end		

		if onTestEvent == 11 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),-463.23712158203,-1592.1785888672,37.519771575928, true) > 4.0001 then
		   DrawMarker(1,-463.23712158203,-1592.1785888672,37.519771575928,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(-900.64721679688,-1986.2814941406,26.109502792358)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
			onTestEvent = 12
		end
	end
	
		if onTestEvent == 12 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),-900.64721679688,-1986.2814941406,26.109502792358, true) > 4.0001 then
		   DrawMarker(1,-900.64721679688,-1986.2814941406,26.109502792358,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(1225.7598876953,-1948.7922363281,38.718940734863)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
			onTestEvent = 13
		end
	end	
	
		if onTestEvent == 13 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),1225.7598876953,-1948.7922363281,38.718940734863, true) > 4.0001 then
		   DrawMarker(1,1225.7598876953,-1948.7922363281,38.718940734863,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(209.54621887207,-1412.8677978516,29.652387619019)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
			onTestEvent = 14
		end
	end	
	
		if onTestEvent == 14 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),1225.7598876953,-1948.7922363281,38.718940734863, true) > 4.0001 then
		   DrawMarker(1,1225.7598876953,-1948.7922363281,38.718940734863,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(1163.6030273438,-1841.7713623047,35.679168701172)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
			DrawMissionText2("Entering town, watch your speed!", 5000)
			drawNotification("~r~Slow down!\n~s~Area: ~y~Town\n~s~Speed limit: ~y~80 km/h\n~s~Error Points: ~y~".. Error.."/4")
			onTestEvent = 15
		end
	end		
	
		if onTestEvent == 15 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),1163.6030273438,-1841.7713623047,35.679168701172, true) > 4.0001 then
		   DrawMarker(1,1163.6030273438,-1841.7713623047,35.679168701172,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			onTestBlipp = AddBlipForCoord(235.28327941895,-1398.3292236328,28.921098709106)
			N_0x80ead8e2e1d5d52e(onTestBlipp)
			SetBlipRoute(onTestBlipp, 1)
			PlaySound(-1, "RACE_PLACED", "HUD_AWARDS", 0, 0, 1)
		    DrawMissionText2("Good job, now lets head back!", 5000)
			drawNotification("Area: ~y~Town\n~s~Speed limit: ~y~80 km/h\n~s~Error Points: ~y~".. Error.."/4")
			SpeedControl = 2
			onTestEvent = 16
		end
	end		

		if onTestEvent == 16 then
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),235.28327941895,-1398.3292236328,28.921098709106, true) > 4.0001 then
		   DrawMarker(1,235.28327941895,-1398.3292236328,28.921098709106,0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
		else
		    if onTestBlipp ~= nil and DoesBlipExist(onTestBlipp) then
				Citizen.InvokeNative(0x86A652570E5F25DD,Citizen.PointerValueIntInitialized(onTestBlipp))
		    end
			EndDTest()
		end
	end		
end
end)

----Theory Test NUI Operator

-- ***************** Open Gui and Focus NUI
function openGui()
  onTtest = 1
  SetNuiFocus(true)
  SendNUIMessage({openQuestion = true})
end

-- ***************** Close Gui and disable NUI
function closeGui()
  SetNuiFocus(false)
  SendNUIMessage({openQuestion = false})
end

-- ***************** Disable controls while GUI open
Citizen.CreateThread(function()
  while true do
    if onTtest == 1 then
      local ply = GetPlayerPed(-1)
      local active = true
      DisableControlAction(0, 1, active) -- LookLeftRight
      DisableControlAction(0, 2, active) -- LookUpDown
      DisablePlayerFiring(ply, true) -- Disable weapon firing
      DisableControlAction(0, 142, active) -- MeleeAttackAlternate
      DisableControlAction(0, 106, active) -- VehicleMouseControlOverride
      if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
        SendNUIMessage({type = "click"})
      end
    end
    Citizen.Wait(0)
  end
end)

-- ***************** NUI Callback Methods
-- Callbacks pages opening
RegisterNUICallback('question', function(data, cb)
  SendNUIMessage({openSection = "question"})
  cb('ok')
end)

-- Callback actions triggering server events
RegisterNUICallback('close', function(data, cb)
  closeGui()
  cb('ok')
  TriggerServerEvent('dmv:success')
  DrawMissionText2("~b~Test passed, you can now proceed to the driving test", 2000)	
  TestDone = 0
  onTtest = 3
end)

RegisterNUICallback('kick', function(data, cb)
    closeGui()
    cb('ok')
    DrawMissionText2("~r~You failed the test, you might try again another day", 2000)	
    onTtest = 0
	testblock = 1
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if(IsPedInAnyVehicle(GetPlayerPed(-1), false)) and TestDone == 1 and onTtest == 0 then
		DrawMissionText2("~r~You are driving without a license", 2000)			
		end
	end
end)


local speedLimit = 0
Citizen.CreateThread( function()
    while true do 
        Citizen.Wait( 0 )   
        local ped = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local vehicleModel = GetEntityModel(vehicle)
        local speed = GetEntitySpeed(vehicle)
        local inVehicle = IsPedSittingInAnyVehicle(ped)
        local float Max = GetVehicleMaxSpeed(vehicleModel)
        if ( ped and inVehicle and DamageControl == 1 ) then
            if IsControlJustPressed(1, 73) then
                if (GetPedInVehicleSeat(vehicle, -1) == ped) then
                    if CruiseControl == 0 then
                        speedLimit = speed
                        SetEntityMaxSpeed(vehicle, speedLimit)
						drawNotification("~y~Cruise Control: ~g~enabled\n~s~MAX speed ".. math.floor(speedLimit*3.6).."kmh")
						Citizen.Wait(1000)
				        DisplayHelpText("Adjust your max speed with ~INPUT_CELLPHONE_UP~ ~INPUT_CELLPHONE_DOWN~ controls")
						PlaySound(-1, "COLLECTED", "HUD_AWARDS", 0, 0, 1)
                        CruiseControl = 1
                    else
                        SetEntityMaxSpeed(vehicle, Max)
						drawNotification("~y~Cruise Control: ~r~disabled")						
                        CruiseControl = 0
                    end
                else
				    drawNotification("You need to be driving to preform this action")						
                end
            elseif IsControlJustPressed(1, 27) then
                if CruiseControl == 1 then
                    speedLimit = speedLimit + 0.45
                    SetEntityMaxSpeed(vehicle, speedLimit)
					PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
					DisplayHelpText("Max speed adjusted to ".. math.floor(speedLimit*3.6).. "kmh")
                end
            elseif IsControlJustPressed(1, 173) then
                if CruiseControl == 1 then
                    speedLimit = speedLimit - 0.45
                    SetEntityMaxSpeed(vehicle, speedLimit)
					PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)	
					DisplayHelpText("Max speed adjusted to ".. math.floor(speedLimit*3.6).. "kmh")
                end
            end
        end
    end
end)

----Theory Test NUI Operator

-- ***************** Open Gui and Focus NUI
function openGui()
  onTtest = 1
  SetNuiFocus(true)
  SendNUIMessage({openQuestion = true})
end

-- ***************** Close Gui and disable NUI
function closeGui()
  SetNuiFocus(false)
  SendNUIMessage({openQuestion = false})
end

-- ***************** Disable controls while GUI open
Citizen.CreateThread(function()
  while true do
    if onTtest == 1 then
      local ply = GetPlayerPed(-1)
      local active = true
      DisableControlAction(0, 1, active) -- LookLeftRight
      DisableControlAction(0, 2, active) -- LookUpDown
      DisablePlayerFiring(ply, true) -- Disable weapon firing
      DisableControlAction(0, 142, active) -- MeleeAttackAlternate
      DisableControlAction(0, 106, active) -- VehicleMouseControlOverride
      if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
        SendNUIMessage({type = "click"})
      end
    end
    Citizen.Wait(0)
  end
end)

Citizen.CreateThread(function()
  while true do
    if DTutOpen then
      local ply = GetPlayerPed(-1)
      local active = true
	  SetEntityVisible(ply, false)
	  FreezeEntityPosition(ply, true)
      DisableControlAction(0, 1, active) -- LookLeftRight
      DisableControlAction(0, 2, active) -- LookUpDown
      DisablePlayerFiring(ply, true) -- Disable weapon firing
      DisableControlAction(0, 142, active) -- MeleeAttackAlternate
      DisableControlAction(0, 106, active) -- VehicleMouseControlOverride
    end
    Citizen.Wait(0)
  end
end)


-- ***************** NUI Callback Methods
-- Callbacks pages opening
RegisterNUICallback('question', function(data, cb)
  SendNUIMessage({openSection = "question"})
  cb('ok')
end)

-- Callback actions triggering server events
RegisterNUICallback('close', function(data, cb)
  -- if question success
  closeGui()
  cb('ok')
  TriggerServerEvent('dmv:success')
  DrawMissionText2("~b~Test passed, you can now proceed to the driving test", 2000)	
  TestDone = 0
  onTtest = 3
end)

RegisterNUICallback('kick', function(data, cb)
    closeGui()
    cb('ok')
    DrawMissionText2("~r~You failed the test, you might try again another day", 2000)	
    onTtest = 0
	testblock = 1
end)

---------------------------------- DMV PED ----------------------------------

Citizen.CreateThread(function()

  RequestModel(GetHashKey("a_m_y_business_01"))
  while not HasModelLoaded(GetHashKey("a_m_y_business_01")) do
    Wait(1)
  end

  RequestAnimDict("mini@strip_club@idles@bouncer@base")
  while not HasAnimDictLoaded("mini@strip_club@idles@bouncer@base") do
    Wait(1)
  end

 	    -- Spawn the DMV Ped
  for _, item in pairs(dmvped) do
    dmvmainped =  CreatePed(item.type, item.hash, item.x, item.y, item.z, item.a, false, true)
    SetEntityHeading(dmvmainped, 137.71)
    FreezeEntityPosition(dmvmainped, true)
	SetEntityInvincible(dmvmainped, true)
	SetBlockingOfNonTemporaryEvents(dmvmainped, true)
    TaskPlayAnim(dmvmainped,"mini@strip_club@idles@bouncer@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    end
end)

local talktodmvped = true
--DMV Ped interaction
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local pos = GetEntityCoords(GetPlayerPed(-1), false)
		for k,v in ipairs(dmvpedpos) do
			if(Vdist(v.x, v.y, v.z, pos.x, pos.y, pos.z) < 1.0)then
				DisplayHelpText("Press ~INPUT_CONTEXT~ to interact with ~y~NPC")
				if(IsControlJustReleased(1, 38))then
						if talktodmvped then
						    Notify("~b~Welcome to the ~h~DMV School!")
						    Citizen.Wait(500)
							DMVMenu()
							Menu.hidden = false
							talktodmvped = false
						else
							talktodmvped = true
						end
				end
				Menu.renderGUI(options)
			end
		end
	end
end)

------------
------------ DRAW MENUS
------------
function DMVMenu()
	ClearMenu()
    options.menu_title = "DMV School"
	Menu.addButton("Obtain a drivers license","VehLicenseMenu",nil)
    Menu.addButton("Close","CloseMenu",nil) 
end

function VehLicenseMenu()
    ClearMenu()
    options.menu_title = "Vehicle License"
	Menu.addButton("Theory test    200$","startttest",nil)
	Menu.addButton("Practical test    500$","startptest",nil)
    Menu.addButton("Return","DMVMenu",nil) 
end

function CloseMenu()
		Menu.hidden = true
end

function Notify(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, false)
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(true, true)
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

----------------
----------------blip
----------------



Citizen.CreateThread(function()
	pos = dmvschool_location
	local blip = AddBlipForCoord(pos[1],pos[2],pos[3])
	SetBlipSprite(blip,408)
	SetBlipColour(blip,11)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('DMV School')
	EndTextCommandSetBlipName(blip)
	SetBlipAsShortRange(blip,true)
	SetBlipAsMissionCreatorBlip(blip,true)
end)