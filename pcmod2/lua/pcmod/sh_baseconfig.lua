
// ---------------------------------------------------------------------------------------------------------
// sh_baseconfig.lua - Revision 1
// Shared
// Loads all base PCMod settings
// ---------------------------------------------------------------------------------------------------------

// **********************************************************************
// * NOTE: IT IS RECOMMENDED NOT TO CHANGE ANYTHING IN THIS FILE *
// **********************************************************************

Msg( "PCMod2: Loading BASE configuation file...\n" )

_G.cfg = {} -- Do not edit

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

// -- | ============================================ | -- \\
// -- | Do NOT change ANY of the stuff BELOW this line, | -- \\
// -- | unless otherwise instructed.				    | -- \\
// -- | ============================================ | -- \\

cfg.UseJson = true -- Should we just JSON for table encoding/decoding? (If you change, all pcmod related data files will need to be deleted)
// Note - it is recommended the above is NOT changed.

cfg.Mats = {
	"gui/pcmod_logo",
	"gui/icons/ico_harddrive",
	"gui/icons/ico_app",
	"gui/icons/ico_firewall",
	"models/Chipstiks_PCMod_Models/Speakers/Black",
	"models/Chipstiks_PCMod_Models/Speakers/speaker",
	"models/Chipstiks_PCMod_Models/Speakers/speaker2",
	"models/Chipstiks_PCMod_Models/Speakers/SpeakerConnectors",
	"models/Chipstiks_PCMod_Models/Speakers/brushed-metal",
	"models/PCMod/eeePC/eeePC",
	"models/PCMod/USB/USB",
	"models/PCMod/kopierer/kopierer",
	"models/PCMod/wrt54g/BEIGE",
	"models/PCMod/wrt54g/BLUE",
	"models/PCMod/wrt54g/FRONT",
	"models/PCMod/wrt54g/GREY",
	"models/PCMod/wrt54g/LINKSYS",
	"models/PCMod/wrt54g/GREEN",
	"models/PCMod/wrt54g/BLACK",
	"models/darksunrise/computer",
	"models/darksunrise/computer_ref",
	"models/darksunrise/screen",
	"models/darksunrise/screenb",
	"models/darksunrise/screenc",
	"models/darksunrise/screend"
}

cfg.Models = {
	"Chipstiks_PCMod_Models/Speakers/StandardSpeakerMetal",
	"pcmod/eeepc",
	"pcmod/kopierer",
	"pcmod/usb",
	"pcmod/wrt54g",
	"darksunrise/monitor01"
}

list.Set( "pc_oslist", "personal", {} )
list.Set( "pc_oslist", "server", {} )

cfg.PCC_FLOOD = -1 -- _OBSOLETE_ as of now, may have use later on

cfg.RPItems = {
	{ "pcmod_tower", 	"Tower", 	"models/props_lab/harddrive02.mdl" },
	{ "pcmod_monitor", 	"Monitor", 	"models/props_lab/monitor01a.mdl" },
	{ "pcmod_tower", 	"Tower", 	"models/props/cs_office/computer_case.mdl" },
	{ "pcmod_monitor", 	"Monitor", 	"models/props/cs_office/computer_monitor.mdl" },
	{ "pcmod_keyboard", "Keyboard", "models/props_c17/computer01_keyboard.mdl" },
	{ "pcmod_speaker", 	"Speaker", 	"models/Chipstiks_PCMod_Models/Speakers/StandardSpeakerMetal.mdl" },
	{ "pcmod_splitter",	"Splitter",	"models/props_lab/tpplug.mdl" },
	{ "pcmod_printer",	"Printer",	"models/pcmod/kopierer.mdl" },
	{ "pcmod_router",	"Router",	"models/props_lab/reciever01a.mdl" },
	{ "#WLSS_R",		"Wireless Router", "models/PCMod/wrt54g.mdl" },
	{ "pcmod_brouter",	"Backbone Router", "models/props_lab/reciever01a.mdl" },
	{ "pcmod_laptop",	"Laptop",	"models/pcmod/eeepc.mdl" }
}

cfg.RPTools = {
	{ "models/weapons/w_c4.mdl", 	"Hard-Drive Copier", 	"pcmod_hdcopier" },
	{ "models/weapons/w_c4.mdl", 	"Password Cracker", 	"pcmod_pwcrack" }
}

