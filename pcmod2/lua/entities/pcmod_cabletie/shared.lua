ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Cable Tie"
ENT.Author = "[GU]thomasfn"
ENT.Category = "PCMod"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.ItemModel = "models/props_c17/utilityconnecter006.mdl"
ENT.IsCableTie = true

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	
	ENT.LinkedPorts = {}

	function ENT:Initialize()

		// Setup all our physics stuff
		self:ChangeModel( self.ItemModel )
		
	end

	function ENT:ChangeModel( mdl )
		self.Entity:SetModel( mdl )
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		local phys = self.Entity:GetPhysicsObject()
		if ((phys) && (phys:IsValid())) then phys:Wake() end
	end
	
	function ENT:OnRemove()
		// We can't stop the entity from being removed
		// Instead, unlink all ports we are linked to
		for _, v in pairs( self.LinkedPorts ) do
			if ((v.EntA) && (v.EntA:IsValid())) then PCMod.Wiring.UnlinkPort( v.EntA, v.PortA )	end
			// The second port should already be unlinked, but let's do it just in case
			if ((v.EntB) && (v.EntB:IsValid())) then PCMod.Wiring.UnlinkPort( v.EntB, v.PortB )	end
		end
	end
	
	function ENT:OnRestore()
		// Remove all ropes
		constraint.RemoveConstraints( self.Entity, "Rope" )
	end
	
end

if (CLIENT) then

	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Draw()
		self:DrawModel()
	end

end