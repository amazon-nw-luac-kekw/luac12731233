local GuildCreationTab = {
  Properties = {
    LandingContents = {
      default = EntityId()
    },
    CreationContents = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    },
    StartCreateCompanyButton = {
      default = EntityId()
    },
    GuildNameInput = {
      default = EntityId()
    },
    GuildNameTitle = {
      default = EntityId()
    },
    GuildNameInputValid = {
      default = EntityId()
    },
    GuildNameInputInvalid = {
      default = EntityId()
    },
    GuildNameInputPlaceholder = {
      default = EntityId()
    },
    TerritoryOwnershipButton = {
      default = EntityId()
    },
    FinalizeCreateCompanyButton = {
      default = EntityId()
    },
    CancelCreateCompany = {
      default = EntityId()
    },
    CrestCreation = {
      default = EntityId()
    },
    CreationErrorText = {
      default = EntityId()
    },
    LandingContentsTitleLine = {
      default = EntityId()
    }
  },
  hasGeneratedRandomCrest = false,
  guildNameInputDelay = 1,
  guildNameInputTimer = 0,
  isGuildNameInputSpinning = false,
  guildNameInputResult = {
    Success = 1,
    Requesting = 2,
    ErrorEmptyString = 3,
    ErrorInvalid = 4,
    ErrorNameTaken = 5,
    ErrorRequestFailed = 6,
    ErrorProfanityFilter = 7
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(GuildCreationTab)
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function GuildCreationTab:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.StartCreateCompanyButton:SetCallback(self.StartCreateCompany, self)
  self.FinalizeCreateCompanyButton:SetText("@ui_create_company")
  self.FinalizeCreateCompanyButton:SetCallback(self.CreateCompany, self)
  self.FinalizeCreateCompanyButton:SetButtonStyle(self.FinalizeCreateCompanyButton.BUTTON_STYLE_HERO)
  self.CancelCreateCompany:SetText("@ui_cancel")
  self.CancelCreateCompany:SetCallback(self.CancelCreate, self)
  self:BusConnect(UiTextInputNotificationBus, self.Properties.GuildNameInput)
  UiElementBus.Event.SetIsEnabled(self.Properties.LandingContents, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.CreationContents, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CreationErrorText, false)
  local territoryIncentivesEnabled = ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enable-territory-incentives-screen")
  UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryOwnershipButton, territoryIncentivesEnabled)
  if territoryIncentivesEnabled then
    self.TerritoryOwnershipButton:SetCallback(self.OnTerritoryOwnershipPressed, self)
  end
  self.LandingContentsTitleLine:SetColor(self.UIStyle.COLOR_TAN)
  if self.Properties.Spinner:IsValid() then
    self.ScriptedEntityTweener:Set(self.Properties.Spinner, {rotation = 0, opacity = 0})
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootPlayerId)
    if rootPlayerId then
      self.rootPlayerId = rootPlayerId
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, factionType)
    local inFaction = factionType and factionType ~= eFactionType_None
    local isInDungeon = false
    if self.rootPlayerId then
      isInDungeon = GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeId(self.rootPlayerId) ~= 0
    end
    self.StartCreateCompanyButton:SetText(inFaction and "@ui_create_company" or "@ui_create_company_with_faction")
    self.StartCreateCompanyButton:SetButtonStyle(inFaction and self.StartCreateCompanyButton.BUTTON_STYLE_CTA or self.StartCreateCompanyButton.BUTTON_STYLE_BLOCKED)
    self.StartCreateCompanyButton:SetEnabled(inFaction and not isInDungeon)
    if isInDungeon then
      self.StartCreateCompanyButton:SetTooltip("@ui_create_company_request_dungeon_tooltip")
    else
      self.StartCreateCompanyButton:SetTooltip("")
    end
  end)
  SetTextStyle(self.Properties.GuildNameTitle, self.UIStyle.FONT_STYLE_TITLE_GENERIC_SMALL)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.NameLength", function(self, maxlength)
    if maxlength then
      UiTextInputBus.Event.SetMaxStringLength(self.Properties.GuildNameInput, maxlength)
    end
  end)
