----// Clientside Phone //----

local client = LocalPlayer()
local phone = Material( "vgui/gphone/gphone.png" )
local firstTimeUsed = CreateClientConVar("gphone_firsttime", "1", true, true)	

--// Builds the phone 
function gPhone.buildPhone()
	gPhone.loadClientConfig()

	gPhone.badgeIDs = {}
	gPhone.apps = {}
	gPhone.importApps()
	
	-- Dimensions
	local pWidth, pHeight = 300, 600 -- Phone
	local sWidth, sHeight = 234, 416 -- Screen
	local hWidth, hHeight = 45, 45 -- Home button
	
	gPhone.rotation = 0
	
	gPhone.isPortrait = true
	gPhone.isInAnimation = false
	gPhone.isOnHomescreen = false
	gPhone.isOnLockscreen = true
	gPhone.shouldUnlock = true
	
	-- Create the phone 
		gPhone.phoneBase = vgui.Create( "DFrame" )
	gPhone.phoneBase:SetSize( pWidth, pHeight )
	gPhone.phoneBase:SetPos( ScrW()-pWidth, ScrH() - 40 )
	gPhone.phoneBase:SetTitle( "" )
	gPhone.phoneBase:SetDraggable( true )  -- TEMPORARY
	gPhone.phoneBase:SetDeleteOnClose( true )
	gPhone.phoneBase:ShowCloseButton( true ) -- TEMPORARY
	gPhone.phoneBase.Paint = function( self, w, h)
		surface.SetDrawColor( gPhone.config.PhoneColor )
		surface.SetMaterial( phone ) 
		--surface.DrawTexturedRect( 0, 0, pWidth, pHeight )
		surface.DrawTexturedRectRotated( self:GetWide()/2, self:GetTall()/2, pWidth, pHeight, gPhone.rotation )
	end
	gPhone.phoneBase.btnClose.DoClick = function ( button ) -- TEMPORARY
		gPhone.destroyPhone()
	end
	
	local phoneBase = gPhone.phoneBase
	local pX, pY = phoneBase:GetPos()
	gPhone.setWallpaper( true, gPhone.config.HomeWallpaper )
	gPhone.setWallpaper( false, gPhone.config.LockWallpaper )
	
		gPhone.phoneScreen = vgui.Create("DPanel", gPhone.phoneBase)
	gPhone.phoneScreen:SetPos( 31, 87 )
	gPhone.phoneScreen:SetSize( sWidth, sHeight ) 
	gPhone.phoneScreen.Paint = function( self )
		surface.SetMaterial( gPhone.getWallpaper( true, true ) )  -- Draw the wallpaper
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
	end
	gPhone.phoneScreen.Think = function()
		if gPhone.config.DarkenStatusBar == true then
			gPhone.darkenStatusBar()
		end
	end
	
	local nextTimeUpdate = 0
	local phoneTime = vgui.Create( "DLabel", gPhone.phoneScreen )
	phoneTime:SetText( os.date("%I:%M %p") )
	phoneTime:SizeToContents()
	phoneTime:SetPos( sWidth/2 - phoneTime:GetWide()/2, 0 )
	phoneTime.Think = function()
		if CurTime() > nextTimeUpdate then
			phoneTime:SetText(os.date("%I:%M %p"))
			phoneTime:SizeToContents()
			phoneTime:SetPos( sWidth/2 - phoneTime:GetWide()/2, 0 )
			nextTimeUpdate = CurTime() + 5
		end
	end
	
	--// Status bar
	local batteryPercent = vgui.Create( "DLabel", gPhone.phoneScreen )
	batteryPercent:SetText( "100%" )
	batteryPercent:SizeToContents()
	batteryPercent:SetPos( sWidth - batteryPercent:GetWide() - 23, 0 )
	local nextPass, battPerc = CurTime() + math.random(30, 60), 100
	batteryPercent.Think = function()
		if CurTime() > nextPass then
			batteryPercent:SetPos( sWidth - batteryPercent:GetWide() - 21, 0)
			local dropPerc = math.random(1, 3)

			battPerc = battPerc - dropPerc
			batteryPercent:SetText( battPerc.."%" )
			batteryPercent:SetPos( sWidth - batteryPercent:GetWide() - 20, 0 )
			
			nextPass = CurTime() + math.random(60, 180)
		end
		
		if battPerc < math.random(1, 4) then -- Simulate a phone dying, its kinda silly and few people will ever see it
			gPhone.chatMsg( "Your phone has run out of battery and died! Recharging..." )
			gPhone.hidePhone()
			timer.Simple(math.random(2, 5), function()
				gPhone.chatMsg( "Phone recharged!" )
				gPhone.showPhone()
				battPerc = 100
			end)
		end
	end
	
	local batteryImage = vgui.Create("DImage", gPhone.phoneScreen)
	batteryImage:SetSize( 16, 8 )
	batteryImage:SetPos( sWidth - 20, 3)
	batteryImage:SetImageColor(Color(255,255,255))
	local batteryMat = Material( "vgui/gphone/battery.png" )
	batteryImage.Paint = function( self )
		-- Draw the battery icon
		surface.SetMaterial( batteryMat ) 
		surface.SetDrawColor( batteryImage:GetImageColor() )
		surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
		
		-- Math to determine the size of the battery bar
		local segments = 11 / 100
		local batterySize = math.Clamp(battPerc * segments, 1, 11)
		
		-- Battery bar color
		if battPerc <= 20 then
			col = Color(200, 30, 30) 
		else
			col = batteryImage:GetImageColor() 
		end
		
		-- Draw the battery bar
		draw.RoundedBox( 0, 2, 2, batterySize, 4, col )
	end
	
	gPhone.SignalStrength = 5
	
	local signalDots = {}
	local xBuffer = 3
	for i = 1, 5 do
		signalDots[i] = vgui.Create("DImage", gPhone.phoneScreen)
		signalDots[i]:SetSize( 6, 6 )
		signalDots[i]:SetPos( xBuffer, 4)
		signalDots[i]:SetImageColor(Color(255,255,255))
		local off = Material( "vgui/gphone/dot_empty.png", "smooth noclamp" )
		local on = Material( "vgui/gphone/dot_full.png", "smooth noclamp" )
		signalDots[i].Paint = function( self )
			if i <= gPhone.SignalStrength then
				surface.SetMaterial( on ) 
				surface.SetDrawColor( self:GetImageColor() )
				surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
			else
				surface.SetMaterial( off ) 
				surface.SetDrawColor( self:GetImageColor() )
				surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
			end
		end
		xBuffer = xBuffer + signalDots[i]:GetWide() + 1
	end
	
	local serviceProvider = vgui.Create( "DLabel", gPhone.phoneScreen )
	serviceProvider:SetText( "Garry" )
	serviceProvider:SizeToContents()
	local lastDot = signalDots[#signalDots]
	serviceProvider:SetPos( lastDot:GetPos() + lastDot:GetWide() + 5, 0 )
	
	gPhone.homeButton = vgui.Create( "DButton", gPhone.phoneBase )
	gPhone.homeButton:SetSize( hWidth, hHeight )
	gPhone.homeButton:SetPos( pWidth/2 - hWidth/2 - 3, pHeight - hHeight - 35 )
	gPhone.homeButton:SetText( "" )
	gPhone.homeButton.Paint = function() end
	gPhone.homeButton.DoClick = function()
		if not gPhone.isOnHomeScreen and not gPhone.isInAnimation and not gPhone.isOnLockscreen then
			gPhone.toHomeScreen()
		end
	end
	
	gPhone.StatusBar = { -- Gotta keep track of all the status bar elements
		["text"] = { battery=batteryPercent, network=serviceProvider, time=phoneTime },
		["image"] = { battery=batteryImage, unpack(signalDots) },
	}
	gPhone.StatusBarHeight = 15
	
	--// Homescreen
	local homeIcons = {}
	local appBadges = {}
	
	-- Loads up icon positions from the oosition file
	local txtPositions = gPhone.getActiveAppPositions()
	local newApps = {}
	local denies = 0
	if #txtPositions > 1 then
		for a = 1,#gPhone.apps do
			local app = gPhone.apps[a] -- name and icon
			local name = app.name
			denies = 0
			
			-- Checks if an app exists in the config file and at which key
			for i = 1,#txtPositions do
				if name == txtPositions[i].name then
					table.insert(newApps, txtPositions[i])
				else
					denies = denies + 1
				end
			end
			
			-- This app does not exist in the config, put it at the end
			if denies == #txtPositions then
				table.insert(newApps, app)
			end
		end 
		
		gPhone.apps = newApps
	end
	
	-- Build the layout
	gPhone.homeIconLayout = vgui.Create( "DPanel", gPhone.phoneScreen )
	gPhone.homeIconLayout:SetSize( sWidth - 10, sHeight - 40 )
	gPhone.homeIconLayout:SetPos( 5, 25 )
	gPhone.homeIconLayout.Paint = function() end
	
	-- App badges
	gPhone.homeIconLayout.PaintOver = function() 
		if gPhone.IsInFolder then return end -- App badges in folders?
		
		for name, data in pairs( appBadges ) do
			if data.num and data.num > 0 then
				if #gPhone.badgeIDs[name] != data.num then
					-- badgeIDs is updated upon number change
					-- appBadges is updated upon homescreen recreation
					data.num = #gPhone.badgeIDs[name]
				end
				
				local text, font = tostring(data.num), "gPhone_12"
				local width, height = gPhone.getTextSize(text, font) -- X, 12
				width = width + height/2
				
				local pnl 
				for k, v in pairs(homeIcons) do
					if string.lower(v.name) == string.lower(name) then
						pnl = v.pnl
					end
				end
				
				if IsValid(pnl) then
					local x, y = pnl:GetPos()
					local tX, tY = x + data.w - width + 3, y
					
					draw.RoundedBox(6, x + data.w - width + height/4, y - height/4, width, height, Color(240, 5, 5) )
					draw.DrawText( text, font, tX + height/4, tY - height/4, color_white )
				end
			end
		end
	end
	
	gPhone.canMoveApps = true
	gPhone.isInFolder = false
	gPhone.currentFolder = nil
	gPhone.currentFolderApps = {}
	-- Handles the dropping of icons on the home screen
	gPhone.homeIconLayout:Receiver( "gPhoneIcon", function( pnl, item, drop, i, x, y ) 
		if drop then
			if not gPhone.canMoveApps then 
				gPhone.msgC( GPHONE_MSGC_WARNING, "Unable to move apps" )
			end

			for k, v in pairs(homeIcons) do
				local iX, iY = v.pnl:GetPos()
				local iW, iH = v.pnl:GetSize()
				
				-- Moving an icon out of a folder
				if gPhone.isInFolder then
					local w, h = gPhone.homeIconLayout:GetWide(), gPhone.homeIconLayout:GetTall()/1.7
					local w, h = gPhone.homeIconLayout:GetWide(), gPhone.homeIconLayout:GetTall()/1.7
					local fW, fH = w - 10, h
					local fX, fY = 5, gPhone.homeIconLayout:GetTall()/2 - h/2
					
					local heldPanel = dragndrop.GetDroppable()[1]
					local curFolder = gPhone.currentFolder
					if x <= fX or x >= fX + fW or y <= fY or y >= fY + fH then
						local droppedData = {name="N/A", icon="N/A"}
						local droppedKey = 0
						local folderKey = 0
						
						-- Grab the icon we are moving
						for k, v in pairs( gPhone.currentFolderApps ) do
							-- [k] = pnl, icon, name
							if heldPanel == v.pnl:GetChildren()[1] then
								local icon = v.pnl:GetChildren()[1]
								droppedData = {name=v.name, icon=v.icon}
								droppedKey = k
							end
						end	
						
						-- Find the folder in the gPhone.apps table
						for k, v in pairs( gPhone.apps ) do
							if curFolder == v then
								folderKey = k
							end
						end
						
						-- Remove the icon from the folder and throw it on the end of the home screen
						table.remove(gPhone.apps[folderKey].apps, droppedKey)
						table.insert(gPhone.apps, droppedData)
						
						-- Table is going to have 1 icon left, destroy it
						if #gPhone.currentFolderApps <= 2 then
							local leftApp = gPhone.apps[folderKey].apps[1]
							table.remove(gPhone.apps, folderKey)
							table.insert(gPhone.apps, folderKey, {name=leftApp.name, icon=leftApp.icon})
						end

						-- Close the folder (rebuilds the homescreen)
						gPhone.CloseFolder()
					else
						print("In folder")
						-- Move apps in the folder
					end
				
				-- Creating a folder
				elseif x >= iX + iW/3 and x <= iX + iW - iW/3 then
					if y >= iY and y <= iY + iH and not gPhone.isInFolder then	
						local targetKey = k 
						local droppedData = {name="Folder", apps={}} 
						local droppedKey = 0
						
						-- Get the name and image of the icon we are moving
						for i = 1,#homeIcons do
							if item[1] == homeIcons[i].pnl:GetChildren()[1] then
								local droppedName = homeIcons[i].name

								for p = 1, #gPhone.apps do
									if gPhone.apps[p].name == droppedName then
										droppedKey = p
									end
								end
							end
						end
						
						local droppedApp = gPhone.apps[droppedKey]
						local targetActiveApp = gPhone.apps[targetKey]

						-- Preventing bad stuff
						if not droppedApp then
							gPhone.msgC( GPHONE_MSGC_WARNING, "Dropped app is not valid in the gPhone.apps table" )
							return
						elseif targetActiveApp.apps and #targetActiveApp.apps >= 9 then
							gPhone.msgC( GPHONE_MSGC_WARNING, "Folder is full and cannot hold any more apps" )
							return
						elseif gPhone.apps[k] == droppedApp then
							gPhone.msgC( GPHONE_MSGC_WARNING, "Cannot drop an app on itself" )
							return
						elseif droppedApp.apps or droppedApp.IsFolder then 
							gPhone.msgC( GPHONE_MSGC_WARNING, "Cannot drop folders on icons or other folders" )
							return
						end
						
						-- Give the folder a name based on app tags
						local droppedAppTable = gApp[droppedApp.name:lower()]
						local targetActiveAppTable = gApp[targetActiveApp.name:lower()]
						if droppedAppTable and targetActiveAppTable then
							local tags = {}
							if droppedAppTable.Data.Tags then
								--table.Merge( tags, droppedAppTable.Data.Tags )
								for k, v in pairs( droppedAppTable.Data.Tags ) do
									tags[#tags+1] = v
								end
							end
							if targetActiveAppTable.Data.Tags then
								--table.Merge( tags, targetActiveAppTable.Data.Tags )
								for k, v in pairs( targetActiveAppTable.Data.Tags ) do
									tags[#tags+1] = v
								end
							end
							
							local tag = table.Random(tags)
							for k, v in pairs(gPhone.apps) do
								print(v.name, tag)
								if v.name == tag then
									tag = table.Random(tags)
								end
							end

							droppedData.name = tag or "Folder"
						end
						
						-- Table stuff
						if gPhone.apps[k].apps != nil then -- Dropped on a folder
							table.insert(gPhone.apps[k].apps, {name=droppedApp.name, icon=droppedApp.icon})
							table.remove(gPhone.apps, droppedKey)
						else
							-- Put the 2 icons into the folder
							table.insert(droppedData.apps, {name=targetActiveApp.name, icon=targetActiveApp.icon})
							table.insert(droppedData.apps, {name=droppedApp.name, icon=droppedApp.icon})
							
							-- Remove the moved icon and the dropped-on icon, create a folder
							table.remove(gPhone.apps, droppedKey)
							table.remove(gPhone.apps, targetKey)
							table.insert(gPhone.apps, targetKey, droppedData)
						end
						
						-- Build a shiny new homescreen
						gPhone.buildHomescreen( gPhone.apps )
					end
					
				-- Moving apps around
				elseif dragndrop.GetDroppable() != nil and not gPhone.isInFolder then
					-- We are not dropping in the folder area, move the apps instead
					local prevX, prevY 

					local x, y = v.pnl:GetPos()
					local w, h = v.pnl:GetSize()
					local heldPanel = dragndrop.GetDroppable()[1]
					local shouldMove = false
					-- GetDroppable doesnt return a true pos, this works just as well
					local mX, mY = gPhone.homeIconLayout:ScreenToLocal( gui.MouseX(), gui.MouseY() )
					if x != 0 and homeIcons[k-1] != nil then
						prevX, prevY = homeIcons[k-1].pnl:GetPos()
						prevH, prevW = homeIcons[k-1].pnl:GetSize()		
					
						-- Check if the mouse is in the droppable area (between panels)
						if mX <= x + w/3 and mX >= prevX + (prevH/3 *2) then -- Increase the drop area by 33% on each side
							if mY >= y and mY <= y + h then
								shouldMove = true
							end
						end
					else
						if mX <= x + w/3 then 
							if mY >= y and mY <= y + h then
								shouldMove = true
							end
						end
					end
					
					if shouldMove then
						local droppedData = {name="N/A", icon="N/A"}
						local droppedKey = 0
						
						-- Get the name and image of the icon we are moving
						for i = 1,#homeIcons do
							if heldPanel == homeIcons[i].pnl:GetChildren()[1] then
								local droppedName = homeIcons[i].name
								
								for p = 1, #gPhone.apps do
									if gPhone.apps[p].name == droppedName then
										droppedData = gPhone.apps[p]
										droppedKey = p
									end
								end
							end
						end
						
						-- Drop the panel
						dragndrop.StopDragging()
						
						-- Remove the icon from its old key and move it to its new key
						table.remove(gPhone.apps, droppedKey)
						table.insert(gPhone.apps, k, droppedData )
						
						-- Build a shiny new homescreen
						gPhone.buildHomescreen( gPhone.apps )
					end
				end
			end
		end
	end, {})
	
	-- Populate the homescreen with apps
	function gPhone.buildHomescreen( tbl )
		if not gPhone.isOnHomescreen or not gPhone.phoneActive or not gPhone.phoneExists then return end
		
		-- Destroy the old homescreen 
		for k, v in pairs( gPhone.homeIconLayout:GetChildren() ) do
			v:Remove()
		end
		homeIcons = {}
		
		-- Run a pass through the table to fix issues
		gPhone.fixHomescreen( tbl )
		
		-- Start building apps and folders
		local xBuffer, yBuffer, iconCount = 0, 0, 1
		for key, data in pairs( tbl ) do
			local bgPanel
			
			if data.icon then
				-- Create a normal app icon
				bgPanel = vgui.Create( "DPanel", gPhone.homeIconLayout )
				bgPanel:SetSize( 50, 45 )
				bgPanel:SetPos( 0 + xBuffer, 10 + yBuffer )
				bgPanel.Paint = function( self, w, h )
					--draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0) )
				end
				
				local imagePanel = vgui.Create( "DImageButton", bgPanel ) 
				imagePanel:SetSize( 32, 32 )
				imagePanel:SetPos( 10, 0 )
				imagePanel:SetImage( data.icon )
				imagePanel:Droppable( "gPhoneIcon" )
				imagePanel.DoClick = function()
					gPhone.runApp( string.lower(data.name) )
				end
				
				local iconLabel = vgui.Create( "DLabel", bgPanel )
				iconLabel:SetText( data.name )
				iconLabel:SetFont("gPhone_12")
				iconLabel:SizeToContents()
				local y = imagePanel:GetTall() + 2
				if iconLabel:GetWide() > bgPanel:GetWide() then
					local w, h = iconLabel:GetSize()
					iconLabel:SetPos( 0, y )
					iconLabel:SetSize( bgPanel:GetWide(), h )
				else
					iconLabel:SetPos( bgPanel:GetWide()/2 - iconLabel:GetWide()/2, y)
				end
			elseif #data.apps > 1 then
				-- The fun part, create a folder
				local folderLabel, nameEditor 
				bgPanel = vgui.Create( "DPanel", gPhone.homeIconLayout )
				bgPanel:SetSize( 50, 45 )
				bgPanel:SetPos( 0 + xBuffer, 10 + yBuffer )
				bgPanel.IsFolder = true
				bgPanel.Paint = function( self, w, h )
					if IsValid(nameEditor) and nameEditor:IsEditing() then
						local w, h = self:GetSize()
						local x, y = self:GetPos()
						draw.RoundedBox(4, 0, y + 10, bgPanel:GetWide(), 50, Color(50, 50, 50, 150) )
					end
				end
				
				local previewPanel = vgui.Create( "DImageButton", bgPanel ) 
				previewPanel:SetSize( 32, 32 )
				previewPanel:SetPos( 10, 0 )
				previewPanel:Droppable( "gPhoneIcon" )
				previewPanel.IsFolder = true
				
				-- Set up the preview icons, updates everytime the homescreen is built
				local drawnIcons = {}
				local xBuffer, yBuffer, previewIconCount = 2, 2, 0
				for k, v in pairs( data.apps ) do
					local icon = v.icon or "error"
					
					table.insert(drawnIcons, {x=xBuffer, y=yBuffer, icon=Material(icon), color=color_white})
					previewIconCount = previewIconCount + 1
					
					if previewIconCount % 3 == 0 then
						xBuffer = 2
						yBuffer = yBuffer + 10
					else
						xBuffer = xBuffer + 10
						yBuffer = yBuffer
					end
				end
				local blur = Material("pp/blurscreen")
				previewPanel.Paint = function( self, w, h )
					-- Background blur
					if not dragndrop.GetDroppable() or not dragndrop.GetDroppable()[1] == self or gPhone.isInFolder then
						-- Vanishes when the panel is picked up or the entire screen becomes blurred
						gPhone.drawPanelBlur( self, 3, 5, 255 )
					end
					
					-- Draw the app icons for the folders contents
					if not gPhone.isInFolder then
						for k, v in pairs( drawnIcons ) do
							surface.SetDrawColor( v.color )
							surface.SetMaterial( v.icon )
							surface.DrawTexturedRect( v.x, v.y, 8, 8 )
						end
					end
				end
				
				local iconLabel = vgui.Create( "DLabel", bgPanel )
				iconLabel:SetText( data.name )
				iconLabel:SetFont("gPhone_12")
				iconLabel:SizeToContents()
				if iconLabel:GetWide() <= bgPanel:GetWide() then
					iconLabel:SetPos( bgPanel:GetWide()/2 - iconLabel:GetWide()/2, previewPanel:GetTall() + 2)
				else
					iconLabel:SetPos( 0, previewPanel:GetTall() + 2)
				end
				
				local x, y = previewPanel:GetPos()
				local w, h = previewPanel:GetSize()
				local oldBGPos = {bgPanel:GetPos()}
				local oldBGSize = {bgPanel:GetSize()}
				
				-- Declared early because I am terrible at managing this
				function gPhone.CloseFolder() 
					if nameEditor then
						nameEditor:OnEnter()
						nameEditor:SetVisible(false)
					end
					
					previewPanel:SetCursor( "hand" )
					bgPanel:SetPos( unpack(oldBGPos) )
					
					previewPanel:SizeTo( w, h, 0.5)
					timer.Simple(0.5, function()
						if IsValid(bgPanel) then
							--bgPanel:Remove()
						end
					end)
					
					gPhone.currentFolder = nil
					gPhone.currentFolderApps = {}
					gPhone.isInFolder = false
					gPhone.buildHomescreen( gPhone.apps )
				end
				
				-- Handle the building of folders
				previewPanel.DoClick = function( self )
					gPhone.currentFolder = data
					gPhone.isInFolder = true
					previewPanel:SetCursor( "arrow" )
						
					-- Hide the other apps
					for k, v in pairs( gPhone.homeIconLayout:GetChildren() ) do
						if v != bgPanel then
							v:SetVisible(false)
						end
					end
					
					bgPanel.OnMousePressed = function()
						if IsValid(previewPanel) then
							gPhone.CloseFolder() 
						end
					end
					
					iconLabel:SetVisible(false)
					bgPanel:SetPos( 0, 0 )
					bgPanel:SetSize( gPhone.homeIconLayout:GetWide(),  gPhone.homeIconLayout:GetTall() )
					
					local w, h = gPhone.homeIconLayout:GetWide(), gPhone.homeIconLayout:GetTall()/1.7
					self:SizeTo( w - 10, h, 0.5)
					self:MoveTo( 5, gPhone.homeIconLayout:GetTall()/2 - h/2, 0.5)
					
					-- Inivisible label to get the size of the DTextEntry
					local sizeLabel = vgui.Create( "DLabel", bgPanel )
					sizeLabel:SetText( data.name )
					sizeLabel:SetFont("gPhone_36")
					sizeLabel:SizeToContents()
					sizeLabel:SetVisible( false )
					sizeLabel:SetPos( bgPanel:GetWide()/2 - sizeLabel:GetWide()/2, 15 )
					
					nameEditor = vgui.Create( "DTextEntry", bgPanel )
					nameEditor:SetText( data.name )
					nameEditor:SetFont( "gPhone_36" )
					nameEditor:SetSize( bgPanel:GetWide(), sizeLabel:GetTall() )
					nameEditor:SetPos( sizeLabel:GetPos() ) 
					nameEditor:SetTextColor( color_white )
					nameEditor:SetDrawBorder( false )
					nameEditor:SetDrawBackground( false )
					nameEditor:SetCursorColor( color_white )
					nameEditor:SetHighlightColor( Color(27,161,226) )
					nameEditor.Think = function( self )
						draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), Color(255, 255, 255) )
						
						if self.Opened == false then
							self:Remove()
						end
					end
					nameEditor.OnChange = function( self )
						local text = self:GetText()
						sizeLabel:SetText(text)
						sizeLabel:SizeToContents()
						sizeLabel:SetPos( bgPanel:GetWide()/2 - sizeLabel:GetWide()/2, 15 )
						
						self:SetPos( sizeLabel:GetPos() )
					end
					nameEditor.OnEnter = function( self )
						local text = string.Trim( self:GetText() )
						if text != "" then
							data.name = self:GetText()
						else
							self:SetText("Invalid")
						end
					end
					-- Why doesn't the text entry have a variable or function for that?
					nameEditor.HasFocus = false
					nameEditor.OnGetFocus = function( self )
						self.HasFocus = true
					end
					nameEditor.OnLoseFocus = function( self )
						self.HasFocus = true
					end
					
					-- Create the folder's app icons
					local xBuffer, yBuffer = 0,0
					local folderIconCount = 1
					for k, v in pairs( tbl[key].apps ) do
						-- Create a normal app icon
						local bgPanel = vgui.Create( "DPanel", previewPanel )
						bgPanel:SetSize( 50, 45 )
						bgPanel:SetPos( 15 + xBuffer, 15 + yBuffer )
						bgPanel.Paint = function( self, w, h )
						end
						
						local imagePanel = vgui.Create( "DImageButton", bgPanel ) 
						imagePanel:SetSize( 32, 32 )
						imagePanel:SetPos( 10, 0 )
						imagePanel:SetImage( v.icon )
						imagePanel:Droppable( "gPhoneIcon" )
						imagePanel.DoClick = function()
							gPhone.runApp( string.lower(v.name) )
						end
						
						local iconLabel = vgui.Create( "DLabel", bgPanel )
						iconLabel:SetText( v.name )
						iconLabel:SetFont("gPhone_12")
						iconLabel:SizeToContents()
						iconLabel:SetPos( bgPanel:GetWide()/2 - iconLabel:GetWide()/2, imagePanel:GetTall() + 2)
						
						local folderLabel = vgui.Create( "DLabel", bgPanel )
						folderLabel:SetText( v.name )
						folderLabel:SetFont("gPhone_12")
						folderLabel:SizeToContents()
						folderLabel:SetPos( bgPanel:GetWide()/2 - folderLabel:GetWide()/2, 34)
						
						if folderIconCount % 3 == 0 then
							xBuffer = 0
							yBuffer = yBuffer + bgPanel:GetTall() + 30
						else
							xBuffer = xBuffer + bgPanel:GetWide() + 10
							yBuffer = yBuffer
						end
						folderIconCount = folderIconCount+ 1

						gPhone.currentFolderApps[k] = {pnl=bgPanel, name=v.name, icon=v.icon}
					end
				end
			end
		
			-- Properly align the icons
			if iconCount % 4 == 0 then
				xBuffer = 0
				yBuffer = yBuffer + 75
			else
				xBuffer = xBuffer + 55
				yBuffer = yBuffer
			end
			
			-- Set any notifications to be drawn
			if data.badge and data.badge > 0 then
				local x, y = bgPanel:GetPos()
				local w, h = bgPanel:GetSize()
				
				--table.insert( appBadges, {x=x,y=y,w=w,h=h,num=data.badge} )
				appBadges[data.name] = {x=x,y=y,w=w,h=h,num=data.badge}
			end
			
			iconCount = iconCount + 1
			table.insert( homeIcons, {name=data.name, pnl=bgPanel} )
		end
		
		-- Save the app positions
		--gPhone.saveAppPositions( gPhone.apps ) -- TEMP FOR TESTING
	end
	gPhone.buildHomescreen( gPhone.apps )
	
	-- Assorted stuff
	gPhone.phoneExists = true
	gPhone.config.PhoneColor.a = 100
	
	-- Check for updates from my website
	gPhone.checkUpdate()
