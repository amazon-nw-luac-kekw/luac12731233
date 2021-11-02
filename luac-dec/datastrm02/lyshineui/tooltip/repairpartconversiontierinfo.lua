local RepairPartConversionTierInfo = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    CurrentText = {
      default = EntityId()
    },
    RemainingText = {
      default = EntityId()
    }
  },
  iconPath = "LyShineUI/Images/Icons/RepairPartsCurrency/RepairPartsT%s_Currency.png",
  remainingTextFontSizeNormal = 28,
  remainingTextFontSizeBigger = 32,
  type = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RepairPartConversionTierInfo)
function RepairPartConversionTierInfo:OnInit()
  BaseElement.OnInit(self)
  self.Icon:SetColor(self.UIStyle.COLOR_WHITE)
  local style = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 24,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  SetTextStyle(self.Properties.CurrentText, style)
  SetTextStyle(self.Properties.RemainingText, style)
end
function RepairPartConversionTierInfo:IsTierInfo()
  return true
end
function RepairPartConversionTierInfo:SetRepairPartConversionTierInfo(conversionData, isTopTier)
  local remaining = conversionData.currentParts + conversionData.convertedParts - conversionData.neededParts
  self.Icon:SetPath(string.format(self.iconPath, conversionData.tier))
  UiTextBus.Event.SetText(self.Properties.CurrentText, GetFormattedNumber(conversionData.currentParts))
  UiTextBus.Event.SetText(self.Properties.RemainingText, GetFormattedNumber(remaining))
  local remainTextFontSize = isTopTier and self.remainingTextFontSizeBigger or self.remainingTextFontSizeNormal
  UiTextBus.Event.SetFontSize(self.Properties.RemainingText, remainTextFontSize)
  local remainTextColor = isTopTier and self.UIStyle.WHITE or self.UIStyle.COLOR_GRAY_80
  UiTextBus.Event.SetColor(self.Properties.RemainingText, remainTextColor)
end
return RepairPartConversionTierInfo
