local FactionReputation_ProgressBar = {
  Properties = {
    ProgressBarImage = {
      default = EntityId()
    },
    ProgressBarBG = {
      default = EntityId()
    },
    RankTick1 = {
      default = EntityId()
    },
    RankTick2 = {
      default = EntityId()
    },
    RankTick3 = {
      default = EntityId()
    },
    RankTick4 = {
      default = EntityId()
    },
    RankTick5 = {
      default = EntityId()
    },
    RankIcon1 = {
      default = EntityId()
    },
    RankIcon2 = {
      default = EntityId()
    },
    RankIcon3 = {
      default = EntityId()
    },
    RankIcon4 = {
      default = EntityId()
    },
    RankIcon5 = {
      default = EntityId()
    }
  },
  rankToTickInfo = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FactionReputation_ProgressBar)
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function FactionReputation_ProgressBar:OnInit()
  BaseElement.OnInit(self)
  self.factionInfoTable = FactionCommon.factionInfoTable
  table.insert(self.rankToTickInfo, {
    tick = self.RankTick1,
    icon = self.RankIcon1
  })
  table.insert(self.rankToTickInfo, {
    tick = self.RankTick2,
    icon = self.RankIcon2
  })
  table.insert(self.rankToTickInfo, {
    tick = self.RankTick3,
    icon = self.RankIcon3
  })
  table.insert(self.rankToTickInfo, {
    tick = self.RankTick4,
    icon = self.RankIcon4
  })
  table.insert(self.rankToTickInfo, {
    tick = self.RankTick5,
    icon = self.RankIcon5
  })
end
function FactionReputation_ProgressBar:SetFillColor(fillColor)
  self.fillColor = fillColor
  UiImageBus.Event.SetColor(self.Properties.ProgressBarImage, fillColor)
end
function FactionReputation_ProgressBar:SetProgressionId(progressionId, progressionEntityId, guildShop, faction)
  for i, tickInfo in ipairs(self.rankToTickInfo) do
    if 1 < i then
      tickInfo.points = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(progressionEntityId, progressionId, i - 2)
    else
      tickInfo.points = 0
    end
    local numNewShopItems = 1 < i and guildShop:GetAvailableItemCountForCrcForRank(progressionId, progressionEntityId, i - 1) or 0
    local rankName = self.factionInfoTable[faction].rankNames[i]
    local rankNameColor = self.factionInfoTable[faction].crestBgColorLight
    local rankIconColor = self.factionInfoTable[faction].crestBgColor
    local rankIconPath = "lyshineui/images/icons/factionranks/factionRank" .. tostring(i) .. ".dds"
    tickInfo.icon:SetFlyoutData(rankName, rankNameColor, rankIconPath, rankIconColor, numNewShopItems, tickInfo.points)
  end
  local maxPoints = self.rankToTickInfo[#self.rankToTickInfo].points
  local barWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  for i, tickInfo in ipairs(self.rankToTickInfo) do
    local barPercentPosition = tickInfo.points / maxPoints
    UiTransformBus.Event.SetLocalPositionX(tickInfo.tick, barPercentPosition * barWidth)
  end
end
function FactionReputation_ProgressBar:SetPoints(points)
  local fillPercent = points / self.rankToTickInfo[#self.rankToTickInfo].points
  self.ScriptedEntityTweener:Play(self.Properties.ProgressBarImage, 1, {
    imgColor = self.UIStyle.COLOR_WHITE
  }, {
    imgColor = self.fillColor,
    ease = "CubicOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.ProgressBarImage, 0.3, {scaleX = fillPercent, ease = "QuadOut"})
  for i, tickInfo in ipairs(self.rankToTickInfo) do
    if points >= tickInfo.points then
      UiImageBus.Event.SetColor(tickInfo.tick, self.UIStyle.COLOR_TAN_LIGHT)
      tickInfo.icon:SetIsUnlocked(true)
    else
      UiImageBus.Event.SetColor(tickInfo.tick, self.UIStyle.COLOR_TAN)
      tickInfo.icon:SetIsUnlocked(false)
    end
  end
end
return FactionReputation_ProgressBar
