/*---------------------------------------------------------------------------
in this file there are no settings, they are in the file "ad_config.lua"
---------------------------------------------------------------------------*/
airdrop.supportedItemTypes = {
	
	[ 'ps_points' ] = function() return PS != nil end, 
	[ 'ps_item' ] = function() return PS != nil end, 
	[ 'entity' ] = function() return true end, 
	[ 'weapon' ] = function() return true end, 
	[ 'money' ] = function() return DarkRP != nil end,
}
airdrop.getPhrase = function( phrase )
		
	local lang = airdrop.config.localisation.language or 'en'
	return ( airdrop.config.localisation[ lang ] and airdrop.config.localisation[ lang ][ phrase ] or phrase ) or phrase
end

airdrop.getEntityName = function( class )
	
	local entdata = scripted_ents.Get( class )
	
	if entdata and entdata.PrintName then
		return entdata.PrintName
	end

	local entlist = list.Get('SpawnableEntities')

	if entlist and entlist[ class ] and entlist[ class ].PrintName then
		return entlist[ class ].PrintName
	end

	return class
end

airdrop.isValidValue = function( str )
	
	return ( str and string.Trim( str ) != '' )
end
airdrop.isValidItem = function( item )
	
	local name, model, class, index, amount = airdrop.isValidValue( item.name ), airdrop.isValidValue( item.model ), airdrop.isValidValue( item.class ), airdrop.isValidValue( item.index ), ( item.amount != nil and tonumber( item.amount ) != nil )
		
	if not airdrop.supportedItemTypes[ item.type ] or not airdrop.supportedItemTypes[ item.type ]() then return false end 
	if item.type == 'entity' then
		return ( model and class )
	elseif item.type == 'weapon' then
		return ( name and class )
	elseif item.type == 'ps_points' then
		return ( name and amount )
	elseif item.type == 'ps_item' then
		return ( index and PS.Items[ item.index ] )
	elseif item.type == 'money' then
		return ( name and amount )
	end
	return false
end