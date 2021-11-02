local CraftingSummaryItem = {
  Properties = {
    ItemLayout = {
      default = EntityId()
    },
    ItemName = {
      default = EntityId()
    },
    GearScore = {
      default = EntityId()
    },
    SalvageButton = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftingSummaryItem)
function CraftingSummaryItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.ItemName, self.UIStyle.FONT_STYLE_CRAFTING_SUMMARY_ITEM)
  SetTextStyle(self.Properties.GearScore, self.UIStyle.FONT_STYLE_CRAFTING_SUMMARY_ITEM_GS)
end
function CraftingSummaryItem:SetItemSlot(itemSlot, salvageCallback, salvageCallbackTable)
  self.itemSlot = itemSlot
  self.salvageCallback = salvageCallback
  self.salvageCallbackTable = salvageCallbackTable
  local descriptor = itemSlot:GetItemDescriptor()
  local rarityLevel = tostring(descriptor:GetRarityLevel())
  self.ItemLayout:SetItemByDescriptor(descriptor)
  self.ItemLayout:SetTooltipEnabled(true)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, descriptor:GetDisplayName(), eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.GearScore, tostring(descriptor:GetGearScore()), eUiTextSet_SetAsIs)
  UiTextBus.Event.SetColor(self.Properties.ItemName, self.UIStyle["COLOR_RARITY_LEVEL_" .. rarityLevel .. "_BRIGHT"])
  self.SalvageButton:SetText("@inv_salvage")
  self.SalvageButton:SetCallback(self.OnSalvage, self)
  self.ScriptedEntityTweener:Set(self.Properties.SalvageButton, {
    opacity = itemSlot:CanSalvageItem() and 1 or 0
  })
end
function CraftingSummaryItem:OnSalvage()
  if self.salvageCallback then
    self.salvageCallback(self.salvageCallbackTable, self.itemSlot)
  end
end
return CraftingSummaryItem
