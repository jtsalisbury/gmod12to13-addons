
// ---------------------------------------------------------------------------------------------------------
// sh_logging.lua - Revision 1
// Shared
// Performs log related functions
// ---------------------------------------------------------------------------------------------------------

PCMod.BufferSaved = { 0, 0, 0, 0 }
PCMod.AddLogBuffer = ""

// ---------------------------------------------------------------------------------------------------------
// SaveLogPre - Tells the client, or everyone if its server-side, that logs are about to be saved,
// then saves logs after 5 seconds
// ---------------------------------------------------------------------------------------------------------
function PCMod.SaveLogPre( force )
	if (force && !PCMod.Cfg.LogMessages) then
			timer.Simple( 4, function() PCMod.Cfg.LogMessages = true; end )
			timer.Simple( 6, function() PCMod.Cfg.LogMessages = false; end )
		end
	if (SERVER) then
		PCMod.GMsg( PCMod.Cfg.SVLogMessage )
	else
		PCMod.Notice( PCMod.Cfg.CLLogMessage )
	end
	timer.Simple( 5, function() PCMod.SaveLog(nil) end )
end
// ---------------------------------------------------------------------------------------------------------
// SaveLog - Run on timer to save logs
// ---------------------------------------------------------------------------------------------------------
function PCMod.SaveLog()
	local tmp = 0
	local i
	for i = 1, table.maxn(PCMod.MsgDebugBuffer), 1 do
		if (PCMod.MsgDebugBuffer[i][1] > PCMod.BufferSaved[1]) then
			tmp = math.max( tmp, PCMod.BufferSaved[1] )
			tmp = math.max( tmp, PCMod.MsgDebugBuffer[i][1] )
			PCMod.AddLog( "MsgDebug", os.date("!%d%b%y %H %M %S"), PCMod.MsgDebugBuffer[i][2] )
		end
	end
	PCMod.BufferSaved[1] = tmp
	PCMod.CommitLog( "MsgDebug" )
	tmp = 0
	for i = 1, table.maxn(PCMod.MsgBuffer), 1 do
		if (PCMod.MsgBuffer[i][1] > PCMod.BufferSaved[2]) then
			tmp = math.max( tmp, PCMod.BufferSaved[2] )
			tmp = math.max( tmp, PCMod.MsgBuffer[i][1] )
			PCMod.AddLog( "Msg", os.date("!%d%b%y %H %M %S"), PCMod.MsgBuffer[i][2] )
		end
	end
	PCMod.BufferSaved[2] = tmp
	PCMod.CommitLog( "Msg" )
	tmp = 0
	for i = 1, table.maxn(PCMod.WarningBuffer), 1 do
		if (PCMod.WarningBuffer[i][1] > PCMod.BufferSaved[3]) then
			tmp = math.max( tmp, PCMod.BufferSaved[3] )
			tmp = math.max( tmp, PCMod.WarningBuffer[i][1] )
			PCMod.AddLog( "Warning", os.date("!%d%b%y %H %M %S"), PCMod.WarningBuffer[i][2] )
		end
	end
	PCMod.BufferSaved[3] = tmp
	PCMod.CommitLog( "Warning" )
	tmp = 0
	for i = 1, table.maxn(PCMod.ErrorBuffer), 1 do
		if (PCMod.ErrorBuffer[i][1] > PCMod.BufferSaved[4]) then
			tmp = math.max( tmp, PCMod.BufferSaved[4] )
			tmp = math.max( tmp, PCMod.ErrorBuffer[i][1] )
			PCMod.AddLog( "Error", os.date("!%d%b%y %H %M %S"), PCMod.ErrorBuffer[i][2] )
		end
	end
	PCMod.BufferSaved[4] = tmp
	PCMod.CommitLog( "Error" )
	if (table.maxn(PCMod.MsgDebugBuffer) > 100) then
		for i = table.maxn(PCMod.MsgDebugBuffer), 100, -1 do
			table.remove(PCMod.MsgDebugBuffer, 1)
		end
	end
	if (table.maxn(PCMod.MsgBuffer) > 20) then
		for i = table.maxn(PCMod.MsgBuffer), 20, -1 do
			table.remove(PCMod.MsgBuffer, 1)
		end
	end
	if (table.maxn(PCMod.WarningBuffer) > 20) then
		for i = table.maxn(PCMod.WarningBuffer), 20, -1 do
			table.remove(PCMod.WarningBuffer, 1)
		end
	end
	if (table.maxn(PCMod.ErrorBuffer) > 20) then
		for i = table.maxn(PCMod.ErrorBuffer), 20, -1 do
			table.remove(PCMod.ErrorBuffer, 1)
		end
	end
end
timer.Adjust( "PCMod.SaveLog", PCMod.Cfg.LogInterval*60, 0, PCMod.SaveLogPre, nil )
if (PCMod.Cfg.LogMessages) then timer.Start( "PCMod.SaveLog" ) end

// ---------------------------------------------------------------------------------------------------------
// AddLog - Creates log file and prepares to append it
// ---------------------------------------------------------------------------------------------------------
function PCMod.AddLog( fname, date, msgtext )
	if (!PCMod.Cfg.LogMessages) then return end
	PCMod.AddLogBuffer = PCMod.AddLogBuffer.."\n["..date.."] "..msgtext
end

