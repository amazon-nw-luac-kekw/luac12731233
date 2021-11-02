local FlyoutRow_Subheader = {
  Properties = {
    Header = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_Subheader)
function FlyoutRow_Subheader:OnInit()
  BaseElement.OnInit(self)
end
function FlyoutRow_Subheader:OnShutdown()
end
function FlyoutRow_Subheader:SetData(data)
  if not data or not data.header then
    Log("[FlyoutRow_Subheader] Error: invalid data passed to SetData")
    return
  end
  UiTextBus.Event.SetTextWithFlags(self.Header, data.header, eUiTextSet_SetLocalized)
  if data.textSize then
    UiTextBus.Event.SetFontSize(self.Header, data.textSize)
  end
end
return FlyoutRow_Subheader
