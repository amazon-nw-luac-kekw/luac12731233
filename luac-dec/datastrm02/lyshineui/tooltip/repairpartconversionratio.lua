local RepairPartConversionRatio = {
  Properties = {
    RatioText = {
      default = EntityId()
    }
  },
  type = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RepairPartConversionRatio)
local InventoryCommon = RequireScript("LyShineUI._Common.InventoryCommon")
function RepairPartConversionRatio:OnInit()
  BaseElement.OnInit(self)
  local style = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 24,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  SetTextStyle(self.Properties.RatioText, style)
end
function RepairPartConversionRatio:IsTierInfo()
  return false
end
function RepairPartConversionRatio:SetRepairPartConversionRatioTier(tier)
  local exchangeData = InventoryCommon:GetRepairPartExchangeData(tier)
  if exchangeData then
    local ratioText = GetLocalizedReplacementText("@inv_repairparts_popup_conversionratio", {
      a = GetFormattedNumber(exchangeData.fromCurrencyQuantity),
      b = GetFormattedNumber(exchangeData.toCurrencyQuantity)
    })
    UiTextBus.Event.SetText(self.Properties.RatioText, ratioText)
  end
end
return RepairPartConversionRatio
