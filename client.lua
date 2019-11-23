-----------------------------------------------------------------------------------------------------------------------------------------
-- Frk👑 - np_hud
-----------------------------------------------------------------------------------------------------------------------------------------

local dir = { [0] = 'N', [90] = 'W', [180] = 'S', [270] = 'E', [360] = 'N'} 

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		local ped = PlayerPedId()
		local ui = GetMinimapAnchor()
		local pos = GetEntityCoords(ped)
		local rua, cross = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
		local zona = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))

		local hora = GetClockHours()
		if hora > 12 then
			hora = hora - 12
			period = "PM"
		else
			period = "AM"
		end
		if hora < 10 then hora = "0" .. hora end
		
		local minuto = GetClockMinutes()
		if minuto < 10 then minuto = "0" .. minuto end

		for k,v in pairs(dir)do
			heading = GetEntityHeading(ped)
			if(math.abs(heading - k) < 45)then
				heading = v
				break
			end
		end

		local hp = GetEntityHealth(ped) / 200.0

		local armour = GetPedArmour(ped) / 100.0
		if armour > 1.0 then armour = 1.0 end

		drawRct(ui.left_x, ui.bottom_y - 0.017, ui.width, 0.028, 0, 0, 0, 255) -- Black background

		drawRct(ui.left_x + 0.001 , ui.bottom_y - 0.015, ui.width - 0.002 , 0.009, 88, 88, 88, 200) -- HP background
		drawRct(ui.left_x + 0.001 , ui.bottom_y - 0.015, (ui.width -0.002) * hp , 0.009, 88, 155, 0, 200) -- HP bar

		drawRct(ui.left_x + 0.001 , ui.bottom_y - 0.002, ui.width - 0.002 , 0.009, 88, 88, 88, 200) -- Armour background
		drawRct(ui.left_x + 0.001 , ui.bottom_y - 0.002, (ui.width - 0.002) * armour , 0.009, 51, 171, 249, 200) -- Armour bar

		if IsPedInAnyVehicle(ped, false) then
			local speed = math.floor(GetEntitySpeed(GetVehiclePedIsIn(ped, false)) * 2.236936)

			DisplayRadar(true) -- Activates minimap
			drawRct(ui.left_x, ui.bottom_y - 0.248 , ui.width, 0.073, 0, 0, 0, 55)
			drawTxt(ui.left_x + 0.001 , ui.bottom_y - 0.249, 0.55, hora .. ":" .. minuto .. " " .. period, 255, 255, 255, 255, 8) -- Clock
			drawTxt(ui.left_x + 0.001 , ui.bottom_y - 0.217 , 0.58, heading, 250, 218, 94, 255, 8) -- Heading
			drawTxt(ui.left_x + 0.023 , ui.bottom_y - 0.216 , 0.3, GetStreetNameFromHashKey(rua), 255, 255, 255, 255, 8) -- Street
			drawTxt(ui.left_x + 0.023 , ui.bottom_y - 0.199 , 0.25, zona, 255, 255, 255, 255, 8) -- Area
			
			drawTxt(ui.left_x + 0.003 , ui.bottom_y - 0.045 , 0.4, speed .. " MPH", 255, 255, 255, 255, 4) -- Speed
			drawRct(ui.left_x, ui.bottom_y - 0.045 , ui.width, 0.073, 0, 0, 0, 55)
		else
			DisplayRadar(false) -- Deactivates minimap
			drawRct(ui.left_x, ui.bottom_y - 0.088 , ui.width, 0.073, 0, 0, 0, 55) -- Background
			drawTxt(ui.left_x + 0.001 , ui.bottom_y - 0.09 , 0.55, hora .. ":" .. minuto .. " " .. period, 255, 255, 255, 255, 8) -- Clock
			drawTxt(ui.left_x + 0.001 , ui.bottom_y - 0.058 , 0.58, heading, 250, 218, 94, 255, 8) -- Heading
			drawTxt(ui.left_x + 0.023 , ui.bottom_y - 0.057 , 0.3, GetStreetNameFromHashKey(rua), 255, 255, 255, 255, 8) -- Street
			drawTxt(ui.left_x + 0.023 , ui.bottom_y - 0.04 , 0.25, zona, 255, 255, 255, 255, 8) -- Area
		end

	end
end)

function drawRct(x,y,width,height,r,g,b,a)
	DrawRect(x+width/2,y+height/2,width,height,r,g,b,a)
end

function drawTxt(x,y,scale,text,r,g,b,a,font)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function disableHud()
	HideHudComponentThisFrame(6)
	HideHudComponentThisFrame(7)	
	HideHudComponentThisFrame(8)	
	HideHudComponentThisFrame(9)
end

function GetMinimapAnchor()
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y
    local Minimap = {}
    Minimap.width = xscale * (res_x / (4 * aspect_ratio))
    Minimap.height = yscale * (res_y / 5.674)
    Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.right_x = Minimap.left_x + Minimap.width
    Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.x = Minimap.left_x
    Minimap.y = Minimap.top_y
    Minimap.xunit = xscale
    Minimap.yunit = yscale
    return Minimap
end