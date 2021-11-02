local SkillRow = {
  Properties = {
    SkillName = {
      default = EntityId()
    },
    SkillLevelsHolder = {
      default = EntityId()
    },
    ComingSoon = {
      default = EntityId()
    }
  },
  SkillLevelSlicePath = "LyShineUI\\Skills\\SkillLevel",
  skillData = {},
  skillLevelEntities = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SkillRow)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(SkillRow)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function SkillRow:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  SetTextStyle(self.SkillName.entityId, self.UIStyle.FONT_STYLE_NAME)
end
function SkillRow:SetData(data)
  self.skillData = {}
  self.skillData.enum = data.enum
  self.skillData.locName = data.locName or ""
  self.skillData.tooltip = data.tooltip or ""
  self.skillData.name = data.name or ""
  UiTextBus.Event.SetTextWithFlags(self.SkillName.entityId, data.locName, eUiTextSet_SetLocalized)
  local nameWidth = UiTextBus.Event.GetTextWidth(self.SkillName.entityId)
  UiTransform2dBus.Event.SetLocalWidth(self.SkillName.entityId, nameWidth)
  local localizedTooltip = LyShineScriptBindRequestBus.Broadcast.LocalizeText(data.tooltip)
  self.SkillName:SetSimpleTooltip(localizedTooltip)
  self:RegisterObservers()
end
function SkillRow:OnSkillNameUnfocus()
  self.SkillName:OnTooltipSetterHoverEnd()
end
function SkillRow:OnSkillNameFocus()
  self.SkillName:OnTooltipSetterHoverStart()
end
function SkillRow:SetLevelCount(data)
  if self.levelCount ~= nil then
    return
  end
  if data ~= nil then
    self.levelCount = data
    self:ClearSkillLevelEntities()
    self:BusConnect(UiSpawnerNotificationBus, self.SkillLevelsHolder)
    for i = 1, self.levelCount do
      local data = {
        itemIndex = i,
        name = self.skillData.name,
        enum = self.skillData.enum
      }
      self:SpawnSlice(self.SkillLevelsHolder, self.SkillLevelSlicePath, self.OnSkillLevelSpawned, data)
    end
    UiElementBus.Event.SetIsEnabled(self.ComingSoon, self.levelCount <= 0)
  end
end
function SkillRow:OnSkillLevelSpawned(entity, data)
  entity:SetData(data)
  self.skillLevelEntities[data.itemIndex] = entity
end
function SkillRow:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataObserver(self, string.format("Hud.LocalPlayer.Tradeskills.%s.Count", self.skillData.name), self.SetLevelCount)
  for i, entity in pairs(self.skillLevelEntities) do
    entity:RegisterObservers()
  end
end
function SkillRow:UnregisterObservers()
  self.dataLayer:UnregisterObservers(self)
  for i, entity in pairs(self.skillLevelEntities) do
    entity:UnregisterObservers()
  end
end
function SkillRow:ClearSkillLevelEntities()
  for i, entity in pairs(self.skillLevelEntities) do
    UiElementBus.Event.DestroyElement(entity.entityId)
    self.skillLevelEntities[i] = nil
  end
end
function SkillRow:OnShutdown()
  self:UnregisterObservers()
  self:ClearSkillLevelEntities()
end
return SkillRow
