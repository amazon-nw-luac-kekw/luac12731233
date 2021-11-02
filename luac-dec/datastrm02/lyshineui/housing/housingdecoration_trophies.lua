local HousingDecoration_Trophies = {
  Properties = {
    TrophyCountText = {
      default = EntityId()
    },
    TrophyIconContainer = {
      default = EntityId()
    },
    TrophyIcon = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(HousingDecoration_Trophies)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function HousingDecoration_Trophies:OnInit()
  BaseElement.OnInit(self)
  self.trophyElements = {}
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  local tooltipText = "<font color=\"#FFFFFF\" face=\"" .. self.UIStyle.FONT_FAMILY_NIMBUS_BOLD .. "\">" .. "@ui_housing_trophy_empty_slot" .. [[
</font>

]] .. "@ui_housing_trophy_buff_desc_tooltip"
  self.TooltipSetter:SetSimpleTooltip(tooltipText)
end
function HousingDecoration_Trophies:OnShutdown()
end
function HousingDecoration_Trophies:OnSetTrophyData(activeTrophies, maxTrophies)
  local numActiveTrophies = #activeTrophies
  local trophyCountText = "<font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_HOUSING_DECORATION_TROPHIES) .. ">" .. numActiveTrophies .. "</font>" .. " / " .. maxTrophies
  UiTextBus.Event.SetText(self.Properties.TrophyCountText, trophyCountText)
  local numElements = #self.trophyElements
  if maxTrophies > numElements then
    for i = numElements, maxTrophies - 1 do
      local entity = CloneUiElement(self.canvasId, self.registrar, self.Properties.TrophyIcon, self.Properties.TrophyIconContainer, true)
      table.insert(self.trophyElements, entity)
    end
  elseif maxTrophies < numElements then
    for i = numElements, maxTrophies + 1 do
      UiElementBus.Event.DestroyElement(self.trophyElements[i].entityId)
      table.remove(self.trophyElements, i)
    end
  end
  for i = 1, maxTrophies do
    local trophyData
    if numActiveTrophies >= i then
      trophyData = activeTrophies[i]
    end
    local trophyElement = self.trophyElements[i]
    trophyElement:SetSeparatorVisible(i ~= 1)
    trophyElement:SetForegroundVisibility(trophyData ~= nil)
    if trophyData then
      local iconPath = "LyShineUI/Images/icons/items/HousingItem/" .. trophyData.icon .. ".dds"
      trophyElement.staticItemData = trophyData.staticItemData
      trophyElement:SetIcon(iconPath, self.UIStyle.COLOR_TAN_LIGHT)
      trophyElement:SetTier(trophyElement.staticItemData.tier)
    else
      trophyElement.staticItemData = nil
    end
  end
end
function HousingDecoration_Trophies:SetEnabled(enabled)
  for i = 1, #self.trophyElements do
    self.trophyElements[i]:SetEnabled(enabled)
  end
end
local itemDesc = ItemDescriptor()
function HousingDecoration_Trophies:GetTooltipDisplayInfo(staticItemData)
  if staticItemData then
    itemDesc.itemId = staticItemData.id
    return StaticItemDataManager:GetTooltipDisplayInfo(itemDesc)
  end
end
function HousingDecoration_Trophies:OnTrophyIconOnFocus(entityId)
  local trophyElement
  for i = 1, #self.trophyElements do
    if entityId == self.trophyElements[i].entityId then
      trophyElement = self.trophyElements[i]
    end
  end
  local trophyTable = self.registrar:GetEntityTable(entityId)
  local itemData = trophyTable.staticItemData
  if itemData then
    local tdi = self:GetTooltipDisplayInfo(trophyTable.staticItemData)
    DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(tdi, self)
  else
    self.TooltipSetter:OnTooltipSetterHoverStart()
  end
end
function HousingDecoration_Trophies:OnTrophyIconOnUnfocus(entityId)
  local trophyElement
  for i = 1, #self.trophyElements do
    if entityId == self.trophyElements[i].entityId then
      trophyElement = self.trophyElements[i]
    end
  end
  local trophyTable = self.registrar:GetEntityTable(entityId)
  local itemData = trophyTable.staticItemData
  if itemData then
    local tdi = self:GetTooltipDisplayInfo(itemData)
    DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  else
    self.TooltipSetter:OnTooltipSetterHoverEnd()
  end
end
return HousingDecoration_Trophies
