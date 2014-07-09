if SERVER then return end

-- Sinwe have no way of telling how much ammo is in a clip in a weapon,
-- we'll have to monitor and store the maxiums.
-- Thanks zyklus for this idea!
local weaponclips = {}

local cctv = CreateClientConVar( "cctv", "0", false, false ) // On/Off
local cctv_num = CreateClientConVar( "cctv_num", "2", false, false )
local cctv_time = CreateClientConVar( "cctv_time", "10", false, false )
local cctv_hud = CreateClientConVar( "cctv_hud", "1", false, false )
local cctv_offset = CreateClientConVar( "cctv_offset", "0", false, false )

local function playerAngles( ply )
	local ang = ply:EyeAngles()
	if ply == LocalPlayer() and ply:InVehicle() then
		ang.yaw = math.NormalizeAngle( ang.yaw + ply:GetVehicle():GetAngles().yaw )
	end
	return ang
end

local function drawLocalPlayer( curnum, num ) -- TODO: Implement args
	local w = 1/num * ScrW() -- Width of each square
	local h = 1/num * ScrH() -- Height of each square

	local len = 8 -- Length of line
	local offset = 4 -- Offset from center
	surface.SetDrawColor( 0, 255, 0, 128 )
	surface.DrawRect( w / 2 - len - offset, h / 2 - 1, len, 2 )
	surface.DrawRect( w / 2 + offset, h / 2 - 1, len, 2 )
	surface.DrawRect( w / 2 - 1, h / 2 - len - offset, 2, len ) -- We're using w not h so it's the same length
	surface.DrawRect( w / 2 - 1, h / 2 + offset, 2, len )
end

local function drawPlayer( ply, curnum, num )
	local w = 1/num * ScrW() -- Width of each square
	local h = 1/num * ScrH() -- Height of each square

	local mulx = math.fmod( curnum-1, num )
	local muly = math.floor( (curnum-1) / num ) -- Make rows

	ply:SetNoDraw( true )

	local cam = {}
	cam.angles = playerAngles( ply )
	cam.origin = ply:GetShootPos()
	cam.x = mulx * w
	cam.y = muly * h
	cam.w = w
	cam.h = h
	render.RenderView( cam )

	ply:SetNoDraw( false )
	
	draw.SimpleText( ply:Nick(), "Default", w * mulx + w * 0.5, h * muly + h * 0.05, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        if cctv_hud:GetBool() then
        	local txt = "HP: " .. ply:Health()
        	if ply:Armor() > 0 then
        		txt = txt .. " AP: " .. ply:Armor()
        	end
		draw.WordBox( 4, w * mulx + 10, h * muly + h - 30, txt, "DefaultSmall", Color( 50, 50, 75, 200 ), Color( 255, 255, 255, 255 ) )

		if ply:GetActiveWeapon():IsValid() then
			local wepclass = ply:GetActiveWeapon():GetClass()
			-- If the variable doesn't exist, then initialize it
			if not weaponclips[ wepclass ] then
				weaponclips[ wepclass ] = -1
			end			

			local txt
			local c1 = ply:GetActiveWeapon():Clip1()
			local c2 = ply:GetActiveWeapon():Clip2()
			
			if c1 == -1 and ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() ) > 0 then
				c1 = ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() )
			end
			
			if weaponclips[ wepclass ] < c1 then
				weaponclips[ wepclass ] = c1
			end
			
			if c2 == -1 and ply:GetAmmoCount( ply:GetActiveWeapon():GetSecondaryAmmoType() ) > 0 then
				c2 = ply:GetAmmoCount( ply:GetActiveWeapon():GetSecondaryAmmoType() )
			end

			if c1 == -1 and c2 == -1 then
				txt = "N/A"
			elseif c2 == -1 then
				txt = c1 .. "/" .. weaponclips[ wepclass ]
			elseif c1 == -1 then
				txt = tostring( c2 )
			else
				txt = c1 .. "/" .. weaponclips[ wepclass ] .. "  " .. c2
			end
			draw.WordBox( 4, w * mulx + w - 83, h * muly + h - 30, "Ammo: " .. txt, "DefaultSmall", Color( 50, 50, 75, 200 ), Color( 255, 255, 255, 255 ) )
		end
	end
