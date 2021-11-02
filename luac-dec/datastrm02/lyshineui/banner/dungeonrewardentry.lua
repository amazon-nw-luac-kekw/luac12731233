local DungeonRewardEntry = {
  Properties = {
    ItemLayout = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DungeonRewardEntry)
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
function DungeonRewardEntry:SetDungeonRewardEntry(itemId, enableTooltip)
  local itemDescriptor = ItemCommon:GetFullDescriptorFromId(itemId)
  self.ItemLayout:SetItemByDescriptor(itemDescriptor)
  self.ItemLayout:SetTooltipEnabled(enableTooltip)
end
return DungeonRewardEntry
