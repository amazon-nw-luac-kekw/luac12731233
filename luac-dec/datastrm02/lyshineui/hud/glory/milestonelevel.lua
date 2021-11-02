local MilestoneLevel = {
  Properties = {
    LevelOutlineBg = {
      default = EntityId()
    },
    LevelText = {
      default = EntityId()
    },
    MajorRewardEntries = {
      default = {
        EntityId()
      }
    },
    MinorRewardEntries = {
      default = {
        EntityId()
      }
    },
    TerritoryRewardEntries = {
      default = {
        EntityId()
      }
    },
    MinorRewardsContainer = {
      default = EntityId()
    },
    TerritoryHeader = {
      default = EntityId()
    },
    TerritoryLabel = {
      default = EntityId()
    }
  },
  unlockedMilestoneDiamondPath = "lyshineui/images/glory/nextMilestoneDiamond.dds",
  otherMilestoneDiamondPath = "lyshineui/images/glory/genericMilestoneDiamond.dds",
  DISPLAY_STATE_UNLOCKED = 0,
  DISPLAY_STATE_LOCKED = 1,
  DISPLAY_STATE_NEXT = 2
}
local BaseElement = RequireScript("LyshineUI._Common.BaseElement")
BaseElement:CreateNewElement(MilestoneLevel)
function MilestoneLevel:OnInit()
  SetTextStyle(self.Properties.LevelText, self.UIStyle.FONT_STYLE_MILESTONE_LEVEL)
  SetTextStyle(self.Properties.TerritoryHeader, self.UIStyle.FONT_STYLE_MILESTONE_TERRITORY_LABEL)
  SetTextStyle(self.Properties.TerritoryLabel, self.UIStyle.FONT_STYLE_MILESTONE_TERRITORY_TEXT)
end
function MilestoneLevel:SetLevel(level)
  UiTextBus.Event.SetText(self.Properties.LevelText, tostring(level))
end
function MilestoneLevel:SetRewardData(data)
  self.rewardEntries = {}
  local majorIndex = 0
  local minorIndex = 0
  local territoryIndex = 0
  for _, rewardData in ipairs(data) do
    if rewardData.type == eMilestoneType_Major then
      local majorReward = self.MajorRewardEntries[majorIndex]
      if majorReward then
        UiElementBus.Event.SetIsEnabled(majorReward.entityId, true)
        majorReward:SetRewardData(rewardData)
        table.insert(self.rewardEntries, majorReward)
      end
      majorIndex = majorIndex + 1
    elseif rewardData.type == eMilestoneType_TerritoryRecommendation then
      local territoryReward = self.TerritoryRewardEntries[territoryIndex]
      if territoryReward then
        UiElementBus.Event.SetIsEnabled(territoryReward.entityId, true)
        territoryReward:SetRewardData(rewardData)
        table.insert(self.rewardEntries, territoryReward)
      end
      territoryIndex = territoryIndex + 1
    else
      local minorReward = self.MinorRewardEntries[minorIndex]
      if minorReward then
        UiElementBus.Event.SetIsEnabled(minorReward.entityId, true)
        minorReward:SetRewardData(rewardData)
        table.insert(self.rewardEntries, minorReward)
      end
      minorIndex = minorIndex + 1
    end
  end
  for i = majorIndex, #self.Properties.MajorRewardEntries do
    UiElementBus.Event.SetIsEnabled(self.Properties.MajorRewardEntries[i], false)
  end
  for i = minorIndex, #self.MinorRewardEntries do
    UiElementBus.Event.SetIsEnabled(self.Properties.MinorRewardEntries[i], false)
  end
  for i = territoryIndex, #self.TerritoryRewardEntries do
    UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryRewardEntries[i], false)
  end
  local minorPosY = 0 < majorIndex and 310 or 90
  UiTransformBus.Event.SetLocalPositionY(self.Properties.MinorRewardsContainer, minorPosY)
end
function MilestoneLevel:SetDisplayState(state)
  if state == self.currentDisplayState then
    return
  end
  local diamondPath = self.otherMilestoneDiamondPath
  local textColor = self.UIStyle.COLOR_GRAY_80
  local entryColor = self.UIStyle.COLOR_GRAY_80
  if state == self.DISPLAY_STATE_UNLOCKED then
    diamondPath = self.unlockedMilestoneDiamondPath
    textColor = self.UIStyle.COLOR_YELLOW
    entryColor = self.UIStyle.COLOR_WHITE
  else
    textColor = self.UIStyle.COLOR_GRAY_50
    entryColor = self.UIStyle.COLOR_GRAY_50
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.LevelOutlineBg, diamondPath)
  UiTextBus.Event.SetColor(self.Properties.LevelText, textColor)
  for _, entry in ipairs(self.rewardEntries) do
    entry:SetDisplayState(state)
  end
  self.currentDisplayState = state
end
return MilestoneLevel
