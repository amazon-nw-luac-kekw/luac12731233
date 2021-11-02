local CraftDoneWindow = {
  Properties = {
    ItemRarity = {
      default = EntityId()
    },
    ItemRarityHeader = {
      default = EntityId()
    }
  },
  oldAmt = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftDoneWindow)
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
local DataLayer = RequireScript("LyShineUI.UiDataLayer")
function CraftDoneWindow:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.ItemRarity, self.UIStyle.FONT_STYLE_CRAFTROLL_TEXT)
  SetTextStyle(self.ItemRarityHeader, self.UIStyle.FONT_STYLE_CRAFTROLL_LABEL)
end
function CraftDoneWindow:SetOriginalInventoryAmount(amt)
  self.oldAmt = amt
end
function CraftDoneWindow:SetHeader(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemRarityHeader, text, eUiTextSet_SetLocalized)
end
return CraftDoneWindow
