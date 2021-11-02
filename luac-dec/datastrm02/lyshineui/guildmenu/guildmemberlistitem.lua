local GuildMemberListItem = {
  Properties = {
    PlayerIcon = {
      default = EntityId()
    },
    MemberName = {
      default = EntityId()
    },
    MemberRank = {
      default = EntityId()
    },
    MemberRankNumber = {
      default = EntityId()
    },
    MemberStatus = {
      default = EntityId()
    },
    MemberStatusIndicator = {
      default = EntityId()
    },
    RankChangeDropdown = {
      default = EntityId()
    },
    KickButton = {
      default = EntityId()
    },
    LocalPlayerIndicator = {
      default = EntityId()
    }
  },
  isOnline = false,
  buttonColorChangeTime = 0.2,
  lowestRank = 6
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(GuildMemberListItem)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function GuildMemberListItem:OnInit()
  BaseElement.OnInit(self)
  if not self.KickButton or type(self.KickButton) ~= "table" then
    return
  end
  self.rankDropdownListData = {}
  self.KickButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE_SMALL)
  self.KickButton:SetCallback(self.OnKick, self)
  self.RankChangeDropdown:SetText("@ui_changerank")
  self.RankChangeDropdown:SetCallback(self.OnRankDropdownSelected, self)
  self.RankChangeDropdown:SetPreOpenCallback(self.OnRankDropdownOpen, self)
  self.RankChangeDropdown:SetCloseCallback(function(self)
    DynamicBus.GuildMemberListItem.Broadcast.SetOtherDropdownEnabled(true)
  end, self)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    if setLang and self.guildComponentActive then
      self:InitRankChangeDropdown()
    end
  end)
  self.guildComponentActive = false
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Enabled", function(self, enabled)
    if enabled then
      self.guildComponentActive = enabled
      self:InitRankChangeDropdown()
    end
  end)
  self.PlayerIcon:SetRefreshDataOnFlyout(true)
  DynamicBus.GuildMemberListItem.Connect(self.entityId, self)
end
function GuildMemberListItem:OnShutdown()
  DynamicBus.GuildMemberListItem.Disconnect(self.entityId, self)
