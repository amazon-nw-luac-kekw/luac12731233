local MilestoneWindow = {
  Properties = {
    Header = {
      default = EntityId()
    },
    Columns = {
      default = {
        EntityId()
      }
    },
    CloseButton = {
      default = EntityId()
    },
    NextMilestoneText = {
      default = EntityId()
    }
  },
  clonedElements = {},
  milestones = {},
  paddingBetweenNodes = 60,
  nextMilestoneLevel = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MilestoneWindow)
local profiler = RequireScript("LyShineUI._Common.Profiler")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function MilestoneWindow:OnInit()
  self.campingData = {
    {
      name = "@ui_unlock_camping_tier_2",
      icon = "lyshineui/images/icons/progressionmilestones/campUpgrade.dds",
      blueprintId = "CampT2"
    },
    {
      name = "@ui_unlock_camping_tier_3",
      icon = "lyshineui/images/icons/progressionmilestones/campUpgrade.dds",
      blueprintId = "CampT3"
    },
    {
      name = "@ui_unlock_camping_tier_4",
      icon = "lyshineui/images/icons/progressionmilestones/campUpgrade.dds",
      blueprintId = "CampT4"
    },
    {
      name = "@ui_unlock_camping_tier_5",
      icon = "lyshineui/images/icons/progressionmilestones/campUpgrade.dds",
      blueprintId = "CampT5"
    }
  }
  for _, data in pairs(self.campingData) do
    local campLevel = LocalPlayerUIRequestsBus.Broadcast.GetLevelRequiredForCampBlueprintId(data.blueprintId)
    if campLevel ~= nil then
      self:AddLevelData(campLevel + 1, data)
    end
  end
  self.slotUnlockData = {
    {
      name = "@ui_unlock_token_slot",
      icon = "lyshineui/images/icons/progressionmilestones/earringSlot.dds",
      slot = ePaperDollSlotTypes_Token
    },
    {
      name = "@ui_unlock_ring_slot",
      icon = "lyshineui/images/icons/progressionmilestones/ringSlot.dds",
      slot = ePaperDollSlotTypes_Ring
    },
    {
      name = "@ui_unlock_second_weapon_slot",
      icon = "lyshineui/images/icons/progressionmilestones/weaponSlot.dds",
      slot = ePaperDollSlotTypes_MainHandOption2
    },
    {
      name = "@ui_unlock_third_weapon_slot",
      icon = "lyshineui/images/icons/progressionmilestones/weaponSlot.dds",
      slot = ePaperDollSlotTypes_MainHandOption3
    },
    {
      name = "@ui_unlock_second_quick_slot",
      icon = "lyshineui/images/icons/progressionmilestones/quickSlot.dds",
      slot = ePaperDollSlotTypes_QuickSlot2
    },
    {
      name = "@ui_unlock_third_quick_slot",
      icon = "lyshineui/images/icons/progressionmilestones/quickSlot.dds",
      slot = ePaperDollSlotTypes_QuickSlot3
    },
    {
      name = "@ui_unlock_fourth_quick_slot",
      icon = "lyshineui/images/icons/progressionmilestones/quickSlot.dds",
      slot = ePaperDollSlotTypes_QuickSlot4
    },
    {
      name = "@ui_unlock_second_bag_slot",
      icon = "lyshineui/images/icons/progressionmilestones/bagSlot.dds",
      slot = ePaperDollSlotTypes_BagSlot2
    },
    {
      name = "@ui_unlock_third_bag_slot",
      icon = "lyshineui/images/icons/progressionmilestones/bagSlot.dds",
      slot = ePaperDollSlotTypes_BagSlot3
    }
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", function(self, paperdollId)
    if not paperdollId then
      return
    end
    self.paperdollId = paperdollId
    self:AddSlotUnlocks()
    self:SetupColumns()
  end)
  UiTextBus.Event.SetColor(self.Properties.NextMilestoneText, self.UIStyle.COLOR_YELLOW_GOLD)
  self.CloseButton:SetCallback(self.OnClickOut, self)
end
function MilestoneWindow:OnShutdown()
  if self.milestoneHandler then
    DynamicBus.MilestoneWindow.Disconnect(self.entityId, self)
    self.milestoneHandler = nil
  end
  UiElementBus.Event.Reparent(self.Properties.NextMilestoneText, self.entityId, EntityId())
  for i = 1, #self.clonedElements do
    UiElementBus.Event.DestroyElement(self.clonedElements[i].entityId)
  end
  self.clonedElements = {}
