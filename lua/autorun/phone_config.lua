----// gPhone //----
-- Author: Exho
-- Version: 2/22/14
-- Phone source: https://creativemarket.com/buatoom/6422-iPhone5-Flat-Template
-- Icon sources: http://www.flaticon.com/

--[[ To Do:
	- Multiplayer
		- App variable which defines a function to run to start a multiplayer game
		- Replace the horrid multiplayer request system with my new one
	- Fix animations so that they are consistant
	- Convert all the back buttons to my format
		objects.Back = vgui.Create("gPhoneBackButton", screen)
		objects.Back:SetTextColor( gPhone.colors.blue )
		objects.Back:SetPos( )
	- Finish apps!!!
	- Mas settings
	- Perhaps move all text logs serverside
		- Regardless of position, they need to NOT be in plain text
		- If encrpyted, perhaps store the key on the server and only decrypt serverside then send the table to the client
	- Moving apps in folders
	- Function to bypass using net.*Table entirely
	- Reroute all net.Send to my own function so I can easily modify them
	- Do something with the 2d side scroller or remove it from the main game
	- Maybe add prompt before deleting apps
	- Phone/calling
		- Screen while in a call
		- No need for screen for being called I don't think, notifications should handle that
		- Either allow people to use their keyboard while in a call or use +voicerecord
		- Enable speaking for both players
	- 911 number for texting
	- Add another optional argument for the banner notify for a title instead of using the app name
	- Some sort of system which logs GPHONE_MSGC_WARNINGs and a debug.traceback would be cool
	- Language
		- Add language support for the entire phone
			- Dont add language support for console print functions
		- Settings tab to change languages
	- Add switch for gPhone.config.airplaneMode
]]

gPhone = gPhone or {}
gPhone.version = "0.0.0"

gPhone.languages = {}
gPhone.invalidNumber = "ERRO-RNUM"
if SERVER then
	--// Serverside config
	gPhone.config = {
		-- Time to count text messages in order to check for spam
		antiSpamTimeframe = 5,
		-- Max amount of texts allowed in the above declared time
		textPerTimeframeLimit = 5,
		-- Time to prevent another text from being sent after a player is flagged as a spammer
		textSpamCooldown = 10, 
		
		-- Admin groups 
		adminGroups = {"owner", "superadmin", "admin"}
	}
else
	gPhone.debugLog = {}
	
	--// Clientside config
	gPhone.config = {
		-- Should we display debug console messages called with the msgC function? 
		showConsoleMessages = true,
		-- Should apps that we cannot use be shown on the home screen?
		showUnusableApps = false,
		-- Should the status bar be darkened on the homescreen for white wallpapers?
		darkStatusBar = false,
		
		-- Default homescreen wallpaper
		homeWallpaper = "vgui/gphone/wallpapers/greyfabric.png",
		-- Default lockscreen wallpaper
		lockWallpaper = "vgui/gphone/wallpapers/greyfabric.png",
		-- Fallback in case either wallpaper is nil
		fallbackWallpaper = "vgui/gphone/wallpapers/wood.png",
		
		-- Held key to open/close the gPhone
		openKey = KEY_G, 
		-- Time to hold the key in order to open/close the gPhone
		keyHoldTime = 0.75,
		-- Time after showing the homescreen to unlock it 
		openLockDelay = 1,
		
		-- Removes files in the data/gphone/archive folder after a time period has elapsed
		deleteArchivedFiles = true,
		daysToCleanupArchive = 14,
			
		-- Default phone color
		phoneColor = Color(255,255,255,255),
		
		-- Disables incoming notifications 
		airplaneMode = false,
	}
	
	--// Color palatte for apps
	gPhone.colors = {
		blue = Color(20, 80, 200),
		red = Color(220, 27, 23),
		softRed = Color(220, 84, 78),
		grey = Color(100, 100, 100),
		
		whiteBG = Color(250, 250, 250),
		darkWhiteBG = Color(230, 230, 230), 
		darkerWhite = Color(210, 210, 210),
		greyAccent = Color(150, 150, 150),
		green = Color(75, 236, 101),
	}
end

if SERVER then
	util.AddNetworkString("gPhone_DataTransfer")
	util.AddNetworkString("gPhone_MultiplayerData")
	util.AddNetworkString("gPhone_MultiplayerStream")
	util.AddNetworkString("gPhone_ChatMsg")
	
	AddCSLuaFile()
	AddCSLuaFile("gphone/cl_phone.lua")
 	AddCSLuaFile("gphone/cl_appbase.lua")
 	AddCSLuaFile("gphone/cl_util.lua")
 	AddCSLuaFile("gphone/cl_util_extension.lua")
 	AddCSLuaFile("gphone/cl_animations.lua")
	AddCSLuaFile("gphone/sh_datatransfer.lua")
	AddCSLuaFile("gphone/sh_util.lua")
	AddCSLuaFile("gphone/sh_lang.lua")
 	AddCSLuaFile("gphone/sh_multiplayer.lua")
	AddCSLuaFile("vgui/backbutton.lua")
	
	-- Apps
	local files = file.Find( "gphone/apps/*.lua", "LUA" )
	for k, v in pairs(files) do
		AddCSLuaFile("gphone/apps/"..v)
	end
	
	-- Language files
	files = file.Find( "gphone/lang/*.lua", "LUA" )
	for k, v in pairs(files) do
		AddCSLuaFile("gphone/lang/"..v)
	end
	
	-- Include languages
	local files = file.Find( "gphone/lang/*.lua", "LUA" )
	for k, v in pairs(files) do
		include("gphone/lang/"..v)
	end
	
	include("gphone/sh_lang.lua")
	include("gphone/sv_phone.lua")
 	include("gphone/sh_util.lua")
 	include("gphone/sh_multiplayer.lua")
	include("gphone/sh_datatransfer.lua")
	
	if game.SinglePlayer() then
		for _, ply in pairs(player.GetAll()) do
			gPhone.chatMsg( ply, "The phone will not work properly in Single Player!!! Expect bugs and other paranormal activities" )
		end
	end
end

if CLIENT then
	-- Include languages
	local files = file.Find( "gphone/lang/*.lua", "LUA" )
	for k, v in pairs(files) do
		include("gphone/lang/"..v)
	end

	include("gphone/cl_phone.lua")
 	include("gphone/cl_appbase.lua")
 	include("gphone/cl_util.lua")
 	include("gphone/cl_util_extension.lua")
 	include("gphone/cl_animations.lua")
	include("gphone/sh_lang.lua")
	include("gphone/sh_util.lua")
 	include("gphone/sh_multiplayer.lua")
	include("gphone/sh_datatransfer.lua")
	include("vgui/backbutton.lua")
end

print([[
        _____  _                      
       |  __ \| |                     
   __ _| |__) | |__   ___  _ __   ___ 
  / _` |  ___/| '_ \ / _ \| '_ \ / _ \
 | (_| | |    | | | | (_) | | | |  __/
  \__, |_|    |_| |_|\___/|_| |_|\___|
   __/ |                              
  |___/ 
	Created by Exho - STEAM_0:0:53332328
	Version: ]]..gPhone.version..[[
]])
--[[
print("---// gPhone //---")
print("- Created by Exho (STEAM_0:0:53332328) -")
print("- https://github.com/Exho1/gPhone -")
print("- Do not reupload anywhere -")
print("---// Version "..gPhone.version.." //---")
]]

