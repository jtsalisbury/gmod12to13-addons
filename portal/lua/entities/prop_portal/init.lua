AddCSLuaFile( "shared.lua" );
AddCSLuaFile( "cl_init.lua" );
include( "shared.lua" );

ENT.Linked = nil
ENT.PortalType = TYPE_BLUE
ENT.Activated = false
ENT.KeyValues = {}

--resource.AddFile("materials/sprites/noblue.mdl")

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "prop_portal" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

--I think this is from sassilization..
local function IsBehind( posA, posB, normal )

	local Vec1 = ( posB - posA ):GetNormalized()

	return ( normal:Dot( Vec1 ) < 0 )

end

hook.Add( "SetupPlayerVisibility", "mySetupVis", function( ply, viewent )
	for k, v in ipairs( ents.FindByClass( "prop_portal" ) ) do
		AddOriginToPVS( v:GetPos() ) --Add each portal to the players PVS. This is because they are sometimes rendering remote positions.
	end
end )

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize( )

	self:SetModel( "models/blackops/portal.mdl" )
	--self:SetModel( "models/portals/portal1_renderfix.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetMoveType( MOVETYPE_NONE )
	self:PhysWake()
	self:DrawShadow(false)
	self:SetTrigger(true)
	self:SetNWBool("Potal:Activated",false)
	self:SetNWBool("Potal:Linked",false)
	self:SetNWInt("Potal:PortalType",self.PortalType)
	
	self:SetPos( self:GetPos() + self:GetForward() * 0.1 + self:GetUp() * 5 )
	
	self.Sides = ents.Create( "prop_physics" )
	self.Sides:SetModel( "models/blackops/portal_sides.mdl" )
	self.Sides:SetPos( self:GetPos() + self:GetForward()*-0.1 )
	self.Sides:SetAngles( self:GetAngles() )
	self.Sides:Spawn()
	self.Sides:Activate()
	self.Sides:SetRenderMode( RENDERMODE_NONE )
	self.Sides:PhysicsInit(SOLID_VPHYSICS)
	self.Sides:SetSolid(SOLID_VPHYSICS)
	self.Sides:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	--self.Sides:SetMoveType( MOVETYPE_NONE ) --causes some weird shit to happen..
	self.Sides:DrawShadow(false)
	
	local phys = self.Sides:GetPhysicsObject()
	
	if IsValid( phys ) then
		phys:EnableMotion( false )
	end
	
	self:DeleteOnRemove(self.Sides)
	
end

function ENT:CleanMeUp()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Forward(),0)
	ang:RotateAroundAxis(ang:Up(),90)

	local ent = ents.Create( "info_particle_system" )
	ent:SetPos(self:GetPos())
	ent:SetAngles(ang)
	if self.PortalType == TYPE_BLUE then
		ent:SetKeyValue( "effect_name", "portal_1_close")
	elseif self.PortalType == TYPE_ORANGE then
		ent:SetKeyValue( "effect_name", "portal_2_close")
	end
	ent:SetKeyValue( "start_active", "1")
	ent:Spawn()
	ent:Activate()
	timer.Simple(5,function()
		if ent and ent:IsValid() then
			ent:Remove()
		end
	end)
	self:Remove()
end

function ENT:MoveToNewPos(pos,newang) --Called by the swep, used if a player already has a portal out.

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Forward(),0)
	ang:RotateAroundAxis(ang:Up(),90)

	local ent = ents.Create( "info_particle_system" )
	ent:SetPos(self:GetPos())
	ent:SetAngles(ang)
	if self.PortalType == TYPE_BLUE then
		ent:SetKeyValue( "effect_name", "portal_1_close")
	elseif self.PortalType == TYPE_ORANGE then
		ent:SetKeyValue( "effect_name", "portal_2_close")
	end
	ent:SetKeyValue( "start_active", "1")
	ent:Spawn()
	ent:Activate()
	
	self:SetPos(pos)
	self:SetAngles(newang)
	
	if IsValid( self.Sides ) then
		self.Sides:SetPos(pos)
		self.Sides:SetAngles(newang)
	end
	
	umsg.Start("Portal:Moved" )
	umsg.Entity( self )
	umsg.End()
	
	for _,ent in pairs(ents.FindInSphere(self:GetPos()+self:GetAngles():Forward()*10,60)) do
		if ent:GetModel() != "models/blackops/portal_sides.mdl" and (ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" or ent:GetClass() == "npc_portal_turret_floor" or ent:GetClass() == "npc_security_camera" ) then
			if ent:GetClass() == "npc_security_camera" then
				ent:SetModel("models/props/Security_Camera_prop_reference.mdl")
			end
			local phys = ent:GetPhysicsObject()
			ent:SetGroundEntity( NULL )
			if phys:IsValid() then
				phys:EnableMotion( true )
				phys:Wake()
				print("WAKE UP "..ent:GetClass())
			end
		end
	end
end

function ENT:GetOpposite() --Don't think this is being used..? Gets the portal type that it would need to be linked too
	if self.PortalType == TYPE_BLUE then
		return TYPE_ORANGE
	elseif self.PortalType == TYPE_ORANGE then
		return TYPE_BLUE
	end
end

function ENT:SuccessEffect()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Forward(),0)
	ang:RotateAroundAxis(ang:Up(),90)

	local ent = ents.Create( "info_particle_system" )
	ent:SetPos(self:GetPos())
	ent:SetAngles(ang)
	if self.PortalType == TYPE_BLUE then
		ent:SetKeyValue( "effect_name", "portal_1_success")
	elseif self.PortalType == TYPE_ORANGE then
		ent:SetKeyValue( "effect_name", "portal_2_success")
	end
	ent:SetKeyValue( "start_active", "1")
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
end

