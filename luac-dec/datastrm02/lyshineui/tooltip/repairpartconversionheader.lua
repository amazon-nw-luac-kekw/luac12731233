local RepairPartConversionHeader = {
  Properties = {
    CurrentText = {
      default = EntityId()
    },
    RemainingText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RepairPartConversionHeader)
function RepairPartConversionHeader:OnInit()
  BaseElement.OnInit(self)
  local style = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 24,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  SetTextStyle(self.Properties.CurrentText, style)
  SetTextStyle(self.Properties.RemainingText, style)
end
return RepairPartConversionHeader
