local OtherGuildListItem = {
  Properties = {
    Arcana = {
      default = EntityId()
    },
    CrestIcon = {
      default = EntityId()
    },
    AtWarIndicator = {
      default = EntityId()
    },
    GuildNameText = {
      default = EntityId()
    },
    GuildLeaderLabel = {
      default = EntityId()
    },
    GuildLeaderName = {
      default = EntityId()
    },
    MembersLabel = {
      default = EntityId()
    },
    MembersText = {
      default = EntityId()
    },
    ClaimsLabel = {
      default = EntityId()
    },
    ClaimsText = {
      default = EntityId()
    }
  },
  guildId = GuildId(),
  lastTimeRemainingSeconds = -1,
  memberSizeGroups = {
    {1, 5},
    {6, 10},
    {11, 25},
    {26, 40},
    {41, 50}
  },
  WAR_TEXT_COUNTER_ATTACK_POS_Y = 12,
  WAR_TEXT_NO_COUNTER_ATTACK_POS_Y = 39
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OtherGuildListItem)
local warDeclarationPopupHelper = RequireScript("LyShineUI.WarDeclaration.WarDeclarationPopupHelper")
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function OtherGuildListItem:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  local coinIconPath = "LyShineUI\\Images\\Icon_Crown"
  local coinIconXPadding = 5
  self.coinImgText = string.format("<img src=\"%s\" xPadding=\"%d\"></img>", coinIconPath, coinIconXPadding)
end
function OtherGuildListItem:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  self.dataLayer = nil
  self.socialDataHandler:OnDeactivate()
end
function OtherGuildListItem:OnUpdateCurrency(currencyAmount)
end
function OtherGuildListItem:SetData(data)
  self.data = data
  self.CrestIcon:SetSmallIcon(data.crestData)
  UiTextBus.Event.SetText(self.GuildNameText, data.guildName)
  UiTextBus.Event.SetText(self.GuildLeaderName, "")
  self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnSetData_OnPlayerIdReady, self.OnPlayerIdFailed, data.guildMasterCharacterIdString)
  self.isLocalPlayerGuild = data.isLocalPlayerGuild
  UiElementBus.Event.SetIsEnabled(self.Arcana, self.isLocalPlayerGuild)
  if self.isLocalPlayerGuild then
    UiImageBus.Event.SetColor(self.Arcana, data.crestData.foregroundColor)
  end
  if data.numMembers == 0 then
    UiTextBus.Event.SetText(self.Properties.MembersText, "0")
  else
    local sizeGroup
    for _, sizeGroupToCheck in ipairs(self.memberSizeGroups) do
      if data.numMembers >= sizeGroupToCheck[1] and data.numMembers <= sizeGroupToCheck[2] then
        sizeGroup = sizeGroupToCheck
        break
      end
    end
    if sizeGroup ~= nil then
      local membersString = GetLocalizedReplacementText("@ui_otherguilds_list_members", {
        numberLow = sizeGroup[1],
        numberHigh = sizeGroup[2]
      })
      UiTextBus.Event.SetText(self.MembersText, membersString)
    else
      UiTextBus.Event.SetText(self.MembersText, "51+")
    end
  end
  UiTextBus.Event.SetText(self.ClaimsText, data.numClaims)
  UiTextBus.Event.SetTextWithFlags(self.ClaimsLabel, data.numClaims == 1 and "@ui_otherguilds_claimslabelsingular" or "@ui_otherguilds_claimslabel", eUiTextSet_SetLocalized)
  self.isAtWar = data.isAtWar
  UiElementBus.Event.SetIsEnabled(self.AtWarIndicator, data.isAtWar)
end
function OtherGuildListItem:GetIsAtWar()
  return self.isAtWar
end
function OtherGuildListItem:OnPlayerIdFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - OtherGuildListItem:OnPlayerIdFailed: Throttled.")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - OtherGuildListItem:OnPlayerIdFailed: Timed Out.")
  end
end
function OtherGuildListItem:OnPlayerIdReady(result)
  local playerId
  if 0 < #result then
    playerId = result[1].playerId
  else
    Log("ERR - OtherGuildListItem:OnPlayerIdReady: Player not found.")
    return
  end
  return playerId
end
function OtherGuildListItem:OnSetData_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    UiTextBus.Event.SetText(self.GuildLeaderName, playerId.playerName)
  end
end
return OtherGuildListItem
