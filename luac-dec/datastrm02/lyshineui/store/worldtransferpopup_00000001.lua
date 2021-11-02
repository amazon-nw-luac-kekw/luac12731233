local WorldTransferPopup = {
  Properties = {
    StoreScreenContainer = {
      default = EntityId()
    },
    StorePopupContainer = {
      default = EntityId()
    },
    PopupContainer = {
      default = EntityId()
    },
    ScreenHeader = {
      default = EntityId()
    },
    RefreshButton = {
      default = EntityId()
    },
    RefreshButtonBg = {
      default = EntityId()
    },
    RefreshButtonIcon = {
      default = EntityId()
    },
    WorldSelectionList = {
      Container = {
        default = EntityId()
      },
      ContinueButton = {
        default = EntityId()
      },
      QuestionMark = {
        default = EntityId()
      },
      RegionName = {
        default = EntityId()
      },
      RegionLabel = {
        default = EntityId()
      },
      ServerSortNameButton = {
        default = EntityId()
      },
      ServerSortWorldSetButton = {
        default = EntityId()
      },
      ServerSortCharacterNameButton = {
        default = EntityId()
      },
      ServerSortWaitTimeButton = {
        default = EntityId()
      },
      ServerSortPopulationButton = {
        default = EntityId()
      },
      ServerSortFriendsButton = {
        default = EntityId()
      },
      ServerSortQueueSize = {
        default = EntityId()
      },
      ServerSortWorldSetLabel = {
        default = EntityId()
      },
      ServerSortWorldSetTooltip = {
        default = EntityId()
      },
      ServerList = {
        default = EntityId()
      },
      ServerContentBoxHolder = {
        default = EntityId()
      },
      ServerContentBox = {
        default = EntityId()
      },
      ServerContentBoxMask = {
        default = EntityId()
      },
      StatusSpinnerEntity = {
        default = EntityId()
      },
      FailedConnectionEntity = {
        default = EntityId()
      },
      CurrentWorldText = {
        default = EntityId()
      },
      CurrentWorldTextLabel = {
        default = EntityId()
      }
    },
    WorldSelectionWarning = {
      Container = {
        default = EntityId()
      },
      PopupBackground = {
        default = EntityId()
      },
      PopupContainer = {
        default = EntityId()
      },
      Button1 = {
        default = EntityId()
      },
      Button2 = {
        default = EntityId()
      },
      CloseButton = {
        default = EntityId()
      },
      FrameHeader = {
        default = EntityId()
      },
      TransferText = {
        default = EntityId()
      },
      DescriptionText1 = {
        default = EntityId()
      },
      DescriptionText2 = {
        default = EntityId()
      },
      DescriptionText3 = {
        default = EntityId()
      },
      DescriptionText6 = {
        default = EntityId()
      },
      TextFAQ = {
        default = EntityId()
      },
      Header1 = {
        default = EntityId()
      },
      Header2 = {
        default = EntityId()
      },
      FinalDetails = {
        default = EntityId()
      }
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WorldTransferPopup)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local worldListCommon = RequireScript("LyShineUI._Common.WorldListCommon")
local CanvasCommon = RequireScript("LyShineUI._Common.CanvasCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local BitwiseHelpers = RequireScript("LyShineUI._Common.BitwiseHelpers")
local sellOrdersStatusEnum = {
  Unknown = 1,
  Outstanding = 2,
  None = 3
}
function WorldTransferPopup:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HasSanctuary", function(self, isSanctuary)
    if isSanctuary ~= self.isSanctuary then
      self.isSanctuary = isSanctuary
      self:UpdateWorldSelectionWarningEnabled()
    end
  end)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.Container, false)
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionWarning.Container, false)
  self.WorldSelectionList.ContinueButton:SetText("@server_transfer_select_world")
  self.WorldSelectionList.ContinueButton:SetCallback(self.OnWorldSelectContinuePressed, self)
  self.WorldSelectionList.ContinueButton:SetButtonStyle(self.WorldSelectionList.ContinueButton.BUTTON_STYLE_HERO)
  self.WorldSelectionList.ContinueButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnPlayHover)
  self.WorldSelectionList.ContinueButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnPlayPress)
  self.WorldSelectionList.ContinueButton:StartStopImageSequence(false)
  self.WorldSelectionList.QuestionMark:SetButtonStyle(self.WorldSelectionList.QuestionMark.BUTTON_STYLE_QUESTION_MARK)
  self.WorldSelectionList.QuestionMark:SetTooltip("@server_transfer_region_hint")
  self.WorldSelectionWarning.Button1:SetText("@ui_cancel")
  self.WorldSelectionWarning.Button1:SetCallback(self.OnWorldSelectionWarningClose, self)
  self.WorldSelectionWarning.Button2:SetButtonStyle(self.WorldSelectionWarning.Button2.BUTTON_STYLE_CTA)
  self.WorldSelectionWarning.Button2:SetText("@server_transfer_confirm_button")
  self.WorldSelectionWarning.Button2:SetCallback(self.OnConfirmWorldTransfer, self)
  self.WorldSelectionWarning.CloseButton:SetCallback(self.OnWorldSelectionWarningClose, self)
  self.WorldSelectionWarning.FrameHeader:SetTextMarkupEnabled(true)
  self.WorldSelectionWarning.FrameHeader:SetTextShrinkToFit(eUiTextShrinkToFit_None)
  self.WorldSelectionWarning.FrameHeader:SetText("@server_transfer_confirm")
  self.WorldSelectionWarning.FrameHeader:SetTextAlignment(self.WorldSelectionWarning.FrameHeader.TEXT_ALIGN_CENTER)
  self.initialDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
  self.ScreenHeader:SetHintCallback(self.ClosePopup, self)
  self.ScreenHeader:SetText("@ui_character_world_transfer")
  self.WorldSelectionList.QuestionMark:SetSize(32)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  UiRadioButtonGroupBus.Event.SetAllowUncheck(self.WorldSelectionList.ServerList, true)
  SetTextStyle(self.WorldSelectionList.RegionName, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_REGION_NAME)
  SetTextStyle(self.WorldSelectionList.RegionLabel, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_REGION_LABEL)
  SetTextStyle(self.WorldSelectionList.CurrentWorldText, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_REGION_NAME)
  SetTextStyle(self.WorldSelectionList.CurrentWorldTextLabel, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_REGION_LABEL)
  SetTextStyle(self.WorldSelectionWarning.TransferText, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_TEXT)
  SetTextStyle(self.WorldSelectionWarning.DescriptionText1, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_BODY)
  SetTextStyle(self.WorldSelectionWarning.DescriptionText2, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_BODY)
  SetTextStyle(self.WorldSelectionWarning.DescriptionText3, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_BODY)
  SetTextStyle(self.WorldSelectionWarning.DescriptionText6, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_BODY)
  SetTextStyle(self.WorldSelectionWarning.TextFAQ, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_BODY)
  SetTextStyle(self.WorldSelectionWarning.Header1, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_SUBHEADER)
  SetTextStyle(self.WorldSelectionWarning.Header2, self.UIStyle.FONT_STYLE_SERVER_TRANSFER_SUBHEADER)
