local CurrencyDisplay = {
  Properties = {
    DisplayPlayerCurrency = {default = false},
    CurrencyAmount = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CurrencyDisplay)
function CurrencyDisplay:OnInit()
  BaseElement.OnInit(self)
  if self.Properties.DisplayPlayerCurrency then
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    self.canvasEnabled = UiCanvasBus.Event.GetEnabled(canvasId)
    self.entityEnabled = UiElementBus.Event.IsEnabled(self.entityId)
    self:UpdateVisibility()
    self:BusConnect(UiCanvasNotificationBus, canvasId)
    self:BusConnect(UiElementNotificationBus, self.entityId)
  end
end
function CurrencyDisplay:SetCurrencyAmount(currencyAmount)
  UiTextBus.Event.SetText(self.Properties.CurrencyAmount, GetLocalizedCurrency(currencyAmount or 0))
end
function CurrencyDisplay:OnCanvasEnabledChanged(isEnabled)
  self.canvasEnabled = isEnabled
  self:UpdateVisibility()
end
function CurrencyDisplay:OnUiElementAndAncestorsEnabledChanged(isEnabled)
  self.entityEnabled = isEnabled
  self:UpdateVisibility()
end
function CurrencyDisplay:UpdateVisibility()
  local isVisible = self.canvasEnabled and self.entityEnabled
  if isVisible then
    if not self.isRegisteredForPlayerCurrency then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.Amount", function(self, currencyAmount)
        self:SetCurrencyAmount(currencyAmount)
      end)
      self.isRegisteredForPlayerCurrency = true
    end
  elseif self.isRegisteredForPlayerCurrency then
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Currency.Amount")
    self.isRegisteredForPlayerCurrency = false
  end
end
return CurrencyDisplay
