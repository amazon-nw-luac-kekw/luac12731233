local EmoteButton = {
  Properties = {
    ButtonText = {
      default = EntityId()
    },
    ButtonTextSecondary = {
      default = EntityId()
    },
    ButtonFocus = {
      default = EntityId()
    },
    ButtonIcon = {
      default = EntityId()
    },
    ButtonTexture = {
      default = EntityId()
    },
    ButtonFrame = {
      default = EntityId()
    },
    ButtonScrim = {
      default = EntityId()
    },
    ButtonLocked = {
      default = EntityId()
    },
    QuantityText = {
      default = EntityId()
    },
    IsNewIndicator = {
      default = EntityId()
    },
    ButtonCooldown = {
      default = EntityId()
    },
    ButtonCooldownText = {
      default = EntityId()
    },
    ButtonCooldownTint = {
      default = EntityId()
    },
    EmoteContainer = {
      default = EntityId()
    },
    HeaderContainer = {
      default = EntityId()
    },
    HeaderText = {
      default = EntityId()
    }
  },
  width = nil,
  height = nil,
  callback = nil,
  callbackTable = nil,
  isLocked = false,
  iconPathRoot = "lyShineui/images/icons/emotes/",
  horizontalSpacing = 9,
  paddingHeight = 7,
  defaultButtonFrame = "LyShineUI/Images/EmoteUI/buttonFrame.dds",
  premiumButtonFrame = "LyShineUI/Images/EmoteUI/buttonTexture_premium.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(EmoteButton)
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
function EmoteButton:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableEntitlements", function(self, enableEntitlements)
    self.entitlementsEnabled = enableEntitlements
  end)
  local buttonTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_BOLD,
    fontSize = 28,
    fontColor = self.UIStyle.COLOR_GRAY_70
  }
  local buttonTextSecondaryStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 22,
    fontColor = self.UIStyle.COLOR_GRAY_70
  }
  SetTextStyle(self.ButtonText, buttonTextStyle)
  SetTextStyle(self.ButtonTextSecondary, buttonTextSecondaryStyle)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  local headerTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 24,
    fontColor = self.UIStyle.COLOR_GRAY_80,
    characterSpacing = 100,
    textCasing = self.UIStyle.TEXT_CASING_UPPER
  }
  self.HeaderText:SetTextStyle(headerTextStyle)
  self.HeaderText:SetDividerColor(self.UIStyle.COLOR_GRAY_50)
end
function EmoteButton:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function EmoteButton:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function EmoteButton:GetElementHeight(gridItemData)
  if gridItemData then
    if gridItemData.rowType.name == "emote" then
      local height = self.paddingHeight + UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
      return height
    elseif gridItemData.rowType.name == "header" then
      return UiTransform2dBus.Event.GetLocalHeight(self.Properties.HeaderContainer)
    end
  end
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function EmoteButton:GetHorizontalSpacing()
  return self.horizontalSpacing
end
function EmoteButton:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ButtonText, value, eUiTextSet_SetLocalized)
end
function EmoteButton:GetText()
  return UiTextBus.Event.GetText(self.Properties.ButtonText)
end
function EmoteButton:SetTextSecondary(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ButtonTextSecondary, value, eUiTextSet_SetLocalized)
end
function EmoteButton:GetTextSecondary()
  return UiTextBus.Event.GetText(self.Properties.ButtonTextSecondary)
end
function EmoteButton:SetQuantityText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.QuantityText, "x" .. value, eUiTextSet_SetAsIs)
end
function EmoteButton:SetIcon(value)
  self.icon = value
  UiImageBus.Event.SetSpritePathname(self.Properties.ButtonIcon, value)
end
function EmoteButton:SetStatusIcon(isLocked, grantInfo)
  self.isLocked = isLocked
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonLocked, isLocked)
  local xPos = 2
  if self.availableProducts and #self.availableProducts > 0 then
    if grantInfo then
      local sourceType = grantInfo.grantor.sourceType
      xPos = 2
      local iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
      if sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_TWITCH then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_Twitch.dds"
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_PRIME then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_TwitchPrime.dds"
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_PREORDER then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
        xPos = 8
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_STORE then
        iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
      else
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
        xPos = 8
      end
      UiImageBus.Event.SetSpritePathname(self.Properties.ButtonLocked, iconTexture)
    end
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.ButtonLocked, "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds")
    xPos = 8
  end
  UiTransformBus.Event.SetLocalPositionX(self.Properties.ButtonLocked, xPos)
  local opacityValue = isLocked and 0.4 or 0
  self.ScriptedEntityTweener:Play(self.Properties.ButtonScrim, 0.3, {opacity = opacityValue, ease = "QuadOut"})
