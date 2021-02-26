/*---------------------------------------------------------------------------
in this file there are no settings, they are in the file "ad_config.lua"
---------------------------------------------------------------------------*/
airdrop.mapSize = airdrop.mapSize or {}
airdrop.occupiedHeights = airdrop.occupiedHeights or {}
airdrop.getStartPos = function( droppos, height )
	return util.TraceLine( { start = droppos, endpos = droppos + Vector( math.random( -10000, 10000 ), math.random( -10000, 10000 ), 0 ) } ).HitPos
end
airdrop.call = function( droppos )
	
	local height = math.random( airdrop.config.airplane.minheight, airdrop.config.airplane.maxheight )
	if not util.IsInWorld( droppos - Vector( 0, 0, droppos.z - height ) ) then
		
		droppos = util.TraceLine( { start = droppos, endpos = droppos - Vector( 0, 0, droppos.z - height ), filter = function( ent ) return false end } ).HitPos - Vector( 0, 0, 10 )
		
		timer.Simple( 0, function()
			local drop = ents.Create( 'ad_airdrop' )
			drop:SetPos( droppos )
			drop:Spawn()
		end )
		return
	end
	
	droppos.z = height
	local startpos = airdrop.getStartPos( droppos, height )
	local angle = ( droppos - startpos ):Angle() + airdrop.config.airplane.addangle
	local airplane = ents.Create( 'ad_airplane' )
	airplane:SetPos( startpos )
	airplane:SetAngles( angle )
	airplane:SetModelScale( airdrop.config.airplane.modelsize )
	airplane.startpos = startpos
	airplane.droppos = droppos
	airplane:Spawn()