function ENT:SetType( int )
	self:SetNWInt("Potal:PortalType",int)
	self.PortalType = int
	
	--[[umsg.Start("Portal:SetPortalType" )
	umsg.Entity( self )
	umsg.Long( int )
	umsg.End()]]
	
	if self.Activated == true then
		self:SetUpEffects(int)
	end
end

function ENT:SetUpEffects(int)

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Forward(),0)
	ang:RotateAroundAxis(ang:Up(),90)

	local ent = ents.Create( "info_particle_system" )
	ent:SetPos(self:GetPos())
	ent:SetAngles(ang)
	if int == TYPE_BLUE then
		ent:SetKeyValue( "effect_name", "portal_1_edge")
	elseif int == TYPE_ORANGE then
		ent:SetKeyValue( "effect_name", "portal_2_edge")
	end
	ent:SetKeyValue( "start_active", "1")
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	
	local ent = ents.Create( "info_particle_system" )
	ent:SetPos(self:GetPos())
	ent:SetAngles(ang)
	if int == TYPE_BLUE then
		ent:SetKeyValue( "effect_name", "portal_1_vacuum")
	elseif int == TYPE_ORANGE then
		ent:SetKeyValue( "effect_name", "portal_2_vacuum")
	end
	ent:SetKeyValue( "start_active", "1")
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
end

function ENT:LinkPortals( ent )
	self:SetNWBool("Potal:Linked",true)
	self:SetNWEntity("Potal:Other",ent)
	ent:SetNWBool("Potal:Linked",true)
	ent:SetNWEntity("Potal:Other",self)
end

function ENT:OnTakeDamage(dmginfo)
end

--Mahalis code
function ENT:CanPort(ent)
	local c = ent:GetClass()
	if ent:IsPlayer() or (ent != nil && ent:IsValid() && !ent.isClone && ent:GetPhysicsObject() && c != "noportal_pillar" && c != "prop_dynamic" && c != "rpg_missile" && string.sub(c,1,5) != "func_" && string.sub(c,1,9) != "prop_door") then
		return true
	else
		return false
	end
end

function ENT:MakeClone(ent)

	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end	
	--if ent:GetClass() != "prop_physics" then return end
	
	local portal = self:GetNWEntity("Potal:Other")

	
	if ent.clone != nil then return end
	local clone = ents.Create("prop_physics")
	clone:SetSolid(SOLID_NONE)
	clone:SetPos(self:GetPortalPosOffsets(portal,ent))
	clone:SetAngles(self:GetPortalAngleOffsets(portal,ent))
	clone.isClone = true
	clone:SetModel(ent:GetModel())
	clone:Spawn()
	clone:SetSkin(ent:GetSkin())
	clone:SetMaterial(ent:GetMaterial())
	ent:DeleteOnRemove(clone)
	local phy = clone:GetPhysicsObject()
	if phy:IsValid() then
		phy:EnableCollisions(false)
		phy:EnableGravity(false)
		phy:EnableDrag(false)
	end
	ent.clone = clone
	
	umsg.Start("Portal:ObjectInPortal" )
	umsg.Entity( portal )
	umsg.Entity( clone )
	umsg.End()
	clone.InPortal = portal
end

--Mahalis code..
function ENT:TransformOffset(v,a1,a2)
	return (v:Dot(a1:Right()) * a2:Right() + v:Dot(a1:Up()) * a2:Up() + v:Dot(a1:Forward()) * a2:Forward())
end

