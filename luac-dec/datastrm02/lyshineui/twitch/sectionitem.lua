local SectionItem = {
  Properties = {
    HeaderText = {
      default = EntityId()
    },
    HeaderArrow = {
      default = EntityId()
    },
    SessionList = {
      default = EntityId()
    }
  },
  sessionItems = {},
  sessionCount = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SectionItem)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(SectionItem)
function SectionItem:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.SessionList)
  self:ClearList()
end
function SectionItem:ClearList()
  local children = UiElementBus.Event.GetChildren(self.Properties.SessionList)
  for i = 1, #children do
    UiElementBus.Event.DestroyElement(children[i])
  end
  self.sessionItems = {}
  self.sessionCount = 0
end
function SectionItem:AddItem(sessionItem)
  if not sessionItem then
    return
  end
  local data = {
    playerName = sessionItem.playerName,
    twitchName = sessionItem.twitchName,
    inviteStatus = sessionItem.inviteStatus
  }
  self:SpawnSlice(self.Properties.SessionList, "LyShineUI\\Twitch\\SessionItem", self.OnSessionItemSpawned, data)
  self.sessionCount = self.sessionCount + 1
end
function SectionItem:OnSessionItemSpawned(entity, data)
  table.insert(self.sessionItems, entity.entityId)
  entity:SetPlayerName(data.playerName)
  entity:SetTwitchName(data.twitchName)
  if data.inviteStatus ~= eSubArmyInviteStatus_Unknown then
    entity:OnRequestJoinResultReceived(data.twitchName, data.inviteStatus)
  end
  UiElementBus.Event.SetIsEnabled(entity.entityId, not self.isCollapsed)
  UiLayoutCellBus.Event.SetTargetHeight(entity.entityId, self.isCollapsed and 0 or 48)
end
function SectionItem:OnHeaderPressed()
  self.isCollapsed = not self.isCollapsed
  local children = UiElementBus.Event.GetChildren(self.Properties.SessionList)
  for i = 1, #children do
    UiElementBus.Event.SetIsEnabled(children[i], not self.isCollapsed)
    UiLayoutCellBus.Event.SetTargetHeight(children[i], self.isCollapsed and 0 or 48)
  end
  UiLayoutColumnBus.Event.SetSpacing(self.Properties.SessionList, self.isCollapsed and 0 or 8)
  UiTransformBus.Event.SetZRotation(self.Properties.HeaderArrow, self.isCollapsed and -90 or 0)
end
function SectionItem:ItemCount()
  return self.sessionCount or 0
end
return SectionItem
