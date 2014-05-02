
// ---------------------------------------------------------------------------------------------------------
// pcmod_document
// Document ent, spawned by printer (NOT DERIVED FROM pcmod_base)
// ---------------------------------------------------------------------------------------------------------

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Printed Document"
ENT.Author = "[GU]thomasfn"
ENT.Category = "PCMod"
ENT.Class = "pcmod_document"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if (SERVER) then

	AddCSLuaFile( "shared.lua" )

end

if (CLIENT) then

	ENT.RenderGroup = RENDERGROUP_OPAQUE

end

------------------|

	ENT.IsPCMod = false -- This entity belongs to the PCMod addon, but does NOT hold any of the usual functions

	ENT.UseDelay = 1 -- Delay between use event fired (secs)
	ENT.NextUse = 0 -- Internal usage data

	ENT.ItemModel = "models/props_c17/paper01.mdl"

------------------|

if (SERVER) then

	function ENT:Initialize()
	
		// Setup all our physics stuff
		self:ChangeModel( self.ItemModel )
		
		// Setup our data slot
		local dt = {}
		PCMod.Data[ self:EntIndex() ] = dt
		
		self:SetDocument( "" )
	end
	
	function ENT:ChangeModel( mdl )
		self.Entity:SetModel( mdl )
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		local phys = self.Entity:GetPhysicsObject()
		if ((phys) && (phys:IsValid())) then phys:Wake() end
	end
	
	function ENT:SetDocument( text )
		PCMod.Data[ self:EntIndex() ].Document = text
	end
	
	function ENT:GetDocument()
		return PCMod.Data[ self:EntIndex() ].Document
	end
	
	function ENT:SetPlayer( ply )
		PCMod.Data[ self:EntIndex() ].Owner = text
	end
	
	function ENT:GetPlayer()
		return PCMod.Data[ self:EntIndex() ].Owner
	end
	
	function ENT:Use( ply )
		if (CurTime() < self.NextUse) then return end
		self.NextUse = CurTime() + self.UseDelay
		PCMod.Beam.BeamString( ply, "docu_info", self:GetDocument() )
	end

end

if (CLIENT) then

	// Ripped straight from pcmod_base -thomasfn
	
	function ENT:Draw()
	
		// See if player is looking at the entity
		local tr = LocalPlayer():GetEyeTrace()
		if (tr.Entity == self) then			
			PCMod.SelEntity = self:EntIndex()
		end
	
		self.Entity:DrawModel() -- Draw the model
	
	end
	
	function ENT:DrawInfo( origin )

		surface.SetFont( "ScoreboardText" )

		local w, h = surface.GetTextSize( self.PrintName )
		w = w + 10
		h = h + 10
		local x = origin.x-(w/2)
		local y = origin.y

		draw.RoundedBox( 6, x, y, w, h, Color( 50, 50, 50, 200 ) )
		draw.SimpleText( self.PrintName, "ScoreboardText", origin.x, origin.y+(h*0.5), Color( 255, 255, 255, 255 ), 1, 1 )
	end


end