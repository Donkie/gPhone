----// Serverside Phone //----

--// Resourcing and app adding
resource.AddFile( "materials/vgui/gphone/gPhone.png" )

local files = file.Find( "materials/vgui/gphone/*.png", "GAME" ) -- Phone images
for k, v in pairs(files) do
	resource.AddFile("materials/vgui/gphone/"..v)
end
files = file.Find( "materials/vgui/gphone/wallpapers/*.png", "GAME" ) -- Wallpapers
for k, v in pairs(files) do
	resource.AddFile("materials/vgui/gphone/wallpapers/"..v)
end

--// Receives data from applications and runs it on the server
net.Receive( "gPhone_DataTransfer", function( len, ply )
	local data = net.ReadTable()
	local dataHeader = data.header
	
	if dataHeader == GPHONE_MONEY_TRANSFER then -- Money transaction
		local amount = tonumber(data.amount)
		local target = data.target
		local plyWallet = tonumber(ply:getDarkRPVar("money"))
		
		-- If somehow a nil amount got through, catch it
		if amount == nil then 
			gPhone.ChatMsg( ply, "Unable to complete transaction - nil amount" )
			return
		else
			amount = math.abs(amount) -- Make sure its never a negative amount
		end
		
		if ply:GetTransferCooldown() > 0 then
			gPhone.ChatMsg( ply, "You must wait "..math.Round(ply:GetTransferCooldown()).."s before sending more money" )
			return
		end
		
		-- If the player disconnected or they are sending money to themselves, stop the transaction
		if not IsValid(target) or target == ply then
			gPhone.ChatMsg( ply, "Unable to complete transaction - invalid recipient" )
			return
		end
		
		-- Make sure the player has this money and didn't cheat it on the client
		if plyWallet > amount then 	
			-- Last measure before allowing the deal, call the hook
			local shouldTransfer, denyReason = hook.Run( "gPhone_ShouldAllowTransaction", ply, target, amount )
			if shouldTransfer == false then
				if denyReason != nil then
					gPhone.ChatMsg( ply, denyReason )
				else
					gPhone.ChatMsg( ply, "Unable to complete transaction, sorry" )
				end
				return
			end
			
			-- Complete the transaction
			target:addMoney(amount)
			ply:addMoney(-amount)
			gPhone.ChatMsg( target, "Received $"..amount.." from "..ply:Nick().."!" )
			gPhone.ChatMsg( ply, "Wired $"..amount.." to "..target:Nick().." successfully!" )
			
			ply:SetTransferCooldown( 5 )
		else
			gPhone.ChatMsg( ply, "Unable to complete transaction - lack of funds" )
			return
		end
	elseif dataHeader == GPHONE_STATE_CHANGED then -- The phone has been opened or closed
		local phoneOpen = data.open
		
		if phoneOpen == true then
			ply:SetNWBool("gPhone_Open", true)
			hook.Run( "gPhone_Built", ply )
		else
			ply:SetNWBool("gPhone_Open", false)
		end
	else
	
	end
end)

hook.Add("PlayerInitialSpawn", "gPhone_GenerateNumber", function( ply )
	ply:GeneratePhoneNumber()
	
	net.Start("gPhone_DataTransfer")
		net.WriteTable({header=GPHONE_OPEN})
	net.Send( ply )
end)


