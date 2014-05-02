
// Personal Player Program for PCMod 2 \\

PROG.Name = "pplayer"
PROG.Author = "[GU]thomasfn"
PROG.Title = "Personal Player"
PROG.Icon = "app"
PROG.OS = "personal"

PROG.SimpleMode = true

PROG.DeviceLink = "window_pplayer"
PROG.DeviceName = "window_pplayer"
PROG.DeviceData = {}

function PROG:DoCommand( com, args )
	if (com == "exit") then
		self:Exit()
		return
	end
	if (com == "play_sound") then
		self:GetOS():RunCommand( "snd_stop" )
		self:GetOS():RunCommand( "snd_play " .. args[1] )
		self.DeviceData.Snd = args[1]
		self:UpdateSS()
	end
	if (com == "stop_sound") then
		self:GetOS():RunCommand( "snd_stop" )
		self.DeviceData.Snd = ""
		self:UpdateSS()
	end
end