function ENT:GetPortalAngleOffsets(portal,ent)
	local angles = ent:GetAngles()
	
	local normal = self:GetForward()
	local forward = angles:Forward()
	local up = angles:Up()
	
	// reflect forward
	local dot = forward:DotProduct( normal )
	forward = forward + ( -2 * dot ) * normal
	
	// reflect up		
	local dot = up:DotProduct( normal )
	up = up + ( -2 * dot ) * normal
	
	// convert to angles
	angles = math.VectorAngles( forward, up );
	
	local LocalAngles = self:WorldToLocalAngles( angles );
	
	// repair
	LocalAngles.y = -LocalAngles.y;
	LocalAngles.r = -LocalAngles.r;
	
	return portal:LocalToWorldAngles( LocalAngles )
end

function ENT:GetPortalPosOffsets(portal,ent)
	local offset = self:WorldToLocal(ent:GetPos())
	offset.x = -offset.x;
	offset.y = -offset.y;
	
	return portal:LocalToWorld( offset )
end

function ENT:SyncClone(ent)
	local clone = ent.clone
	
	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end	
	if clone == nil then return end
	
	local portal = self:GetNWEntity("Potal:Other")

	clone:SetPos(self:GetPortalPosOffsets(portal,ent))
	clone:SetAngles(self:GetPortalAngleOffsets(portal,ent))
end

function ENT:StartTouch(ent)
	--if ent:IsPlayer() then return end
	if ent:GetModel() == "models/blackops/portal_sides.mdl" then return end
	
	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end
	
	--ent:SetNWEntity("ImInPortal",self)
	
	if ent.InPortal then return end
	
	umsg.Start( "Portal:ObjectInPortal" )
	umsg.Entity( self )
	umsg.Entity( ent )
	umsg.End()
	ent.InPortal = self
	
	if self:CanPort(ent) and !ent:IsPlayer() then
		constraint.AdvBallsocket( ent, GetWorldEntity(), 0, 0, Vector(0,0,0), Vector(0,0,0), 0, 0,  -180, -180, -180, 180, 180, 180,  0, 0, 0, 1, 1 )
		self:MakeClone(ent)
	elseif ent:IsPlayer() then
		ent:SetMoveType(MOVETYPE_NOCLIP)
		--print("noclipping")
		if !ent.JustEntered then
			ent:EmitSound("player/portal_enter".. self.PortalType ..".wav",80,100 + (30 * (ent:GetVelocity():Length() - 100)/1000))
			ent.JustEntered = true
		end
	end
end

function ENT:Touch( ent )

	--if ent:IsPlayer() then return end
	if !self:CanPort(ent) then return end
	
	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end
	
	local portal = self:GetNWEntity("Potal:Other")
	
	if portal and portal:IsValid() then
		
		ent:SetGroundEntity( NULL )
		self:SyncClone(ent)
		
		if ent:IsPlayer() then
			local eyepos = ent:EyePos()
			if !IsBehind( eyepos, self:GetPos(), self:GetForward() ) then --if the players eyes are behind the portal, we do the end touch shit we need anyway
				self:DoPort(ent) --end the touch
				ent.AlreadyPorted = true
			end
		end
		
	end
end

function ENT:EndTouch(ent)

	if ent.AlreadyPorted then
		ent.AlreadyPorted = false
	else
		self:DoPort(ent)
	end
end

function ENT:DoPort(ent)

	if !self:CanPort(ent) then return end
	if !ent or !ent:IsValid() then return end
		
	constraint.RemoveConstraints(ent, "AdvBallsocket")

	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end
	
	umsg.Start( "Portal:ObjectLeftPortal" )
	umsg.Entity( ent )
	umsg.End()

	local portal = self:GetNWEntity("Potal:Other")
	
	--Mahalis code
	local vel = ent:GetVelocity()
	if !vel then return end
	vel = vel - 2*vel:Dot(self:GetAngles():Up())*self:GetAngles():Up()
	local nuVel = self:TransformOffset(vel,self:GetAngles(),portal:GetAngles()) * -1
	
	local phys = ent:GetPhysicsObject()
	
	if portal and portal:IsValid() and phys:IsValid() and ent.clone and ent.clone:IsValid() and !ent:IsPlayer() then
		if !IsBehind( ent:GetPos(), self:GetPos(), self:GetForward() ) then
			ent:SetPos(ent.clone:GetPos())
			ent:SetAngles(ent.clone:GetAngles())
			phys:SetVelocity(nuVel)
		end
		ent.InPortal = nil
		
		ent.clone:Remove()
		ent.clone = nil
	elseif ent:IsPlayer() then
		local eyepos = ent:EyePos()
		
		if !IsBehind( eyepos, self:GetPos(), self:GetForward() ) then
			ent:SetPos(self:GetPortalPosOffsets(portal,ent))
			
			ent:SetLocalVelocity(nuVel)
			
			--local newang = math.VectorAngles(ent:GetForward(), ent:GetUp()) + Angle(0,180,0) + (portal:GetAngles() - self:GetAngles())
			local newang = self:GetPortalAngleOffsets(portal,ent)
			newang.r = 0
			ent:SetEyeAngles(newang)
			
			ent.InPortal = portal
			
			umsg.Start("Portal:ObjectInPortal", rp )
			umsg.Entity( portal )
			umsg.Entity( ent )
			umsg.End()
	
			ent.JustEntered = false
			ent.JustPorted = true
		else
			ent.InPortal = nil
			ent:SetMoveType(MOVETYPE_WALK)
			ent:EmitSound("player/portal_exit".. self.PortalType ..".wav",80,100 + (30 * (nuVel:Length() - 100)/1000))
			--print("Walking")
		end
	end
