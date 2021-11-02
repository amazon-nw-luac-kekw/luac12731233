local RaidGroup = {
  Properties = {
    Bg = {
      default = EntityId()
    },
    MemberContainer = {
      default = EntityId()
    },
    Name = {
      default = EntityId()
    },
    Members = {
      default = {
        EntityId()
      }
    },
    IconPopup = {
      default = EntityId()
    },
    ColorPopup = {
      default = EntityId()
    },
    DragInstruction = {
      default = EntityId()
    }
  },
  NUM_MEMBERS = 5,
  groupDataHandler = nil,
  iconIndex = 0,
  colorIndex = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RaidGroup)
function RaidGroup:OnInit()
  BaseElement.OnInit(self)
  local validGroupData = PlayerDataManagerBus.Broadcast.GetValidGroupData()
  local colorlist = {}
  for i = 1, #validGroupData.colors do
    table.insert(colorlist, {
      color = validGroupData.colors[i],
      index = i,
      callback = self.SetColorIndex,
      callbackTable = self
    })
  end
  local iconlist = {}
  for i = 1, #validGroupData.iconPaths do
    table.insert(iconlist, {
      icon = validGroupData.iconPaths[i],
      index = i,
      callback = self.SetIconIndex,
      callbackTable = self
    })
  end
  self.ColorPopup.SimpleGrid:OnListDataSet(colorlist)
  self.IconPopup.SimpleGrid:OnListDataSet(iconlist)
end
function RaidGroup:SetGroupData(index, groupId)
  self.groupIndex = index
  self.groupId = groupId
  local groupName = GetLocalizedReplacementText("@ui_raid_group_header", {
    index = tostring(self.groupIndex + 1)
  })
  UiTextBus.Event.SetText(self.Properties.Name, groupName)
  for i = 1, self.NUM_MEMBERS do
    local member = self.Members[i - 1]
    member.RaidMember.groupIndex = index
    member.RaidMember.indexInGroup = i - 1
  end
  if groupId and groupId:IsValid() then
    self:BusDisconnect(self.groupDataHandler)
    self.groupDataHandler = self:BusConnect(GroupDataNotificationBus, self.groupId)
    GroupDataRequestBus.Event.NotifyConnected(self.groupId)
  else
    self:BusDisconnect(self.groupDataHandler)
  end
end
function RaidGroup:OnMemberAdded(index, characterId, characterName, characterIcon)
  local playerId = SimplePlayerIdentification()
  playerId.playerName = characterName
  playerId.characterIdString = characterId
  self.Members[index].RaidMember:SetData(playerId, true)
end
function RaidGroup:OnMemberRemoved(index, characterId)
  self.Members[index].RaidMember:ClearData()
end
function RaidGroup:OnMemberNameChanged(index, newName)
  if newName == "" then
    newName = "Empty"
  end
  self.Members[index].RaidMember:SetName(newName)
end
function RaidGroup:ClearData()
  for _, member in pairs(self.Members) do
    member.RaidMember:ClearData()
  end
end
function RaidGroup:OnMemberLeaderStatusChanged(index, isLeader)
  self.Members[index].RaidMember:SetLeaderStatus(isLeader)
end
function RaidGroup:OnMemberOnlineStatusChanged(index, isOnline)
  self.Members[index].RaidMember:SetIsOnline(isOnline)
end
function RaidGroup:OnMemberRaidPermissionChanged(index, permission)
  self.Members[index].RaidMember:SetPermissions(permission)
end
function RaidGroup:SetColorIndex(index)
  self.colorIndex = index - 1
  DynamicBus.Raid.Broadcast.SetGroupData(self.groupIndex, self.groupId, self.iconIndex, self.colorIndex)
  self.ColorPopup:OnIconClick()
end
function RaidGroup:OnColorIndexChanged(newIndex)
  local validGroupData = PlayerDataManagerBus.Broadcast.GetValidGroupData()
  local modifiedIndex = newIndex + 1
  if modifiedIndex < 1 or modifiedIndex > #validGroupData.colors then
    Debug.Log("Warning, New Color Index is out of bounds, tried passing: " .. tostring(newIndex))
    return
  end
  UiImageBus.Event.SetColor(self.IconPopup.Properties.Icon, validGroupData.colors[modifiedIndex])
  UiTextBus.Event.SetColor(self.Properties.Name, validGroupData.colors[modifiedIndex])
  self.colorIndex = modifiedIndex
end
function RaidGroup:SetIconIndex(index)
  self.iconIndex = index - 1
  DynamicBus.Raid.Broadcast.SetGroupData(self.groupIndex, self.groupId, self.iconIndex, self.colorIndex)
  self.IconPopup:OnIconClick()
end
function RaidGroup:OnIconIndexChanged(newIndex)
  local validGroupData = PlayerDataManagerBus.Broadcast.GetValidGroupData()
  local modifiedIndex = newIndex + 1
  if modifiedIndex < 1 or modifiedIndex > #validGroupData.iconPaths then
    Debug.Log("Warning, New Icon Index is out of bounds, tried passing: " .. tostring(newIndex))
    return
  end
  UiImageBus.Event.SetSpritePathname(self.IconPopup.Properties.Icon, validGroupData.iconPaths[modifiedIndex])
  self.iconIndex = modifiedIndex
end
function RaidGroup:SetEmptyState(isEmpty)
  if isEmpty then
    self.ScriptedEntityTweener:Set(self.Properties.MemberContainer, {opacity = 0.5})
  else
    self.ScriptedEntityTweener:Set(self.Properties.MemberContainer, {opacity = 1})
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.DragInstruction, isEmpty)
  self.Members[0].RaidMember:ShowName(not isEmpty)
  self.Members[1].RaidMember:ShowName(not isEmpty)
  self.Members[2].RaidMember:ShowName(not isEmpty)
  self.Members[3].RaidMember:ShowName(not isEmpty)
  self.Members[4].RaidMember:ShowName(not isEmpty)
end
return RaidGroup
