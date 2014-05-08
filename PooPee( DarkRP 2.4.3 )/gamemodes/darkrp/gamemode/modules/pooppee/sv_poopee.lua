SetGlobalInt("poopeemod", 1);

function PooPee.UpdatePoop(ply)
    if not IsValid(ply) then return end
    ply:SetDarkRPVar("Poop", math.Clamp((ply.DarkRPVars.Poop or 0) + 1, 0, 100))
    if ply.DarkRPVars.Poop >= 100 then
        GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed * 0.5, GAMEMODE.Config.runspeed * 0.5)
    end
end

function PooPee.UpdatePee(ply)
    if not IsValid(ply) or GetGlobalInt("poopeemod") ~= 1 then return end
    ply:SetDarkRPVar("Pee", math.Clamp((ply.DarkRPVars.Pee or 0) + 1, 0, 100) )
    if ply.DarkRPVars.Pee >= 100 then
        PooPee.DoPee(ply)
    end
end

function PooPee.PlayerSpawn(ply)
    ply:GetTable().LastPeeUpdate = CurTime()
    ply:GetTable().LastPoopUpdate = CurTime()
end
hook.Add("PlayerSpawn", "PooPee.PlayerSpawn", PooPee.PlayerSpawn)

function PooPee.AteFood(ply, food)
    if GetGlobalInt("poopeemod") ~= 1 then return end
    local food2 = string.lower(food)
    if string.find(food2, "milk") or string.find(food2, "bottle") or string.find(food2, "popcan") then
        ply:SetDarkRPVar("Pee", math.Clamp(ply.DarkRPVars.Pee + 9, 0, 100))
        PooPee.UpdatePee(ply)
    else
        ply:SetDarkRPVar("Poop", math.Clamp(ply.DarkRPVars.Poop + 9, 0, 100))
        PooPee.UpdatePoop(ply)
    end
end

function PooPee.Think()
    if GetGlobalInt("poopeemod") ~= 1 then return end

    for k, v in pairs(player.GetAll()) do
        if not v:GetTable().LastPeeUpdate then
			v:GetTable().LastPeeUpdate = CurTime()
        end
                        
        if not v:GetTable().LastPoopUpdate then
			v:GetTable().LastPoopUpdate = CurTime()
        end
                        
        if v:Alive() and CurTime() - v:GetTable().LastPoopUpdate > 12 then
			PooPee.UpdatePoop(v)
			v:GetTable().LastPoopUpdate = CurTime()
        end
                        
        if v:Alive() and CurTime() - v:GetTable().LastPeeUpdate > 6  then
            PooPee.UpdatePee(v)
            v:GetTable().LastPeeUpdate = CurTime()
        end
    end
end
hook.Add("Think", "PooPee.Think", PooPee.Think)


function PooPee.DoPoo(ply)
    if not ply:Alive() or ply.DarkRPVars.Poop < 30 then
       GAMEMODE:Notify(ply,1,6, string.format(LANGUAGE.unable, "/poo", ""))
        return ""
    end
    local turd = ents.Create("prop_physics")
    turd:SetModel("models/Gibs/HGIBS_spine.mdl")
    turd.ShareGravgun = true
    turd:SetPos(ply:GetPos() + Vector(0,0,32))
    turd:Spawn()
    turd:SetColor(80, 45, 0, 255)
    turd:SetMaterial("models/props_pipes/pipeset_metal") 
    ply:SetDarkRPVar("Poop", 0)
    ply:EmitSound("ambient/levels/canals/swamp_bird2.wav", 50, 80)
    GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed , GAMEMODE.Config.runspeed)
    timer.Simple(30, function() if turd:IsValid() then turd:Remove() end end)
    return ""
end
AddChatCommand("/poo", PooPee.DoPoo)
AddChatCommand("/poop", PooPee.DoPoo)

function PooPee.DoPee(ply)
    if GetGlobalInt("poopeemod") ~= 1 then
       GAMEMODE:Notify(ply,1,4, string.format(LANGUAGE.disabled, "/pee", ""))
        return ""
    end
    if not ply:Alive() then return "" end
                
    umsg.Start("PlayerPeeParticles") -- usermessage to everyone
        umsg.Entity(ply)
        umsg.Long(ply.DarkRPVars.Pee)
    umsg.End()
                
    local sound = CreateSound(ply, "ambient/water/leak_1.wav")
    sound:Play()
    timer.Simple(ply.DarkRPVars.Pee/10, function() sound:Stop() ply:SetDarkRPVar("Pee", 0) end)
    return "" 
end
AddChatCommand("/pee", PooPee.DoPee)

concommand.Add("rp_poopeemod", function(ply, cmd, args)
	if (!args) then print("1/0 pls!") return; end
	
	SetGlobalInt("poopeemod", tonumber(args[1]));
end)
