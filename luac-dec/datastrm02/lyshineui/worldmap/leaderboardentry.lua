local LeaderboardEntry = {
  Properties = {
    SelfIndicator = {
      default = EntityId()
    },
    RankText = {
      default = EntityId()
    },
    GuildCrest = {
      default = EntityId()
    },
    GuildName = {
      default = EntityId()
    },
    ClaimsNumber = {
      default = EntityId()
    },
    ScoreNumber = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(LeaderboardEntry)
function LeaderboardEntry:OnInit()
  BaseElement.OnInit(self)
end
function LeaderboardEntry:SetShowEntry(show)
  UiElementBus.Event.SetIsEnabled(self.GuildCrest.entityId, show)
  UiElementBus.Event.SetIsEnabled(self.GuildName, show)
  UiElementBus.Event.SetIsEnabled(self.ClaimsNumber, show)
  UiElementBus.Event.SetIsEnabled(self.ScoreNumber, show)
end
function LeaderboardEntry:SetTextColor(color)
  UiTextBus.Event.SetColor(self.RankText, color)
  UiTextBus.Event.SetColor(self.GuildName, color)
  UiTextBus.Event.SetColor(self.ClaimsNumber, color)
  UiTextBus.Event.SetColor(self.ScoreNumber, color)
end
function LeaderboardEntry:SetShowSelfIndicator(show)
  UiElementBus.Event.SetIsEnabled(self.SelfIndicator, show)
end
function LeaderboardEntry:SetRankNum(rank)
  local rankText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_leaderboard_rank_number", GetLocalizedNumber(rank or 0))
  UiTextBus.Event.SetTextWithFlags(self.RankText, rankText, eUiTextSet_SetAsIs)
  if rank ~= 1 then
    self.crestChangeCb = nil
    self.crestChangeTable = nil
  end
end
function LeaderboardEntry:SetGuildCrest(crestData)
  local isCrestValid = crestData and crestData:IsValid()
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrest, isCrestValid)
  if isCrestValid then
    self.GuildCrest:SetSmallIcon(crestData)
    if self.crestChangeTable and self.crestChangeCb then
      self.crestChangeCb(self.crestChangeTable, crestData)
    end
  end
end
function LeaderboardEntry:SetGuildName(guildName)
  UiTextBus.Event.SetTextWithFlags(self.GuildName, guildName, eUiTextSet_SetAsIs)
end
function LeaderboardEntry:SetNumClaims(claims)
  UiTextBus.Event.SetTextWithFlags(self.ClaimsNumber, GetLocalizedNumber(claims or 0), eUiTextSet_SetAsIs)
end
function LeaderboardEntry:SetScore(score)
  local scoreText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_leaderboard_area_score", GetLocalizedNumber(score or 0))
  UiTextBus.Event.SetTextWithFlags(self.ScoreNumber, scoreText, eUiTextSet_SetAsIs)
end
function LeaderboardEntry:SetLeaderGuildCrestChangeCallback(cb, table)
  self.crestChangeCb = cb
  self.crestChangeTable = table
end
return LeaderboardEntry
