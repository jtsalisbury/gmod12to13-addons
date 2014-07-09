-- Read the weapon_real_base if you really want to know what each action does

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "ar2"
end

if (CLIENT) then
	SWEP.PrintName 		= "ARC.GUN"
	SWEP.ViewModelFOV		= 70
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= "o"

	killicon.AddFont("", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ))
end

/*---------------------------------------------------------
Muzzle Effect + Shell Effect
---------------------------------------------------------*/
SWEP.MuzzleEffect			= "rg_muzzle_rifle" -- This is an extra muzzleflash effect
-- Available muzzle effects: rg_muzzle_grenade, rg_muzzle_highcal, rg_muzzle_hmg, rg_muzzle_pistol, rg_muzzle_rifle, rg_muzzle_silenced, none

SWEP.ShellEffect			= "" -- This is a shell ejection effect
-- Available shell eject effects: rg_shelleject, rg_shelleject_rifle, rg_shelleject_shotgun, none

SWEP.MuzzleAttachment		= "1" -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment	= "2" -- Should be "2" for CSS models or "1" for hl2 models
/*-------------------------------------------------------*/

SWEP.Instructions 		= "Zoom: Right Click \nChange Fire Mode: E + Right Click"

SWEP.Base 				= "base_a"

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 		= true

SWEP.ViewModel 			= "models/weapons/V_MNU.mdl"
SWEP.WorldModel 			= "models/weapons/w_mnu.mdl"

SWEP.Primary.Sound 		= Sound("weapons/arc_fire1.MP3")
SWEP.Primary.Damage 		= 999
SWEP.Primary.Recoil 		= 0.1
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0.0001
SWEP.Primary.ClipSize 		= 999
SWEP.Primary.Delay 		= 0
SWEP.Primary.DefaultClip 	= 999
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 		= "pistol"

SWEP.data 				= {}
SWEP.mode 				= "auto"

SWEP.data.zoomfov 		= 45
SWEP.data.snipefov 		= 0

SWEP.data.semi 			= {}

SWEP.data.auto 			= {}

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	-- If your gun have a problem or if you are under water, you'll not be able to fire

	self.Reloadaftershoot = CurTime() + self.Primary.Delay
	-- Set the reload after shoot to be not able to reload when firering

	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	-- Set next secondary fire after your fire delay

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	-- Set next primary fire after your fire delay

	self.Weapon:EmitSound(self.Primary.Sound)
	-- Emit the gun sound when you fire

	self:RecoilPower()

	self:TakePrimaryAmmo(1)
	-- Take 1 ammo in you clip

	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	if self.NextSecondaryAttack > CurTime() or self.OwnerIsNPC then return end
	self.NextSecondaryAttack = CurTime() + 0.3
	
	if self.Owner:KeyDown(IN_USE) then
		if self.mode == "semi" then
			self.mode = "auto"
			self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
		else
			self.mode = "semi"
			self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
		end
		self.data[self.mode].Init(self)

/*---------------------------------------------------------
	-- All of this is more complicated than it needs to be. Oh well.
	elseif self.IronSightsPos then
	
		local NumberOfScopeZooms = table.getn(self.ScopeZooms)

		if self.UseScope and self.Weapon:GetNetworkedBool("Scope", false) then
		
			self.CurScopeZoom = self.CurScopeZoom + 1
			if self.CurScopeZoom <= NumberOfScopeZooms then
				self:SetIronsights(false,self.Owner)
			end
		else
			local bIronsights = not self.Weapon:GetNetworkedBool("Ironsights", false)
			self:SetIronsights(bIronsights,self.Owner)
		end
---------------------------------------------------------*/
	end
end

---------------------------
-- Ironsight/Scope --
---------------------------
-- IronSightsPos and IronSightsAng are model specific paramaters that tell the game where to move the weapon viewmodel in ironsight mode.

SWEP.IronSightsPos			= Vector (0, -2, 1.8911)
SWEP.IronSightsAng 			= Vector (0, 0, 0)
SWEP.IronSightZoom			= 1.6 -- How much the player's FOV should zoom in ironsight mode. 
SWEP.UseScope				= false -- Use a scope instead of iron sights.
SWEP.ScopeScale 				= 0.4 -- The scale of the scope's reticle in relation to the player's screen size.
SWEP.ScopeZooms				= {6} -- The possible magnification levels of the weapon's scope.   If the scope is already activated, secondary fire will cycle through each zoom level in the table.
SWEP.DrawParabolicSights		= false -- Set to true to draw a cool parabolic sight (helps with aiming over long distances)