end
function GuildCreationTab:OnShutdown()
end
function GuildCreationTab:OnTick(deltaTime, timePoint)
  self.guildNameInputTimer = self.guildNameInputTimer + deltaTime
  if self.guildNameInputTimer > self.guildNameInputDelay then
    socialDataHandler:RequestGuildNameAvailability_ServerCall(self, function(self, name, success)
      if success then
        self:SetTextInputVisualFeedback(self.guildNameInputResult.Success)
      else
        self:SetTextInputVisualFeedback(self.guildNameInputResult.ErrorNameTaken)
      end
      self:StopSpinner()
    end, function(self, reason)
      if reason == eSocialRequestFailureReasonUsingBadWords then
        self:SetTextInputVisualFeedback(self.guildNameInputResult.ErrorProfanityFilter)
      else
        self:SetTextInputVisualFeedback(self.guildNameInputResult.ErrorRequestFailed)
      end
      self:StopSpinner()
    end, self.currentText)
    self:StopTick()
  end
end
function GuildCreationTab:StartTick()
  if self.tickHandler == nil then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function GuildCreationTab:StopTick()
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function GuildCreationTab:TransitionIn()
  self.FinalizeCreateCompanyButton:StartStopImageSequence(true)
  self:SetContentsVisible(self.Properties.LandingContents)
end
function GuildCreationTab:SetContentsVisible(contentsEntity)
  if contentsEntity == self.Properties.LandingContents then
    self.ScriptedEntityTweener:PlayC(self.Properties.CreationContents, 0.15, tweenerCommon.fadeOutQuadIn, nil, function()
      UiElementBus.Event.SetIsEnabled(self.Properties.CreationContents, false)
    end)
    UiElementBus.Event.SetIsEnabled(self.Properties.LandingContents, true)
    self.ScriptedEntityTweener:PlayC(self.Properties.LandingContents, 0.15, tweenerCommon.fadeInQuadOut, 0.15)
    self.LandingContentsTitleLine:SetVisible(false, 0)
    self.LandingContentsTitleLine:SetVisible(true, 1.2)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.LandingContents, 0.15, tweenerCommon.fadeOutQuadIn, nil, function()
      UiElementBus.Event.SetIsEnabled(self.Properties.LandingContents, false)
    end)
    UiElementBus.Event.SetIsEnabled(self.Properties.CreationContents, true)
    self.ScriptedEntityTweener:PlayC(self.Properties.CreationContents, 0.15, tweenerCommon.fadeInQuadOut, 0.15)
    self.CrestCreation:SetScreenVisible(true)
  end
end
function GuildCreationTab:StartCreateCompany()
  self:SetContentsVisible(self.Properties.CreationContents)
  if not self.hasGeneratedRandomCrest then
    self.CrestCreation:RandomizeCrest()
    self:OnTextInputChange(UiTextInputBus.Event.GetText(self.Properties.GuildNameInput))
    self.hasGeneratedRandomCrest = true
  end
end
function GuildCreationTab:CreateCompany()
  local guildName = UiTextInputBus.Event.GetText(self.Properties.GuildNameInput)
  if GuildsComponentBus.Broadcast.IsValidGuildName(guildName, true) then
    DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(true)
    socialDataHandler:RequestGuildNameAvailability_ServerCall(self, function(self, name, success)
      if success then
        local crestData = self.CrestCreation:GetCrestData()
        GuildsComponentBus.Broadcast.RequestCreateGuild(guildName, crestData)
        UiTextInputBus.Event.SetText(self.Properties.GuildNameInput, "")
        self:SetTextInputVisualFeedback(self.guildNameInputResult.ErrorEmptyString)
      else
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = "@ui_guild_creation_failed"
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
      end
    end, function()
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@ui_guild_creation_failed"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
    end, guildName)
  end