end

--// Moves the phone up into visiblity
function gPhone.showPhone()
	if gPhone and gPhone.phoneBase then
		local pWidth, pHeight = gPhone.phoneBase:GetSize()
		gPhone.phoneBase:MoveTo( ScrW()-pWidth, ScrH()-pHeight, 0.7, 0, 2, function()
			gPhone.phoneBase:MakePopup()
		end)
		
		gPhone.config.PhoneColor.a = 255
		
		if firstTimeUsed:GetBool() then
			gPhone.bootUp()
			LocalPlayer():ConCommand("gphone_firsttime 0")
		end
		
		gPhone.buildLockScreen()
		
		gPhone.isOnHomeScreen = true
		gPhone.phoneActive = true
		
		-- Tell the server we are done and the phone is ready to be used
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_STATE_CHANGED, open=true})
		net.SendToServer()
	end
end

--// Moves the phone down and disables it
function gPhone.hidePhone()
	if gPhone and gPhone.phoneBase then
		local x, y = gPhone.phoneBase:GetPos()
		
		gPhone.phoneBase:SetMouseInputEnabled( false )
		gPhone.phoneBase:SetKeyboardInputEnabled( false )
		
		gPhone.phoneBase:MoveTo( x, ScrH()-40, 0.7, 0, 2, function()
			gPhone.config.PhoneColor.a = 100 -- Fade the alpha
		end)
		
		gPhone.phoneActive = false
		
		gApp.removeTickers()
		
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_STATE_CHANGED, open=false})
		net.SendToServer()
		
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_CUR_APP, app=nil})
		net.SendToServer()
	end
