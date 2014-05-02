
SWEP.Author = "[GU]thomasfn"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "PCMod 2"

if (CLIENT) then

	SWEP.PrintName = "Password Cracker"
	
	SWEP.Slot = 5
	SWEP.SlotPos = 3
	
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	
end

if (SERVER) then

	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 5
	
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true

end

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/v_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Snd = {}
SWEP.Snd.Cracked = ""
SWEP.Snd.StartCrack = ""

SWEP.CrackTime = 10 -- seconds
SWEP.CrackEnd = 0
SWEP.Cracking = false
SWEP.CrackChance = 10 -- value:1 chance of success

for k, v in pairs( SWEP.Snd ) do
	if (v != "") then SWEP.Snd[ k ] = Sound( v ) end
end

function SWEP:Think()
	if (CLIENT) then
		self.Cracking = self:GetNWBool( "cracking" )
		return
	end
	if (!self.Cracking) then return end
	local tr = self.Owner:GetEyeTrace()
	if (!self:TraceHitTower( tr )) then
		self:StopCrack()
		return
	end
	local ent = tr.Entity
	if (CurTime() > self.CrackEnd) then
		self:StopCrack()
		math.randomseed( os.time() )
		local cracked = math.random(1, self.CrackChance)
		if (cracked == 1) then
			local pw = PCMod.Data[ ent:EntIndex() ].Password
			if ((!pw) || (pw == "")) then
				self.Owner:PrintMessage( HUD_PRINTTALK, "The tower has no password!" )
			else
				self.Owner:PrintMessage( HUD_PRINTTALK, "The password is: '" .. pw .. "'" )
			end
		else
			self.Owner:PrintMessage( HUD_PRINTTALK, "You failed to crack the password!" )
		end
	end
end

function SWEP:TraceHitTower( tr )
	return ((!tr.HitWorld) && (tr.Entity) && (tr.Entity:IsValid()) && (tr.Entity.IsPCMod) && (tr.Entity.Class == "pcmod_tower") && ((tr.HitPos-self.Owner:GetPos()):Length()<128))
end

function SWEP:Deploy()
	self:StopCrack()
	return true
end

function SWEP:Holster()
	self:StopCrack()
	return true
end

function SWEP:StartCrack( endtime )
	self.CrackEnd = endtime
	self.Cracking = true
	self:SetNWBool( "cracking", true )
end

function SWEP:StopCrack()
	self.CrackEnd = 0
	self.Cracking = false
	self:SetNWBool( "cracking", false )
end

function SWEP:PrimaryAttack()
	if (self:TraceHitTower( self.Owner:GetEyeTrace() )) then self:StartCrack( CurTime() + self.CrackTime ) end
end

function SWEP:DrawHUD()
	if (SERVER) then return end
	
	local w = ScrW()
	local h = ScrH()
	
	// Draw the crosshair
	local tr = self.Owner:GetEyeTrace()
	local sel = false
	if ((tr.HitPos - self.Owner:GetPos()):Length() < 128) then
		if ((!tr.HitWorld) && (tr.Entity) && (tr.Entity:IsValid()) && (tr.Entity.IsPCMod)) then sel = true end
	end		
	local col = Color( 255, 255, 255, 255 )
	if (sel) then col = Color( 255, 0, 0, 255 ) end
	if (self.Cracking) then col = Color( 0, 255, 0, 255 ) end
	surface.SetDrawColor( col.r, col.g, col.b, col.a )
	surface.DrawRect( w * 0.475, h * 0.4975, w * 0.05, h * 0.005 )
	surface.DrawRect( w * 0.4975, h * 0.475, w * 0.005, h * 0.05 )
	
	// Draw the cracking stuff
	if (self.Cracking) then
		// Compile a nice random string
		// local str = self:MakeCrack( 10 )
		surface.SetFont( "ScoreboardHeader" )
		local tw, th = surface.GetTextSize( " CRACKING " )
		// draw.SimpleText( str, "ScoreboardText", w * 0.5, h * 0.5, Color( 255, 255, 255, 255 ), 1, TEXT_ALIGN_TOP )
		local show = ((CurTime()%1) > 0.49 )
		draw.RoundedBox( 6, (w*0.5)-(tw*0.5), h*0.5, tw, th, Color( 50, 50, 50, 255 ) )
		if (show) then draw.SimpleText( "CRACKING", "ScoreboardText", w*0.5, (h*0.5)+(th*0.5), Color( 255, 255, 255, 255 ), 1, 1 ) end
	end
end

function SWEP:PlaySnd( sname )
	local snd = self.Snd[ sname ]
	if ((snd) && (snd != "")) then self:EmitSound( snd ) end
end

function SWEP:GetShootTrace( dist )
	local trace = {}
	trace.startpos = self.Owner:GetShootPos()
	trace.endpos = trace.startpos + (self.Owner:GetAimVector() * dist)
	trace.filter = self.Owner
	return util.TraceLine( trace )
end

function SWEP:MakeCrack( size )
	local strpos = {
		"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
		"1","2","3","4","5","6","7","8","9","0"
	}
	local cnt = 0
	local str = ""
	math.randomseed( os.time() )
	for cnt=1,size do
		str = str .. strpos[ math.random( 1, #strpos ) ]
	end
	return str
end