end
function GuildCreationTab:CancelCreate()
  self:SetContentsVisible(self.Properties.LandingContents)
end
function GuildCreationTab:StartSpinner()
  if self.Properties.Spinner:IsValid() and not self.isGuildNameInputSpinning then
    self.ScriptedEntityTweener:Play(self.Properties.Spinner, 1, {rotation = 0, opacity = 1}, {timesToPlay = -1, rotation = 359})
    self.isGuildNameInputSpinning = true
  end
end
function GuildCreationTab:StopSpinner()
  if self.Properties.Spinner:IsValid() and self.isGuildNameInputSpinning then
    self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
    self.ScriptedEntityTweener:Set(self.Properties.Spinner, {rotation = 0, opacity = 0})
    self.isGuildNameInputSpinning = false
  end
end
function GuildCreationTab:SetTextInputVisualFeedback(guildNameInputResult)
  local success = guildNameInputResult == self.guildNameInputResult.Success
  local emptyString = guildNameInputResult == self.guildNameInputResult.ErrorEmptyString
  local requesting = guildNameInputResult == self.guildNameInputResult.Requesting
  if guildNameInputResult == self.guildNameInputResult.ErrorNameInvalid then
    UiTextBus.Event.SetTextWithFlags(self.Properties.CreationErrorText, "@ui_create_company_invalid_name", eUiTextSet_SetLocalized)
  elseif guildNameInputResult == self.guildNameInputResult.ErrorNameTaken then
    UiTextBus.Event.SetTextWithFlags(self.Properties.CreationErrorText, "@ui_create_company_invalid_name_taken", eUiTextSet_SetLocalized)
  elseif guildNameInputResult == self.guildNameInputResult.ErrorRequestFailed then
    UiTextBus.Event.SetTextWithFlags(self.Properties.CreationErrorText, "@ui_create_company_request_failed", eUiTextSet_SetLocalized)
  elseif guildNameInputResult == self.guildNameInputResult.ErrorProfanityFilter then
    UiTextBus.Event.SetTextWithFlags(self.Properties.CreationErrorText, "@mm_invalidname_badwords", eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildNameInputPlaceholder, emptyString)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildNameInputValid, success)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildNameInputInvalid, not success and not emptyString and not requesting)
  UiElementBus.Event.SetIsEnabled(self.Properties.CreationErrorText, not success and not emptyString and not requesting)
  self.FinalizeCreateCompanyButton:SetEnabled(success)
end
function GuildCreationTab:OnTextInputChange(textString)
  textString = textString or ""
  if textString == self.currentText then
    return
  end
  self.currentText = textString
  if textString == "" then
    self:SetTextInputVisualFeedback(self.guildNameInputResult.ErrorEmptyString)
    self:StopSpinner()
    self:StopTick()
  elseif not GuildsComponentBus.Broadcast.IsValidGuildName(textString, false) then
    self:SetTextInputVisualFeedback(self.guildNameInputResult.ErrorNameInvalid)
    self:StopSpinner()
    self:StopTick()
  else
    self:SetTextInputVisualFeedback(self.guildNameInputResult.Requesting)
    self.guildNameInputTimer = 0
    self:StartSpinner()
    self:StartTick()
  end
end
function GuildCreationTab:OnTextInputStartEdit()
  SetActionmapsForTextInput(self.canvasId, true)
end
function GuildCreationTab:OnTextInputEndEdit()
  SetActionmapsForTextInput(self.canvasId, false)
end
function GuildCreationTab:OnTextInputEnter()
  self:CreateCompany()
end
function GuildCreationTab:OnTerritoryOwnershipPressed()
  local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  DynamicBus.TerritoryIncentivesNotifications.Broadcast.OnRequestTerritoryIncentivesScreen(territoryId)
end
return GuildCreationTab
