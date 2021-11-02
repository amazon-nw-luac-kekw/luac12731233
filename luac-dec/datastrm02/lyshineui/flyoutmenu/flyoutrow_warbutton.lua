local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local FlyoutRow_WarButton = {
  Properties = {
    Button = {
      default = EntityId()
    },
    NoButtonText = {
      default = EntityId()
    }
  },
  declareWarTemplate = "@ui_declarewarwithcost",
  callback = nil,
  callbackTable = nil,
  warEndTimePoint = WallClockTimePoint(),
  lastwarTimeRemainingSeconds = -1,
  canModifyWar = false,
  coinIconPath = "LyShineUI\\Images\\Icon_Crown",
  coinIconXPadding = 5,
  additionalButtonHeight = 15
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_WarButton)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function FlyoutRow_WarButton:OnInit()
  BaseElement.OnInit(self)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.timeHelpers = timeHelpers
  self.coinImgText = string.format("<img src=\"%s\" xPadding=\"%d\" yOffset=\"3\"></img>", self.coinIconPath, self.coinIconXPadding)
  self.Button:SetTooltip("@ui_war_cost_info")
  self.Button:SetButtonStyle(self.Button.BUTTON_STYLE_CTA)
end
function FlyoutRow_WarButton:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  self.socialDataHandler:OnDeactivate()
  self.socialDataHandler = nil
end
function FlyoutRow_WarButton:OnMenuClosed()
  self.dataLayer:UnregisterObservers(self)
  self:StopTick()
end
function FlyoutRow_WarButton:SetData(data)
  if not data or not data.guildId and not data.settlementKey then
    Log("[FlyoutRow_WarButton] Error: invalid data passed to SetData")
    return
  end
  if data.guildId ~= nil then
    self.guildId = data.guildId
  elseif data.settlementKey ~= nil then
    self.settlementKey = data.settlementKey
    if self.landClaimHandler then
      self:BusDisconnect(self.landClaimHandler)
    end
    self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.settlementKey)
    local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.settlementKey)
    self.guildId = ownerData.guildId
  end
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Guild.Id", self.UpdateGuildWarState)
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", self.UpdateGuildWarState)
  self:SetCallback(data.callback, data.callbackTable)
  self.Button:SetCallback(self.OnButtonClick, self)
  self:UpdateGuildWarState()
end
function FlyoutRow_WarButton:OnTick(deltaTime, timePoint)
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  local warTimeRemainingSeconds = self.warEndTimePoint:Subtract(now):ToSeconds()
  if warTimeRemainingSeconds ~= self.lastwarTimeRemainingSeconds then
    if warTimeRemainingSeconds <= 0 then
      return
    end
    self.lastwarTimeRemainingSeconds = warTimeRemainingSeconds
  end
end
function FlyoutRow_WarButton:StartTick()
  if self.tickHandler == nil then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function FlyoutRow_WarButton:StopTick()
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function FlyoutRow_WarButton:IsWarButtonClickable()
  local warDetails = dominionCommon:GetWarDetailsFromGuildId(self.guildId)
  if warDetails == nil then
    return false
  end
  local warCampTier = 0
  return WarRequestBus.Broadcast.CanDeclareWar(self.guildId, self.settlementKey, warCampTier) == eCanDeclareWarReturnResult_Success
end
function FlyoutRow_WarButton:OnClaimOwnerChanged(claimKey, newOwnerData)
  if claimKey ~= self.settlementKey then
    return
  end
  self:UpdateOwnership(newOwnerData.guildId)
end
function FlyoutRow_WarButton:UpdateOwnership(newGuildId)
  self.guildId = newGuildId
  self:UpdateGuildWarState()
end
function FlyoutRow_WarButton:UpdateGuildWarState()
  local function warCostSuccessCallback(self, warDeclarationCost)
    local isAtWar = IsAtWarWithGuild(self.guildId)
    local warCost = warDeclarationCost
    local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(WarDataClientRequestBus.Broadcast.GetWarId(self.guildId))
    local isAttacker = warDetails and warDetails:GetAttackerGuildId() == self.guildId
    self.isShowingButton = not isAtWar
    UiElementBus.Event.SetIsEnabled(self.Button.entityId, self.isShowingButton)
    UiElementBus.Event.SetIsEnabled(self.NoButtonText, not self.isShowingButton)
    if self.isShowingButton then
      self:UpdateWarCostText(warCost)
      self.Button:SetEnabled(self:IsWarButtonClickable())
    end
    if isAtWar then
      self.canModifyWar = CanModifyWarWithGuild(self.guildId)
      local warCalendar = warDetails:GetRemainingWarSchedule()
      self.warEndTimePoint = nil
      for i = #warCalendar, 1, -1 do
        if warCalendar[i]:GetWarPhase() == eWarPhase_Resolution then
          if 1 < i then
            self.warEndTimePoint = warCalendar[i - 1]:GetPhaseEndTime()
          end
          break
        end
      end
      if self.warEndTimePoint == nil then
        self.warEndTimePoint = warDetails:GetWarEndTime()
      end
      if self.isShowingButton then
        self.Button:SetTooltip("@ui_war_cost_info")
      end
    else
      self.Button:SetText(self.declareWarText)
      local tooltip = dominionCommon:GetWarDeclarationRequirementText(self.guildId, warCost)
      self.Button:SetTooltip(tooltip)
    end
  end
  if not self.socialDataHandler:GetWarCost_ServerCall(self, warCostSuccessCallback, nil, self.guildId) then
    self.Button:SetEnabled(false)
    UiInteractableBus.Event.SetIsHandlingEvents(self.Button.entityId, true)
    self:UpdateWarCostText(0)
  end
end
function FlyoutRow_WarButton:UpdateWarCostText(warCost)
  if 0 < warCost then
    warCost = GetLocalizedCurrency(warCost)
  else
    warCost = "-"
  end
  local costText = string.format("<font color=%s face=\"%s\">%s</font>", ColorRgbaToHexString(self.UIStyle.COLOR_WHITE), self.UIStyle.FONT_FAMILY_CASLON, warCost)
  self.locKeys = vector_basic_string_char_char_traits_char()
  self.locKeys:push_back("coinImage")
  self.locKeys:push_back("cost")
  self.locValues = vector_basic_string_char_char_traits_char()
  self.locValues:push_back(self.coinImgText)
  self.locValues:push_back(costText)
  self.declareWarText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements(self.declareWarTemplate, self.locKeys, self.locValues)
  self.locKeys:push_back("timeRemaining")
  self.locValues:push_back("")
end
function FlyoutRow_WarButton:SetCallback(command, table)
  self.callback = command
  self.table = table
end
function FlyoutRow_WarButton:ExecuteCallback()
  if self.callback and self.table then
    if type(self.callback) == "function" then
      self.callback(self.table)
    elseif type(self.table[self.callback]) == "function" then
      self.table[self.callback](self.table)
    end
  end
end
function FlyoutRow_WarButton:OnButtonClick()
  self:ExecuteCallback()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
end
return FlyoutRow_WarButton