end
airdrop.generateContent = function()
	local itemscount = math.random( airdrop.config.airdrop.minitems, airdrop.config.airdrop.maxitems )
	local content = {}
	for i = 1, itemscount do
		local random = math.random( 1, 100 ) 
		for r = #airdrop.config.airdrop.items, 1, -1 do
			if #airdrop.config.airdrop.items[ r ] == 0 then
				if i == 1 then
					MsgN( '[airdrop] there are no items with a rare [' .. r .. ']!' )
				end
				continue
				
			end
			if not airdrop.config.airdrop.items[ r ].chance then
				if i == 1 then
					MsgN( '[airdrop] there is not a chance for a rarity [' .. r .. ']!' )
				end
				continue
			end
			if r == 1 or random < airdrop.config.airdrop.items[ r ].chance then
				table.insert( content, { rarity = r, key = i * r * ( table.Count( content ) + i ) } )
				break
			else
				continue 
			end
		end
	end
	if #content == 0 then
		return {}
	end
	for k, v in pairs( content ) do
		v.item = table.Copy( airdrop.config.airdrop.items[ v.rarity ][ math.random( 1, #airdrop.config.airdrop.items[ v.rarity ] ) ] )
	end
	return content
end
airdrop.sendContent = function( ent, ply )
	
	if not ent.content then 
		ent.content = airdrop.generateContent()
	end
	if #ent.content == 0 and not timer.Exists( 'airdrop_remove#' .. ent:EntIndex() ) then
		timer.Create( 'airdrop_remove#' .. ent:EntIndex(), airdrop.config.airdrop.removetime or 60, 1, function()
			if not IsValid( ent ) then return end
			ent:Remove() 
		end )
	end
	net.Start( 'airdrop_itemact' )
	net.WriteEntity( ent )
	net.WriteString( util.TableToJSON( ent.content ) )
	net.Send( ply )
end
airdrop.getCellByKey = function( ent, key )
		
	if not ent.content then return end
	for k, v in pairs( ent.content ) do
		if v.key == key then
			return k
		end
	end
	return nil
end
airdrop.dropItem = function( drop, ply, key )
	local cell = airdrop.getCellByKey( drop, key )
	if not drop.content[ cell ] then return end
	local item = drop.content[ cell ].item
	
	if item.type == 'weapon' then
		local ent = ents.Create( 'ad_weapon' )
		ent:SetWeapon( item.class )
		ent:SetPos( drop:GetPos() + Vector( 0, 0, 35 ) )
		ent.ShareGravgun = true
		ent.nodupe = true
		if ent.dt then
			ent.dt.owning_ent = ply
		end
		ent:Spawn()
		ent:Activate()
	elseif item.type == 'entity' then
		local ent = ents.Create( item.class )
		ent:SetModel( item.model )
		ent:SetPos( drop:GetPos() + Vector( 0, 0, 45 ) )
		ent.ShareGravgun = true
		ent.nodupe = true
		if ent.dt then
			ent.dt.owning_ent = ply
		end
		ent:Spawn()
		ent:Activate()
	elseif item.type == 'money' then
		local ent = ents.Create( 'spawned_money' )
		ent:SetModel( item.model )
		ent:SetPos( drop:GetPos() + Vector( 0, 0, 45 ) )
		ent:Setamount( item.amount or 1 )
		ent.ShareGravgun = true
		ent.nodupe = true
		ent:Spawn()
		ent:Activate()
	elseif item.type == 'ps_item' or item.type == 'ps_points' then
		airdrop.sendContent( drop, ply )
		return
	end
	table.remove( drop.content, cell )
	airdrop.sendContent( drop, ply )
	
end
airdrop.useItem = function( drop, ply, key )
	
	if not IsValid( drop ) or not ply:Alive() then return end
	local cell = airdrop.getCellByKey( drop, key )
	if not drop.content[ cell ] then return end
	local item = drop.content[ cell ].item
	if item.type == 'weapon' then
		local ent = ents.Create( 'ad_weapon' )
		ent:SetWeapon( item.class )
		ent:SetPos( drop:GetPos() + Vector( 0, 0, 35 ) )
		ent.ShareGravgun = true
		ent.nodupe = true
		if ent.dt then
			ent.dt.owning_ent = ply
		end
		ent:Spawn()
		ent:Activate()
		ent:Use( ply, ply, SIMPLE_USE, 0 )
	elseif item.type == 'entity' then
		if not item.useable then
			airdrop.sendNotification( ply, 1, 4, airdrop.getPhrase( 'unuseable_item' ) )
			return
		end
		local ent = ents.Create( item.class )
		ent:SetModel( item.model )
		ent:SetPos( drop:GetPos() + Vector( 0, 0, 45 ) )
		ent.ShareGravgun = true
		ent.nodupe = true
		if ent.dt then
			ent.dt.owning_ent = ply
		end
		ent:Spawn()
		ent:Activate()
		ent:Use( ply, ply, SIMPLE_USE, 0 )
	elseif item.type == 'ps_item' then
		if not PS and not PS.Items then
			table.remove( drop.content, cell )
			airdrop.sendContent( drop, ply )
			return
		end
		if ply.PS_Items[ item.index ] then
			airdrop.sendNotification( ply, 0, 5, airdrop.getPhrase( 'ps_alreadyavailable' ) )
			airdrop.sendContent( drop, ply )
			return
		end
		local success = ply:PS_GiveItem( item.index )
		if not success then
			airdrop.sendNotification( ply, 0, 5, 'Pointshop error' )
			table.remove( drop.content, cell )
			airdrop.sendContent( drop, ply )
			return
		end
		airdrop.sendNotification( ply, 0, 5, string.format( airdrop.getPhrase( 'ps_added' ), PS.Items[ item.index ].Name ) )
	elseif item.type == 'ps_points' then
		if not PS and not PS.Items then
			table.remove( drop.content, cell )
			airdrop.sendContent( drop, ply )
			return
		end
		ply:PS_GivePoints( item.amount )
		airdrop.sendNotification( ply, 0, 5, string.format( airdrop.getPhrase( 'ps_gived' ), item.amount ) )
	elseif item.type == 'money' then
		if not DarkRP then
			table.remove( drop.content, cell )
			airdrop.sendContent( drop, ply )
			return
		end
		local ent = ents.Create( 'spawned_money' )
		ent:SetModel( item.model )
		ent:SetPos( drop:GetPos() + Vector( 0, 0, 45 ) )
		ent:Setamount( item.amount or 1 )
		ent.ShareGravgun = true
		ent.nodupe = true
		ent:Spawn()
		ent:Activate()
		ent:Use( ply, ply, SIMPLE_USE, 0 )
	end
	table.remove( drop.content, cell )
	airdrop.sendContent( drop, ply )
end
airdrop.sendNotification = function( ply, msgtype, length, msg )
	net.Start( 'airdrop_notify' )
	net.WriteUInt( msgtype, 8 )
	net.WriteUInt( length, 8 )
	net.WriteString( msg )
	net.Send( ply )
	
end

airdrop.setDefaultConfig = function()
	
	airdrop.config.localisation.language = 'en'
	airdrop.config.ui = {
	
		animations_speed = 0.25, itempnl_wide = 1.35,
		rarityColors = {
			[ 1 ] = Color( 0, 161, 255, 150 ), [ 2 ] = Color( 127, 0, 255, 150 ), [ 3 ] = Color( 127, 0, 0, 150 ), [ 4 ] = Color( 221, 19, 123, 150 ), [ 5 ] = Color( 255, 255, 0, 150 )
		}
	}
	airdrop.config.airdrop = {
	
		force = 1, removetime = 60, minitems = 3, maxitems = 9, items = {
			[ 1 ] = { chance = 100 }, [ 2 ] = { chance = 50 }, [ 3 ] = { chance = 25 }, [ 4 ] = { chance = 10 }, [ 5 ] = { chance = 2 }
		}
	}
	airdrop.config.airplane = { 
		minspeed = 3, maxspeed = 6, minheight = 500, maxheight = 512, modelsize = 1, addangle = Angle( 0, 90, 0 ),
		sound = 'sound/ambient/machines/aircraft_distant_flyby3.wav', volume = 5
	}
	airdrop.saveConfig()
end
airdrop.saveConfig = function()
	
	if not file.Exists( 'airdrop', 'DATA' ) then
		file.CreateDir( 'airdrop' )
	end
	local config = table.Copy( airdrop.config )
	config.localisation = nil
	file.Write( 'airdrop/airdrop_settings.txt', util.TableToJSON( config ) )
end
airdrop.loadConfig = function()
	
	if not file.Exists( 'airdrop', 'DATA' ) or not file.Exists( 'airdrop/airdrop_settings.txt', 'DATA' ) then
		airdrop.setDefaultConfig()
		for k, v in pairs( player.GetAll() ) do
			airdrop.sendUISettings( v )
		end
		return
	end
	local localisation = airdrop.config.localisation
	airdrop.config = util.JSONToTable( file.Read( 'airdrop/airdrop_settings.txt', 'DATA' ) )
	airdrop.config.localisation = localisation
	for k, v in pairs( player.GetAll() ) do
		airdrop.sendUISettings( v )
	end
end
airdrop.sendUISettings = function( ply )
	
	local config = {
		[ 'language' ] = airdrop.config.localisation.language,
		[ 'ui' ] = airdrop.config.ui,
		[ 'airplane' ] = { volume = airdrop.config.airplane.volume, sound = airdrop.config.airplane.sound }
	}
	config = util.TableToJSON( config )
	net.Start( 'airdrop_configact' )
	net.WriteString( 'ui_settings' )
	net.WriteString( config )
	net.Send( ply )
end
airdrop.loadConfig()
--# Console commands #--
concommand.Add( 'airdrop_config', function( ply )
	if not table.HasValue( airdrop.config.usergroups, ply:GetUserGroup() ) then return end
	local config = table.Copy( airdrop.config )
	// We do not send some parameters to not reach the network limit
	config.localisation = nil
	config.airplane_models = nil
	config.usergroups = nil
	net.Start( 'airdrop_configact' )
	net.WriteString( 'full_config' )
	net.WriteString( util.TableToJSON( config ) )
	net.Send( ply )
end )
--# Hooks #--
hook.Add( 'GravGunPickupAllowed', 'airdrop', function( ply, ent )
	if ent:GetClass() == 'ad_airdrop' then return false end
end )
hook.Add( 'GravGunPunt', 'airdrop', function( ply, ent )
	if ent:GetClass() == 'ad_airdrop' then return false end
end )
hook.Add( 'PlayerInitialSpawn', 'airdrop', function( ply )
	airdrop.sendUISettings( ply )
end )
--# Network #--
util.AddNetworkString( 'airdrop_itemact' )
util.AddNetworkString( 'airdrop_configact' )
util.AddNetworkString( 'airdrop_notify' )
net.Receive( 'airdrop_itemact', function( len, ply )
	local ent = net.ReadEntity()
	if not IsValid( ent ) or ent:GetClass() != 'ad_airdrop' then return end
	if not ply:Alive() or ply:GetPos():Distance( ent:GetPos() ) > 200 then return end
	local action = net.ReadString()
	if action == 'drop' then
		airdrop.dropItem( ent, ply, net.ReadFloat() )
	elseif action == 'use' then
		airdrop.useItem( ent, ply, net.ReadFloat() )
	end
end )
net.Receive( 'airdrop_configact', function( len, ply )
	if not table.HasValue( airdrop.config.usergroups, ply:GetUserGroup() ) then return end 
	local action = net.ReadString()
	if action == 'itemedit' then
		local rarity = net.ReadUInt( 8 )
		local newitem = net.ReadBool()
		local id = newitem and 1 or net.ReadUInt( 8 )
		
		local item = util.JSONToTable( net.ReadString() )
		if not airdrop.isValidItem( item ) then return end
		if not airdrop.config.airdrop.items[ rarity ] then return end
		if newitem then
			id = table.insert( airdrop.config.airdrop.items[ rarity ], item )
			airdrop.sendNotification( ply, 0, 4, string.format( airdrop.getPhrase( 'success_itemadd' ), rarity .. '-' .. id ) )
		else
			airdrop.sendNotification( ply, 0, 4, string.format( airdrop.getPhrase( 'success_itemedit' ), rarity .. '-' .. id ) )
			airdrop.config.airdrop.items[ rarity ][ id ] = item
		end
		airdrop.saveConfig()
			
	elseif action == 'itemdel' then
		local rarity = net.ReadUInt( 8 )
		local id = net.ReadUInt( 8 )
		if not airdrop.config.airdrop.items[ rarity ] then return end
		if not airdrop.config.airdrop.items[ rarity ][ id ] then return end
		airdrop.sendNotification( ply, 0, 10, string.format( airdrop.getPhrase( 'success_itemdel' ), rarity .. '-' .. id ) )
		table.remove( airdrop.config.airdrop.items[ rarity ], id )
		airdrop.saveConfig()
	elseif action == 'airdrop' or action == 'airplane'  or action == 'ui' then
		local key = net.ReadString()
		local value = net.ReadFloat()
		if not airdrop.config[ action ][ key ] then return end
		airdrop.sendNotification( ply, 0, 10, airdrop.getPhrase( action .. '_' .. key ) .. ' -> ' .. value )
		airdrop.config[ action ][ key ] = value
		airdrop.saveConfig()
		if key == 'volume' or key == 'animations_speed' then
			for k, v in pairs( player.GetAll() ) do
				airdrop.sendUISettings( v )
			end
		end
	elseif action == 'rarityedit' then
		local key = net.ReadString()
		local rarity = net.ReadUInt( 8 )
		local value = ( key == 'chance' and net.ReadUInt( 8 ) or net.ReadColor() )
		if not airdrop.config.airdrop.items[ rarity ] then return end
		if key == 'chance' then
			value = math.Clamp( value, 1, 100 )
			airdrop.config.airdrop.items[ rarity ].chance = value
			airdrop.sendNotification( ply, 0, 10, string.format( airdrop.getPhrase( 'changed_chance' ), rarity, value ) )
		elseif key == 'color' then
		end
		airdrop.saveConfig()
	end
end )