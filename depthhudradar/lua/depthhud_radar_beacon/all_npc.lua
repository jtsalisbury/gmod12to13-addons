BEACON.Name = "NPCs"

BEACON.angle = nil
BEACON.dist  = nil
BEACON.isup  = nil

BEACON.spriteScale = nil
BEACON.spriteColor = Color(255,0,0,255)
BEACON.sprite      = nil
BEACON.spriteAngle = nil
BEACON.spriteColorShadow = Color(0,0,0,128)

BEACON.coneColor = Color(255,255,255,128)
BEACON.coneAngle = nil

BEACON.name = ""

function BEACON:FindFunction( entities , myTrashTable )
	for k,ent in pairs(entities) do
		if ent:IsNPC() then
			table.insert(myTrashTable,ent)
		end
	end
	return myTrashTable
end

function BEACON:DrawFunction( ent )
	self.angle, self.dist, self.isup = dhradar_CalcGetPolar( ent:GetPos() )
	self.spriteScale = math.Clamp(ent:BoundingRadius()/64,0.3,8)*1.5
	self.sprite, self.spriteAngle = dhradar_CalcGenericAltitudeSprite(self.isup, dhradar_GetTexture("square"), dhradar_GetTexture("triangle"), 45, 0, 180)
	
	dhradar_DrawPin(self.sprite, self.angle, self.dist, self.spriteColorShadow, 1.25*self.spriteScale, self.spriteAngle, true, 0.5)
	dhradar_DrawPin(self.sprite, self.angle, self.dist, self.spriteColor      , 1.00*self.spriteScale, self.spriteAngle, true, 0.5)
	
	if self.dist < 1 and ent:GetClass() != "npc_rollermine" then
		self.coneColor.r = 255*0.5 + self.spriteColor.r*0.5
		self.coneColor.g = 255*0.5 + self.spriteColor.r*0.5
		self.coneColor.b = 255*0.5 + self.spriteColor.r*0.5
		self.coneColor.a = 128
		self.coneAngle = ent:GetAngles().y - dhradar_Angles().y + 90
		
		dhradar_DrawPin(dhradar_GetTexture("cone"), self.angle, self.dist, self.coneColor, 6, self.coneAngle)
	end
	
	if self.dist < 1 and (GetConVarNumber("dhradar_ui_showplayernames") > 0) then
		self.name = string.Replace(ent:GetClass(),"npc_","")
		self.name = dhradar_StringNiceNameTransform( self.name )
		dhradar_DrawText(self.name, self.angle, self.dist + 0.10, self.spriteColor, true)
	end
	
	return true
end