end

--[[local function BulletHook(self,bullet,trace)

	local self = trace.Entity
	if self and self:IsValid() and self:GetClass() == "prop_portal" then
		local portal = self:GetNWEntity("Potal:Other")
	
		if portal and portal:IsValid() then
			--PrintTable(bullet)
			--PrintTable(trace)
			
			local offset = self:WorldToLocal(trace.HitPos) --Wayyy better calculation of the offsets
			offset.x = -offset.x;
			offset.y = -offset.y;
			
			local newbullet = {}
			newbullet.Num = bullet.Num
			newbullet.Src = portal:LocalToWorld( offset ) + portal:GetForward() * 20
			newbullet.Dir = WTFHOWCANIGETANGLES
			newbullet.Spread = bullet.Spread
			newbullet.Tracer = bullet.Tracer
			newbullet.Force = bullet.Force
			newbullet.Damage = bullet.Damage
			newbullet.Attacker = bullet.Attacker
			portal:FireBullets(newbullet)
		end
	end
	-- Self: Entity, who shoots the bullet
	-- Bullet: Bullet-Table to shoot
	-- Trace: Traceline which fits to this bullet. This is where you can add the "bullet teleportation".
end  
hook.Add("StarGate.Bullet","Horray",BulletHook)]]

function ENT:SetActivatedState(bool)
	self.Activated = bool
	self:SetNWBool("Potal:Activated",bool)
	
	local other = self:FindOpenPair()
	if other and other:IsValid() then
		self:LinkPortals(other)
	end
end

function ENT:FindOpenPair() --This is for singeplayer, it finds a portal that is of the same type.
	local portals = ents.FindByClass( "prop_portal" );
	local mycolor = self:GetNWInt("Potal:PortalType",nil)
	local othercolor
	for k, v in pairs( portals ) do
		othercolor = v:GetNWInt("Potal:PortalType",nil)
		if v:GetNWBool("Potal:Activated",false) == true and v != self and othercolor and mycolor and othercolor != mycolor then
			return v
		end
	end
	return nil
end

function ENT:AcceptInput(name) --Map inputs (Seems to work..)
 
	if (name == "Fizzle") then
		--self:Remove()
		self.Activated = false
		self:SetNWBool("Potal:Activated",false)
	end
	
	if (name == "SetActivatedState") then
		self:SetActivatedState(true)
	end
 
end

function ENT:KeyValue( key, value ) --Map keyvalues

	self.KeyValues[key] = value
	
	if key == "LinkageGroupID" then --I don't think this does jack shit, but it was on the valve wiki..
		self:SetNWInt("Potal:LinkageGroupID",value)
	end
	
	if key == "Activated" then --Set if it should start activated or not..
		self.Activated = tobool(value)
		self:SetNWBool("Potal:Activated",tobool(value))
	end
	
	if key == "PortalTwo" then --Sets the portal type
		self:SetType( value+1 )
	end
	
end

--Jintos code..
function math.VectorAngles( forward, up )

	local angles = Angle( 0, 0, 0 );

	local left = up:Cross( forward );
	left:Normalize();
	
	local xydist = math.sqrt( forward.x * forward.x + forward.y * forward.y );
	
	// enough here to get angles?
	if( xydist > 0.001 ) then
	
		angles.y = math.deg( math.atan2( forward.y, forward.x ) );
		angles.p = math.deg( math.atan2( -forward.z, xydist ) );
		angles.r = math.deg( math.atan2( left.z, ( left.y * forward.x ) - ( left.x * forward.y ) ) );

	else
	
		angles.y = math.deg( math.atan2( -left.x, left.y ) );
		angles.p = math.deg( math.atan2( -forward.z, xydist ) );
		angles.r = 0;
	
	end

	return angles;
	
end
