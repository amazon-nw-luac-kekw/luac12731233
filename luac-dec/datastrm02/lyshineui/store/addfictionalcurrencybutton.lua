local AddFictionalCurrencyButton = {
  Properties = {
    Frame = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AddFictionalCurrencyButton)
function AddFictionalCurrencyButton:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.Text, self.UIStyle.FONT_STYLE_STORE_FICTIONAL_CURRENCY_TEXT)
end
function AddFictionalCurrencyButton:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function AddFictionalCurrencyButton:OnHover()
  UiImageBus.Event.SetSpritePathname(self.Properties.Frame, "lyshineui/images/mtx/store_add_button_selected.dds")
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function AddFictionalCurrencyButton:OnUnhover()
  UiImageBus.Event.SetSpritePathname(self.Properties.Frame, "lyshineui/images/mtx/store_add_button")
end
function AddFictionalCurrencyButton:SetValue(value)
  UiTextBus.Event.SetText(self.Properties.Text, value)
end
function AddFictionalCurrencyButton:OnPress()
  if self.callbackTable and type(self.callback) == "function" then
    self.callback(self.callbackTable)
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
return AddFictionalCurrencyButton
