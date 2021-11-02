local TimeHelperFunctions = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TaxAndFeeSlider = {
  Properties = {
    EditButton = {
      default = EntityId()
    },
    AcceptButton = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    NoEditAmount = {
      default = EntityId()
    },
    Slider = {
      default = EntityId()
    },
    GlobalAverage = {
      default = EntityId()
    },
    CurrentValue = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    Label = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
BaseElement:CreateNewElement(TaxAndFeeSlider)
function TaxAndFeeSlider:OnInit()
  BaseElement.OnInit(self)
  self:SetEditMode(false)
  self.EditButton:SetCallback(self.OnEdit, self)
  self.AcceptButton:SetCallback(self.OnAccept, self)
  self.CancelButton:SetCallback(self.OnCancel, self)
  self:BusConnect(UiInteractableNotificationBus, self.entityId)
  self.EditButton:SetTextStyle(self.UIStyle.FONT_STYLE_TERRITORYINFO_EDIT)
  self.AcceptButton:SetTextStyle(self.UIStyle.FONT_STYLE_TERRITORYINFO_ACCEPT)
  self.CancelButton:SetTextStyle(self.UIStyle.FONT_STYLE_TERRITORYINFO_ACCEPT)
end
function TaxAndFeeSlider:SetTaxAndFeeInfo(v2enabled, taxId, currentValue, min, max, globalAverage, canEdit, canEditTime, beginEditCallback, endEditCallback, context)
  if self.isEditing then
    return
  end
  local valueText = TerritoryDataHandler:GetTaxOrFeeDisplayText(currentValue, taxId)
  local avgNumText = TerritoryDataHandler:GetTaxOrFeeDisplayText(globalAverage, taxId)
  local avgText = GetLocalizedReplacementText("@ui_global_average_tax", {tax = avgNumText})
  if v2enabled then
    UiElementBus.Event.SetIsEnabled(self.Properties.NoEditAmount, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.EditButton, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.NoEditAmount, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.EditButton, false)
    UiTextBus.Event.SetText(self.Properties.NoEditAmount, valueText)
    return
  end
  self.taxId = taxId
  self.currentValue = currentValue
  self.max = max
  self.min = min
  self.beginEditCallback = beginEditCallback
  self.endEditCallback = endEditCallback
  self.context = context
  if taxId == eTaxOrFee_PropertyTax or taxId == eTaxOrFee_TradingTax then
    local baseTax = 1
    if taxId == eTaxOrFee_PropertyTax then
      baseTax = ConfigProviderEventBus.Broadcast.GetFloat("javelin.housing.taxes-base-percent")
    elseif taxId == eTaxOrFee_TradingTax then
      baseTax = ContractsRequestBus.Broadcast.GetBaseTradingTax()
    end
    self.multiplier = 10000 * baseTax
  elseif taxId == eTaxOrFee_CraftingFee or taxId == eTaxOrFee_RefiningFee then
    self.multiplier = 100
  end
  UiTextBus.Event.SetText(self.Properties.CurrentValue, valueText)
  UiTextBus.Event.SetText(self.Properties.GlobalAverage, avgText)
  self.Slider:SetCurrencyDisplay(true)
  self.Slider:SetSliderMaxValue(self.max * self.multiplier)
  self.Slider:SetSliderMinValue(self.min * self.multiplier)
  self.Slider:SetSliderValue(currentValue * self.multiplier)
  self.Slider:SetCallback(self.OnSliderChanged, self)
  self.Slider:SetInputMaxDigits(4)
  local now = timeHelpers:ServerNow()
  if canEditTime < now then
    self.EditButton:SetText("@ui_edit", false, false)
    self.EditButton:SetEnabled(canEdit)
  else
    local duration = canEditTime:Subtract(now):ToSeconds() + 1
    local canEditTimeText = TimeHelperFunctions:ConvertSecondsToHrsMinSecString(duration, true, true)
    self.EditButton:SetText(canEditTimeText, false, false)
    self.EditButton:SetEnabled(false)
  end
end
function TaxAndFeeSlider:OnShutdown()
end
function TaxAndFeeSlider:SetEditMode(isEditing)
  self.isEditing = isEditing
  UiElementBus.Event.SetIsEnabled(self.Properties.EditButton, not isEditing)
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrentValue, not isEditing)
  UiElementBus.Event.SetIsEnabled(self.Properties.Description, not isEditing)
  UiElementBus.Event.SetIsEnabled(self.Properties.AcceptButton, isEditing)
  UiElementBus.Event.SetIsEnabled(self.Properties.CancelButton, isEditing)
  UiElementBus.Event.SetIsEnabled(self.Properties.Slider, isEditing)
  UiElementBus.Event.SetIsEnabled(self.Properties.GlobalAverage, isEditing)
end
function TaxAndFeeSlider:OnEdit()
  self:SetEditMode(true)
  if self.beginEditCallback then
    self.beginEditCallback(self.context, self)
  end
end
function TaxAndFeeSlider:OnSliderChanged(slider)
  local value = slider:GetValue() / self.multiplier
  self.AcceptButton:SetEnabled(self.currentValue ~= value)
end
function TaxAndFeeSlider:OnAccept()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_confirm_set_tax_title", "@ui_confirm_set_tax_desc", "on_accept_id", self, self.OnPopupResult)
end
function TaxAndFeeSlider:OnCancel()
  self:SetEditMode(false)
  if self.endEditCallback then
    self.endEditCallback(self.context, self, false)
  end
end
function TaxAndFeeSlider:OnPopupResult(result, eventId)
  if eventId == "on_accept_id" then
    if result == ePopupResult_Yes then
      local value = self.Slider:GetSliderValue() / self.multiplier
      if value < 0 then
        self.Slider:SetSliderValue(0)
        return
      elseif value > self.max then
        self.Slider:SetSliderValue(self.max * self.multiplier)
        return
      end
      local valueText = TerritoryDataHandler:GetTaxOrFeeDisplayText(value, self.taxId)
      UiTextBus.Event.SetText(self.Properties.CurrentValue, valueText)
      self.currentValue = value
      self:SetEditMode(false)
      if self.endEditCallback then
        self.endEditCallback(self.context, self, true, value)
      end
    else
      self:OnCancel()
    end
  end
end
function TaxAndFeeSlider:OnHoverStart()
end
function TaxAndFeeSlider:OnHoverEnd()
end
return TaxAndFeeSlider