end
function WorldTransferPopup:OnShutdown()
  self.WorldSelectionList.ContinueButton:StartStopImageSequence(false)
  if self.WorldSelectionList.StatusSpinnerEntity:IsValid() then
    self.ScriptedEntityTweener:Stop(self.WorldSelectionList.StatusSpinnerEntity)
  end
end
function WorldTransferPopup:OnWorldSelectContinuePressed()
  self.showingWorldSelectionWarning = true
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionWarning.Container, true)
  self.ScriptedEntityTweener:Play(self.WorldSelectionWarning.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.WorldSelectionWarning.PopupContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
  local worldName = self.selectedWorld.worldData.name
  local worldSetName = self.selectedWorld.worldSetName
  local localizedText = GetLocalizedReplacementText("@server_transfer_names", {
    playerName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.PlayerName"),
    ServerName = worldName,
    WorldSetName = worldSetName
  })
  UiTextBus.Event.SetTextWithFlags(self.WorldSelectionWarning.TransferText, localizedText, eUiTextSet_SetLocalized)
  self.sellOrdersStatus = sellOrdersStatusEnum.Unknown
  self:UpdateWorldSelectionWarningEnabled()
  self:CheckUserHasOrders(function(self, numOutstanding)
    self.sellOrdersStatus = 0 < numOutstanding and sellOrdersStatusEnum.Outstanding or sellOrdersStatusEnum.None
    self:UpdateWorldSelectionWarningEnabled()
  end, function(self, fail)
    Debug.Log("Failed to get contract status")
  end)
end
function WorldTransferPopup:UpdateWorldSelectionWarningEnabled()
  local disabledReason = ""
  local guildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  local inCompany = guildId and guildId:IsValid()
  if not self.isSanctuary then
    disabledReason = "@server_transfer_requirements_sanctuary\n"
  end
  if inCompany then
    disabledReason = disabledReason .. "@server_transfer_requirements_company\n"
  end
  if self.sellOrdersStatus == sellOrdersStatusEnum.Unknown then
    disabledReason = disabledReason .. "@server_transfer_requirements_tradingPost_unknown"
  elseif self.sellOrdersStatus == sellOrdersStatusEnum.Outstanding then
    disabledReason = disabledReason .. "@server_transfer_requirements_tradingPost"
  end
  self.WorldSelectionWarning.Button2:SetEnabled(disabledReason == "")
  self.WorldSelectionWarning.Button2:SetTooltip(disabledReason)
end
function WorldTransferPopup:OnWorldSelectionWarningClose()
  self.ScriptedEntityTweener:Play(self.WorldSelectionWarning.PopupBackground, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.WorldSelectionWarning.PopupContainer, 0.3, {opacity = 1, y = 0}, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.WorldSelectionWarning.Container, false)
    end
  })
  self.showingWorldSelectionWarning = false