end

--// Completely removes the phone from the game
function gPhone.destroyPhone()
	if gPhone and gPhone.phoneBase then
		gPhone.phoneBase:Close()
		gPhone.phoneBase = nil
		
		gPhone.phoneActive = false
		gPhone.phoneExists = false
		
		gApp.removeTickers()
		
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_STATE_CHANGED, open=false})
		net.SendToServer()
		
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_CUR_APP, app=nil})
		net.SendToServer()
	end
end

--// Receives a Server-side net message
net.Receive( "gPhone_DataTransfer", function( len, ply )
	local data = net.ReadTable()
	local header = data.header
	
	if header == GPHONE_BUILD then
		gPhone.buildPhone()
	elseif header == GPHONE_NOTIFY_GAME then
		local sender = data.sender
		local game = data.text
		
		local msg = sender:Nick().." has invited you to play "..game
		
		if gPhone.isInApp then
			gPhone.notifyPassive( msg, {game=game} )
		else
			if not gPhone.phoneActive then
				gPhone.vibrate()
			end
			
			gPhone.notifyInteract( {msg=msg, app=game, options={"Accept", "Deny"}} )
		end
	elseif header == GPHONE_RETURNAPP then
		local name, active = nil, gApp["_active_"]
		active = active or {}
		active.Data = active.Data or {}
		
		if active.Data.PrintName then
			name = active.Data.PrintName or nil
		end

		net.Start("gPhone_DataTransfer")
			net.WriteTable( {header=GPHONE_RETURNAPP, app=name} )
		net.SendToServer()
	elseif header == GPHONE_RUN_APPFUNC then
		local app = data.app
		local func = data.func
		local args = data.args
		
		if gApp[app:lower()] then
			app = app:lower()
			for k, v in pairs( gApp[app].Data ) do
				if k:lower() == func:lower() then
					gApp[app].Data[k]( unpack(args) )
					return
				end
			end
		end
		gPhone.msgC( GPHONE_MSGC_WARNING, "Unable to run application function "..func.."!" )
	elseif header == GPHONE_RUN_FUNC then
		local func = data.func
		local args = data.args
		
		for k, v in pairs(gPhone) do
			if k:lower() == func:lower() and type(k) == "function" then
				gPhone[k]( unpack(args) )
				return
			end
		end
		
		gPhone.msgC( GPHONE_MSGC_WARNING, "Unable to run phone function "..func.."!")
	elseif header == GPHONE_MONEY_CONFIRMED then
		local writeTable = {}
		data.header = nil
		data = data[1]
		
		--[[
			Problemo:
		On Client - ALL transactions for any server will show up
		On Server - Server gets flooded with tons of .txt documents that might only contain 1 transaction
		
		No limit on logs
		]]
		
		if file.Exists( "gphone/appdata/t_log.txt", "DATA" ) then
			local readFile = file.Read( "gphone/appdata/t_log.txt", "DATA" )
			print("File exists", readFile)
			local readTable = util.JSONToTable( gPhone.unscrambleJSON( readFile ) ) 
			
			--table.Add( tbl, readTable )
			writeTable = readTable
			
			--local key = #writeTable+1
			table.insert( writeTable, 1, {amount=data.amount, target=data.target, time=data.time} )
			--writeTable[key] = {amount=data.amount, target=data.target, time=data.time}
			gPhone.msgC( GPHONE_MSGC_NONE, "Appending new transaction log into table")
		else
			gPhone.msgC( GPHONE_MSGC_WARNING, "No transaction file, creating one...")
			writeTable[1] = {amount=data.amount, target=data.target, time=data.time}
			
			PrintTable(writeTable)
		end
		
		local json = util.TableToJSON( writeTable )
		json = gPhone.scrambleJSON( json )
	
		file.CreateDir( "gphone" )
		file.Write( "gphone/appdata/t_log.txt", json)
	elseif header == GPHONE_TEXT_MSG then
		gPhone.receiveTextMessage( data.data )
	end
end)

