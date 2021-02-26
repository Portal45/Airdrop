AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )
ENT.Initialize = function( self )
	
	self:SetModel( 'models/weapons/w_rif_ak47.mdl' )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	
	self:SetSolid( SOLID_VPHYSICS )
	
	self:SetCollisionGroup( COLLISION_GROUP_NONE )
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
		
	if IsValid( phys ) then
		phys:Wake()
	end
end
ENT.SetWeapon = function( self, class )
		
	local weapon = weapons.Get( class )
	if not weapon then return end
	self:SetNWString( 'weaponclass', class )
	self:SetNWInt( 'ammotype', weapon.Primary.Ammo )
	self:SetNWInt( 'defaultclip', weapon.Primary.DefaultClip )
	self:SetModel( weapon.WorldModel )
	self:PhysicsInit( SOLID_VPHYSICS )
	if not IsValid( self:GetPhysicsObject() ) then
		self:SetModel( 'models/weapons/w_rif_ak47.mdl' )
		self:PhysicsInit( SOLID_VPHYSICS )
	end					
end
ENT.Use = function( self, activator, caller )
	
	if not IsValid( caller ) or not caller:IsPlayer() then return end
	if not self:GetNWString( 'weaponclass', nil ) then return end
	local class = self:GetNWString( 'weaponclass' ) 
	if caller:HasWeapon( class ) then
		if self:GetNWString( 'defaultclip' ) == -1 then
			return
		end
		caller:GiveAmmo( self:GetNWString( 'defaultclip' ), self:GetNWString( 'ammotype' ) )
	else
		caller:Give( class )
	end
	self:Remove()
end