end
function EmoteButton:SetButtonEmpty()
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTextSecondary, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFocus, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTexture, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFrame, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIcon, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonLocked, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.QuantityText, false)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, false)
end
function EmoteButton:SetButtonActive()
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonText, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTextSecondary, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTexture, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFrame, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIcon, true)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, true)
end
function EmoteButton:SetTooltipData(rewardType, rewardKey, availableProducts, lockReason, description, grantInfo)
  self.rewardType = rewardType
  self.rewardKey = rewardKey
  self.availableProducts = availableProducts
  self.lockReason = lockReason
  self.emoteDescription = description
  if grantInfo then
    if grantInfo.grantor ~= nil then
      self.sourceType = grantInfo.grantor.sourceType
    else
      self.sourceType = ""
    end
  end
end
function EmoteButton:OnFocus()
  local productType = ""
  if self.rewardType and self.rewardKey then
    local rewardDisplayInfo = EntitlementsDataHandler:GetEntitlementDisplayInfo(self.rewardType, self.rewardKey)
    productType = rewardDisplayInfo.typeString
  end
  if self.isLocked then
    local rows = {
      {
        slicePath = "LyShineUI/Tooltip/DynamicTooltip",
        itemTable = {
          displayName = self:GetText(),
          spriteName = self.icon,
          spriteColor = self.UIStyle.COLOR_WHITE,
          description = self.emoteDescription,
          sourceType = self.sourceType,
          productType = productType
        },
        rewardType = self.rewardType,
        rewardKey = self.rewardKey,
        availableProducts = self.availableProducts,
        dynamicInfoText = self.lockReason,
        dynamicInfoColor = self.UIStyle.COLOR_RED,
        disclaimerText = "@ui_mtx_disclaimer"
      }
    }
    local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
    if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
      flyoutMenu:SetOpenLocation(self.entityId, flyoutMenu.PREFER_RIGHT)
      flyoutMenu:SetClosedCallback(self, self.OnFlyoutMenuClosed)
      flyoutMenu:EnableFlyoutDelay(true, 0.25)
      flyoutMenu:SetFadeInTime(0.4)
      flyoutMenu:SetRowData(rows)
      flyoutMenu:DockToCursor(10)
    end
  end
  if self.isNew then
    EntitlementRequestBus.Broadcast.MarkEntryIdOfRewardTypeSeen(self.rewardType, self.rewardKey)
  end
  local animDuration = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.ScriptedEntityTweener:Play(self.Properties.ButtonIcon, animDuration, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration, {
    textColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.ButtonTextSecondary, animDuration, {
    textColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  if self.timeline == nil then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = animDuration,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_EmoteMenu)
end
function EmoteButton:SetGridItemData(emote)
  self.rowType = nil
  UiElementBus.Event.SetIsEnabled(self.entityId, emote ~= nil)
  if not emote then
    return
  end
  self.rowType = emote.rowType
  UiElementBus.Event.SetIsEnabled(self.Properties.HeaderContainer, self.rowType.name == "header")
  UiElementBus.Event.SetIsEnabled(self.Properties.EmoteContainer, self.rowType.name == "emote")
  if self.rowType.name == "emote" then
    self:SetCallback(emote.callbackFn, emote.callbackSelf)
    local emoteData = emote.emoteData
    if emoteData.displayName ~= "" then
      self.emoteId = emoteData.id
      self:SetText(emoteData.displayName)
      self:SetTextSecondary("/" .. emoteData.slashCommand)
      local iconPath = self.iconPathRoot .. emoteData.uiImage .. ".dds"
      if emoteData.uiImage == "" then
        iconPath = self.iconPathRoot .. "emote_Unknown.dds"
      end
      self:SetIcon(iconPath)
      self.isNew = emote.isNew
      UiElementBus.Event.SetIsEnabled(self.Properties.IsNewIndicator, emote.isNew)
      UiElementBus.Event.SetIsEnabled(self.Properties.QuantityText, emote.quantity > 0)
      if emote.quantity > 0 then
        self:SetQuantityText(emote.quantity)
      end
      if not self.Properties.IsNewIndicator:IsValid() and emote.isNew then
        self:SetText("(New!) " .. emoteData.displayName)
      end
      if emote.cooldown then
        self.cooldown = emote.cooldown
        if emote.callbackSelf.isScreenVisible then
          self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
          UiTextBus.Event.SetText(self.Properties.ButtonCooldownText, string.format("%.1f", self.cooldown.endTimePoint:Subtract(TimePoint:Now()):ToSecondsUnrounded()))
        end
        UiElementBus.Event.SetIsEnabled(self.Properties.ButtonCooldown, emote.callbackSelf.isScreenVisible)
        UiElementBus.Event.SetIsEnabled(self.Properties.ButtonCooldownTint, emote.callbackSelf.isScreenVisible)
        UiElementBus.Event.SetIsEnabled(self.Properties.ButtonCooldownText, emote.callbackSelf.isScreenVisible)
        self.totalDuration = self.cooldown.endTimePoint:Subtract(self.cooldown.startTimePoint):ToSecondsUnrounded()
      else
        if self.tickHandler then
          self:BusDisconnect(self.tickHandler)
          self.tickHandler = nil
        end
        UiElementBus.Event.SetIsEnabled(self.Properties.ButtonCooldown, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.ButtonCooldownTint, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.ButtonCooldownText, false)
      end
      local emoteAvailabilityInfo
      local availableProducts = {}
      self.isEntitlement = emoteData.isEntitlement
      self.isPremiumEmote = emoteData.isPremiumEmote
      if self.isEntitlement and self.entitlementsEnabled then
        self:SetTooltipData(eRewardTypeEmote, emoteData.id, emote.availableProducts, emote.tooltipText, emote.description, emote.grantInfo)
        UiImageBus.Event.SetSpritePathname(self.Properties.ButtonFrame, self.premiumButtonFrame)
        UiTextBus.Event.SetColor(self.Properties.ButtonText, self.UIStyle.COLOR_YELLOW)
        UiTextBus.Event.SetColor(self.Properties.ButtonTextSecondary, self.UIStyle.COLOR_TAN_LIGHT)
        UiImageBus.Event.SetColor(self.Properties.ButtonTexture, self.UIStyle.COLOR_BRIGHT_YELLOW)
      else
        self:SetTooltipData()
        UiImageBus.Event.SetSpritePathname(self.Properties.ButtonFrame, self.defaultButtonFrame)
        UiTextBus.Event.SetColor(self.Properties.ButtonText, self.UIStyle.COLOR_GRAY_70)
        UiTextBus.Event.SetColor(self.Properties.ButtonTextSecondary, self.UIStyle.COLOR_GRAY_70)
        UiImageBus.Event.SetColor(self.Properties.ButtonTexture, self.UIStyle.COLOR_WHITE)
      end
      self:SetStatusIcon(not emote.isAvailable, emote.grantInfo)
    end
  elseif self.rowType.name == "header" then
    self.HeaderText:SetText(emote.headerText)
  end
  self:OnUnfocus()
end
function EmoteButton:OnUnfocus()
  local animDuration = 0.3
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonIcon, animDuration, {opacity = 0.65, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration, {
    textColor = self.isEntitlement and self.UIStyle.COLOR_YELLOW or self.UIStyle.COLOR_GRAY_70,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.ButtonTextSecondary, animDuration, {
    textColor = self.isEntitlement and self.UIStyle.COLOR_TAN_LIGHT or self.UIStyle.COLOR_GRAY_70,
    ease = "QuadOut"
  })
end
function EmoteButton:OnPress()
  self.audioHelper:PlaySound(self.audioHelper.OnEmoteButtonPress)
  if self.isLocked then
    if self.availableProducts and #self.availableProducts > 0 then
      local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
      flyoutMenu:SetSourceHoverOnly(false)
      flyoutMenu:Lock()
    end
  elseif self.callback ~= nil and self.callbackTable ~= nil then
    self.callback(self.callbackTable, self)
    local animDuration = 0.3
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0, ease = "QuadOut"})
  end
end
function EmoteButton:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function EmoteButton:OnTick(elapsed, timepoint)
  if not self.cooldown then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
    return
  end
  local secondsRemaining = self.cooldown.endTimePoint:Subtract(TimePoint:Now()):ToSecondsUnrounded()
  if 3 < secondsRemaining then
    UiTextBus.Event.SetText(self.Properties.ButtonCooldownText, string.format("%d", math.floor(secondsRemaining)))
  else
    UiTextBus.Event.SetText(self.Properties.ButtonCooldownText, string.format("%.1f", secondsRemaining))
  end
  local perc = secondsRemaining / self.totalDuration
  if 0 < perc then
    UiProgressBarBus.Event.SetProgressPercent(self.Properties.ButtonCooldown, perc)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonCooldown, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonCooldownTint, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonCooldownText, false)
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
return EmoteButton
