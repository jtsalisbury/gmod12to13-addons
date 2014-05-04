if( SERVER ) then
        AddCSLuaFile( "portalmove.lua" );
end

if( CLIENT ) then
       
        /*------------------------------------
                CreateMove()
        ------------------------------------*/
        local function CreateMove( cmd )
       
                local pl = LocalPlayer();
                if( IsValid( pl ) ) then
               
                        if( pl.InPortal ) then

                                local right = 0;
                                local forward = 0;
                                local maxspeed = pl:GetMaxSpeed();
                               
                                // forward/back
                                if( cmd:KeyDown( IN_FORWARD ) ) then
                               
                                        forward = forward + maxspeed;
                               
                                end
                                if( cmd:KeyDown( IN_BACK ) ) then
                               
                                        forward = forward - maxspeed;
                               
                                end
                               
                                // left/right
                                if( cmd:KeyDown( IN_MOVERIGHT ) ) then
                               
                                        right = right + maxspeed;
                               
                                end
                                if( cmd:KeyDown( IN_MOVELEFT ) ) then
                               
                                        right = right - maxspeed;
                               
                                end
                               
                                cmd:SetForwardMove( forward );
                                cmd:SetSideMove( right );
                       
                        end
               
                end
       
        end
        hook.Add( "CreateMove", "Noclip.CreateMove", CreateMove );

end

function SubAxis( v, x )
        return v - ( v:Dot( x ) * x )
end

function ipMove( ply, mv )

        if IsValid( ply.InPortal ) then

                if ply:GetMoveType() != MOVETYPE_NOCLIP then
                        return
                end
       
                local deltaTime = FrameTime()
               
                // I hate having to get these by name like this.
                local noclipSpeed = 1.75
                local noclipAccelerate = 5
               
                // calculate acceleration for this frame.
                local ang = mv:GetMoveAngles()
                local acceleration = ( ang:Forward() * mv:GetForwardSpeed() ) + ( ang:Right() * mv:GetSideSpeed() )
               
                local pos = mv:GetOrigin() + Vector( 0, 0, 38 )
                local pOrg = ply.InPortal:GetPos()
                local pAng = ply.InPortal:GetAngles()
                local off = pos - pOrg
                local vOff = SubAxis( SubAxis( off,pAng:Right() ), pAng:Forward() )
               
                if ply:GetPos().z > math.abs( ( ply.InPortal:GetUp() * -42 ).z ) then
                       
                        acceleration.z = -150
                       
                else
               
                        acceleration.z = 0
                       
                end
               
                // clamp to our max speed, and take into account noclip speed
                local accelSpeed = math.min( acceleration:Length(), ply:GetMaxSpeed() );
                local accelDir = acceleration:GetNormal()
                acceleration = accelDir * accelSpeed * noclipSpeed
               
                // calculate final velocity with friction
                local getvel = mv:GetVelocity()
                local newVelocity = getvel + acceleration * deltaTime * noclipAccelerate;
                newVelocity = newVelocity * ( 0.98 - deltaTime * 5 )
                --newVelocity.z = newVelocity.z - 20
               
                if vOff:Length() > 16 then
               
                        off = SubAxis( off, pAng:Up() ) + vOff:GetNormal() * 16
                       
                end
               
                local hOff = SubAxis( SubAxis( off, pAng:Up() ), pAng:Forward() )
               
                if hOff:Length() > 15 then
               
                        off = SubAxis( off, pAng:Right() ) + hOff:GetNormal() * 15
                       
                end

                // set velocity
                mv:SetVelocity( newVelocity )
               
                // move the player
                mv:SetOrigin( ( pOrg + off - Vector( 0, 0, 38 ) + newVelocity * deltaTime ) )
               
                return true;
        end
end
hook.Add("Move","hpdMoveHook",ipMove)

