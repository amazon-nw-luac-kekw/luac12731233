local EncounterDataHandler = {
  SpawnerToPlayerLevel = {
    25,
    35,
    45,
    55,
    60,
    65
  },
  SpawnerToRequiredItem = {
    760197844,
    3024544622,
    3275871224,
    1562723931,
    706901709,
    706901709
  },
  GroupTypeToSize = {
    {min = 1, max = 2},
    {min = 2, max = 3},
    {min = 3, max = 4},
    {min = 5, max = 5}
  },
  DangerPostfix = "_danger",
  cachedDangerIcons = {}
}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function EncounterDataHandler:OnActivate()
end
function EncounterDataHandler:Reset()
  self:OnDeactivate()
end
function EncounterDataHandler:GetLevel(spawnerTag)
  if spawnerTag ~= nil then
    local difficultyLevel = self.SpawnerToPlayerLevel[spawnerTag]
    if difficultyLevel then
      return difficultyLevel
    end
  end
  return 0
end
function EncounterDataHandler:GetRequiredItem(spawnerTag)
  if spawnerTag ~= nil then
    local itemId = self.SpawnerToRequiredItem[spawnerTag]
    if itemId then
      return itemId
    end
  end
  return 760197844
end
function EncounterDataHandler:GetGroupRange(definition)
  local groupData = self.GroupTypeToSize[definition.groupSize + 1]
  if groupData then
    return groupData.min, groupData.max
  end
  return 0, 0
end
function EncounterDataHandler:IsRecommendedGroup(definition)
  local min, max = self:GetGroupRange(definition)
  local memberCount = math.max(1, dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.MemberCount") or 1)
  return min <= memberCount
end
function EncounterDataHandler:IsRecommendedLevel(spawnerTag)
  local min = self:GetLevel(spawnerTag) or 1
  local level = dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
  return min <= level, min
end
function EncounterDataHandler:GetRecommendedIcons(spawnerTag, definition)
  if definition then
    if self:IsRecommendedGroup(definition) and self:IsRecommendedLevel(spawnerTag) then
      return definition.mapIcon, definition.compassIcon
    end
    local dangerMapIcon = self.cachedDangerIcons[definition.mapIcon]
    if not dangerMapIcon then
      dangerMapIcon = string.sub(definition.mapIcon, 1, string.find(definition.mapIcon, ".png") - 1) .. self.DangerPostfix .. ".png"
      self.cachedDangerIcons[definition.mapIcon] = dangerMapIcon
    end
    local dangerCompassIcon = self.cachedDangerIcons[definition.compassIcon]
    if not dangerCompassIcon then
      dangerCompassIcon = string.sub(definition.compassIcon, 1, string.find(definition.compassIcon, ".png") - 1) .. self.DangerPostfix .. ".png"
      self.cachedDangerIcons[definition.mapIcon] = dangerCompassIcon
    end
    return dangerMapIcon, dangerCompassIcon
  end
end
return EncounterDataHandler
