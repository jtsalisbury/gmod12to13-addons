function PooPee.HUDPaint()
        if (GetGlobalInt("poopeemod") or 0) == 1 then 
                LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
                local x = 7
                local y = ScrH() - 110 - GetConVarNumber("HudH")
                local y2 = y + 10
                local poop = LocalPlayer().DarkRPVars.Poop or 0
                local pee = LocalPlayer().DarkRPVars.Pee or 0
                
                draw.RoundedBox(4, x - 1, y - 1, GetConVarNumber("HudW") , 9, Color(0, 0, 0, 255))
                draw.RoundedBox(4, x, y, GetConVarNumber("HudW") * (math.Clamp(poop, 0, 100) / 100), 7, Color(80, 45, 0, 255))
                draw.DrawText("Poop: "..math.ceil(poop) .. "%", "DefaultSmall", GetConVarNumber("HudW") / 2, y - 2, Color(255, 255, 255, 255), 1)
                
                draw.RoundedBox(4, x - 1, y2 - 1, GetConVarNumber("HudW") , 9, Color(0, 0, 0, 255))
                draw.RoundedBox(4, x, y2, GetConVarNumber("HudW") * (math.Clamp(pee, 0, 100) / 100), 7, Color(215, 255, 0, 255))
                draw.DrawText("Pee: "..math.ceil(pee) .. "%", "DefaultSmall", GetConVarNumber("HudW") / 2, y2 - 2, Color(255, 255, 255, 255), 1)
        end
end
hook.Add("HUDPaint", "PooPee.HUDPaint", PooPee.HUDPaint)

local function collideback(Particle, HitPos, Normal)
        Particle:SetAngleVelocity(Angle(0, 0, 0))
        local Ang = Normal:Angle()
        Ang:RotateAroundAxis(Normal, Particle:GetAngles().y)
        Particle:SetAngles(Ang)
        
        Particle:SetBounce(1)
        Particle:SetVelocity(Vector(0, 0, -100))
        Particle:SetGravity(Vector(0, 0, -100))
        
        Particle:SetLifeTime(0)
        Particle:SetDieTime(30)
        
        Particle:SetStartSize(10)
        Particle:SetEndSize(0)
        
        Particle:SetStartAlpha(255)
        Particle:SetEndAlpha(0)
end

function PooPee.DoPee(umsg)
        local ply = umsg:ReadEntity()
        local time = umsg:ReadLong()
        if not IsValid(ply) then return end
        local centr = ply:GetPos() + Vector(0,0,32)
        local em = ParticleEmitter(centr) 
        for i=1, time * 10 do 
                timer.Simple(i/100, function()
                        if not ply:IsValid() then return end
                        local part = em:Add("sprites/orangecore2",ply:GetPos() + Vector(0,0,32)) 
                        if part then 
                                part:SetVelocity(ply:GetAimVector() * 1000 + Vector(math.random(-50,50),math.random(-50,50),0) ) 
                                part:SetDieTime(30) 
                                part:SetLifeTime(1) 
                                part:SetStartSize(10) 
                                part:SetAirResistance( 100 )
                                part:SetRoll( math.Rand(0, 360) )
                                part:SetRollDelta( math.Rand(-200, 200) )
                                part:SetGravity( Vector( 0, 0, -600 ) )
                                part:SetCollideCallback(collideback)
                                part:SetCollide(true)
                                part:SetEndSize(0) 
                        end 
                end)
        end 
		timer.Simple(time, function()
			em:Finish() 
		end)
end
usermessage.Hook("PlayerPeeParticles", PooPee.DoPee)