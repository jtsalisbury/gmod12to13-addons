
SWEP.Author = "[GU]thomasfn"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "PCMod 2"

if (CLIENT) then

	SWEP.PrintName = "Hard-Disk Copier"
	
	SWEP.Slot = 5
	SWEP.SlotPos = 4
	
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
SWEP.Snd.Copy = ""
SWEP.Snd.Paste = ""
SWEP.Snd.NextSlot = ""
SWEP.Snd.ClearSlot = ""

for k, v in pairs( SWEP.Snd ) do
	if (v != "") then SWEP.Snd[ k ] = Sound( v ) end
end

SWEP.Slots = {}
SWEP.SelSlot = 1

SWEP.LabelPos = 1
SWEP.ZipRat = 0.25

SWEP.NextR = 0

function SWEP:Think()
	if (SERVER) then return end
	self.SelSlot = self:GetNWInt( "selslot" )
	local cnt
	for cnt=1, 4 do
		self.Slots[ cnt ] = self:GetNWBool( "slot_" .. tostring( cnt ) )
	end
	if ((self.SelSlot < 1) || (self.SelSlot > 4)) then self.SelSlot = 1 end
	if (self.LabelPos != self.SelProg) then
		self.LabelPos = math.Mid( self.LabelPos, self.SelSlot, self.ZipRat )
		if ((self.LabelPos > (self.SelSlot-0.1)) && (self.LabelPos < (self.SelSlot+0.1))) then self.LabelPos = self.SelSlot end
	end
end

function SWEP:Deploy()
	if (SERVER) then
		local ply = self.Owner
		if ((!ply) || (!ply:IsValid())) then return end
		local dat = PCMod.PLD.GetPlyData( ply )
		if (!dat) then return end
		if (!dat.HDrives) then dat.HDrives = {} end
		local cnt
		for cnt=1, 4 do
			if (dat.HDrives[ cnt ]) then
				self.Slots[ cnt ] = true
				self:SetNWBool( "slot_" .. tostring( cnt ), true )
			else
				self.Slots[ cnt ] = false
				self:SetNWBool( "slot_" .. tostring( cnt ), false )
			end
		end
	end
end

function SWEP:PrimaryAttack()
	self:PasteHD()
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end

function SWEP:Reload()
	self:EraseSlot()
end

function SWEP:PasteHD()
	local tr = self.Owner:GetEyeTrace()
	if ((tr.HitPos - self.Owner:GetPos()):Length() > 128) then return end
	local ent = tr.Entity
	if ((tr.HitWorld) || (!ent) || (!ent:IsValid())) then
		if (CLIENT) then PCMod.Notice( "You must be looking at an object!" ) end
		return
	end
	if ((!ent.IsPCMod) || (ent.Class != "pcmod_tower")) then
		if (CLIENT) then PCMod.Notice( "You must be looking at a PC Tower!" ) end
		return
	end
	if (CLIENT) then return true end -- Client stops here
	
	local slot = self.Slots[ self.SelSlot ]
	if (!slot) then
		PCMod.Notice( "Slot empty!", self.Owner )
		return
	end
	
	local data = PCMod.PLD.GetPlyData( self.Owner )
	if (!data) then return end
	if (!data.HDrives) then data.HDrives = {} end
	local hd = data.HDrives[ self.SelSlot ]
	if (!hd) then return end
	
	local osid = hd[ "/system/os/osid.sys" ]
	if (!osid) then osid = {} end
	local trid = PCMod.Data[ ent:EntIndex() ].HardDrive[ "/system/os/osid.sys" ]
	if (!trid) then trid = {} end
	if (osid.ItemContent != trid.ItemContent) then
		PCMod.Notice( "OS didn't match!", self.Owner )
		return
	end
	
	PCMod.Data[ ent:EntIndex() ].HardDrive = table.Copy( hd )
	
	self.Owner:SendLua( "PCMod.Gui.FlashIcon( \"gui/icons/ico_harddrive\", 1 );" )
	
	self:PlaySnd( "Paste" )
end