end
function WorldTransferPopup:OnConfirmWorldTransfer()
  if self.selectedWorld and self:IsWorldSelectable(self.selectedWorld) then
    DynamicBus.SocialPaneBus.Broadcast.RejectAllInvites()
    local selectedWorldId = self.selectedWorld.worldData.worldId
    self.onRequestTransferCallback(self.onRequestTransferCaller, selectedWorldId)
  end
end
function WorldTransferPopup:OnRequestWorldTransferPopup(isPurchase, callerSelf, callerFunction)
  self.isPurchase = isPurchase
  self.onRequestTransferCaller = callerSelf
  self.onRequestTransferCallback = callerFunction
  self.isPopupEnabled = true
  self.selectedWorld = nil
  self.WorldSelectionList.ContinueButton:StartStopImageSequence(true)
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionWarning.Container, false)
  self.sortType = worldListCommon.SORT_BYPOPULATION_ASC
  self.sortButtons = {
    {
      button = self.WorldSelectionList.ServerSortNameButton,
      sort = "NAME",
      label = "@ui_world_select_world"
    },
    {
      button = self.WorldSelectionList.ServerSortWorldSetButton,
      sort = "WORLDSET",
      label = "@ui_world_select_world_set"
    },
    {
      button = self.WorldSelectionList.ServerSortCharacterNameButton,
      sort = "CHARACTER",
      label = "@mm_charactercount"
    },
    {
      button = self.WorldSelectionList.ServerSortWaitTimeButton,
      sort = "WAIT",
      label = "@ui_world_select_queue_time"
    },
    {
      button = self.WorldSelectionList.ServerSortPopulationButton,
      sort = "POPULATION",
      label = "@ui_world_select_population"
    },
    {
      button = self.WorldSelectionList.ServerSortFriendsButton,
      sort = "FRIENDS",
      label = "@ui_online_friends"
    },
    {
      button = self.WorldSelectionList.ServerSortQueueSize,
      sort = "QUEUE",
      label = "@ui_world_select_queue_size"
    }
  }
  self.WorldSelectionList.ServerSortWorldSetTooltip:SetButtonStyle(self.WorldSelectionList.ServerSortWorldSetTooltip.BUTTON_STYLE_QUESTION_MARK)
  self.WorldSelectionList.ServerSortWorldSetTooltip:SetTooltip("@world_set_desc")
  for _, buttonData in ipairs(self.sortButtons) do
    local button = buttonData.button
    button:SetCallback(self.OnSortButtonClicked, self)
    button:SetText(buttonData.label)
    button:SetDeselected()
  end
  local textWidth = UiTextBus.Event.GetTextWidth(self.WorldSelectionList.ServerSortWorldSetLabel)
  local padding = 10
  self.ScriptedEntityTweener:Set(self.Properties.WorldSelectionList.ServerSortWorldSetTooltip, {
    x = textWidth + padding
  })
  UiTextBus.Event.SetText(self.WorldSelectionList.CurrentWorldText, LyShineManagerBus.Broadcast.GetWorldName())
  local regionName = self.dataLayer:GetDataFromNode("WorldInfo.RegionName") or ""
  UiTextBus.Event.SetText(self.WorldSelectionList.RegionName, regionName)
  self.dataLayer:ClearDataTree(3766102462)
  self.dataLayer:ClearDataTree(2976668229)
  self.dataLayer:RegisterObserver(self, "Game.GetWorldList", self.OnWorldListData)
  self.dataLayer:RegisterObserver(self, "Game.GetCharactersPayload", self.OnCharacterData)
  if self.WorldSelectionList.StatusSpinnerEntity:IsValid() then
    self.ScriptedEntityTweener:Play(self.WorldSelectionList.StatusSpinnerEntity, 1, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  end
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.FailedConnectionEntity, false)
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.ServerContentBoxHolder, true)
  self:OnRefreshServerPress()
  UiCanvasBus.Event.SetDrawOrder(self.canvasId, CanvasCommon.POPUP_DRAW_ORDER - 1)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.Container, true)
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.ContinueButton.entityId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.StoreScreenContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.StorePopupContainer, false)
  self.ScriptedEntityTweener:Play(self.Properties.StorePopupContainer, 0.2, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.WorldSelectionList.Container, 0.3, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.2
  })
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 0
  self.targetDOFBlur = 0.95
  timingUtils:UpdateForDuration(0.5, self, function(self, currentValue)
    self:UpdateDepthOfField(currentValue)
  end)
  DynamicBus.SocialPaneBus.Broadcast.VisibilityChanged(false)
  DynamicBus.NavBarBus.Broadcast.OnTransitionOut()
  local headerText = self.isPurchase and "@server_transfer_confirm_purchase" or "@server_transfer_confirm"
  self.WorldSelectionWarning.FrameHeader:SetText(headerText)
  local confirmButtonText = self.isPurchase and "@server_transfer_confirm_button_purchase" or "@server_transfer_confirm_button"
  self.WorldSelectionWarning.Button2:SetText(confirmButtonText)
  local finalDetailsText = self.isPurchase and "@server_transfer_final_details_purchase" or "@server_transfer_final_details"
  UiTextBus.Event.SetTextWithFlags(self.Properties.WorldSelectionWarning.FinalDetails, finalDetailsText, eUiTextSet_SetLocalized)