end

local function hudPaint()
	if not cctv:GetBool() or not LocalPlayer():IsAdmin() then return end

	local num = cctv_num:GetInt() -- Num of squares on each side
	local totalnum = num * num
	local curnum = 1 -- Current square we're working with
	local startoff = 0 -- Offset, used if we don't have enough room
	local curplayer = 1 -- Current player we're working with (need so we can skip over inactive players)
	local w = 1/num * ScrW() -- Width of each square
	local h = 1/num * ScrH() -- Height of each square
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( 0, 0, ScrW(), ScrH() )

	if totalnum > 1 then -- If we have more than one panel, lock local player in top left.
		drawPlayer( LocalPlayer(), 1, num )
		drawLocalPlayer( 1, num )

		curnum = curnum + 1
	end
	
	local players = player.GetAll()
	local iplayers = #players - #team.GetPlayers( TEAM_CONNECTING ) -- Total active players
	if totalnum > 1 then
		iplayers = iplayers - 1 -- Since we drew local player already
	end

	if totalnum - 1 < iplayers then -- If we have less room than players
		startoff = iplayers - math.floor( math.fmod( CurTime() / cctv_time:GetFloat(), iplayers ) ) -- Count backwards, cycle through players.
	end
	
	if cctv_offset:GetInt() > 0 then
		startoff = iplayers - math.fmod( cctv_offset:GetInt(), iplayers )
	end

	while true do -- Have break inside
		local i = math.fmod( startoff + curplayer - 1, #players ) + 1

		if curnum > iplayers + 1 or curnum > totalnum then break end -- Already done this player or already too far

		local ply = players[ i ]
		if not ply or not ply:IsValid() then break end -- Inactive player!

		if ply:Team() ~= TEAM_CONNECTING and (ply ~= LocalPlayer() or totalnum <= 1) then -- Bad team or skip local player
			drawPlayer( ply, curnum, num )
			
			curnum = curnum + 1
		end
		curplayer = curplayer + 1
	end

	-- Now draw lines between them. I realize we could just shrink the original render, but I prefer this method.
	local lines = num -1

	for i=1, lines do
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 0, h * i - 1, ScrW(), 2 )
	end

	for i=1, lines do
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( w * i - 1, 0, 2, ScrH() )
	end
end
hook.Add( "HUDPaint", "PaintCCTV", hudPaint )

local shoulddrawtable =
{
	["CHudAmmo"] = false,
	["CHudHealth"] = false,
	["CHudBattery"] = false,
	["CHudSecondaryAmmo"] = false,
}

function hideDefaultHUD( element )
	if not cctv:GetBool() or not LocalPlayer():IsAdmin() then return end

	return shoulddrawtable[ element ]
end
hook.Add( "HUDShouldDraw", "hideDefaultHUD", hideDefaultHUD )

-- Hook the Tab to the Spawn Menu
hook.Add( "AddToolMenuTabs", "Unique_Name", function()
	spawnmenu.AddToolTab( "UccTV", "UccTV Controls", "icon16/wrench.png" )
	spawnmenu.AddToolMenuOption("UccTV", "Settings", "Controls", "Controls", "", "", function(panel)
		panel:AddControl("Header", { Text = "UccTV Settings" })
		
		panel:AddControl( "CheckBox", {
			Label = "Enable",
			Command = "cctv",
		})
		
		panel:AddControl( "CheckBox", {
			Label = "Show HUD",
			Description = "Show HUDs for players",
			Command = "cctv_hud",
		})
		
		panel:AddControl( "Slider", {
			Label = "Number of screens (squared)",
			Description = "Number of screens on the edge",
			Command = "cctv_num",
			Type = "Integer",
			Min = 1,
			Max = 8,
		})
		
		panel:AddControl( "Slider", {
			Label = "Screen offset",
			Description = "To lock a view when squares < players. 0 = Disable.",
			Command = "cctv_offset",
			Type = "Integer",
			Min = 0,
			Max = 64,
		})
		
		panel:AddControl( "Slider", {
			Label = "Rotation time",
			Description = "Time it takes to rotate views when squares < players",
			Command = "cctv_time",
			Type = "Float",
			Min = 0,
			Max = 30,
		})
	end)
	
end)