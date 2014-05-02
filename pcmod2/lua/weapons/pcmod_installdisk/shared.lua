
SWEP.PrintName = "Install Disk"

SWEP.Author = "[GU]thomasfn"
SWEP.Contact = "Don't."
SWEP.Category = "PCMod 2"
SWEP.Purpose = "To install programs onto a PC."
SWEP.Instructions = "Left click a PC to install program onto. Right click to change program."

if (CLIENT) then
	
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	
end

if (SERVER) then

	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 5
	
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = false

end

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/v_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.HoldType = "pistol"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.SoundEffect = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.SoundEffect = ""

if (SWEP.Primary.SoundEffect != "") then SWEP.Primary.SoundEffect = Sound( SWEP.Primary.SoundEffect ) end
if (SWEP.Secondary.SoundEffect != "") then SWEP.Secondary.SoundEffect = Sound( SWEP.Secondary.SoundEffect ) end

SWEP.Programs = {}
SWEP.ProgCnt = 0
SWEP.SelProg = 0
SWEP.PackName = ""

SWEP.LabelPos = 0
SWEP.ZipRat = 0.25

if (SERVER) then

	function SWEP:Initialize()
		self:SetWeaponHoldType( self.HoldType )
	end
	
end

function SWEP:Reset()
	self.Programs = {}
	self.ProgCnt = 0
	self:SetNWInt( "progs", 0 )
	self:SetNWInt( "selprog", 0 )
	self:SetPackName( "Install Disk" )
end

function SWEP:AddProgram( progname, nicename, osid )
	if (CLIENT) then return end
	local id = self.ProgCnt + 1
	self.ProgCnt = id
	self:SetNWInt( "progs", id )
	self:SetNWString( "prog_" .. tostring( id ), nicename )
	self:SetNWString( "prog_" .. tostring( id ) .. "_os", osid )
	self.Programs[ id ] = progname
	if (self.SelProg == 0) then self.SelProg = 1 end
	self:SetNWInt( "selprog", self.SelProg )
end

function SWEP:SetPackName( name )
	self:SetNWString( "packname", name )
end

function SWEP:Think()
	if (SERVER) then return end
	self.ProgCnt = self:GetNWInt( "progs" )
	if (self.ProgCnt == 0) then
		self.SelProg = 0
		return
	end
	self.SelProg = self:GetNWInt( "selprog" )
	local cnt
	for cnt=1, self.ProgCnt do
		local id = "prog_" .. tostring( cnt )
		self.Programs[ cnt ] = { self:GetNWString( id ), self:GetNWString( id .. "_os" ) }
	end
	if ((self.SelProg < 1) || (self.SelProg > self.ProgCnt)) then self.SelProg = 1 end
	self.PackName = self:GetNWString( "packname" )
	if (self.LabelPos != self.SelProg) then
		self.LabelPos = math.Mid( self.LabelPos, self.SelProg, self.ZipRat )
		if ((self.LabelPos > (self.SelProg-0.1)) && (self.LabelPos < (self.SelProg+0.1))) then self.LabelPos = self.SelProg end
	end
end

function SWEP:PrimaryAttack()
	local tr = self.Owner:GetEyeTrace()
	if ((tr.HitPos - self.Owner:GetPos()):Length() > 128) then return end
	local ent = tr.Entity
	if ((tr.HitWorld) || (!ent) || (!ent:IsValid())) then
		if (CLIENT) then PCMod.Notice( "You must be looking at an object!" ) end
		return
	end
	if ((!ent.IsPCMod) || ((ent.Class != "pcmod_tower") && (ent.Class != "pcmod_laptop"))) then
		if (CLIENT) then PCMod.Notice( "You must be looking at a PC Tower!" ) end
		return
	end
	if (CLIENT) then return true end -- Client stops here
	local prog = self.Programs[ self.SelProg ]
	if ((!prog) || (prog == "")) then
		PCMod.Notice( "No selected program!", self.Owner )
		return
	end
	local result = ent:InstallProgram( prog )
	if (type(result) == "string") then
		PCMod.Notice( result, self.Owner )
		return
	end
	self.Owner:SendLua( "PCMod.Gui.FlashIcon( \"gui/icons/ico_app\", 1 );" )
	local snd = self.Primary.SoundEffect
	if ((snd) && (snd != "")) then self:EmitSound( snd ) end
end

function SWEP:SecondaryAttack()
	if (CLIENT) then return end
	
	self.SelProg = self.SelProg + 1
	if ((self.SelProg < 1) || (self.SelProg > self.ProgCnt)) then self.SelProg = 1 end
	self:SetNWInt( "selprog", self.SelProg )
	local snd = self.Secondary.SoundEffect
	if ((snd) && (snd != "")) then self:EmitSound( snd ) end
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
	surface.SetDrawColor( col.r, col.g, col.b, col.a )
	surface.DrawRect( w * 0.475, h * 0.4975, w * 0.05, h * 0.005 )
	surface.DrawRect( w * 0.4975, h * 0.475, w * 0.005, h * 0.05 )
	
	// Draw the select menu
	if (#self.Programs > 0) then
		local col = Color( 100, 100, 100, 255 )
		surface.SetFont( "ScoreboardText" )
		local tw, th = surface.GetTextSize( self.PackName .. " " )
		local mh = th + (th * #self.Programs)
		local my = (h*0.5)-(mh*0.5)
		local mw = w*0.2
		local mx = w - mw
		draw.RoundedBox( 6, mx, my, mw, mh, col )
		draw.SimpleText( self.PackName, "ScoreboardText", mx+(mw*0.5), my+(th*0.5), Color( 255, 255, 255, 255 ), 1, 1 )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawLine( mx, (h*0.5)-(mh*0.5)+th, w, (h*0.5)-(mh*0.5)+th )
		local ypos = self.LabelPos
		if (ypos != 0) then
			local ly = my+(th*ypos)
			draw.RoundedBox( 4, mx, ly, mw, th, Color( 255, 255, 255, 128 ) )
		end
		for k, v in pairs( self.Programs ) do
			draw.SimpleText( v[1], "ScoreboardText", mx+(mw*0.5), (h*0.5)-(mh*0.5)+(th*(k+0.5)), Color( 0, 0, 0, 255 ), 1, 1 )
		end
		
		// Draw the selected OS
		local ypos = my + mh + (h*0.02)
		draw.RoundedBox( 6, mx, ypos, mw, th, col )
		draw.SimpleText( self.Programs[ self.SelProg ][ 2 ], "ScoreboardText", mx+(mw*0.5), ypos+(th*0.5), Color( 255, 255, 255, 255 ), 1, 1 )
	end
end

function SWEP:GetShootTrace( dist )
	local trace = {}
	trace.startpos = self.Owner:GetShootPos()
	trace.endpos = trace.startpos + (self.Owner:GetAimVector() * dist)
	trace.filter = self.Owner
	return util.TraceLine( trace )
end