--// Fake signal strength for the phone based on distance from the map's origin
local mapOrigin = Vector(0,0,0)
function gPhone.updateSignalStrength()
	-- If I ever scrap Distance() and make my own, make the Z axis have more weight 
	local distFromOrigin = mapOrigin:Distance( LocalPlayer():GetPos() ) 

	-- rp_Downtown_v2 is 7000 units at its longest point
	if distFromOrigin <= 1000 then
		gPhone.SignalStrength = 5
	elseif distFromOrigin <= 2000 then
		gPhone.SignalStrength = 4
	elseif distFromOrigin <= 4000 then
		gPhone.SignalStrength = 3
	elseif distFromOrigin <= 6000 then
		gPhone.SignalStrength = 2
	else
		gPhone.SignalStrength = 1
	end
end

--// Updates the signal strength
local nextUpdate = 0
hook.Add( "Think", "gPhone_SignalStrength", function()
	if CurTime() > nextUpdate then
		-- Its purely for looks and players don't normally move 1-2k units in 5 seconds
		gPhone.updateSignalStrength()
		nextUpdate = CurTime() + 5 
	end
end)

--// Logic for opening the phone by holding down a key
local keyStartTime = 0
hook.Add( "Think", "gPhone_OpenAndCloseKey", function()
	if input.IsKeyDown( gPhone.config.OpenKey ) then
		if keyStartTime == 0 then
			keyStartTime = CurTime()
		end
		
		-- Key has been held down long enough and the phone is not animating
		if CurTime() - keyStartTime >= gPhone.config.KeyHoldTime and not gPhone.isInAnimation then
			if gPhone.phoneActive != true then
				gPhone.showPhone()
			else
				gPhone.hidePhone()
			end
			
			keyStartTime = 0
		end
	else
		keyStartTime = 0
	end
end)
