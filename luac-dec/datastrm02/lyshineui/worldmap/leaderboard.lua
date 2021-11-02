local Leaderboard = {
  Properties = {
    HeaderTitle = {
      default = EntityId()
    },
    HeaderTime = {
      default = EntityId()
    },
    HeaderClaims = {
      default = EntityId()
    },
    HeaderScore = {
      default = EntityId()
    },
    Entries = {
      default = {
        EntityId()
      }
    },
    SelfEntry = {
      default = EntityId()
    }
  },
  entryCount = 0,
  entryMap = {},
  ownGuildId = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Leaderboard)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function Leaderboard:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  self.entryCount = #self.Entries + 1
  self.SelfEntry:SetShowSelfIndicator(true)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Id", function(self, guildId)
    self.ownGuildId = guildId
    self:UpdateOwnGuildEntryOnBoard()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Name", function(self, guildName)
    self.SelfEntry:SetGuildName(guildName)
    local ownEntry = self:GetEntryOnBoard(self.ownGuildId)
    if ownEntry then
      ownEntry:SetGuildName(guildName)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Crest", function(self, crestData)
    self.SelfEntry:SetGuildCrest(crestData)
    local ownEntry = self:GetEntryOnBoard(self.ownGuildId)
    if ownEntry then
      ownEntry:SetGuildCrest(crestData)
    end
  end)
end
function Leaderboard:OnShutdown()
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
function Leaderboard:SetEntries(entries)
  self.entryMap = {}
  local ids = vector_GuildId()
  if entries then
    for i = 1, self.entryCount do
      local entryEntity = self.Entries[i - 1]
      if i <= #entries then
        local entryData = entries[i]
        self.entryMap[tostring(entryData.guildId)] = entryEntity
        ids:push_back(entryData.guildId)
        entryEntity:SetNumClaims(entryData.totalSettlementDays)
        entryEntity:SetScore(entryData.totalScore)
        entryEntity:SetShowEntry(true)
      else
        entryEntity:SetShowEntry(false)
      end
      entryEntity:SetRankNum(i)
      entryEntity:SetTextColor(self.UIStyle.COLOR_TAN)
      entryEntity:SetShowSelfIndicator(false)
      if i == 1 then
        entryEntity:SetLeaderGuildCrestChangeCallback(self.crestChangeCb, self.crestChangeTable)
      end
    end
  end
  self:UpdateOwnGuildEntryOnBoard()
  socialDataHandler:RequestGetGuilds_ServerCall(self, self.GuildDataSuccess, self.GuildDataFailed, ids)
end
function Leaderboard:GuildDataSuccess(results)
  for i = 1, #results do
    local guildData = results[i]
    local entity = self.entryMap[tostring(guildData.guildId)]
    if entity then
      entity:SetGuildName(guildData.guildName)
      entity:SetGuildCrest(guildData.crestData)
    end
  end
end
function Leaderboard:GuildDataFailed(reason)
  local reasonText = "Unknown"
  if reason == eSocialRequestFailureReasonThrottled then
    reasonText = "Request throttled"
  elseif reason == eSocialRequestFailureReasonTimeout then
    reasonText = "Request timed out"
  end
  Debug.Log("Failed to get GuildData for guild: " .. reasonText)
end
function Leaderboard:SetOwnEntry(entryData)
  self.SelfEntry:SetRankNum(entryData.position)
  self.SelfEntry:SetNumClaims(entryData.totalSettlementDays)
  self.SelfEntry:SetScore(entryData.totalScore)
end
function Leaderboard:GetEntryOnBoard(guildId)
  return guildId and self.entryMap[tostring(guildId)] or nil
end
function Leaderboard:TryUpdateEntryForGuild(guildId, data)
  if not guildId or not data then
    return
  end
  local entry = self.entryMap[tostring(guildId)]
  if entry then
    if data.guildName then
      entry:SetGuildName(data.guildName)
    end
    if data.guildCrestData then
      entry:SetGuildCrest(data.guildCrestData)
    end
  end
end
function Leaderboard:UpdateOwnGuildEntryOnBoard()
  local ownEntry = self:GetEntryOnBoard(self.ownGuildId)
  if ownEntry then
    ownEntry:SetTextColor(self.UIStyle.COLOR_WHITE)
    ownEntry:SetShowSelfIndicator(true)
  end
end
function Leaderboard:SetRemainingTimeText(timeText)
  UiTextBus.Event.SetTextWithFlags(self.HeaderTime, timeText, eUiTextSet_SetAsIs)
end
function Leaderboard:SetLeaderGuildCrestChangeCallback(cb, table)
  self.crestChangeCb = cb
  self.crestChangeTable = table
end
return Leaderboard
