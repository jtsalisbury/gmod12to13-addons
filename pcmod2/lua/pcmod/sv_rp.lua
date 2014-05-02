
// ---------------------------------------------------------------------------------------------------------
// sv_rp.lua - Revision 1
// Server-Side
// Allows RP commands to be used
// ---------------------------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------------------------
// Define core tables
// ---------------------------------------------------------------------------------------------------------

PCMod.RP = {}
PCMod.RP.Version = "1.0.0"

PCMod.Msg( "RolePlay Library Loaded! (V" .. PCMod.RP.Version .. ")", true )


// ---------------------------------------------------------------------------------------------------------
// Specific RP Related Commands
// ---------------------------------------------------------------------------------------------------------
// If you know how do, edit the functions below to make this addon compatible with your RP gamemode!
// For help with this, visit either the fortfn forums or the FP thread
// Editing this WRONG could cause the RP section of PCMod to STOP working!
// ---------------------------------------------------------------------------------------------------------

	function PCMod.RP.GetMoney( ply )
		// This function should return the amount of money a player has.
		// ply is the player object.
	
		return 1000
	end
	
	function PCMod.RP.CanBuy( ply, entclass )
		// This function should return if a player can buy an item or not.
		// ply is the player object.
		// entclass is the name of the object (such as 'pcmod_tower').
		// You might wish to test if the player has a certain job here, so only that job can buy stuff.
		// This function applies to hardware, software (pcmod_installdisk) and tools.
		
		return true
	end
	
	function PCMod.RP.CanBuyPack( ply, pack )
		// This function should return if a player can buy a CD pack or not.
		// ply is the player object.
		// pack is the name of the pack.
		// You might wish to test the pack against the player's job - for example, if the pack...
		// ...is 'cop', only return true if the player is a cop.
		
		return true
	end
	
	function PCMod.RP.DeductMoney( ply, amount )
		// This function should deduct the specified amount from the player's wallet.
		// You do not need to check the amount, it will be validated already.
		// ply is the player object.
		// amount is the numerical amount of money to deduct.
		// This doesn't need to return anything.
	
	end
	
// ---------------------------------------------------------------------------------------------------------
// Do not edit anything below this line
// ---------------------------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------------------------
// SpawnItem - Spawns the item in front of the player
// ---------------------------------------------------------------------------------------------------------
function PCMod.RP.SpawnItem( ply, classname, mdl, setupdata )
	if (!PCMod.Cfg.RPMode) then return end
	local tr = ply:GetEyeTrace()
	local pos = tr.HitPos
	if ((tr.HitPos-ply:GetPos()):Length() > 128) then pos = ply:GetShootPos() + (ply:GetAimVector()*128) end
	local ent = PCTool.SpawnEntity( ply, mdl, pos, Angle( 0, 0, 0 ), classname, nil, setupdata )
	// PCTool.SpawnEntity( ply, model, pos, ang, entclass, harddrive, setupdata )
	return ent
end

// ---------------------------------------------------------------------------------------------------------
// BuyItem - Will 'buy' the item, and deduct money from the player's wallet
// ---------------------------------------------------------------------------------------------------------
function PCMod.RP.BuyItem( ply, com, args )
	if (!PCMod.Cfg.RPMode) then return end
	if ((!args) || (!args[1]) || (!args[2])) then return end
	PCMod.Msg( "Buying item! (" .. table.concat( args, ", " ) .. ")", true )
	local item = tostring( args[1] )
	local wireless = false
	if (item == "#WLSS_R") then
		wireless = true
		item = "pcmod_router"
	end
	if (string.Left( item, 6 ) != "pcmod_") then return end
	if (!PCMod.RP.CanBuy( ply, item )) then
		// ply:PrintMessage( HUD_PRINTTALK, "You may not buy this item!" )
		PCMod.SendPopupNotice( ply, "Buy Item", "You may not buy this item!" )
		return
	end
	local model = tostring( args[2] )
	local mon = PCMod.RP.GetMoney( ply )
	local cost = PCMod.Cfg.RPCost[ item ]
	if (!cost) then cost = 0 end
	cost = tonumber( cost )
	if (cost < 0) then cost = 0 end
	if (cost > mon) then
		PCMod.SendPopupNotice( ply, "Buy Item", "You cannot afford this item!" )
		return
	end
	local sdat
	if ((args[3]) && (item == "pcmod_tower")) then
		sdat = {
			OS = args[3],
			BootCommand = "os:instance\nos:launch"
		}
	end
	if ((wireless) && (item == "pcmod_router")) then
		sdat = { Wireless = true }
	end
	local ent = PCMod.RP.SpawnItem( ply, item, model, sdat )
	// if (type( ent ) != "Entity") then return end
	PCMod.Msg( "About to validate entity!", true )
	if ((!ent) || (!ent:IsValid())) then return end
	PCMod.Msg( "Entity validated!!", true )
	PCMod.RP.DeductMoney( ply, cost )
	// ply:PrintMessage( HUD_PRINTTALK, "Item purchased!" )
	PCMod.SendPopupNotice( ply, "Buy Item", "Item purchased!" )
