local ConvertRepairPartsPopup = {
  Properties = {
    PopupScrim = {
      default = EntityId()
    },
    PopupHolder = {
      default = EntityId()
    },
    FromIcon = {
      default = EntityId()
    },
    FromNumberText = {
      default = EntityId()
    },
    FromChangeText = {
      default = EntityId()
    },
    ToIcon = {
      default = EntityId()
    },
    ToNumberText = {
      default = EntityId()
    },
    ToChangeText = {
      default = EntityId()
    },
    RatioText = {
      default = EntityId()
    },
    MessageText = {
      default = EntityId()
    },
    Slider = {
      default = EntityId()
    },
    ButtonConfirm = {
      default = EntityId()
    },
    ButtonCancel = {
      default = EntityId()
    }
  },
  iconPath = "LyShineUI/Images/Icons/RepairPartsCurrency/RepairPartsT%s_Currency.png"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ConvertRepairPartsPopup)
local InventoryCommon = RequireScript("LyShineUI._Common.InventoryCommon")
function ConvertRepairPartsPopup:OnInit()
  BaseElement.OnInit(self)
  UiTextBus.Event.SetColor(self.Properties.FromChangeText, self.UIStyle.COLOR_RED)
  UiTextBus.Event.SetColor(self.Properties.ToChangeText, self.UIStyle.COLOR_GREEN)
  UiTextBus.Event.SetColor(self.Properties.MessageText, self.UIStyle.COLOR_GRAY_60)
  self.FromIcon:SetColor(self.UIStyle.COLOR_WHITE)
  self.ToIcon:SetColor(self.UIStyle.COLOR_WHITE)
  self.ButtonConfirm:SetText("@ui_confirm")
  self.ButtonConfirm:SetCallback(self.OnConvertRepairParts, self)
  self.ButtonCancel:SetText("@ui_cancel")
  self.ButtonCancel:SetCallback(self.OnCloseConvertRepairPartsPopup, self)
  self.Slider:HideCrownIcons()
  self.Slider:SetCallback(self.OnSliderChange, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
end
function ConvertRepairPartsPopup:SetConvertRepairPartsPopupVisibility(isVisible, tier, pos)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  if isVisible then
    PositionEntityOnScreen(self.Properties.PopupHolder, pos, {right = 10})
    local exchangeData = CurrencyConversionRequestBus.Event.GetCurrencyExchangeData(self.playerEntityId, InventoryCommon:GetRepairPartExchangeId(tier))
    self.fromTier = tier
    self.fromQuantity = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, InventoryCommon:GetRepairPartId(tier))
    self.fromExchangeQuantity = exchangeData.fromCurrencyQuantity
    self.toTier = tier + 1
    local toRepairPartId = InventoryCommon:GetRepairPartId(self.toTier)
    self.toQuantity = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, toRepairPartId)
    self.toExchangeQuantity = exchangeData.toCurrencyQuantity
    self.FromIcon:SetPath(string.format(self.iconPath, self.fromTier))
    self.ToIcon:SetPath(string.format(self.iconPath, self.toTier))
    local messageText = GetLocalizedReplacementText("@inv_repairparts_popup_message", {
      tier = self.toTier
    })
    UiTextBus.Event.SetText(self.Properties.MessageText, messageText)
    local ratioText = GetLocalizedReplacementText("@inv_repairparts_popup_conversionratio", {
      a = GetFormattedNumber(self.fromExchangeQuantity),
      b = GetFormattedNumber(self.toExchangeQuantity)
    })
    UiTextBus.Event.SetText(self.Properties.RatioText, ratioText)
    local sliderMax = 0
    if self.fromExchangeQuantity > 0 then
      local toMaxQuantity = CategoricalProgressionRequestBus.Event.GetMaxPointsForCurrentRank(self.playerEntityId, toRepairPartId)
      local toSliderMax = math.floor((toMaxQuantity - self.toQuantity) * self.toExchangeQuantity / self.fromExchangeQuantity)
      local fromSliderMax = math.floor(self.fromQuantity / self.fromExchangeQuantity)
      sliderMax = math.min(toSliderMax, fromSliderMax)
    end
    self.Slider:SetSliderMaxValue(sliderMax)
    self.Slider:SetSliderValue(0)
    self:UpdateValues(0)
    self.ScriptedEntityTweener:Play(self.Properties.PopupHolder, 0.8, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.PopupScrim, 0.5, {opacity = 0}, {opacity = 0.8, ease = "QuadOut"})
  else
    self.Slider:SetSliderValue(0)
  end
end
function ConvertRepairPartsPopup:OnSliderChange(slider)
  local value = slider:GetValue()
  self:UpdateValues(value)
end
function ConvertRepairPartsPopup:UpdateValues(sliderValue)
  local fromDelta = sliderValue * self.fromExchangeQuantity
  local toDelta = sliderValue * self.toExchangeQuantity
  UiTextBus.Event.SetText(self.Properties.FromNumberText, GetFormattedNumber(self.fromQuantity - fromDelta, 0))
  UiTextBus.Event.SetText(self.Properties.ToNumberText, GetFormattedNumber(self.toQuantity + toDelta, 0))
  local opacity = 0 < sliderValue and 1 or 0
  UiFaderBus.Event.SetFadeValue(self.Properties.FromChangeText, opacity)
  UiFaderBus.Event.SetFadeValue(self.Properties.ToChangeText, opacity)
  if 0 < sliderValue then
    local fromChangeText = GetLocalizedReplacementText("@inv_repairparts_popup_valuechangeneg", {
      changeAmount = GetFormattedNumber(fromDelta, 0)
    })
    UiTextBus.Event.SetText(self.Properties.FromChangeText, fromChangeText)
    local toChangeText = GetLocalizedReplacementText("@inv_repairparts_popup_valuechangepos", {
      changeAmount = GetFormattedNumber(toDelta, 0)
    })
    UiTextBus.Event.SetText(self.Properties.ToChangeText, toChangeText)
  end
  self.ButtonConfirm:SetEnabled(0 < sliderValue)
end
function ConvertRepairPartsPopup:OnConvertRepairParts()
  local quantity = self.Slider:GetSliderValue()
  local exchangeId = InventoryCommon:GetRepairPartExchangeId(self.fromTier)
  CurrencyConversionRequestBus.Event.RequestCurrencyConversion(self.playerEntityId, exchangeId, quantity)
  self:SetConvertRepairPartsPopupVisibility(false)
end
function ConvertRepairPartsPopup:OnCloseConvertRepairPartsPopup()
  self:SetConvertRepairPartsPopupVisibility(false)
end
return ConvertRepairPartsPopup
