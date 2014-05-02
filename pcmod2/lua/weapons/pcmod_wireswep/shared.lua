SWEP.Author = "[GU]thomasfn"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "PCMod 2"

if (CLIENT) then

	SWEP.PrintName = PC_WireSwep_PrintName or "PC Wire Tool"
	PC_WireSwep_PrintName = nil
	
	SWEP.Slot = 5
	SWEP.SlotPos = 4
	
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
	
end

if (SERVER) then

	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 5
	
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true

end

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/v_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.ShootSound	= Sound( "Airboat.FireGunRevDown" )

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

ToolObj = {}
include( "weapons/pcmod_wireswep/stool.lua" )
if (SERVER) then AddCSLuaFile( "weapons/pcmod_wireswep/stool.lua" ) end
if (ToolObj.Create) then table.Merge( ToolObj, ToolObj:Create() ) end
SWEP.ToolBase = table.Copy( ToolObj or {} )
ToolObj = nil

TOOL = {}
table.Merge( TOOL, SWEP.ToolBase )
ToolOnly = true
local toolmode = PC_WireSwep_ToolMode or "pcwire"
PC_WireSwep_ToolMode = nil
SWEP.Mode = toolmode
include( "weapons/gmod_tool/stools/" .. toolmode .. ".lua" )
SWEP.MainTool = table.Copy( TOOL )
TOOL = nil
ToolOnly = nil


function SWEP:Initialize()
	self.ToolMode = table.Copy( self.MainTool )
	self:Setup()
end

function SWEP:Deploy( init )
	self:Setup()
	self.ToolMode:Deploy()
	return true
end

function SWEP:Setup()
	self.ToolMode.SWEP = self
	self.ToolMode.Mode = self.Mode
	self.ToolMode.Owner = self.Owner
	self.ToolMode.Weapon = self.Weapon
	self.ToolMode:CheckObjects()
end

function SWEP:Holster()
	self:Setup()
	self.ToolMode:Holster()
	return true
end

function SWEP:PrimaryAttack()
	self:Setup()
	
	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = ( CONTENTS_SOLID+CONTENTS_MOVEABLE+CONTENTS_MONSTER+CONTENTS_WINDOW+CONTENTS_DEBRIS+CONTENTS_GRATE+CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	
	self:DoShoot( self.ToolMode:LeftClick( trace ), trace )
end

function SWEP:SecondaryAttack()
	self:Setup()
	
	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = ( CONTENTS_SOLID+CONTENTS_MOVEABLE+CONTENTS_MONSTER+CONTENTS_WINDOW+CONTENTS_DEBRIS+CONTENTS_GRATE+CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	
	self:DoShoot( self.ToolMode:RightClick( trace ), trace )
end

function SWEP:Think()
	self.ToolMode:CheckObjects()
	self.ToolMode:Think()
end

function SWEP:DoShoot( doit, tr )
	if (!doit) then return end
	self:DoShootEffect( tr.HitPos, tr.HitNormal, tr.Entity, tr.PhysicsBone )
end

function SWEP:DoShootEffect( hitpos, hitnormal, entity, physbone )

	self.Weapon:EmitSound( self.ShootSound	)
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 	// View model animation
	
	// There's a bug with the model that's causing a muzzle to 
	// appear on everyone's screen when we fire this animation. 
	//self.Owner:SetAnimation( PLAYER_ATTACK1 )			// 3rd Person Animation
	
	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetNormal( hitnormal )
		effectdata:SetEntity( entity )
		effectdata:SetAttachment( physbone )
	util.Effect( "selection_indicator", effectdata )	
	
	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self.Weapon )
	util.Effect( "ToolTracer", effectdata )
	
end

function SWEP:Reload()
	self:Setup()
	self.NextReload = self.NextReload or 0
	if (CurTime() > self.NextReload) then
		self.NextReload = CurTime()+1
		
		local tr = util.GetPlayerTrace( self.Owner )
		tr.mask = ( CONTENTS_SOLID+CONTENTS_MOVEABLE+CONTENTS_MONSTER+CONTENTS_WINDOW+CONTENTS_DEBRIS+CONTENTS_GRATE+CONTENTS_AUX )
		local trace = util.TraceLine( tr )
		if (!trace.Hit) then return end
		
		self:DoShoot( self.ToolMode:Reload( trace ), trace )
	end
end

if (CLIENT) then

	local RTTexture 	= GetRenderTarget( "GModToolgunScreen", 256, 256 )
	local matScreen 	= Material( "models/weapons/v_toolgun/screen" )
	local txBackground	= surface.GetTextureID( "gui/pcmod_logo" )

	function SWEP:ViewModelDrawn()
		local TEX_SIZE = 256
		local NewRT = RTTexture
		
		// Set the material of the screen to our render target
		matScreen:SetTexture( "$basetexture", NewRT )
		
		local OldRT = render.GetRenderTarget();
		
		// Set up our view for drawing to the texture
		render.SetRenderTarget( NewRT )
		render.SetViewPort( 0, 0, TEX_SIZE, TEX_SIZE )
		cam.Start2D()
		
		// Background
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 0, 0, TEX_SIZE, TEX_SIZE )
		
		// Logo
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( txBackground )
		surface.DrawTexturedRect( 0, 0, TEX_SIZE, TEX_SIZE )

		cam.End2D()
		render.SetRenderTarget( OldRT )	
	end
	
	function SWEP:DrawHUD()
		surface.SetFont( "ScoreboardText" )
		local tw, th = surface.GetTextSize( self.PrintName )
		tw = tw + 5
		th = th + 2
		surface.SetDrawColor( 50, 50, 50, 200 )
		surface.DrawRect( ScrW()-tw, 0, tw, th )
		surface.DrawOutline( ScrW()-tw, 0, tw, th, Color( 0, 0, 0, 255 ) )
		draw.SimpleText( self.PrintName, "ScoreboardText", ScrW()-(tw*0.5), th*0.5, Color( 255, 255, 255, 255 ), 1, 1 )
	end
	
end