end
function MilestoneWindow:SetupColumns()
  local columnHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Columns[0])
  local height = 0
  local columnIndex = 0
  local numHeaders = 1
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  for i, data in pairs(self.milestones) do
    local clonedElement = CloneUiElement(canvasId, self.registrar, self.Properties.Header, self.Properties.Columns[columnIndex], true)
    table.insert(self.clonedElements, clonedElement)
    clonedElement:SetLevel(data.level)
    UiDynamicLayoutBus.Event.SetNumChildElements(clonedElement.Properties.Container, #data.data)
    data.entity = clonedElement
    local children = UiElementBus.Event.GetChildren(clonedElement.Properties.Container)
    for i = 1, #children do
      local entityTable = self.registrar:GetEntityTable(children[i])
      UiTextBus.Event.SetTextWithFlags(entityTable.Properties.Name, data.data[i].name, eUiTextSet_SetLocalized)
      UiImageBus.Event.SetSpritePathname(entityTable.Properties.Icon, data.data[i].icon)
    end
    local position = UiTransformBus.Event.GetLocalPosition(clonedElement.Properties.Container)
    UiTransformBus.Event.SetLocalPosition(clonedElement.entityId, Vector2(0, height))
    height = height + position.y + (#data.data * UiTransform2dBus.Event.GetLocalHeight(children[1]) + self.paddingBetweenNodes)
    if columnHeight < height then
      columnIndex = columnIndex + 1
      if columnIndex > #self.Properties.Columns then
        Debug.Log("Warning: There are too many milestone nodes to fit on the screen! Skipping remaining nodes.")
        break
      end
      UiElementBus.Event.Reparent(clonedElement.entityId, self.Properties.Columns[columnIndex], EntityId())
      height = 0
      UiTransformBus.Event.SetLocalPosition(clonedElement.entityId, Vector2(0, height))
      height = position.y + (#data.data * UiTransform2dBus.Event.GetLocalHeight(children[1]) + self.paddingBetweenNodes)
    end
    numHeaders = numHeaders + 1
  end
end
function MilestoneWindow:SetEnabled(isEnabled)
  if isEnabled then
    self.milestoneHandler = DynamicBus.MilestoneWindow.Connect(self.entityId, self)
  else
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    self.isVisible = false
    if self.milestoneHandler then
      DynamicBus.MilestoneWindow.Disconnect(self.entityId, self)
      self.milestoneHandler = nil
    end
  end
end
function MilestoneWindow:SetVisible(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
  else
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.15, tweenerCommon.fadeOutQuadIn, nil, function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
    end)
  end
end
function MilestoneWindow:AddSlotUnlocks()
  for _, data in pairs(self.slotUnlockData) do
    local level = PaperdollRequestBus.Event.GetLevelRequirementForSlot(self.paperdollId, data.slot)
    self:AddLevelData(level + 1, data)
  end
end
function MilestoneWindow:AddLevelData(level, data)
  if level <= 1 then
    return
  end
  local dataTable = self:GetDataFromLevel(level)
  if not dataTable then
    table.insert(self.milestones, {
      level = level,
      data = {}
    })
    dataTable = self.milestones[#self.milestones].data
    local compare = function(a, b)
      return a.level < b.level
    end
    table.sort(self.milestones, compare)
  end
  table.insert(dataTable, data)
end
function MilestoneWindow:GetDataFromLevel(level)
  for _, data in pairs(self.milestones) do
    if data.level == level then
      return data.data
    end
  end
  return nil
end
function MilestoneWindow:IsMilestoneLevel(level)
  for _, data in ipairs(self.milestones) do
    if data.level == level then
      return true
    end
  end
  return false
end
function MilestoneWindow:SetCurrentLevel(level)
  local nextMilestoneLevel = 0
  local hasFoundMilestone = false
  for _, milestoneData in pairs(self.milestones) do
    if level >= milestoneData.level then
      milestoneData.entity:SetDisplayState(milestoneData.entity.DISPLAY_STATE_UNLOCKED)
    elseif not hasFoundMilestone then
      hasFoundMilestone = true
      milestoneData.entity:SetDisplayState(milestoneData.entity.DISPLAY_STATE_NEXT)
      UiElementBus.Event.SetIsEnabled(self.Properties.NextMilestoneText, true)
      UiElementBus.Event.Reparent(self.Properties.NextMilestoneText, milestoneData.entity.entityId, EntityId())
      nextMilestoneLevel = milestoneData.level
    else
      milestoneData.entity:SetDisplayState(milestoneData.entity.DISPLAY_STATE_LOCKED)
    end
  end
  if not hasFoundMilestone then
    UiElementBus.Event.SetIsEnabled(self.Properties.NextMilestoneText, false)
  end
  return nextMilestoneLevel
end
function MilestoneWindow:GetNextMilestoneForLevel(currentLevel)
  for _, milestoneData in ipairs(self.milestones) do
    if currentLevel < milestoneData.level then
      return milestoneData.level
    end
  end
  return 0
end
function MilestoneWindow:OnClickOut()
  self:SetVisible(false)
end
return MilestoneWindow