end
concommand.Add( "pc_buyitem", PCMod.RP.BuyItem )

// ---------------------------------------------------------------------------------------------------------
// BuyDisk - Will 'buy' a disk with a certain number of programs on, and deduct money from the player's wallet
// ---------------------------------------------------------------------------------------------------------
function PCMod.RP.BuyDisk( ply, com, args )
	if (!PCMod.Cfg.RPMode) then return end
	if ((!args) || (!args[1])) then return end
	if (!PCMod.RP.CanBuy( ply, "pcmod_installdisk" )) then
		// ply:PrintMessage( HUD_PRINTTALK, "You may not buy this item!" )
		PCMod.SendPopupNotice( ply, "Buy Item", "You may not buy this item!" )
		return
	end
	local id = tonumber( args[1] )
	local item = PCMod.Cfg.RPDisks[ id ]
	if (!item) then return end
	local name = tostring( item[1] )
	local cost = tonumber( item[2] )
	local pname = tostring( item[3] )
	local progs = tostring( item[4] )
	local mon = PCMod.RP.GetMoney( ply )
	if (!PCMod.RP.CanBuyPack( ply, pname )) then
		// ply:PrintMessage( HUD_PRINTTALK, "You may not buy this CD pack!" )
		PCMod.SendPopupNotice( ply, "Buy Item", "You may not buy this Install Disk pack!" )
		return
	end
	if (cost < 0) then cost = 0 end
	if (cost > mon) then
		// ply:PrintMessage( HUD_PRINTTALK, "You cannot afford this item!" )
		PCMod.SendPopupNotice( ply, "Buy Item", "You cannot afford this item!" )
		return
	end
	PCMod.Msg( "About to deduct money for Install Disk!", true )
	PCMod.RP.DeductMoney( ply, cost )
	ply:Give( "pcmod_installdisk" )
	local wep = ply:GetWeapon( "pcmod_installdisk" )
	if ((!wep) || (!wep:IsValid())) then return end
	wep:Reset()
	wep:SetPackName( name )
	if (ps != "") then
		local ps = string.Explode( ",", progs )
		for _, v in pairs( ps ) do
			if (PCMod.Progs[ v ]) then
				local title = PCMod.Progs[ v ].Title
				local osid = PCMod.Progs[ v ].OS
				wep:AddProgram( v, title, osid )
			end
		end
		//wep:AddProgram( "test1", "Test 1" )
		//wep:AddProgram( "test2", "Test 2" )
		//wep:AddProgram( "test3", "Test 3" )
	end
	// ply:PrintMessage( HUD_PRINTTALK, "Item purchased!" )
	PCMod.SendPopupNotice( ply, "Buy Item", "Item purchased!" )
end
concommand.Add( "pc_buydisk", PCMod.RP.BuyDisk )

// ---------------------------------------------------------------------------------------------------------
// BuyTool - Will 'buy' a tool
// ---------------------------------------------------------------------------------------------------------
function PCMod.RP.BuyTool( ply, com, args )
	if (!PCMod.Cfg.RPMode) then return end
	if ((!args) || (!args[1])) then return end
	local id = tonumber( args[1] )
	local item = PCMod.Cfg.RPTools[ id ]
	if (!item) then return end
	if (!PCMod.RP.CanBuy( ply, item[3] )) then
		// ply:PrintMessage( HUD_PRINTTALK, "You may not buy this item!" )
		PCMod.SendPopupNotice( ply, "Buy Item", "You may not buy this item!" )
		return
	end
	local cost = PCMod.Cfg.RPCost[ item[3] ]
	if (!cost) then cost = 0 end
	local mon = PCMod.RP.GetMoney( ply )
	if (cost < 0) then cost = 0 end
	if (cost > mon) then
		// ply:PrintMessage( HUD_PRINTTALK, "You cannot afford this item!" )
		PCMod.SendPopupNotice( ply, "Buy Item", "You cannot afford this item!" )
		return
	end
	PCMod.RP.DeductMoney( ply, cost )
	ply:Give( item[3] )
	// ply:PrintMessage( HUD_PRINTTALK, "Item purchased!" )
	PCMod.SendPopupNotice( ply, "Buy Item", "Item purchased!" )
end
concommand.Add( "pc_buytool", PCMod.RP.BuyTool )

// ---------------------------------------------------------------------------------------------------------
// OpenRPMenu - Opens the RolePlay menu
// ---------------------------------------------------------------------------------------------------------
function PCMod.RP.OpenRPMenu( ply, com, args )
	if (!PCMod.Cfg.RPMode) then return end
	umsg.Start( "pcmod_rpmenu", ply )
	umsg.End()
end
concommand.Add( "pc_rp", PCMod.RP.OpenRPMenu )