end
function GuildMemberListItem:InitRankChangeDropdown()
  local numRanks = GuildsComponentBus.Broadcast.GetNumRanks()
  ClearTable(self.rankDropdownListData)
  for i = 0, numRanks - 1 do
    table.insert(self.rankDropdownListData, {
      text = GuildsComponentBus.Broadcast.GetRankName(i),
      newRank = i
    })
  end
  self.RankChangeDropdown:SetDropdownListHeightByRows(#self.rankDropdownListData)
  self.RankChangeDropdown:SetListData(self.rankDropdownListData)
end
function GuildMemberListItem:OnRankDropdownOpen(entityId)
  local holder = UiElementBus.Event.GetParent(self.entityId)
  holder = UiElementBus.Event.GetParent(holder)
  local holderRect = UiTransformBus.Event.GetViewportSpaceRect(holder)
  local toViewportPosition = UiTransformBus.Event.GetViewportPosition(self.entityId)
  self.RankChangeDropdown:SetForceOpenUpwards(toViewportPosition.y > holderRect:GetCenterY())
  DynamicBus.GuildMemberListItem.Broadcast.HideRankChangeDropdown()
  DynamicBus.GuildMemberListItem.Broadcast.SetOtherDropdownEnabled(false)
  self:SetOtherDropdownEnabled(true)
end
function GuildMemberListItem:SetOtherDropdownEnabled(isEnabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.RankChangeDropdown, isEnabled and self.rankChangeEnabled)
end
function GuildMemberListItem:SetGuildMenuEntityId(entityId)
  if self.guildMenuEntityId ~= entityId then
    self.guildMenuEntityId = entityId
    self.RankChangeDropdown:SetDropdownScreenCanvasId(entityId)
  end
end
function GuildMemberListItem:SetName(value)
  UiTextBus.Event.SetText(self.Properties.MemberName, value)
end
function GuildMemberListItem:SetRank(value, number)
  number = number ~= nil and number or ""
  UiTextBus.Event.SetTextWithFlags(self.Properties.MemberRank, value, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(self.Properties.MemberRankNumber, number .. ".")
end
function GuildMemberListItem:SetOfflineText()
  if self.lastOnlineTime then
    local timeSinceLastOnline = timeHelpers:ServerNow():Subtract(self.lastOnlineTime):ToSeconds()
    local localizedTime = timeHelpers:ConvertToLargestTimeEstimate(timeSinceLastOnline)
    local text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_offline_time", localizedTime)
    UiTextBus.Event.SetText(self.Properties.MemberStatus, text)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.MemberStatus, "@ui_offline", eUiTextSet_SetLocalized)
  end
end
function GuildMemberListItem:SetIsOnline(isOnline)
  if self.isOnline ~= isOnline then
    UiElementBus.Event.SetIsEnabled(self.Properties.MemberStatusIndicator, isOnline)
    if isOnline then
      self.lastOnlineTime = nil
      UiTextBus.Event.SetTextWithFlags(self.Properties.MemberStatus, "@ui_online", eUiTextSet_SetLocalized)
    else
      self:SetOfflineText()
    end
    self.isOnline = isOnline
  end
end
function GuildMemberListItem:SetLastOnlineTime(lastOnlineTime)
  self.lastOnlineTime = lastOnlineTime
  if lastOnlineTime and lastOnlineTime:IsZero() then
    self.lastOnlineTime = nil
  end
  if not self.isOnline then
    self:SetOfflineText()
  end
end
function GuildMemberListItem:SetPlayerIconId(playerId)
  self.PlayerIcon:SetPlayerId(playerId)
end
function GuildMemberListItem:SetRankChangeCallback(cb, cbTable)
  self.rankChangeCb = cb
  self.rankChangeCbTable = cbTable
end
function GuildMemberListItem:SetCanKick(canKick)
  if canKick then
    self.KickButton:SetTextColor(self.UIStyle.COLOR_WHITE, self.buttonColorChangeTime)
  else
    self.KickButton:SetTextColor(self.UIStyle.COLOR_GRAY_50, self.buttonColorChangeTime)
  end
  self.KickButton:SetIsClickable(canKick)
end
function GuildMemberListItem:SetKickCallback(fn, fnTable)
  self.kickCallback = fn
  self.kickCallbackTable = fnTable
end
function GuildMemberListItem:SetKickTooltip(value)
  self.KickButton:SetTooltip(value)
end
function GuildMemberListItem:OnKick()
  if self.kickCallback and self.kickCallbackTable then
    self.kickCallback(self.kickCallbackTable)
  end
end
function GuildMemberListItem:SetIsLocalPlayer(value)
  self:SetButtonsShowing(not value)
  UiElementBus.Event.SetIsEnabled(self.Properties.LocalPlayerIndicator, value)
end
function GuildMemberListItem:SetButtonsShowing(value)
  self.rankChangeEnabled = value
  UiElementBus.Event.SetIsEnabled(self.Properties.RankChangeDropdown, value)
  UiElementBus.Event.SetIsEnabled(self.Properties.KickButton, value)
end
function GuildMemberListItem:HideRankChangeDropdown()
  UiDropdownBus.Event.Collapse(self.Properties.RankChangeDropdown)
end
function GuildMemberListItem:UpdateRankChangeDropdown(memberCharacterId, memberRank, localPlayerRank, hasPromotePrivilege, hasDemotePrivilege, isAtWar)
  local hasValidEntry = false
  local numRanks = GuildsComponentBus.Broadcast.GetNumRanks()
  for rankIndex = 0, numRanks - 1 do
    local tooltip
    local isValid = GuildsComponentBus.Broadcast.CanSetMemberRank(memberCharacterId, rankIndex)
    local itemIndex = rankIndex + 1
    if rankIndex < memberRank then
      if not isValid then
        if not hasPromotePrivilege then
          tooltip = "@ui_cantpromote_lackpermission"
        elseif memberRank == 0 then
          tooltip = "@ui_cantpromote_maxrank"
        elseif localPlayerRank == 0 and memberRank == 1 and isAtWar then
          tooltip = "@ui_cantpromote_leaderatwar"
        else
          tooltip = "@ui_cantpromote_lackpermissionforrank"
        end
      end
    elseif memberRank < rankIndex then
      if not isValid then
        if not hasDemotePrivilege then
          tooltip = "@ui_cantdemote_lackpermission"
        elseif memberRank == self.lowestRank then
          tooltip = "@ui_cantdemote_lowestrank"
        else
          tooltip = "@ui_cantdemote_lackpermissionforrank"
        end
      end
    else
      tooltip = "@ui_cantchangerank_iscurrentrank"
      self.RankChangeDropdown:SetSelectedItemData(self.rankDropdownListData[itemIndex])
      self.RankChangeDropdown:SetText("@ui_changerank")
    end
    self.RankChangeDropdown:SetListItemEnabled(itemIndex, isValid)
    self.RankChangeDropdown:SetListItemTooltip(itemIndex, tooltip)
    if isValid then
      hasValidEntry = true
    end
  end
  self.rankChangeEnabled = hasValidEntry
  UiElementBus.Event.SetIsEnabled(self.Properties.RankChangeDropdown, hasValidEntry)
end
function GuildMemberListItem:OnRankDropdownSelected(item, itemData)
  self.RankChangeDropdown:SetText("@ui_changerank")
  if self.rankChangeCb ~= nil and self.rankChangeCbTable ~= nil then
    self.rankChangeCb(self.rankChangeCbTable, itemData.newRank)
  end
end
return GuildMemberListItem
