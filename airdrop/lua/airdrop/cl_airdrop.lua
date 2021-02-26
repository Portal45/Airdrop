/*---------------------------------------------------------------------------
in this file there are no settings, they are in the file "ad_config.lua"
---------------------------------------------------------------------------*/
airdrop.browSize = ScrH() - ( ScrH() / 1.035 )
airdrop.indent = 5
airdrop.gradientMaterial = Material( 'vgui/gradient-l' )
airdrop.blurMaterial = Material( 'pp/blurscreen' )
airdrop.notify = function( msg, msgtype, length )
	
	msg = '[airdrop] ' .. msg
	MsgN( msg )
	notification.AddLegacy( msg, msgtype and msgtype or 0, length and length or 5 )
	surface.PlaySound( 'buttons/lightswitch2.wav' )
end
airdrop.getDefaultItemModel = function( item )
		
	if item.type == 'entity' then
		return 'models/props_junk/wood_crate001a.mdl'
	elseif item.type == 'weapon' then
		local weapon = weapons.Get( item.class )
		if weapon and weapon.WorldModel then
			return weapon.WorldModel
		else
			return 'models/items/item_item_crate.mdl'
		end
	elseif item.type == 'money' then
		return 'models/props/cs_assault/money.mdl'
	elseif item.type == 'ps_item' then
		if PS and PS.Items[ item.index ] then
			return PS.Items[ item.index ].Model
		end
	elseif item.type == 'ps_points' then
		return 'models/props_junk/garbage_glassbottle003a.mdl'
	end
	return 'models/props_junk/wood_crate001a.mdl'
end
airdrop.blurPanel = function( panel, layers, density, alpha )
	
	local x, y = panel:LocalToScreen( 0, 0 )
	surface.SetDrawColor( Color( 255, 255, 255, alpha ) )
	surface.SetMaterial( airdrop.blurMaterial )
	for i = 1, 3 do
		airdrop.blurMaterial:SetFloat( '$blur', ( i / layers) * density )
		airdrop.blurMaterial:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