function SWEP:SecondaryAttack()
	// == Right Click Changes Slot == \\
	
	local tr = self.Owner:GetEyeTrace()
	if ((tr.HitPos - self.Owner:GetPos()):Length() > 128) then
		self:ChangeSlot()
		return
	end
	local ent = tr.Entity
	if ((tr.HitWorld) || (!ent) || (!ent:IsValid())) then
		self:ChangeSlot()
		return
	end
	if ((!ent.IsPCMod) || (ent.Class != "pcmod_tower")) then
		self:ChangeSlot()
		return
	end

	if (CLIENT) then return end
	
	self:CopyHD( ent )
end

function SWEP:ChangeSlot()
	self.SelSlot = self.SelSlot + 1
	if ((self.SelSlot < 1) || (self.SelSlot > 4)) then self.SelSlot = 1 end
	if (SERVER) then self:SetNWInt( "selslot", self.SelSlot ) end
	self:PlaySnd( "ChangeSlot" )
end

function SWEP:CopyHD( ent )
	
	if (CLIENT) then return true end -- Client stops here
	
	PCMod.Msg( "About to copy hd...", true )
	
	local sl = self.SelSlot
	local dat = PCMod.PLD.GetPlyData( self.Owner )
	if (!dat) then dat = {} end
	
	local hd = PCMod.Data[ ent:EntIndex() ].HardDrive
	if (!hd) then return end
	
	PCMod.Msg( "HD copying...", true )
	
	if (!dat.HDrives) then dat.HDrives = {} end
	dat.HDrives[ sl ] = table.Copy( hd )
	PCMod.PLD.SetPlyData( self.Owner, dat )
	
	self.Slots[ sl ] = true
	self:SetNWBool( "slot_" .. tostring( sl ), true )
	
	PCMod.Msg( "HD copied!", true )
	
	self.Owner:SendLua( "PCMod.Gui.FlashIcon( \"gui/icons/ico_harddrive\", 0 );" )
	
	self:PlaySnd( "Copy" )
end

function SWEP:EraseSlot()
	local sl = self.SelSlot
	local dat = PCMod.PLD.GetPlyData( self.Owner )
	if (!dat) then dat = {} end
	if (!dat.HDrives) then dat.HDrives = {} end
	
	local ss = (!dat.HDrives[ sl ])
	
	dat.HDrives[ sl ] = nil
	self.Slots[ sl ] = false
	self:SetNWBool( "slot_" .. tostring( sl ), false )
	
	if (ss) then
	
		self:PlaySnd( "ClearSlot" )
		PCMod.PLD.SetPlyData( self.Owner, dat )
		
	end
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
	local slot_size = w * 0.12
	local col = Color( 100, 100, 100, 255 )
	surface.SetFont( "ScoreboardText" )
	local tw, th = surface.GetTextSize( "Slots" )
	local mh = th + ((slot_size+5)*4)+5
	local mw = slot_size+10
	local my = (h*0.5)-(mh*0.5)
	local mx = ScrW()-mw
	draw.RoundedBox( 6, mx, my, mw, mh, col )
	draw.SimpleText( "Slots", "ScoreboardText", (mx+ScrW())*0.5, my+(th*0.5), Color( 255, 255, 255, 255 ), 1, 1 )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawLine( mx, my+th, w, my+th )
	local cnt = 0
	for cnt=1, 4 do
		local sl_y = my+th+((cnt-1)*(slot_size+5))+5
		draw.RoundedBox( 6, mx+5, sl_y, slot_size, slot_size, Color( 255, 255, 255, 128 ) )
		if (self.Slots[ cnt ]) then
			surface.SetTexture( PCMod.Res.Mats[ "gui/icons/ico_harddrive" ] )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( mx+5, sl_y, slot_size, slot_size )
		end
	end
	local ypos = self.LabelPos
	if (ypos != 0) then
		local sl_y = my+th+((ypos-1)*(slot_size+5))+5
		draw.RoundedBox( 4, mx+5, sl_y, slot_size, slot_size, Color( 0, 255, 0, 64 ) )
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