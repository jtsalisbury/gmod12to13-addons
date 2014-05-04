TYPE_BLUE = 1
TYPE_ORANGE = 2

PORTAL_HEIGHT = 110
PORTAL_WIDTH = 68

if ( SERVER ) then
        AddCSLuaFile( "shared.lua" )
        SWEP.Weight                     = 4
        SWEP.AutoSwitchTo               = false
        SWEP.AutoSwitchFrom             = false
end

if ( CLIENT ) then
        if(file.Exists("materials/weapons/portalgun_inventory.vmt", "GAME")) then
                SWEP.WepSelectIcon = surface.GetTextureID("weapons/portalgun_inventory")
        end
        SWEP.PrintName          = "A.S.H.P.D."
        SWEP.Author                     = "Fernando5567"
        SWEP.Contact            = "Fergp1998@hotmail.com"
        SWEP.Purpose            = "Shoot Linked Portals"
        SWEP.ViewModelFOV       = "60"
        SWEP.Instructions       = ""
        SWEP.Slot = 0
        SWEP.Slotpos = 0
        SWEP.CSMuzzleFlashes    = true
       
        function SWEP:DrawWorldModel()
                if ( RENDERING_PORTAL or RENDERING_MIRROR or GetViewEntity() != LocalPlayer() ) then
                        self.Weapon:DrawModel()
                end
        end
end

SWEP.Category = "Aperture Science Handheld Portal Device"

SWEP.HoldType                   = "ar2"

SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

SWEP.ViewModel                  = "models/weapons/v_portalgun.mdl"
SWEP.WorldModel                 = "models/weapons/w_portalgun_hl2.mdl"


SWEP.ViewModelFlip              = false

SWEP.Drawammo = false
SWEP.DrawCrosshair = true

SWEP.ShootOrange        = Sound( "Weapon_Portalgun.fire_red" )
SWEP.ShootBlue          = Sound( "Weapon_Portalgun.fire_blue" )
SWEP.Delay                      = 0.5

SWEP.Primary.ClipSize           = -1
SWEP.Primary.DefaultClip        = -1
SWEP.Primary.Automatic          = true
SWEP.Primary.Ammo                       = "none"

SWEP.Secondary.ClipSize         = -1
SWEP.Secondary.DefaultClip      = -1
SWEP.Secondary.Automatic        = true
SWEP.Secondary.Ammo                     = "none"

SWEP.RunBob = 1.0
SWEP.RunSway = 1.0

SWEP.HasOrangePortal = false
SWEP.HasBluePortal = false

function SWEP:Initialize()

        self:SetWeaponHoldType( self.HoldType )
       
end

function SWEP:GetViewModelPosition( pos, ang )

        self.SwayScale  = self.RunSway
        self.BobScale   = self.RunBob

        return pos, ang
end

local function VectorAngle( vec1, vec2 ) -- Returns the angle between two vectors

        local costheta = vec1:Dot( vec2 ) / ( vec1:Length() *  vec2:Length() )
        local theta = math.acos( costheta )
       
        return math.deg( theta )
       
end

function SWEP:MakeTrace( start, off, normAng )
        local trace = {}
        trace.start = start
        trace.endpos = start + off
        trace.filter = { self.Owner }
        trace.mask = MASK_SOLID_BRUSHONLY
       
        local tr = util.TraceLine( trace )
       
        if !tr.Hit then
       
                local trace = {}
                local newpos = start + off
                trace.start = newpos
                trace.endpos = newpos + normAng:Forward() * -2
                trace.filter = { self.Owner }
                trace.mask = MASK_SOLID_BRUSHONLY
                local tr2 = util.TraceLine( trace )
               
                if !tr2.Hit then
               
                        local trace = {}
                        trace.start = start + off + normAng:Forward() * -2
                        trace.endpos = start + normAng:Forward() * -2
                        trace.filter = { self.Owner }
                        trace.mask = MASK_SOLID_BRUSHONLY
                        local tr3 = util.TraceLine( trace )
                       
                        if tr3.Hit then
                       
                                tr.Hit = true
                                tr.Fraction = 1 - tr3.Fraction
                               
                        end
                       
                end
               
        end
       
        return tr