cfg.Music = {
	[ "Half-Life 2" ] = {
		{ "Intro Song", "music/hl2_intro.mp3" },
		{ "Song 1", "music/hl2_song1.mp3" },
		{ "Song 2", "music/hl2_song2.mp3" },
		{ "Song 3", "music/hl2_song3.mp3" },
		{ "Song 4", "music/hl2_song4.mp3" },
		{ "Song 6", "music/hl2_song6.mp3" },
		{ "Song 7", "music/hl2_song7.mp3" },
		{ "Song 8", "music/hl2_song8.mp3" },
		{ "Song 10", "music/hl2_song10.mp3" },
		{ "Song 11", "music/hl2_song11.mp3" },
		{ "Song 12", "music/hl2_song12_long.mp3" },
		{ "Song 13", "music/hl2_song13.mp3" },
		{ "Song 14", "music/hl2_song14.mp3" },
		{ "Song 15", "music/hl2_song15.mp3" },
		{ "Song 16", "music/hl2_song16.mp3" },
		{ "Song 17", "music/hl2_song17.mp3" },
		{ "Song 19", "music/hl2_song19.mp3" },
		{ "Song 20A", "music/hl2_song20_submix0.mp3" },
		{ "Song 20B", "music/hl2_song20_submix4.mp3" },
		{ "Suit Song", "music/hl2_song23_SuitSong3.mp3" },
		{ "Song 25", "music/hl2_song25_Teleporter.mp3" },
		{ "Song 26", "music/hl2_song26.mp3" },
		{ "Song 27", "music/hl2_song27_trainstation2.mp3" },
		{ "Song 28", "music/hl2_song28.mp3" },
		{ "Song 29", "music/hl2_song29.mp3" },
		{ "Song 30", "music/hl2_song30.mp3" },
		{ "Song 31", "music/hl2_song31.mp3" },
		{ "Song 32", "music/hl2_song32.mp3" },
		{ "Song 33", "music/hl2_song33.mp3" }
	}, // *sigh* if you MUST add stuff here, just follow the same format as the rest.  -thomasfn
	[ "Portal" ] = {
		{ "Still Alive", "music/portal_still_alive.mp3" },
		{ "4000 Degrees", "music/portal_4000_degrees_kelvin.mp3" },
		{ "Android Hell", "music/portal_android_hell.mp3" },
		{ "No Cake", "music/portal_no_cake_for_you.mp3" },
		{ "Party Escort", "music/portal_party_escort.mp3" },
		{ "Jiggle Bone", "music/portal_procedural_jiggle_bone.mp3" },
		{ "Self Esteem", "music/portal_self_esteem_fund.mp3" },
		{ "Stop It", "music/portal_stop_what_you_are_doing.mp3" },
		{ "Subject Name", "music/portal_subject_name_here.mp3" },
		{ "Taste Of Blood", "music/portal_taste_of_blood.mp3" },
		{ "No Escape", "music/portal_you_cant_escape_you_know.mp3" },
		{ "Bad Person", "music/portal_youre_not_a_good_person.mp3" }
	},
	[ "Custom" ] = cfg.CustomSongs
}

cfg.StatusCodes = {
	[000] = "",
	[001] = "Success!",
	[002] = "Failure!",
	[003] = "Unknown Error",
	[004] = "File Saved",
	[005] = "File Opened",
	[006] = "Unsaved Changes",
	[007] = "No Printer Hardware",
	[008] = "File Printed",
	[009] = "Invalid Filename",
	[010] = "==| BIOS Initialised |==",
	[011] = "==| Version: 1.0.0 |==",
	[012] = "-> Running execution command...",
	[013] = "-> Awaiting command...",
	[014] = "OS already instanced!",
	[015] = "No OS detected!",
	[016] = "OS Installation Invalid!",
	[017] = "OS instance created!",
	[018] = "OS not instanced!",
	[019] = "Launching OS...",
	[020] = "Target pinged successfully!",
	[021] = "Waiting for response...",
	[022] = "Ping timed out!",
	[023] = "Target traced successfully!",
	[024] = "Trace timed out!",
	[025] = "Target port closed!",
	[026] = "Target port locked!",
	[027] = "Failed to connect!",
	
}

cfg.InstallDiskModel	=		"models/weapons/w_c4.mdl"

cfg.DataFolderRoot = "pcmod/"

cfg.PlayerPath = "players/"
cfg.LogPath = "logs/"
cfg.DumpPath = "datadump/"

if (CLIENT) then
	cfg.BadHooks = {
		{ "CalcView", "MyCalcView" }
	}
end

if (SERVER) then
	cfg.BadHooks = {}
end

Msg( "PCMod2: Loading ACTUAL configuation file...\n" )
include( "pcmod/sh_config.lua" )
if (!cfg.Loaded) then
	Error( "PCMod2: Failed to load config!\n" )
else
	Msg( "PCMod2: Configuration file loaded!\n" )
end


PCMod.Cfg = table.Copy( cfg ) -- Do not edit
cfg = nil