end
function WorldTransferPopup:OnSortButtonClicked(sortButton)
  local sortType
  for _, buttonData in pairs(self.sortButtons) do
    if buttonData.button == sortButton then
      if buttonData.button.isSelected and buttonData.button.direction == buttonData.button.ASCENDING then
        buttonData.button:SetSelectedDescending()
        sortType = worldListCommon["SORT_BY" .. buttonData.sort .. "_DESC"]
      else
        buttonData.button:SetSelectedAscending()
        sortType = worldListCommon["SORT_BY" .. buttonData.sort .. "_ASC"]
      end
    else
      buttonData.button:SetDeselected()
    end
  end
  worldListCommon:SortWorldList(sortType, self.worldTable)
  self.sortType = sortType
  self:PopulateWorldList(self.worldTable)
  if self.selectedWorld then
    local selectedWorldId = self.selectedWorld.worldData.worldId
    worldListCommon:ReselectWorldIdInList(self.WorldSelectionList.ServerList, selectedWorldId)
  end
  self:UpdateServerListContinueButton()
end
function WorldTransferPopup:HandleEscPressed()
  local handled = false
  if self.isPopupEnabled then
    handled = true
    if self.showingWorldSelectionWarning then
      self:OnWorldSelectionWarningClose()
    else
      self:ClosePopup()
    end
  end
  return handled
end
function WorldTransferPopup:OnStoreTransitionOut()
  if self.isPopupEnabled then
    if self.showingWorldSelectionWarning then
      self:OnWorldSelectionWarningClose()
    end
    self:ClosePopup()
  end