end

function SWEP:IsPosionValid( pos, normal, minwallhits, dosecondcheck )

        local owner = self.Owner
       
        local noPortal = false
        local normAng = normal:Angle()
        local BetterPos = pos
       
        local elevationangle = VectorAngle( vector_up, normal )
       
        if elevationangle <= 15 or ( elevationangle >= 175 and elevationangle <= 185 )  then --If the degree of elevation is less than 15 degrees, use the players yaw to place the portal
       
                normAng.y = owner:EyeAngles().y + 180
               
        end
       
        local VHits = 0
        local HHits = 0
       
        local tr = self:MakeTrace( pos, normAng:Up() * -PORTAL_HEIGHT * 0.5, normAng )
       
        if tr.Hit then
       
                local length = tr.Fraction * -PORTAL_HEIGHT * 0.5
                BetterPos = BetterPos + normAng:Up() * ( length + ( PORTAL_HEIGHT * 0.5 ) )
                VHits = VHits + 1
       
        end
       
        local tr = self:MakeTrace( pos, normAng:Up() * PORTAL_HEIGHT * 0.5, normAng )
       
        if tr.Hit then
       
                local length = tr.Fraction * PORTAL_HEIGHT * 0.5
                BetterPos = BetterPos + normAng:Up() * ( length - ( PORTAL_HEIGHT * 0.5 ) )
                VHits = VHits + 1
       
        end
       
        local tr = self:MakeTrace( pos, normAng:Right() * -PORTAL_WIDTH * 0.5, normAng )
       
        if tr.Hit then
       
                local length = tr.Fraction * -PORTAL_WIDTH * 0.5
                BetterPos = BetterPos + normAng:Right() * ( length + ( PORTAL_WIDTH * 0.5 ) )
                HHits = HHits + 1
       
        end
       
        local tr = self:MakeTrace( pos, normAng:Right() * PORTAL_WIDTH * 0.5, normAng )
       
        if tr.Hit then
       
                local length = tr.Fraction * PORTAL_WIDTH * 0.5
                BetterPos = BetterPos + normAng:Right() * ( length - ( PORTAL_WIDTH * 0.5 ) )
                HHits = HHits + 1
       
        end
       
        if dosecondcheck then
       
                return self:IsPosionValid( BetterPos, normal, 2, false )
               
        elseif ( HHits >= minwallhits or VHits >= minwallhits ) then
       
                return false, false
               
        else
       
                return BetterPos, normAng
       
        end


end

