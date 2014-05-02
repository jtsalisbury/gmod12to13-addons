
SWEP.PrintName = "Network Tester"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Author = "thomasfn"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to select source ent, left click again to select dest ent and send"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.WorldModel = "models/weapons/w_hands.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Deploy()
	if (SERVER) then self:SetMode( self.Mode ) end
	return true
end

function SWEP:Holster()
	return true
end

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	SWEP.Modes = {
		"Test Packet Delivery"
	}
	SWEP.Mode = 1

	function SWEP:Reload()
		self.EntA = nil
	end
	
	function SWEP:SetMode( id )
		if ((id < 1) || (id > #self.Modes)) then id = 1 end
		self.Mode = id
		self:SetNWString( "mode", self.Modes[ id ] )
	end
	
	function SWEP:SecondaryAttack()
		self:SetMode( self.Mode + 1 )
	end
	
	function SWEP:PrimaryAttack()
		local ent = self.Owner:GetEyeTrace().Entity
		if (!self.EntA) then
			if ((ent) && (ent:IsValid())) then
				self.EntA = ent
				self:Say( "(A) Entity " .. ent:EntIndex() .. " selected!" )
			end
			return
		end
		if ((!ent) || (!ent:IsValid())) then return end
		self:Say( "(B) Entity " .. ent:EntIndex() .. " selected!" )
		self:DoStuff( self.EntA, ent )
		self.EntA = nil
	end
	
	function SWEP:DoStuff( enta, entb )
		local md = self.Mode
		if (md == 1) then
			self:Say( "Attempting to send net packet..." )
			local pts = enta:Ports()
			for k, v in pairs( pts ) do
				if ((v.Type == "network") || (v.Type == "optic")) then
					self:Say( "Sending net packet..." )
					enta:SendPacket( k, entb:GetFullIP(), 0, { "netPing_DEBUG", self.Weapon } )
				end
			end
		
		end
	end
	
	function SWEP:Say( txt )
		self.Owner:PrintMessage( HUD_PRINTTALK, txt )
	end
	
end

if (CLIENT) then

	function SWEP:DrawHUD()
		local txt = self:GetNWString( "mode" )
		surface.SetFont( "ScoreboardText" )
		local tw, th = surface.GetTextSize( txt )
		tw = tw + 5
		th = th + 2
		surface.SetDrawColor( 50, 50, 50, 200 )
		surface.DrawRect( ScrW()-tw, 0, tw, th )
		surface.DrawOutline( ScrW()-tw, 0, tw, th, Color( 0, 0, 0, 255 ) )
		draw.SimpleText( txt, "ScoreboardText", ScrW()-(tw*0.5), th*0.5, Color( 255, 255, 255, 255 ), 1, 1 )
	end

end