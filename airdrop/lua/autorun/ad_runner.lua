if SERVER then
	AddCSLuaFile( 'ad_config.lua' )
	AddCSLuaFile( 'ad_localisation.lua' )
			
	AddCSLuaFile( 'airdrop/sh_airdrop.lua' )
	AddCSLuaFile( 'airdrop/cl_airdrop.lua' )
	
	include( 'ad_config.lua' )
	include( 'ad_localisation.lua' )
	include( 'ad_resources.lua' )
	include( 'airdrop/sh_airdrop.lua' )
	include( 'airdrop/sv_airdrop.lua' )
else
	include( 'ad_config.lua' )
	include( 'ad_localisation.lua' )
	include( 'airdrop/sh_airdrop.lua' )
	include( 'airdrop/cl_airdrop.lua' )
end