end
function WorldTransferPopup:ClosePopup()
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 50
  self.targetDOFBlur = 0.5
  timingUtils:UpdateForDuration(0.3, self, function(self, currentValue)
    self:UpdateDepthOfField(currentValue)
  end)
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.ContinueButton.entityId, false)
  self.ScriptedEntityTweener:Play(self.WorldSelectionList.Container, 0.3, {opacity = 1}, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      self.isPopupEnabled = false
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.Container, false)
      UiElementBus.Event.SetIsEnabled(self.WorldSelectionWarning.Container, false)
      UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.initialDrawOrder)
      UiElementBus.Event.SetIsEnabled(self.Properties.StoreScreenContainer, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.StorePopupContainer, true)
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.StorePopupContainer, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.3
  })
  DynamicBus.SocialPaneBus.Broadcast.VisibilityChanged(true)
  DynamicBus.NavBarBus.Broadcast.OnTransitionIn()
  self.WorldSelectionList.ContinueButton:StartStopImageSequence(false)
  self.dataLayer:ClearDataTree(3766102462)
  self.dataLayer:ClearDataTree(2976668229)
  self.dataLayer:UnregisterObserver(self, "Game.GetWorldList")
  self.dataLayer:UnregisterObserver(self, "Game.GetCharactersPayload")
  if self.mainMenuHandler then
    self:BusDisconnect(self.mainMenuHandler)
    self.mainMenuHandler = nil
  end
  if self.WorldSelectionList.StatusSpinnerEntity:IsValid() then
    self.ScriptedEntityTweener:Stop(self.WorldSelectionList.StatusSpinnerEntity)
  end
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.FailedConnectionEntity, false)
end
function WorldTransferPopup:OnRefreshFocus()
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButtonBg, 0.2, {opacity = 0.3, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.OnHover_LandingScreen)
end
function WorldTransferPopup:OnRefreshUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButtonBg, 0.2, {opacity = 0.1, ease = "QuadOut"})
end
function WorldTransferPopup:OnRefreshServerPress()
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButtonIcon, 0.38, {rotation = 0}, {timesToPlay = 1, rotation = 359})
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnRefreshServerPress)
  if self.isRefreshButtonThrottled then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.StatusSpinnerEntity, true)
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.FailedConnectionEntity, false)
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.ServerContentBoxHolder, false)
  self.oldSelectedWorld = self.selectedWorld
  self.selectedWorld = nil
  self:UpdateServerListContinueButton()
  self.dataLayer:Call(3766102462)
  local throttleDelay = 15
  self.isRefreshButtonThrottled = true
  timingUtils:StopDelay(self, self.ResetRefreshServerButtonThrottle)
  timingUtils:Delay(throttleDelay, self, self.ResetRefreshServerButtonThrottle)
end
function WorldTransferPopup:OnWorldListData(worldListDataNode)
  self.worldListDataNode = worldListDataNode
end
function WorldTransferPopup:OnCharacterData(characterPayloadDataNode)
  self.characterPayloadDataNode = characterPayloadDataNode
  if not characterPayloadDataNode then
    return
  end
  local characterPayloadVector = characterPayloadDataNode:GetData()
  if characterPayloadVector then
    if not self.mainMenuHandler then
      self.mainMenuHandler = self:BusConnect(UiMainMenuBus)
    end
    DynamicContentBus.Broadcast.RetrieveCMSData(eCMSDataType_Worlds, true)
  else
    self:OnGettingWorldListDataError()
  end
end
function WorldTransferPopup:OnWorldCMSDataSet(worldCMSData)
  local worldListVector = self.worldListDataNode and self.worldListDataNode:GetData() or nil
  local characterVector = self.characterPayloadDataNode and self.characterPayloadDataNode:GetData() or nil
  if worldListVector and characterVector and worldCMSData then
    UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.StatusSpinnerEntity, false)
    local worldTable = worldListCommon:WorldVectorToTable(worldListVector)
    local pendingWorldMergeList = self.dataLayer:Call(225285239):GetData()
    worldListCommon:UpdateWorldAndCharacterData(worldTable, characterVector, pendingWorldMergeList)
    worldListCommon:UpdateWorldDataWithCMS(worldTable, worldCMSData)
    worldListCommon:SortWorldList(self.sortType, worldTable)
    self.worldTable = worldTable
    self:PopulateWorldList(worldTable)
    self:UpdateServerListContinueButton()
    UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.ServerContentBoxHolder, true)
  else
    self:OnGettingWorldListDataError()
  end
