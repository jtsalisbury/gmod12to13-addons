
// ---------------------------------------------------------------------------------------------------------
// cl_input.lua - Revision 1
// Client-Side
// Defines the keyboard input library (thanks to Kogitstune)
// ---------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------------------
// Define the module
// ---------------------------------------------------------------------------------------------------------

module( "keyboard", package.seeall )

local Latency, Available, Keys, Keys_Shift, Typing, Callback

Keys            = { }
Keys_Shift		= { }
Available       = { }
Latency         = 200 / 1000
Typing          = false
Callback        = print

function SetLatency( m )
	Latency = m / 1000
end

function EnableCapture( b )
	Typing = b
end

function AddKey( key, value, shiftvalue )
	if (!shiftvalue) then shiftvalue = string.upper( value ) end
	Keys[ key ] = value
	Keys_Shift[ key ] = shiftvalue
	Available[ key ] = true
end

function Reset( )
	local k, v
	EnableCapture( false )
	
	for k, v in pairs( Available ) do
		Available[ k ] = true
	end
end

function SetCallback( callback )
	Callback = callback
end

function SetKeyPressCallback( callback )
	KeyPressCallback = callback
end

local function PlayerBindPress( pl, bnd )
	if Typing then
		if (bnd != "toggleconsole") then
			return true
		end
	end
end

local function EnableKey( key )
	Available[ key ] = true
end

local function InputEntered( key )
	Callback( key )
end

local function Think( )
	local k, v, shift, sent, val
	
	if not Typing then
		return
	end
	
	shift = input.IsKeyDown( KEY_LSHIFT ) || input.IsKeyDown( KEY_RSHIFT )
	
	for k, v in pairs( Keys ) do
		if ((Available[ k ]) && (input.IsKeyDown( k ))) then
			val = v
			if (shift) then val = Keys_Shift[ k ] end
			InputEntered( val )
			Available[ k ] = false
			timer.Simple( Latency, EnableKey, k )
		end
	end
end

hook.Add( "Think", "Keyboard:Think2", Think )
hook.Add( "PlayerBindPress", "Keyboard:BindPress", PlayerBindPress )

AddKey( KEY_1,		"1", "!" )
AddKey( KEY_2,		"2", "\"" )
AddKey( KEY_3,		"3", "£" )
AddKey( KEY_4,		"4", "$" )
AddKey( KEY_5,		"5", "%" )
AddKey( KEY_6,		"6", "^" )
AddKey( KEY_7,		"7", "&" )
AddKey( KEY_8,		"8", "*" )
AddKey( KEY_9,		"9", "(" )
AddKey( KEY_0,		"0", ")" )
AddKey( KEY_PAD_1,	"1" )
AddKey( KEY_PAD_2,	"2" )
AddKey( KEY_PAD_3,	"3" )
AddKey( KEY_PAD_4,	"4" )
AddKey( KEY_PAD_5,	"5" )
AddKey( KEY_PAD_6,	"6" )
AddKey( KEY_PAD_7,	"7" )
AddKey( KEY_PAD_8,	"8" )
AddKey( KEY_PAD_9,	"9" )
AddKey( KEY_PAD_0,	"0" )
AddKey( KEY_A,		"a" )
AddKey( KEY_B,		"b" )
AddKey( KEY_C,		"c" )
AddKey( KEY_D,		"d" )
AddKey( KEY_E,		"e" )
AddKey( KEY_F,		"f" )
AddKey( KEY_G,		"g" )
AddKey( KEY_H,		"h" )
AddKey( KEY_I,		"i" )
AddKey( KEY_J,		"j" )
AddKey( KEY_K,		"k" )
AddKey( KEY_L,		"l" )
AddKey( KEY_M,		"m" )
AddKey( KEY_N,		"n" )
AddKey( KEY_O,		"o" )
AddKey( KEY_P,		"p" )
AddKey( KEY_Q,		"q" )
AddKey( KEY_R,		"r" )
AddKey( KEY_S,		"s" )
AddKey( KEY_T,		"t" )
AddKey( KEY_U,		"u" )
AddKey( KEY_V,		"v" )
AddKey( KEY_W,		"w" )
AddKey( KEY_X,		"x" )
AddKey( KEY_Y,		"y" )
AddKey( KEY_Z,		"z" )

AddKey( KEY_LBRACKET,		"[", "{" )
AddKey( KEY_RBRACKET,		"]", "}" )
AddKey( KEY_APOSTROPHE,		"'", "@" )
AddKey( KEY_SLASH,			"/", "?" )
AddKey( KEY_COMMA,			",", "<" )
AddKey( KEY_PERIOD,			".", ">" )
AddKey( KEY_SEMICOLON,		";", ":" )
AddKey( KEY_ENTER,			"\n" )
AddKey( KEY_PAD_ENTER,		"\n" )
AddKey( KEY_PAD_MULTIPLY,	"*" )
AddKey( KEY_TAB,			"\t" )
AddKey( KEY_PAD_DECIMAL,	"." )
AddKey( KEY_PAD_DIVIDE,		"/" )
AddKey( KEY_SPACE,			" " )
AddKey( KEY_EQUAL,			"=", "+" )
AddKey( KEY_PAD_PLUS,		"+" )
AddKey( KEY_PAD_MINUS,		"-" )
AddKey( KEY_BACKSLASH,		"\\", "|" )
AddKey( KEY_MINUS,			"-", "_" )

AddKey( KEY_BACKSPACE,		"<--" )