// ---------------------------------------------------------------------------------------------------------
// CommitLog - Appends log file
// ---------------------------------------------------------------------------------------------------------
function PCMod.CommitLog( fname )
	if (!PCMod.Cfg.LogMessages) then return end
	local root = PCMod.Cfg.DataFolderRoot .. PCMod.Cfg.LogPath
	if (!file.Exists( root, "DATA")) then
		file.CreateDir( root )
	end
	if (CLIENT) then root = root .. "client_" end
	if (SERVER) then root = root .. "server_" end
	if (!file.Exists( root .. fname .. ".txt", "DATA")) then
		local text = file.Read(root..fname..".txt", "DATA");
		local new_text = "\n---[Type "..fname.."]---\n---[Date Format ddmmmyy hh mm ss]---";
		
		file.Write(root .. fname .. ".txt", text)
		//filex.Append(root .. fname .. ".txt", "\n---[Type "..fname.."]---\n---[Date Format ddmmmyy hh mm ss]---")
	end
	//filex.Append(root .. fname .. ".txt", PCMod.AddLogBuffer)
	PCMod.AddLogBuffer = ""
end

// ---------------------------------------------------------------------------------------------------------
// GetSvSMessages - Gets serverside buffers and displays in derma
// ---------------------------------------------------------------------------------------------------------
if (SERVER) then
	function PCMod.GetSvSMessages( ply, com, args )
		if (CLIENT) then return end
		
		if (!args[1]) then
			ply:PrintMessage( HUD_PRINTCONSOLE, "pc_getsvsmessages <Password>" )
			return
		end
		
		if (args[1] != PCMod.Cfg.DbgPass) then
			ply:PrintMessage( HUD_PRINTCONSOLE, "invalid password" )
			return
		end

		local tmp
		local tbl = {}
		tbl.MsgDebug = {}
		tmp = table.Copy( PCMod.MsgDebugBuffer )
		if (table.maxn(tmp) > 100) then
			for i = table.maxn(tmp), 100, -1 do
				table.remove(tmp, 1)
			end
		end
		local temp
		for i = 0, table.maxn(tmp), 1 do
			temp = table.remove(tmp, i)
			if (temp != nil) then
				table.insert(tbl.MsgDebug, i, temp[2])
			end
		end

		tmp = table.Copy( PCMod.MsgBuffer )
		tbl.Msg = {}
		if (table.maxn(tmp) > 20) then
			for i = table.maxn(tmp), 20, -1 do
				table.remove(tmp, 1)
			end
		end
		local temp
		for i = 0, table.maxn(tmp), 1 do
			temp = table.remove(tmp, i)
			if (temp != nil) then
				table.insert(tbl.Msg, i, temp[2])
			end
		end

		tmp = table.Copy( PCMod.WarningBuffer )
		tbl.Warning = {}
		if (table.maxn(tmp) > 20) then
			for i = table.maxn(tmp), 20, -1 do
				table.remove(tmp, 1)
			end
		end
		local temp
		for i = 0, table.maxn(tmp), 1 do
			temp = table.remove(tmp, i)
			if (temp != nil) then
				table.insert(tbl.Warning, i, temp[2])
			end
		end

		tmp = table.Copy( PCMod.ErrorBuffer )
		tbl.Error = {}
		if (table.maxn(tmp) > 20) then
			for i = table.maxn(tmp), 20, -1 do
				table.remove(tmp, 1)
			end
		end
		local temp
		for i = 0, table.maxn(tmp), 1 do
			temp = table.remove(tmp, i)
			if (temp != nil) then
				table.insert(tbl.Error, i, temp[2])
			end
		end

		PCMod.Beam.BeamTable( ply, "GetSvSMessages", tbl )
	end
	concommand.Add( "pc_getsvsmessages", PCMod.GetSvSMessages )
end
if (CLIENT) then
	
	function PCMod.ShowSvSMessages( str )
		// Remove existing window
		if (PCMod.Beam.SVSWin) then
			// PCMod.Beam.SVSWin:Remove()
			PCMod.Beam.SVSWin = nil
		end

		local tbl = PCMod.StringToTable( str )
		
		// Create the window
		local win = vgui.CreateWindow( 0.8, 0.8, "Get ServerSide Message Buffer", true )
		win:MakePopup()
		win:SetVisible( true )

		local sheet = vgui.CreateSheet( win )
		local tb_md = vgui.AddTab( sheet, Color( 50, 50, 50, 255 ), "Debug Messages", "page_white_wrench" )
		local tb_m = vgui.AddTab( sheet, Color( 50, 50, 50, 255 ), "Messages", "page" )
		local tb_w = vgui.AddTab( sheet, Color( 50, 50, 50, 255 ), "Warnings", "shield" )
		local tb_e = vgui.AddTab( sheet, Color( 50, 50, 50, 255 ), "Errors", "exclamation" )

		for _, v in pairs(tbl.MsgDebug) do
			if (v != nil) then
				vgui.AddText( tb_md, v )
			end
		end
		for _, v in pairs(tbl.Msg) do
			if (v != nil) then
				vgui.AddText( tb_m, v )
			end
		end
		for _, v in pairs(tbl.Warning) do
			if (v != nil) then
				vgui.AddText( tb_w, v )
			end
		end
		for _, v in pairs(tbl.Error) do
			if (v != nil) then
				vgui.AddText( tb_e, v )
			end
		end
		
		// Save the window
		PCMod.Beam.SVSWin = win
	end
	timer.Simple( 3, function() PCMod.Beam.Hook( "GetSvSMessages", PCMod.ShowSvSMessages ); end )
	
end