end
function WorldTransferPopup:PopulateWorldList(worldTable)
  UiDynamicLayoutBus.Event.SetNumChildElements(self.WorldSelectionList.ServerList, #worldTable)
  local childList = UiElementBus.Event.GetChildren(self.WorldSelectionList.ServerList)
  for i = 1, #childList do
    local isVisible = i <= #worldTable
    UiElementBus.Event.SetIsEnabled(childList[i], isVisible)
    if isVisible then
      local entity = Entity(childList[i])
      entity:SetName(worldTable[i].worldData.worldId)
      local worldInfoBox = self.registrar:GetEntityTable(childList[i])
      worldInfoBox:SetWorldInfo(worldTable[i], true)
      worldInfoBox:SetSelectedCallback(self, self.OnWorldSelected)
      local isSelectable = self:IsWorldSelectable(worldTable[i])
      worldInfoBox:SetIsSelectable(isSelectable)
      if self.oldSelectedWorld and self.oldSelectedWorld.worldData.worldId == worldTable[i].worldData.worldId and isSelectable then
        self.selectedWorld = worldTable[i]
      end
    end
  end
  worldListCommon:ReselectWorldIdInList(self.WorldSelectionList.ServerList, self.selectedWorld and self.selectedWorld.worldData.worldId)
  self:UpdateServerListContinueButton()
  self.oldSelectedWorld = nil
end
function WorldTransferPopup:IsWorldSelectable(world)
  return not BitwiseHelpers:TestFlag(world.worldData.publicStatusCode, BitwiseHelpers.SERVERSTATUS_DISABLED) and not BitwiseHelpers:TestFlag(world.worldData.publicStatusCode, BitwiseHelpers.SERVERSTATUS_DOWNFORMAINTENANCE) and not BitwiseHelpers:TestFlag(world.worldData.publicStatusCode, BitwiseHelpers.SERVERSTATUS_NOCHARACTERTRANSFER)
end
function WorldTransferPopup:OnWorldSelected(worldInfoBox)
  if not self:IsWorldSelectable(worldInfoBox.worldInfo) then
    self.selectedWorld = nil
  else
    self.selectedWorld = worldInfoBox.worldInfo
  end
  self:UpdateServerListContinueButton()
end
function WorldTransferPopup:OnGettingWorldListDataError()
  self.selectedWorld = nil
  self:UpdateServerListContinueButton()
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.FailedConnectionEntity, true)
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.StatusSpinnerEntity, false)
  UiElementBus.Event.SetIsEnabled(self.WorldSelectionList.ServerContentBoxHolder, false)
  if self.mainMenuHandler then
    self:BusDisconnect(self.mainMenuHandler)
    self.mainMenuHandler = nil
  end
