
// Test Program for PCMod 2 \\

PROG.Name = "test"
PROG.Author = "gmt2001"
PROG.Title = "Render Test"
PROG.Icon = "app"
PROG.OS = "personal"

PROG.SimpleMode = true

PROG.DeviceLink = "window_test"
PROG.DeviceName = "window_test"
PROG.DeviceData = {}

function PROG:DoCommand( com, args )
	if (com == "exit") then
		self:Exit()
		return
	end
end