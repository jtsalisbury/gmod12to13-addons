
// ---------------------------------------------------------------------------------------------------------
// sh_config.lua - Revision 1
// Shared
// Loads all PCMod settings
// ---------------------------------------------------------------------------------------------------------


cfg.UsePCModTags 		=	false -- Change sv_tags?
cfg.PCModTags 			=	"pcmod2" -- Change to what?

cfg.TimedMessage 		= 	true -- Show a timed message advertising PCMod?
cfg.TimedMessageDelay 	= 	300 -- Message delay (seconds)
cfg.Message 			= 	"This server uses PCMod " .. PCMod.Version .. "!" -- What message to show

cfg.DebugMode 			= 	false -- Is the addon in debug mode?
cfg.LogMessages			= 	false -- Should we log messages to file?
cfg.LogInterval			= 	15 -- Minutes in-between logging saves if above is true
cfg.SVLogMessage			= 	"PCMod is saving serverside logs. This may cause some lag" -- Message to show when saving logs (SV)
cfg.CLLogMessage			= 	"PCMod is saving clientside logs. This may cause some lag" -- Message to show when saving logs (CL)
cfg.RPMode 				= 	true -- Should the addon enable RP mode?

if (SERVER) then -- Security, dont want clients to somehow access this
	cfg.DbgPass			=	"pcm201" -- Password to retrieve server-side debugging as a client
end -- Do not edit

cfg.RPCost = { -- Do not edit
	pcmod_tower 	=	250, -- Cost for a tower
	pcmod_monitor 	= 	100, -- Cost for a monitor
	pcmod_keyboard 	= 	25, -- Cost for a keyboard
	pcmod_router 	=	80, -- Cost for a router
	pcmod_brouter 	= 	120, -- Cost for a backbone router
	pcmod_speaker 	= 	50, -- Cost for a speaker
	pcmod_printer	=	100, -- Cost for a printer
	pcmod_hdcopier	=	150, -- Cost for a hard drive copier
	pcmod_pwcrack	=	600, -- Cost for a password cracker
	pcmod_splitter	=	25, -- Cost for a sound splitter
	["#WLSS_R"]		=	100, -- Cost for a wireless router
	pcmod_laptop	=	350, -- Cost for a laptop
} -- Do not edit

// Note that the above costs only apply to buying items through the RP interface.
// Spawning items using the toolgun costs nothing.
// In order for the above to work, you will need to make changes to sv_rp.lua.
// See the forums for more information.

// Below, you can add your own songs to PersonalPlayer. They will come up on the custom tab.
cfg.CustomSongs = { -- Do not edit
	// { "music/SONG_NAME.mp3", "Song Name Here" }, -- EXAMPLE
	// { "music/SONG_NAME2.mp3, "Second Song Name Here" }, -- EXAMPLE
} -- Do not edit

cfg.FullProgramList = "chathost,printshare,chatserv,pplayer,firewall,p2pchat,iocontroller,alarmz" -- A list of all programs that can be installed (don't change this unless you are adding in a new program)

// Below, you can edit or make new Install Disk packs. The last paremeter is a list of programs (for example: "mycomputer,notepad")
// The first parameter is the name of the pack, and the second parameter is the cost of the pack
// The third parameter is the internal (short) name of the pack - leave it in lower-case and with no spaces
cfg.RPDisks = { -- Do not edit
	{ "Ultimate Pack", 		250, 	"ulti", 	cfg.FullProgramList }, -- Ultimate pack
	{ "Chat Pack", 			100,	"chat",		"chathost,chatserv,p2pchat" },
	{ "Security Pack",		100,	"secur",	"firewall,alarmz" },
	{ "Misc Pack",			100,	"misc",		"pplayer,iocontroller" }
} -- Do not edit

cfg.ReachDistance = 256 -- How far away can a person reach? (For keyboards)
cfg.SightRange = 1024 -- How far away can a person see? (For monitor screens)
cfg.WirelessRange = 2048 -- How far away can a wireless router reach? (0 = Unlimited Range)
cfg.WirelessInfo = true -- Should we draw wireless links when looking at a wireless router?
cfg.WirelessInfoDrawCol = Color( 255, 0, 0, 255 )

cfg.QuickType = 3 -- 0 = Completely disabled, 1 = debug mode only, 2 = keyboard only OR debug mode, 3 = always on

cfg.PrintTime = 5 -- How long does it take to print a document? (Seconds)

cfg.CamLockSmoothTime = 1 -- How long does it take for the camera to center on a monitor? (Seconds) (0 = instant)

cfg.IO_Inputs = { "A", "B", "C", "D", "E", "F" } -- A list of all the inputs of a wired I/O device (you wire buttons and stuff to these)
cfg.IO_Outputs = { "1", "2", "3", "4", "5", "6" } -- A list of all the outputs of a wired I/O device (you wire screens and lights to these)

cfg.AdvancedMode = false -- Enable/disable advanced mode (Using a PC without camlock)

cfg.MaxNetworkPass = 50 -- What's the maximum amount of routers a packet can pass through in one go?

cfg.HighQuality = true -- Should the client use theme hooks? (3D form elements)

cfg.WireTypes = {} -- Do not edit

// It is recommended you do not edit any of the things below unless you are an experienced Lua coder and want to make changes to the addon.

cfg.WireTypes[ 1 ] = { Name="vga", 		ExtName="VGA Display", 		SameType=false } -- VGA Display Cable (Tower -> Monitor)
cfg.WireTypes[ 2 ] = { Name="usb", 		ExtName="USB Port", 		SameType=false } -- USB Cable (Misc devices)
cfg.WireTypes[ 3 ] = { Name="network", 	ExtName="Network", 			SameType=false } -- Network Cable (Tower -> Router)
cfg.WireTypes[ 4 ] = { Name="optic", 	ExtName="Fibre Optic", 		SameType=true } -- Fibre optic cable (Router -> Router)
cfg.WireTypes[ 5 ] = { Name="ps2", 		ExtName="PS2 Connection", 	SameType=false } -- PS2 cable (Keyboard -> Tower)
cfg.WireTypes[ 6 ] = { Name="minijack", ExtName="Mini-Jack Port", 	SameType=false } -- MiniJack port (Splitter -> Tower)
cfg.WireTypes[ 7 ] = { Name="phono",	ExtName="Phono Connection",	SameType=false } -- Phono cable (Speaker -> Splitter)

cfg.Loaded = true -- Do not edit