end
function WorldTransferPopup:UpdateServerListContinueButton()
  local canTransferToThisServer = true
  local disabledReason
  local rootPlayerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local localPlayerRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  local isInRaid = localPlayerRaidId and localPlayerRaidId:IsValid()
  local dugeonGameModeId = GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeId(rootPlayerId)
  local isInDungeon = dugeonGameModeId ~= 0
  local isInArena = PlayerArenaRequestBus.Event.IsInArena(rootPlayerId)
  local isInDuel = GameModeParticipantComponentRequestBus.Event.IsInGameMode(rootPlayerId, 2612307810)
  local isInOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(rootPlayerId, 2444859928)
  local isInOutpostRushQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForGameMode(rootPlayerId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  local currentWorldName = LyShineManagerBus.Broadcast.GetWorldName()
  local selectedSameWorld = self.selectedWorld and self.selectedWorld.worldData.name == currentWorldName
  local isWorldSetUnavailable = false
  if self.selectedWorld then
    local currentWorldSetName = self.dataLayer:GetDataFromNode("WorldInfo.WorldSetName")
    local selectedWorldSetName = self.selectedWorld.worldData.worldSet
    if currentWorldSetName ~= selectedWorldSetName then
      for i = 1, #self.worldTable do
        local world = self.worldTable[i]
        if world.worldData.worldSet == selectedWorldSetName and 0 < world.characterCount then
          isWorldSetUnavailable = true
          break
        end
      end
    end
  end
  local isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  local localPlayerGroupId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
  local localPlayerIsInGroup = localPlayerGroupId and localPlayerGroupId:IsValid()
  local disableReasonsAndText = {
    {
      isDisabled = localPlayerIsInGroup,
      locText = "@ui_leavegroup"
    },
    {
      isDisabled = isInDungeon,
      locText = "@server_transfer_unavailable_dungeon"
    },
    {
      isDisabled = isInRaid,
      locText = "@server_transfer_unavailable_raidid"
    },
    {
      isDisabled = isInArena,
      locText = "@server_transfer_unavailable_arena"
    },
    {
      isDisabled = isInDuel,
      locText = "@server_transfer_unavailable_duel"
    },
    {
      isDisabled = isInOutpostRush,
      locText = "@server_transfer_unavailable_outpost_rush"
    },
    {
      isDisabled = isInOutpostRushQueue,
      locText = "@server_transfer_unavailable_outpost_rush_queue"
    },
    {
      isDisabled = not self.selectedWorld,
      locText = "@server_transfer_select_world_fail"
    },
    {
      isDisabled = selectedSameWorld,
      locText = "@server_transfer_select_world_fail_same"
    },
    {
      isDisabled = isWorldSetUnavailable,
      locText = "@mm_world_character_limit"
    },
    {
      isFtue = isWorldSetUnavailable,
      locText = "@ftue_action_unavailable"
    }
  }
  for _, disableInfo in ipairs(disableReasonsAndText) do
    if disableInfo.isDisabled then
      disabledReason = disableInfo.locText
      canTransferToThisServer = false
      break
    end
  end
  self.WorldSelectionList.ContinueButton:SetEnabled(canTransferToThisServer)
  self.WorldSelectionList.ContinueButton:SetTooltip(disabledReason)
end
function WorldTransferPopup:ResetRefreshServerButtonThrottle()
  self.isRefreshButtonThrottled = false
end
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
function WorldTransferPopup:CheckUserHasOrders(successCallback, failureCallback)
  local numContractsPerPage = Contract.GetMaxOpenContractsPerPlayer()
  local paginationData = contractsDataHandler:GetPaginationData(numContractsPerPage)
  if self.searchRequestId then
    contractsDataHandler:CancelRequest(self.searchRequestId)
    self.searchRequestId = nil
  end
  self.searchRequestId = contractsDataHandler:LookupContractsForLocalPlayer(self, function(self, rawContracts)
    successCallback(self, rawContracts and #rawContracts or 1)
    if rawContracts then
      if 0 < #rawContracts then
        self:SendServerTransferOpenContractTelemetry(contractsDataHandler:ContractsVectorToTable(rawContracts))
      end
    else
      self:SendServerTransferContractLookupInvalidTelemetry()
    end
  end, failureCallback, eContractEventOpenFilter_Open, eContractEventRoleFilter_All, paginationData.contractsPerPage, paginationData)
end
function WorldTransferPopup:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function WorldTransferPopup:SendServerTransferOpenContractTelemetry(contracts)
  local event = UiAnalyticsEvent("server_transfer_open_contracts")
  local numStatus = {}
  local numBuy = 0
  local numSell = 0
  local numCreator = 0
  local numNotCreator = 0
  for _, contractData in ipairs(contracts) do
    if numStatus[contractData.status] == nil then
      numStatus[contractData.status] = 0
    end
    numStatus[contractData.status] = numStatus[contractData.status] + 1
    if contractData.contractType == eContractType_Sell then
      numSell = numSell + 1
    else
      numBuy = numBuy + 1
    end
    if contractData.isLocalPlayerCreator then
      numCreator = numCreator + 1
    else
      numNotCreator = numNotCreator + 1
    end
  end
  for status, count in pairs(numStatus) do
    event:AddMetric("num_status_" .. status, count)
  end
  event:AddMetric("num_buy", numBuy)
  event:AddMetric("num_sell", numSell)
  event:AddMetric("num_creator", numCreator)
  event:AddMetric("num_not_creator", numNotCreator)
  event:Send()
end
function WorldTransferPopup:SendServerTransferContractLookupInvalidTelemetry()
  local event = UiAnalyticsEvent("server_transfer_contract_lookup_invalid")
  event:Send()
end
return WorldTransferPopup
