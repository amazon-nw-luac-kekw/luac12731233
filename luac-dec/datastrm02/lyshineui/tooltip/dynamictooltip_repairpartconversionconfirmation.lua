local DynamicTooltip_RepairPartConversionConfirmation = {
  Properties = {
    Title = {
      default = EntityId()
    },
    InfoContainer = {
      default = EntityId()
    },
    InfoDivider = {
      default = EntityId()
    },
    DisabledTierInfoContainer = {
      default = EntityId()
    },
    DisabledRatioContainer = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    ConfirmationButton = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    }
  },
  isShowing = false,
  CONFIRM_ACTION_NAME = "ui_interact",
  INFO_TYPE_TIER = 0,
  INFO_TYPE_RATIO = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DynamicTooltip_RepairPartConversionConfirmation)
function DynamicTooltip_RepairPartConversionConfirmation:OnInit()
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.ConfirmationButton:SetText("@ui_confirm")
  self.ConfirmationButton:SetHint(self.CONFIRM_ACTION_NAME, true)
  self.ConfirmationButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE_CTA)
  self.ConfirmationButton:SetBackgroundColor(self.UIStyle.COLOR_BUTTON_SIMPLE_CTA)
  self.ConfirmationButton:SetBackgroundOpacity(self.UIStyle.BUTTON_SIMPLE_CTA_OPACITY)
  self.ConfirmationButton:SetButtonBgTexture(self.ConfirmationButton.BG_TEXTURE_STYLE_COLOR_BACKGROUND)
  self.CancelButton:SetText("@ui_cancel")
  local titleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 24,
    characterSpacing = 75,
    fontColor = self.UIStyle.COLOR_TAN
  }
  SetTextStyle(self.Properties.Title, titleStyle)
  local descriptionStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 20,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  SetTextStyle(self.Properties.Description, descriptionStyle)
  self.initialWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
end
function DynamicTooltip_RepairPartConversionConfirmation:OnShutdown()
  self.isShowing = false
  if self.cryActionNotificationHandler then
    self:BusDisconnect(self.cryActionNotificationHandler)
  end
end
function DynamicTooltip_RepairPartConversionConfirmation:ShowFlyout(positionVector, flyoutData)
  if self.isShowing then
    return
  end
  for i = #flyoutData.conversionData, 1, -1 do
    local conversionData = flyoutData.conversionData[i]
    local tierInfoEntityId = UiElementBus.Event.GetChild(self.Properties.DisabledTierInfoContainer, 0)
    local tierInfoTable = self.registrar:GetEntityTable(tierInfoEntityId)
    local isTopTier = i == 1
    tierInfoTable:SetRepairPartConversionTierInfo(conversionData, isTopTier)
    UiElementBus.Event.Reparent(tierInfoEntityId, self.Properties.InfoContainer, EntityId())
    if 1 < i then
      local ratioEntityId = UiElementBus.Event.GetChild(self.Properties.DisabledRatioContainer, 0)
      local ratioTable = self.registrar:GetEntityTable(ratioEntityId)
      ratioTable:SetRepairPartConversionRatioTier(conversionData.tier)
      UiElementBus.Event.Reparent(ratioEntityId, self.Properties.InfoContainer, EntityId())
    end
  end
  UiCanvasBus.Event.RecomputeChangedLayouts(self.canvasId)
  local infoPadding = 40
  local infoWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.InfoContainer)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.InfoDivider, infoWidth + infoPadding)
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, math.max(infoWidth + infoPadding, self.initialWidth))
  PositionEntityOnScreen(self.entityId, positionVector, {
    left = 12,
    right = 12,
    top = 12,
    bottom = 12
  })
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0}, {opacity = 1})
  UiTextBus.Event.SetTextWithFlags(self.Properties.Description, flyoutData.description, eUiTextSet_SetLocalized)
  self.confirmCallback = flyoutData.confirmCallback
  self.confirmCallbackTable = flyoutData.confirmCallbackTable
  self.ConfirmationButton:SetCallback(self.OnConfirmPress, self)
  self.CancelButton:SetCallback(self.HideFlyout, self)
  self.cryActionNotificationHandler = self:BusConnect(CryActionNotificationsBus, self.CONFIRM_ACTION_NAME)
  self.isShowing = true
end
function DynamicTooltip_RepairPartConversionConfirmation:OnConfirmPress()
  if self.confirmCallback and self.confirmCallbackTable then
    self.confirmCallback(self.confirmCallbackTable)
  end
end
function DynamicTooltip_RepairPartConversionConfirmation:HideFlyout()
  if not self.isShowing then
    return
  end
  if self.cryActionNotificationHandler then
    self:BusDisconnect(self.cryActionNotificationHandler)
  end
  self.isShowing = false
  self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
    opacity = 0,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      local children = UiElementBus.Event.GetChildren(self.Properties.InfoContainer)
      for i = 2, #children do
        local entityId = children[i]
        local entityTable = self.registrar:GetEntityTable(entityId)
        local containerEntityId = entityTable:IsTierInfo() and self.Properties.DisabledTierInfoContainer or self.Properties.DisabledRatioContainer
        UiElementBus.Event.Reparent(entityId, containerEntityId, EntityId())
      end
    end
  })
  self.ConfirmationButton:SetCallback(nil, nil)
end
function DynamicTooltip_RepairPartConversionConfirmation:OnCryAction(actionName, value)
  if self.isShowing and value == 1 then
    self.ConfirmationButton:OnPress()
    self:HideFlyout()
  elseif not self.isShowing then
    self:HideFlyout()
  end
end
return DynamicTooltip_RepairPartConversionConfirmation