function SWEP:ShootPortal( type )

        local weapon = self.Weapon
        local owner = self.Owner
       
        weapon:SetNextPrimaryFire( CurTime() + self.Delay )
        weapon:SetNextSecondaryFire( CurTime() + self.Delay )

        local OrangePortalEnt = owner:GetNWEntity( "Portal:Orange", nil )
        local BluePortalEnt = owner:GetNWEntity( "Portal:Blue", nil )
       
        local EntToUse = type == TYPE_BLUE and BluePortalEnt or OrangePortalEnt
        local OtherEnt = type == TYPE_BLUE and OrangePortalEnt or BluePortalEnt
       
        local tr = {}
        tr.start = owner:GetShootPos()
        tr.endpos = owner:GetShootPos() + ( owner:GetAimVector() * 2048 * 1000 )
       
        tr.filter = { owner, EntToUse, EntToUse.Sides }
       
        for k,v in pairs(ents.FindByClass( "prop_physics*" )) do
                table.insert( tr.filter, v )
        end
       
        for k,v in pairs( ents.FindByClass( "npc_turret_floor" ) ) do
                table.insert( tr.filter, v )
        end
       
        tr.mask = MASK_SHOT
       
        local trace = util.TraceLine( tr )
       
        if IsFirstTimePredicted() and owner:IsValid() then --Predict that motha' fucka'
       
                if ( trace.Hit and trace.HitWorld ) then
               
                        weapon:EmitSound( self.ShootOrange, 100, 100 )
                        weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
                       
                        if SERVER then
                               
                                local validpos, validnormang = self:IsPosionValid( trace.HitPos, trace.HitNormal, 2, true )
                               
                                if !trace.HitNoDraw and !trace.HitSky and ( trace.MatType != MAT_METAL or ( trace.MatType == MAT_CONCRETE or trace.MatType == MAT_DIRT ) ) and validpos and validnormang then
                                       
                                        if !IsValid( EntToUse ) then
                                       
                                                local Portal = ents.Create( "prop_portal" )
                                                Portal:SetPos( validpos )
                                                Portal:SetAngles( validnormang )
                                                Portal:Spawn()
                                                Portal:Activate()
                                                Portal:SetMoveType( MOVETYPE_NONE )
                                                Portal:SetActivatedState(true)
                                                Portal:SetType( type )
                                                Portal:SuccessEffect()
                                               
                                                if type == TYPE_BLUE then
                                               
                                                        owner:SetNWEntity( "Portal:Blue", Portal )
                                                       
                                                else
                                               
                                                        owner:SetNWEntity( "Portal:Orange", Portal )
                                                       
                                                end
                                               
                                                EntToUse = Portal
                                               
                                                if IsValid( OtherEnt ) then
                                               
                                                        EntToUse:LinkPortals( OtherEnt )
                                                       
                                                end
                                               
                                        else
                                       
                                                EntToUse:MoveToNewPos( validpos, validnormang )
                                                EntToUse:SuccessEffect()
                                               
                                        end
                                       
                                else
                               
                                        local ang = trace.HitNormal:Angle()
                               
                                        ang:RotateAroundAxis( ang:Right(), -90 )
                                        ang:RotateAroundAxis( ang:Forward(), 0 )
                                        ang:RotateAroundAxis( ang:Up(), 90 )
                                        local ent = ents.Create( "info_particle_system" )
                                        ent:SetPos( trace.HitPos + trace.HitNormal * 0.1 )
                                        ent:SetAngles( ang )
                                        ent:SetKeyValue( "effect_name", "portal_" .. type .. "_badsurface")
                                        ent:SetKeyValue( "start_active", "1")
                                        ent:Spawn()
                                        ent:Activate()
                                       
                                        timer.Simple( 5, function()
                                       
                                                if IsValid( ent ) then
                                               
                                                        ent:Remove()
                                                       
                                                end
                                               
                                        end )
                                       
                                end
                               
                        end
                       
                end
               
        end
       
end

function SWEP:SecondaryAttack()

        self:ShootPortal( TYPE_ORANGE )

end

function SWEP:PrimaryAttack()
       
        self:ShootPortal( TYPE_BLUE )

end

function SWEP:CleanPortals()

        local blueportal = self.Owner:GetNWEntity( "Portal:Blue" )
        local orangeportal = self.Owner:GetNWEntity( "Portal:Orange" )
        local cleaned = false
       
        for k,v in ipairs( ents.FindByClass( "prop_portal" ) ) do
       
                if v == blueportal or v == orangeportal and v.CleanMeUp then
               
                        if SERVER then
                       
                                v:CleanMeUp()
                               
                        end
                       
                        cleaned = true
                       
                end
               
        end
       
        if cleaned then
       
                self.Weapon:SendWeaponAnim( ACT_VM_FIZZLE )
               
        end
       
end

function SWEP:Reload()

        self:CleanPortals()
        return
       
end

function SWEP:Deploy()
       
        self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
        return true
       
end

function SWEP:OnRestore()
end

function SWEP:Think()
end

function SWEP:DrawHUD()
end

