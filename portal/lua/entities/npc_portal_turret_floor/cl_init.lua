include( 'shared.lua' )

function ENT:Draw()
	self:DrawModel()
end

local beam = Material("trails/laser")
local beamhit = Material("Sprites/light_glow02_add")

local function RenderScreenspaceEffects()

	for k,v in pairs(ents.FindByClass( "npc_turret_floor" )) do
		if v:GetModel() == "models/props/turret_01.mdl" then
			cam.Start3D(EyePos(), EyeAngles())

				local attach = v:GetAttachment(v:LookupAttachment("eyes"))
				local attachlight = v:GetAttachment(v:LookupAttachment("light"))

				local tr = {}
				tr.start = attachlight.Pos
				tr.endpos = attach.Pos + ( attach.Ang:Forward() * 999999 )
				tr.filter = v
				tr.mask = MASK_SHOT
				local trace = util.TraceLine( tr )

				local TexOffset = CurTime( ) * 3
				local Distance = trace.HitPos:Distance( attachlight.Pos )

				render.SetMaterial(beam)
				render.DrawBeam(attachlight.Pos, trace.HitPos, 16, TexOffset, TexOffset + Distance / 8, Color(255, 0, 0, 255))

				local Size = 8+(math.random()*25)
				render.SetMaterial(beamhit)
				render.DrawQuadEasy(trace.HitPos, (EyePos() - trace.HitPos):GetNormal(), Size, Size, Color(255,0,0,255), 0)
				
			cam.End3D()
		end
	end
end
hook.Add("RenderScreenspaceEffects","PortalTurret.RenderScreenspaceEffects",RenderScreenspaceEffects)