end
airdrop.createFrame = function( title, closebutton )
	
	local frame = vgui.Create( 'DFrame' )
	frame:MakePopup()
	frame:ShowCloseButton( false )
	frame:SetDraggable( false )
	frame:SetTitle( '' )
	frame.title = title
	frame.Paint = function( self, w, h )
		
		airdrop.blurPanel( self, 3, 6 )
		surface.SetDrawColor( 0,0,0,100 )
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 130 ) )
		draw.RoundedBoxEx( 0, 0, 0, w, airdrop.browSize, Color( 0, 0, 0, 100 ), false, false )
		draw.SimpleText( self.title, 'airdrop_normal', 5, airdrop.browSize / 2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
	airdrop.activeFrame = frame
	if closebutton then
		
		local button = vgui.Create( 'DButton', frame )
		button:SetText( '' )
		button:SetFont( 'airdrop_normal' )
		button:SetTextColor( Color( 255, 255, 255 ) )
		button:SizeToContents()
		button:SetSize( 25, 25 )
		button.Paint = function( self, w, h )
			
			draw.SimpleText( 'x', 'airdrop_normal', w / 2, h / 2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		button.DoClick = function( )
			frame:AlphaTo( 0, 0.15 * airdrop.config.ui.animations_speed, 0, function( anim, self )
				self:Remove()
			end )
		end
		frame.closebutton = button
		local funcs = {
			'SetSize', 'SetWide', 'SetTall'
		}
		for k, v in pairs( funcs ) do
			local oldfunc = frame[ v ]
			if not oldfunc then continue end
			frame[ v ] = function( self, ... )
				oldfunc( self, ... )
				frame.closebutton:SetPos( frame:GetWide() - frame.closebutton:GetWide() - 2.5, ( airdrop.browSize - frame.closebutton:GetTall() ) / 2 )
			end
		end
	end
	return frame
end
airdrop.buttonPaint = function( self, w, h )
	
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 130 ) )
	draw.SimpleText( self.text or '?', self.font and self.font or 'airdrop_small', w / 2, h / 2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
airdrop.comboboxPaint = function( combobox )
	combobox.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end
end
airdrop.createButton = function( text, font, parent, autowide )
	
	local button = vgui.Create( 'DButton', parent )
	button:SetText( autowide and text or '' )
	if autowide then
		button:SetFont( font )
		button:SizeToContents()
		button:SetWide( button:GetWide() * 1.5 )
		button:SetText( '' ) 
	end
	button.font = font
	button.text = text
	button.Paint = airdrop.buttonPaint
	
	return button
end
airdrop.createTextEntry = function( defaultText, parent )
	
	local textEntry = vgui.Create( 'DTextEntry', parent )
	textEntry:SetFont('airdrop_normal')
	textEntry:SetTextColor( Color( 255, 255, 255 ) )
	textEntry.defaultText = defaultText
	textEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		if not self:IsEditing() and self:GetValue() == '' then
			draw.SimpleText( self.defaultText, 'airdrop_normal', 10, h / 2, Color( 255, 255, 255, 100 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		if self:GetValue() != '' then
			draw.SimpleText( self:GetValue(), 'airdrop_normal', 10, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		if self:IsEditing() then
			surface.SetFont('airdrop_normal')
			local vw, vh = surface.GetTextSize( utf8.sub(self:GetValue(), 1, self:GetCaretPos() ) )
			local alpha = ( CurTime() - ( self.lastChange or 0 ) > 0.5 ) and math.cos( (CurTime() - ( self.lastChange or 0 ) )* 5 ) * 255 or 255
			draw.RoundedBox( 1, vw + 10, h - ( h - 4 ), 2, h - 8, Color( 255, 255, 255, alpha ) )
		end
	end
	textEntry.OnChange = function( self )
		self.lastChange = CurTime()
	end
	return textEntry
end
airdrop.createNumWang = function( parent )
	local numberWang = vgui.Create( 'DNumberWang', parent )
	numberWang:SetFont('airdrop_normal')
	numberWang:SetTextColor( Color( 255, 255, 255 ) )
	numberWang.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		if self:GetValue() != '' then
			draw.SimpleText( self:GetValue(), 'airdrop_small', 10, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		if self:IsEditing() then
			surface.SetFont( 'airdrop_small' )
			local vw, vh = surface.GetTextSize(  utf8.sub(tostring(self:GetValue()), 1, self:GetCaretPos() )  )
			local alpha = ( CurTime() - ( self.lastChange or 0 ) > 0.5 ) and math.cos( (CurTime() - ( self.lastChange or 0 ) ) * 5 ) * 255 or 255
			draw.RoundedBox( 1, vw + 10, h - ( h - 4 ), 2, h - 8, Color( 255, 255, 255, alpha ) )
		end
	end
	numberWang.OnChange = function( self )
		self.lastChange = CurTime()
	end
	return numberWang
end
airdrop.createNumWangLine = function( text, defValue, minvalue, maxvalue, action, key, y, w, parent, config, bits )
	
	local label = vgui.Create( 'DLabel', parent )
	label:SetFont( 'airdrop_small' )
	label:SetTextColor( Color( 255, 255, 255 ) )
	label:SetText( text .. ':' )
	label:SizeToContents()
	label:SetPos( airdrop.indent, y )
	local numberWang = airdrop.createNumWang( parent )
	numberWang:SetSize( w - ( airdrop.indent * 3 + label:GetWide() ), label:GetTall() )
	numberWang:SetPos( airdrop.indent * 2 + label:GetWide(), y )
	if minvalue then numberWang:SetMin( minvalue ) end
	if maxvalue then numberWang:SetMax( maxvalue ) end
	numberWang:SetText( defValue )
	numberWang.OnEnter = function( self )
		if not action or not key then return end
		net.Start( 'airdrop_configact' )
		net.WriteString( action )
		net.WriteString( key )
		net.WriteFloat( self:GetValue() )
		net.SendToServer()
		config[ action ][ key ] = tonumber( self:GetValue() )
	end
	numberWang.OnRemove = function( self )
		label:Remove()
	end
	return label, numberWang
end
airdrop.createItempnl = function( item, itempnl_wide, itempnl_height, frame, rarity )
	
	local itempnl = vgui.Create( 'DPanel', frame )
	itempnl:SetSize( itempnl_wide, itempnl_height )
	itempnl.Paint = function( self, w, h )
		if rarity != -1 then
			surface.SetMaterial( airdrop.gradientMaterial )
				
			surface.SetDrawColor( airdrop.config.ui.rarityColors[ rarity ] or airdrop.config.ui.rarityColors[ #airdrop.config.ui.rarityColors ] )
				
			surface.DrawTexturedRect( 0, 0, 400, 100 )
		end
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end
	local iconbg, icon
	item.model = item.model or airdrop.getDefaultItemModel( item )
	if item.model then
		iconbg = vgui.Create( 'DPanel', itempnl )
		iconbg:SetPos( airdrop.indent / 2, airdrop.indent / 2 )
		iconbg:SetTall( itempnl:GetTall() - airdrop.indent )
		iconbg:SetWide( iconbg:GetTall() )
		iconbg.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 130 ) )
		end
		icon = vgui.Create( 'SpawnIcon', iconbg )
		icon:SetPos( airdrop.indent / 2, airdrop.indent / 2 )
		icon:SetTall( iconbg:GetTall() - airdrop.indent )
		icon:SetWide( icon:GetTall() )
		icon:SetModel( item.model )
		icon.IsHovered = function() return false end
		icon:SetTooltip( false )
	end
	if item.type == 'ps_item' and PS then
		item.name = PS.Items[ item.index ].Name
	elseif item.type == 'entity' then
		item.name = airdrop.getEntityName ( item.class )
	end

	local name = vgui.Create( 'DLabel', itempnl )
	name:SetText( item.name or 'item name' )
	name:SetTextColor( Color( 255, 255, 255 ) )
	name:SetFont( 'airdrop_normal' )
	name:SizeToContents()
	name:SetTall( itempnl:GetTall() )
	name:SetContentAlignment( 4 )
	name:SetPos( item.model and iconbg:GetWide() + airdrop.indent * 2 or airdrop.indent, 0 )
	return itempnl
end
airdrop.removeScrollBar = function( pnl )
	pnl:GetVBar().Paint = function() return true end
	pnl:GetVBar():SetVisible( false )
	pnl:GetVBar().btnUp.Paint = function() return true end
	pnl:GetVBar().btnDown.Paint = function() return true end
	pnl:GetVBar().btnGrip.Paint = function() return true end
	pnl.OnScrollbarAppear = function() return true end
end
airdrop.activeFrame = airdrop.activeFrame or nil
airdrop.showAirdropItems = function( ent, content )
	if not airdrop.config.loaded then 
		airdrop.notify( airdrop.GetPhrase( 'ui_not_loaded' ), 1, 4 )
		return 
	end
		
	if airdrop.activeFrame then airdrop.activeFrame:Remove() end
	local frame = airdrop.createFrame( 'Airdrop Items', true )
	
	if #content > 0 then
		for k, v in pairs( content ) do
			local item = v.item			
			local itempnl = airdrop.createItempnl( item, airdrop.itempnl_wide, airdrop.itempnl_height, frame, v.rarity )
			itempnl:SetPos( airdrop.indent, airdrop.browSize + airdrop.indent + ( airdrop.indent + itempnl:GetTall() ) * ( k - 1 ) )
			local buttonWide = ScrW() - ( ScrW() / 1.05 )
			local buttonTall = itempnl:GetTall() - airdrop.indent * 2.5
			local dropbutton
			if item.type != 'ps_item' and item.type != 'ps_points' then
				dropbutton = airdrop.createButton( 'Drop', 'airdrop_small', itempnl, true )
				dropbutton:SetTall( buttonTall )
				dropbutton:SetPos( itempnl:GetWide() - airdrop.indent - dropbutton:GetWide(), ( itempnl:GetTall() - buttonTall ) / 2 )
				dropbutton.DoClick = function( self )
					net.Start( 'airdrop_itemact' )
					net.WriteEntity( ent )
					net.WriteString( 'drop' )
					net.WriteFloat( v.key )
					net.SendToServer()
				end
			end
			if item.useable or item.type != 'entity' then
				local usebutton = airdrop.createButton( 'Use', 'airdrop_small', itempnl )
				usebutton:SetSize( buttonWide, buttonTall )
				usebutton:SetPos( itempnl:GetWide() - airdrop.indent - ( dropbutton and dropbutton:GetWide() or 0 ) - airdrop.indent / 2 - usebutton:GetWide(), ( itempnl:GetTall() - buttonTall ) / 2 )
				usebutton.DoClick = function( self )
					net.Start( 'airdrop_itemact' )
					net.WriteEntity( ent )
					net.WriteString( 'use' )
					net.WriteFloat( v.key )
					net.SendToServer()
				end
			end
		end
		frame:SetSize( airdrop.indent * 2 + airdrop.itempnl_wide, airdrop.browSize + airdrop.indent + #content * airdrop.itempnl_height + #content * airdrop.indent )
		frame:Center()
	else
		local wide, height = ScrW() - ( ScrW() / 1.2 ), ScrH() - ( ScrH() / 1.075 )
		local pnl = vgui.Create( 'DPanel', frame )
		pnl:SetPos( 0, airdrop.browSize )
		pnl:SetSize( wide, height )
		pnl.Paint = function( self, w, h )
			draw.SimpleText( airdrop.getPhrase( 'airdrop_empty' ) .. ' ;(', 'airdrop_normal', w / 2, h / 2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		frame:SetSize( wide, height + airdrop.browSize )
		frame:Center()
	end
end

airdrop.openconfigurator = function( config )
	if not airdrop.config.loaded then 
		airdrop.notify( airdrop.GetPhrase( 'ui_not_loaded' ), 1, 4 )
		return 
	end
	
	local frame = airdrop.createFrame( 'Airdrop Configurator', true )
	local panelH, panelW = ScrH() - ( ScrH() / 1.05 )
	local panels = {
		{
			name = airdrop.getPhrase( 'items_settings' ),
			w = ScrW() - ( ScrW() / ( config.ui[ 'itempnl_wide' ] / 1.05 ) ),
			h = ScrH() - ( ScrH() / 1.3 ),
			hidebackground = true,
			func = function( self, pnl, backfunc )
				local editpanel = vgui.Create( 'DPanel', pnl )
				editpanel:SetSize( self.w, self.h )
				editpanel:SetPos( 0, 0 )
				editpanel.item = {}
				editpanel:SetAlpha( 0 )
				editpanel:SetVisible( false )
				editpanel.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
				end
				table.insert( pnl.pelements, editpanel )
				editpanel.item.model = editpanel.item.model or airdrop.getDefaultItemModel( editpanel.item )
				local iconbg = vgui.Create( 'DPanel', editpanel )
				iconbg:SetPos( airdrop.indent, airdrop.indent )
				iconbg:SetTall( ScrW() - ( ScrW() / 1.05 ) )
				iconbg:SetWide( iconbg:GetTall() )
				iconbg.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 130 ) )
				end
				local icon = vgui.Create( 'SpawnIcon', iconbg )
				icon:SetPos( airdrop.indent, airdrop.indent )
				icon:SetTall( iconbg:GetTall() - airdrop.indent * 2 )
				icon:SetWide( icon:GetTall() )
				icon.IsHovered = function() return false end
				icon:SetModel( 'models/props_junk/wood_crate001a.mdl' )
				icon.model = 'models/props_junk/wood_crate001a.mdl'
				icon:SetTooltip( false )
				icon.Think = function( self )
				
					if self.model != editpanel.item.model then
						self:SetModel( ( editpanel.item.model and string.Trim( editpanel.item.model ) != '' )  and editpanel.item.model or airdrop.getDefaultItemModel( editpanel.item ) )
					
						self.model = editpanel.item.model
					end
				end
				local itemrarity = vgui.Create( 'DComboBox', editpanel )
				itemrarity:SetSize( editpanel:GetWide() - airdrop.indent * 3 - iconbg:GetWide(), iconbg:GetTall() / 2 - airdrop.indent / 2 )
				itemrarity:SetPos( airdrop.indent * 2 + iconbg:GetWide(), airdrop.indent + iconbg:GetTall() - itemrarity:GetTall() )
				itemrarity:SetValue( airdrop.getPhrase( 'item_rarity' ) )
				itemrarity:SetFont( 'airdrop_normal' )
				itemrarity:SetTextColor( Color( 255, 255, 255 ) )
				for i = 1, #config.ui.rarityColors do
					itemrarity:AddChoice( airdrop.getPhrase( 'rarity' ) .. ' ' .. i .. ( ( i == 1 or i == 5 ) and ( ' (' ..airdrop.getPhrase( i == 1 and 'quite_frequent' or 'very_rare' ) .. ')' ) or '' ) )
				end
				if editpanel.item.rarity then
					itemrarity:ChooseOptionID( editpanel.item.rarity )
				end
				itemrarity.OnSelect = function( self, index )
					editpanel.item.rarity = index
				end
				airdrop.comboboxPaint( itemrarity )
				local textentry = airdrop.createTextEntry( airdrop.getPhrase( 'item_name' ), editpanel )
				textentry:SetSize( editpanel:GetWide() - airdrop.indent * 2, itemrarity:GetTall() )
				textentry:SetPos( airdrop.indent, airdrop.indent * 2 + iconbg:GetTall() )
				textentry.Think = function( self )
					if editpanel.item.type == 'entity' then
						editpanel.item.class = self:GetValue()
					elseif editpanel.item.type == 'weapon' then
						editpanel.item.name = self:GetValue()
					elseif editpanel.item.type == 'ps_points' then
						editpanel.item.name = self:GetValue()
					elseif editpanel.item.type == 'ps_item' then
						editpanel.item.index = self:GetValue()
					
						editpanel.item.model = airdrop.getDefaultItemModel( editpanel.item )
					elseif editpanel.item.type == 'money' then
						editpanel.item.name = self:GetValue()
					end
				end
				local textentry2 = airdrop.createTextEntry( '?', editpanel )
				textentry2:SetSize( editpanel:GetWide() - airdrop.indent * 2, itemrarity:GetTall() )
				textentry2:SetPos( airdrop.indent, airdrop.indent * 3 + iconbg:GetTall() + textentry:GetTall() )
				textentry2:SetText( '' )
				textentry2.Think = function( self )
					if editpanel.item.type == 'entity' then
						editpanel.item.model = string.Trim( self:GetValue() ) == '' and nil or self:GetValue()
					elseif editpanel.item.type == 'weapon' then
						editpanel.item.class = self:GetValue()
						editpanel.item.model = airdrop.getDefaultItemModel( editpanel.item )
					elseif editpanel.item.type == 'ps_item' or editpanel.item.type == 'weapon' then
						editpanel.item.index = self:GetValue()
						editpanel.item.model = airdrop.getDefaultItemModel( editpanel.item )
					elseif editpanel.item.type == 'ps_points' or editpanel.item.type == 'money' then
						editpanel.item.amount = self:GetValue()
					end
						
				end
				local itemtype = vgui.Create( 'DComboBox', editpanel )
				itemtype:SetPos( airdrop.indent * 2 + iconbg:GetWide(), airdrop.indent )
				itemtype:SetSize( editpanel:GetWide() - airdrop.indent * 3 - iconbg:GetWide(), iconbg:GetTall() / 2 - airdrop.indent / 2 )
				itemtype:SetValue( airdrop.getPhrase( 'item_type' ) )
				itemtype:SetFont( 'airdrop_normal' )
				itemtype:SetTextColor( Color( 255, 255, 255 ) )
				itemtype.types = {}
				for k, v in pairs( airdrop.supportedItemTypes ) do
					if not v() then continue end
					itemtype:AddChoice( airdrop.getPhrase( 'itemtype_' .. k ) )
					table.insert( itemtype.types, k )
				end
				airdrop.comboboxPaint( itemtype )
				itemtype.OnSelect = function( self, index )
					local selectedtype = itemtype.types[ index ]
					
					if not editpanel.item.type then
						textentry:SetVisible( true )
						textentry2:SetVisible( true )
					end
					if editpanel.item.type != selectedtype then
						textentry2:SetText( '' )
						textentry:SetText( '' )
						if editpanel.item.type then
							local rarity = editpanel.item.rarity 
							local id = editpanel.item.id
							editpanel.item = { rarity = rarity or nil, id = id or nil }
						end
						editpanel.item.type = selectedtype
						editpanel.item.model = airdrop.getDefaultItemModel( editpanel.item )
					end
					if selectedtype == 'entity' then
						textentry.defaultText = airdrop.getPhrase( 'item_class' )
						textentry2.defaultText = airdrop.getPhrase( 'item_model' )
						textentry2:SetVisible( true )
					elseif selectedtype == 'ps_points' or selectedtype == 'money' then
						textentry.defaultText = airdrop.getPhrase( 'item_name' )
						textentry2.defaultText = airdrop.getPhrase( 'item_amount' )
						textentry2:SetVisible( true )
					elseif selectedtype == 'ps_item' then
						textentry.defaultText = airdrop.getPhrase( 'item_index' )
						textentry2:SetVisible( false )
					elseif selectedtype == 'weapon' then
						textentry.defaultText = airdrop.getPhrase( 'item_name' )
						textentry2.defaultText = airdrop.getPhrase( 'item_class' )
						textentry2:SetVisible( true )
					end
				end
				local itemspanel
				local applybutton = airdrop.createButton( airdrop.getPhrase( 'apply' ), 'airdrop_small', editpanel )
				applybutton:SetSize( editpanel:GetWide() / 2 - airdrop.indent * 1.5, editpanel:GetTall() - ( textentry2:GetTall() * 4 + airdrop.indent * 6 ) )
				applybutton:SetPos( airdrop.indent, editpanel:GetTall() - airdrop.indent - applybutton:GetTall() )
				applybutton.DoClick = function()
					local isvalid = airdrop.isValidItem( editpanel.item )
					if isvalid then
						editpanel:AlphaTo( 0, 0.5 * config.ui.animations_speed, 0, function()
							editpanel:SetVisible( false )
							itemspanel:SetVisible( true )
							itemspanel:AlphaTo( 255, 0.5 * config.ui.animations_speed )
						end )
						local rarity = editpanel.item.rarity or 1
						local id = editpanel.item.id
						
						editpanel.item.rarity = nil
						editpanel.item.id = nil
						net.Start( 'airdrop_configact' )
						net.WriteString( 'itemedit' )
						net.WriteUInt( rarity, 8 )
						net.WriteBool( ( id == -1 or not id ) )
					
						if id and id != -1 then
							net.WriteUInt( id, 8 )
						end
						net.WriteString( util.TableToJSON( editpanel.item ) )
						net.SendToServer()
						if id and id != -1 then
							config.airdrop.items[ rarity ][ id ] = editpanel.item
						else
							table.insert( config.airdrop.items[ rarity ], editpanel.item )
						end
						itemspanel:drawItems()
					else
						airdrop.notify( airdrop.getPhrase( 'incorrect_item' ), 1, 4 )
					end
				end
				local cancelbutton = airdrop.createButton( airdrop.getPhrase( 'cancel' ), 'airdrop_small', editpanel )
				cancelbutton:SetSize( editpanel:GetWide() / 2 - airdrop.indent * 1.5, editpanel:GetTall() - ( textentry2:GetTall() * 4 + airdrop.indent * 6 ) )
				cancelbutton:SetPos( editpanel:GetWide() - airdrop.indent - cancelbutton:GetWide(), editpanel:GetTall() - airdrop.indent - cancelbutton:GetTall() )
				cancelbutton.DoClick = function()
					editpanel:AlphaTo( 0, 0.5 * config.ui.animations_speed, 0, function()
						editpanel:SetVisible( false )
						itemspanel:SetVisible( true )
						itemspanel:AlphaTo( 255, 0.5 * config.ui.animations_speed )
					end )
				end
				editpanel.resetValues = function()
					textentry:SetVisible( false )
					textentry2:SetVisible( false )
					itemtype:SetValue( airdrop.getPhrase( 'item_type' ) )
					itemrarity:SetValue( airdrop.getPhrase( 'item_rarity' ) )
					icon:SetModel( 'models/props_junk/wood_crate001a.mdl' )
					icon.model = 'models/props_junk/wood_crate001a.mdl'
				end
				editpanel.setItemValues = function()
					//local saved = editpanel.item
					--# itemtype #--
					for k, v in pairs( itemtype.types ) do
						if v == editpanel.item.type then
							itemtype:ChooseOptionID( k )
							break
						end
					end
					--# itemrarity #--
					itemrarity:ChooseOptionID( editpanel.item.rarity )
					--# icon #--
					icon:SetModel( ( editpanel.item.model and string.Trim( editpanel.item.model ) != '' )  and editpanel.item.model or airdrop.getDefaultItemModel( editpanel.item ) )
					
					icon.model = editpanel.item.model
					--# textentry 1 #--
					if editpanel.item.type == 'entity' and editpanel.item.class then
						textentry:SetText( editpanel.item.class )
						textentry.defaultText = airdrop.getPhrase( 'item_class' )
					elseif editpanel.item.type != 'entity' and editpanel.item.name then
						textentry:SetText( editpanel.item.name )
						
						textentry.defaultText = airdrop.getPhrase( 'item_name' )
					elseif editpanel.item.type == 'ps_item' and editpanel.item.index then
						textentry:SetText( editpanel.item.index )
						textentry.defaultText = airdrop.getPhrase( 'item_index' )
					elseif not editpanel.item.type then
						textentry:SetVisible( false )
					end
					--# textentry 2 #--
					if editpanel.item.type == 'money' or editpanel.item.type == 'ps_points'  then
						textentry2:SetText( editpanel.item.amount )
						textentry2.defaultText = airdrop.getPhrase( 'item_amount' )
					elseif editpanel.item.type == 'entity' and editpanel.item.model then
						textentry2:SetText( editpanel.item.model )
						textentry2.defaultText = airdrop.getPhrase( 'item_model' )
					elseif editpanel.item.type == 'weapon' and editpanel.item.class then
						textentry2:SetText( editpanel.item.class )
						textentry2.defaultText = airdrop.getPhrase( 'item_class' )
					elseif not editpanel.item.type then
						textentry2:SetVisible( false )
					end
				end
				itemspanel = vgui.Create( 'DScrollPanel', pnl )
				itemspanel:SetSize( self.w + itemspanel:GetVBar():GetWide(), self.h )
				itemspanel:SetPos( 0, 0 )
				itemspanel.Paint = function( self, w, h )
					//draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
				end
				airdrop.removeScrollBar( itemspanel )
				table.insert( pnl.pelements, itemspanel )
	 			
	 			itemspanel.drawItems = function()
	 				itemspanel:Clear()
	 				local items = {}
					for i = 1, #config.airdrop.items do
						for k, v in pairs( config.airdrop.items[ i ] ) do
							if not istable( v ) then continue end
							v.rarity = i
							v.id = k
							table.insert( items, v )
						end
					end
					table.insert( items, { type = 'newitem', name = 'New item', rarity = -1 } )
	 				for k, v in pairs( items ) do
						local itempnl = airdrop.createItempnl( v, self.w, airdrop.itempnl_height, itemspanel, v.rarity )
						itempnl:SetPos( 0, ( k - 1 ) * ( airdrop.itempnl_height + airdrop.indent ) )
						local removebutton
						if v.type != 'newitem' then
							removebutton = airdrop.createButton( 'Del', 'airdrop_small', itempnl, true )
							removebutton:SetTall( itempnl:GetTall() - airdrop.indent * 2.5 )
							removebutton:SetPos( itempnl:GetWide() - removebutton:GetWide() - airdrop.indent, ( itempnl:GetTall() - removebutton:GetTall() ) / 2 )
							removebutton.DoClick = function()
							
								net.Start( 'airdrop_configact' )
								net.WriteString( 'itemdel' )
								net.WriteUInt( v.rarity, 8 )
								net.WriteUInt( v.id, 8 )
								net.SendToServer()
			
								table.remove( config.airdrop.items[ v.rarity ], v.id )
								itemspanel:AlphaTo( 0, 0.5 * config.ui.animations_speed, 0, function()
									itemspanel:drawItems()
									itemspanel:AlphaTo( 255, 0.5 * config.ui.animations_speed )
								end )
							end
						end
						local editbutton = airdrop.createButton( v.type == 'newitem' and 'Add' or 'Edit', 'airdrop_small', itempnl, true )
						editbutton:SetTall( itempnl:GetTall() - airdrop.indent * 2.5 )
						editbutton:SetPos( itempnl:GetWide() - ( removebutton and removebutton:GetWide() or 0 ) - editbutton:GetWide() - airdrop.indent * ( removebutton and 2 or 1 ), ( itempnl:GetTall() - editbutton:GetTall() ) / 2 )
						editbutton.DoClick = function()
							itemspanel:AlphaTo( 0, 0.5 * config.ui.animations_speed, 0, function()
								itemspanel:SetVisible( false )
								editpanel:SetVisible( true )
								editpanel:AlphaTo( 255, 0.5 * config.ui.animations_speed )
							end )
							if v.type == 'newitem' then
								editpanel.item = {}
								editpanel:resetValues()
							else
								editpanel.item = v
								editpanel:setItemValues()
							end
						end
					end
	 			end

				itemspanel:drawItems()
			end
		},
		{
			name = airdrop.getPhrase( 'airdrop_settings' ),
			w = ScrW() - ( ScrW() / ( airdrop.config.localisation[ airdrop.config.localisation.language ][ 'font_size' ] * 1.45 ) ),
			h = ScrH() - ( ScrH() / ( airdrop.config.localisation[ airdrop.config.localisation.language ][ 'font_size' ] * 1.15 ) ),
			hidebackground = false,
			func = function( self, pnl, backfunc )
				local y = airdrop.indent
				local label, nwang_force = airdrop.createNumWangLine( airdrop.getPhrase( 'airdrop_force' ), config.airdrop.force, 0, 10, 'airdrop', 'force', y, self.w, pnl, config )
				y = y + airdrop.indent + nwang_force:GetTall()
				local label, nwang_removetime = airdrop.createNumWangLine( airdrop.getPhrase( 'airdrop_removetime' ) .. '(sec)', config.airdrop.removetime, 0, 60 * 30, 'airdrop', 'removetime', y, self.w, pnl, config )
				y = y + airdrop.indent + nwang_removetime:GetTall() * 2
				local label, nwang_minitems = airdrop.createNumWangLine( airdrop.getPhrase( 'airdrop_minitems' ), config.airdrop.minitems, 1, 30, 'airdrop', 'minitems', y, self.w, pnl, config )
				y = y + airdrop.indent + nwang_minitems:GetTall()
				local label, nwang_maxitems = airdrop.createNumWangLine( airdrop.getPhrase( 'airdrop_maxitems' ), config.airdrop.maxitems, 1, 30, 'airdrop', 'maxitems', y, self.w, pnl, config )
				table.insert( pnl.pelements, nwang_force )
				table.insert( pnl.pelements, nwang_removetime )
				table.insert( pnl.pelements, nwang_minitems )
				table.insert( pnl.pelements, nwang_maxitems )
			end
		},
		{
			name = airdrop.getPhrase( 'airplane_settings' ),
			w = ScrW() - ( ScrW() / ( airdrop.config.localisation[ airdrop.config.localisation.language ][ 'font_size' ] * 1.25 ) ),
			h = ScrH() - ( ScrH() / ( airdrop.config.localisation[ airdrop.config.localisation.language ][ 'font_size' ] * 1.3 ) ),
			hidebackground = false,
			func = function( self, pnl, backfunc )
				local y = airdrop.indent
				local label, nwang_minspeed = airdrop.createNumWangLine( airdrop.getPhrase( 'airplane_minspeed' ), config.airplane.minspeed, nil, nil, 'airplane', 'minspeed', y, self.w, pnl, config )
				y = y + airdrop.indent + nwang_minspeed:GetTall()
				local label, nwang_maxspeed = airdrop.createNumWangLine( airdrop.getPhrase( 'airplane_maxspeed' ), config.airplane.maxspeed, nil, nil, 'airplane', 'maxspeed', y, self.w, pnl, config )
				y = y + airdrop.indent + nwang_maxspeed:GetTall() * 2
				local label, nwang_minheight = airdrop.createNumWangLine( airdrop.getPhrase( 'airplane_minheight' ), config.airplane.minheight, nil, nil, 'airplane', 'minheight', y, self.w, pnl, config )
				y = y + airdrop.indent + nwang_minheight:GetTall()
				local label, nwang_maxheight = airdrop.createNumWangLine( airdrop.getPhrase( 'airplane_maxheight' ), config.airplane.maxheight, nil, nil, 'airplane', 'maxheight', y, self.w, pnl, config )
				y = y + airdrop.indent + nwang_maxheight:GetTall() * 2

				local label, nwang_modelsize = airdrop.createNumWangLine( airdrop.getPhrase( 'airplane_modelsize' ), config.airplane.modelsize, nil, nil, 'airplane', 'modelsize', y, self.w, pnl, config )
				y = y + airdrop.indent + nwang_maxheight:GetTall()
				local label, nwang_volume = airdrop.createNumWangLine( airdrop.getPhrase( 'airplane_volume' ), config.airplane.volume, nil, nil, 'airplane', 'volume', y, self.w, pnl, config )
				y = y + airdrop.indent + nwang_volume:GetTall()
				local button_listen = airdrop.createButton( airdrop.getPhrase( 'listen' ), 'airdrop_small', pnl )
				button_listen:SetPos( airdrop.indent, y )
				button_listen:SetSize( self.w - airdrop.indent * 2, nwang_volume:GetTall() )
				button_listen.DoClick = function( self )
					if IsValid( self.sound ) then
						self.sound:Stop()
					end
					sound.PlayFile( airdrop.config.airplane.sound, '3d', function( station, errcode )
			
						if not IsValid( station ) then return end
						station:SetPos( LocalPlayer():GetPos() + Vector( 0, 0, math.random( config.airplane.minheight, config.airplane.maxheight ) ) )
						station:SetVolume( config.airplane.volume )
						
						station:Play()
						self.sound = station
					end )
				end
				table.insert( pnl.pelements, nwang_minspeed )
				table.insert( pnl.pelements, nwang_maxspeed )
				table.insert( pnl.pelements, nwang_minheight )
				table.insert( pnl.pelements, nwang_maxheight )
				table.insert( pnl.pelements, nwang_modelsize )
				table.insert( pnl.pelements, nwang_volume )
				table.insert( pnl.pelements, button_listen )
			end
		},
		{
			name = airdrop.getPhrase( 'chance_settings' ),
			w = ScrW() - ( ScrW() / ( airdrop.config.localisation[ airdrop.config.localisation.language ][ 'font_size' ] * 1.3 ) ),
			h = ScrH() - ( ScrH() / ( airdrop.config.localisation[ airdrop.config.localisation.language ][ 'font_size' ] * 1.3 ) ),
			hidebackground = true,
			shitvbar = true,
			func = function( self, pnl, backfunc )
				for k, v in pairs( config.airdrop.items ) do
					local raritypanel = vgui.Create( 'DPanel', pnl )
					raritypanel:SetSize( self.w + 10, ScrH() - ( ScrH() / 1.1 ) )
					raritypanel:SetPos( 0, ( raritypanel:GetTall() + airdrop.indent ) * ( k - 1) )
					raritypanel.Paint = function( self, w, h )
						surface.SetMaterial( airdrop.gradientMaterial )
							
						surface.SetDrawColor( airdrop.config.ui.rarityColors[ k ] or airdrop.config.ui.rarityColors[ #airdrop.config.ui.rarityColors ] )
							
						surface.DrawTexturedRect( 0, 0, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
					end
					table.insert( pnl.pelements, raritypanel )
					local namepnl = vgui.Create( 'DPanel', raritypanel )
					namepnl:SetSize( self.w - airdrop.indent * 2, raritypanel:GetTall() / 2 - airdrop.indent * 1.5 )
					namepnl:SetPos( airdrop.indent, airdrop.indent  )
					namepnl.Paint = function( self, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
					end
					local name = vgui.Create( 'DLabel', namepnl )
					name:SetTextColor( Color( 255, 255, 255 ) ) 
					name:SetFont( 'airdrop_normal' )
					name:SetText( airdrop.getPhrase( 'rarity' ) .. ' ' .. k )
					name:SizeToContents()
					name:SetPos( airdrop.indent, ( namepnl:GetTall() - name:GetTall() ) / 2 )
					namepnl:SetWide( name:GetWide() + airdrop.indent * 2 )
					local chancepnl = vgui.Create( 'DPanel', raritypanel )
					chancepnl:SetSize( self.w - airdrop.indent * 2, raritypanel:GetTall() / 2 - airdrop.indent * 1.5 )
					chancepnl:SetPos( airdrop.indent, raritypanel:GetTall() - chancepnl:GetTall() - airdrop.indent )
					chancepnl.Paint = function( self, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
					end
					local chancelabel = vgui.Create( 'DLabel', chancepnl )
					chancelabel:SetTextColor( Color( 255, 255, 255 ) ) 
					chancelabel:SetFont( 'airdrop_normal' )
					chancelabel:SetText( airdrop.getPhrase( 'item_chance' ) ) 
					chancelabel:SizeToContents()
					chancelabel:SetPos( airdrop.indent, ( chancepnl:GetTall() - chancelabel:GetTall() ) / 2 )
					chancepnl:SetWide( chancelabel:GetWide() + airdrop.indent * 2 )
					local chancewang = airdrop.createNumWang( raritypanel )
					chancewang:SetPos( airdrop.indent * 2 + chancepnl:GetWide(), chancepnl.y )
					chancewang:SetSize( raritypanel:GetWide() - chancepnl:GetWide() - airdrop.indent * 5, chancepnl:GetTall() )
					chancewang:SetMax( 100 )
					chancewang:SetMin( 0 )
					if v.chance then
						chancewang:SetValue( v.chance )
					end
					chancewang.OnEnter = function( self )
						self:SetText( math.Clamp( self:GetValue(), 0, 100 ) )
						net.Start( 'airdrop_configact' )
						net.WriteString( 'rarityedit' )
						net.WriteString( 'chance' )	
						net.WriteUInt( k, 8 )
						net.WriteUInt( self:GetValue(), 8 )
						net.SendToServer()
						config.airdrop.items[ k ].chance = tonumber( self:GetValue() )
					end
				end
			end
		},
		{
			name = airdrop.getPhrase( 'ui_settings' ),
			w = ScrW() - ( ScrW() / ( airdrop.config.localisation[ airdrop.config.localisation.language ][ 'font_size' ] * 1.23 ) ),
			h = ScrH() - ( ScrH() / ( airdrop.config.localisation[ airdrop.config.localisation.language ][ 'font_size' ] * 1.05 ) ),
			hidebackground = false,
			func = function( self, pnl, backfunc )
				local y = airdrop.indent
				local label, nwang_animspeed = airdrop.createNumWangLine( airdrop.getPhrase( 'ui_animations_speed' ), config.airplane.minspeed, 0.01, 10, 'ui', 'animations_speed', y, self.w, pnl, config, -1 )
				nwang_animspeed:SetDecimals( 2 )
				y = y + airdrop.indent + nwang_animspeed:GetTall()
				table.insert( pnl.pelements, nwang_animspeed )
			end
		}
	}
	for k, v in pairs( panels ) do
		surface.SetFont( 'airdrop_normal' )
		local nameW, nameH = surface.GetTextSize( v.name )
		panelW = math.max( panelW or 0, nameW )
	end
	panelW = panelW * 1.25
	panelW = math.max( ScrW() - ( ScrW() / 1.15 ), panelW )
	local defW, defH = panelW + airdrop.indent * 4, panelH * #panels + airdrop.browSize + airdrop.indent * 2 + airdrop.indent * #panels
	frame:SetSize( defW, defH )
	frame:Center()
	local mainpnl = vgui.Create( 'DPanel', frame )
	mainpnl:SetSize( frame:GetWide() - airdrop.indent * 2, frame:GetTall() - airdrop.browSize - airdrop.indent * 2 )
	mainpnl:SetPos( airdrop.indent, airdrop.browSize + airdrop.indent )
	mainpnl.defW, mainpnl.defH = mainpnl:GetWide(), mainpnl:GetTall()
	mainpnl.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end
	local pnl = vgui.Create( 'DScrollPanel', frame )
	pnl:SetSize( mainpnl:GetWide(), mainpnl:GetTall() )
	pnl:SetPos( airdrop.indent, airdrop.browSize + airdrop.indent )
	pnl.defW, pnl.defH = pnl:GetWide(), pnl:GetTall()
	pnl.pelements = {}
	pnl:SetAlpha( 0 )
	pnl:SetVisible( false )
	pnl.Paint = function( self, w, h )
		if self.hidebackground then return end
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end
	pnl.Clear = function( self )
		for k, v in pairs( self.pelements ) do
			v:Remove()
		end
	end
	airdrop.removeScrollBar( pnl )
	local backbutton = airdrop.createButton( airdrop.getPhrase( 'goback' ), 'airdrop_small', frame )
	backbutton:SetPos( 0, 0 )
	backbutton:SetSize( 0, ScrH() - ( ScrH() / 1.04 ) )
	backbutton:SetVisible( false )
	backbutton.DoClick = function()
				
		if not IsValid( frame ) then return end
		if not backbutton:IsVisible() or backbutton.closing then return end
		backbutton.closing = true
		backbutton:SizeTo( 0, backbutton:GetTall(), 0.5 * config.ui.animations_speed, 0, -1, function()
			backbutton:SetVisible( false )
			backbutton.closing = false
		end )

		pnl:AlphaTo( 0, 0.5 * config.ui.animations_speed, 0, function()
			pnl:Clear()
			pnl:SetVisible( false )
			frame:SizeTo( defW, defH, 0.5 * config.ui.animations_speed, 0, -1, function()
				mainpnl:SetVisible( true )
				mainpnl:AlphaTo( 255, 0.5, 0 )
			end )
			frame:MoveTo( ( ScrW() - defW ) / 2, ( ScrH() - defH ) / 2, 0.5 * config.ui.animations_speed )
		end )
	end
	for k, v in pairs( panels ) do
		local button = airdrop.createButton( v.name, 'airdrop_small', mainpnl )
		button:SetPos( airdrop.indent, airdrop.indent * k + panelH * ( k - 1 ) )
		button:SetSize( panelW, panelH )
		button.DoClick = function()
			pnl.hidebackground = v.hidebackground
			mainpnl:AlphaTo( 0, 0.5 * config.ui.animations_speed, 0, function()
				mainpnl:SetVisible( false )
				
				local fw, fh = v.w + airdrop.indent * 2,  v.h + airdrop.indent * 3 + airdrop.browSize + backbutton:GetTall()
				frame:SizeTo( fw, fh, 0.5 * config.ui.animations_speed )
				frame:MoveTo( ( ScrW() - fw ) / 2, ( ScrH() - fh ) / 2, 0.5 * config.ui.animations_speed, 0, -1, function()
					backbutton:SetVisible( true )
					backbutton:SetPos( frame:GetWide() - airdrop.indent, frame:GetTall() - airdrop.indent - backbutton:GetTall() )
					backbutton:SizeTo( v.w, backbutton:GetTall(), 0.5 * config.ui.animations_speed )
					backbutton:MoveTo( airdrop.indent, frame:GetTall() - airdrop.indent - backbutton:GetTall(), 0.5 * config.ui.animations_speed )
					
				end )
				pnl:SizeTo( v.w + ( v.shitvbar and pnl:GetVBar():GetWide() or 0 ), v.h, 0.5 * config.ui.animations_speed, 0, -1, function()
					pnl:AlphaTo( 255, 0.5 * config.ui.animations_speed, 0 )
				end )
			end )
			pnl:SetVisible( true )
			v.func( v, pnl, backbutton.DoClick )
		end
	end
end
--# Network #--
net.Receive( 'airdrop_itemact', function( len, ply )
	local ent = net.ReadEntity()
	local content = net.ReadString()
	if not IsValid( ent ) or content == '' then return end
	content = util.JSONToTable( content )
	airdrop.showAirdropItems( ent, content )
end )
net.Receive( 'airdrop_notify', function( len, ply )
	local msgtype = net.ReadUInt( 8 )
	local msglength = net.ReadUInt( 8 )
	local msg = net.ReadString()
	
	airdrop.notify( msg, msgtype, length )
end )
net.Receive( 'airdrop_configact', function( len, ply )
	local contents = net.ReadString()
	local config = util.JSONToTable( net.ReadString() )
	
	if contents == 'ui_settings' then
		
		airdrop.config.localisation.language = config.language
		airdrop.config.ui = config.ui
		airdrop.config.airplane = config.airplane
		airdrop.config.loaded = true
		surface.CreateFont( 'airdrop_normal', { font = 'Roboto',  size = ScrH() - ( ScrH() / airdrop.config.localisation[ airdrop.config.localisation.language ][ 'font_size' ] ) } )
		
		surface.CreateFont( 'airdrop_small', { font = 'Roboto',  size = ScrH() - ( ScrH() / ( airdrop.config.localisation[ airdrop.config.localisation.language ][ 'font_size' ] * 0.99998 ) ) } )
		airdrop.itempnl_wide = ScrW() - ( ScrW() / airdrop.config.ui[ 'itempnl_wide' ] )
		airdrop.itempnl_height = ScrH() - ( ScrH() / ( airdrop.config.localisation[ airdrop.config.localisation.language ][ 'font_size' ] * 1.02 ) ) 
	elseif contents == 'full_config' then
		airdrop.openconfigurator( config )
	end
end )