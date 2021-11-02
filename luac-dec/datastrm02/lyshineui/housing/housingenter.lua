local HousingEnter = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    HouseOwnerText = {
      default = EntityId()
    },
    PrototypeElement = {
      default = EntityId()
    },
    PrototypeElementSmall = {
      default = EntityId()
    },
    TopList = {
      default = EntityId()
    },
    GroupList = {
      default = EntityId()
    },
    LineTop = {
      default = EntityId()
    },
    LineLeft = {
      default = EntityId()
    },
    LineRight = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    },
    BackgroundContainer = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    GroupListContainer = {
      default = EntityId()
    },
    TopListContainer = {
      default = EntityId()
    },
    ScrollBar = {
      default = EntityId()
    },
    CurrentDisplayHeader = {
      default = EntityId()
    },
    UpdateTimeText = {
      default = EntityId()
    },
    QuestionMark = {
      default = EntityId()
    }
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(HousingEnter)
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
function HousingEnter:OnInit()
  BaseScreen.OnInit(self)
  self.ScreenHeader:SetHintCallback(self.OnHomeBackButton, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
  self.QuestionMark:SetTooltip("@ui_housing_point_tooltip")
  self.QuestionMark:SetButtonStyle(self.QuestionMark.BUTTON_STYLE_QUESTION_MARK)
  self.QuestionMark:SetSize(30)
  self.TopList:SetHeaderText("@ui_top_houses")
  self.TopList:Initialize(self.PrototypeElementSmall)
  self.TopList:OnListDataSet(nil, {
    label = "@ui_resident_homes_no_data"
  })
  self.GroupList:SetHeaderText("@ui_group_member_homes")
  self.GroupList:Initialize(self.PrototypeElementSmall)
  self.GroupList:OnListDataSet(nil, {
    label = "@ui_group_member_homes_no_data"
  })
  self.LineTop:SetLength(940)
  self.LineLeft:SetLength(900)
  self.LineRight:SetLength(900)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.dataLayer:RegisterDataCallback(self, "Hud.Housing.QuickEnter", function(self, requestedQuickEnter)
    DynamicBus.FullScreenFader.Broadcast.ExecuteFadeInOut(0.1, 0.3, 0.4)
  end)
end
function HousingEnter:OnShutdown()
  BaseScreen.OnShutdown(self)
end
function HousingEnter:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.Housing.HousingEnterDataUpdate", function(self, _)
    local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
    local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
    local housingData = {
      houseName = territoryName and territoryName or "Brightmark <font face='lyshineui/fonts/CaslonAnt.font'>6</font>"
    }
    self:InitializeEnterHouseData(housingData)
  end)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_HousingEnter", 0.5)
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.BackgroundContainer, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.BackgroundContainer, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.2
  })
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 13
  self.targetDOFBlur = 0.5
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 0.5,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.LineTop:SetVisible(true, 1.2, {delay = 0.35})
  self.LineLeft:SetVisible(true, 1.2, {delay = 0.35})
  self.LineRight:SetVisible(true, 1.2, {delay = 0.35})
end
function HousingEnter:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  self.dataLayer:UnregisterObserver(self, "Hud.Housing.HousingEnterDataUpdate")
  self.dataLayer:UnregisterObserver(self, "Hud.Housing.Enter.NextRecompute")
  self.dataLayer:UnregisterObserver(self, "Hud.Housing.Enter.HouseScore")
  self:SetTicking(false)
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_HousingEnter", 0.5)
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.BackgroundContainer, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  local durationOut = 0.2
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = durationOut,
    opacity = 0,
    onComplete = function()
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    end
  })
  self.LineTop:SetVisible(false, 0)
  self.LineLeft:SetVisible(false, 0)
  self.LineRight:SetVisible(false, 0)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function HousingEnter:InitializeEnterHouseData(housingData)
  self.ScreenHeader:SetText(housingData.houseName .. ".")
  local peacockingCharacterId
  local housingPoints = 0
  local plotEntityId = PlayerHousingClientRequestBus.Broadcast.GetInteractionHousingPlotEntityId()
  local topHouses = HousingPlotRequestBus.Event.GetTopHousesData(plotEntityId)
  local playerOwnsHomeOnPlot = PlayerHousingClientRequestBus.Broadcast.HasOwnedHouseOnInteractingPlot()
  if playerOwnsHomeOnPlot then
    do
      local ownerName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.PlayerName")
      local ownerNameText = GetLocalizedReplacementText("@ui_residence", {playerName = ownerName})
      peacockingCharacterId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CharacterId")
      UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentDisplayHeader, "@ui_your_house", eUiTextSet_SetLocalized)
      PlayerHousingClientRequestBus.Broadcast.ClientRequestPlotAdditionalInfo()
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.Housing.Enter.NextRecompute", function(self, timeToNextRecompute)
        self.timeToNextRecompute = timeToNextRecompute
        self:UpdateTimeToNextRecompute()
        self:SetTicking(true)
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.Housing.Enter.HouseScore", function(self, myPeacockedHouseScore)
        myPeacockedHouseScore = myPeacockedHouseScore or 0
        local isMyHouseTop = true
        if topHouses and 0 < #topHouses then
          local topHouseScore = topHouses[1].houseScore
          isMyHouseTop = topHouseScore == myPeacockedHouseScore
        end
        self.PrototypeElement:SetGridItemData({
          peacockingCharacterId = peacockingCharacterId,
          ownerName = ownerNameText,
          housingPoints = myPeacockedHouseScore,
          callbackSelf = self,
          callbackFn = self.OnEnterPlotButton,
          plotIndex = (not (not playerOwnsHomeOnPlot and topHouses) or #topHouses == 0) and -1 or 0,
          primaryButton = true,
          isMyHouseTop and 1 or 0,
          isMyHouse = true
        })
      end)
    end
  else
    local ownerNameText = "@ui_no_home_owners"
    peacockingCharacterId = HousingPlotRequestBus.Event.GetPeacockingCharacterId(plotEntityId)
    if topHouses and 0 < #topHouses then
      housingPoints = topHouses[1].houseScore
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentDisplayHeader, "@ui_currently_displaying", eUiTextSet_SetLocalized)
    self.PrototypeElement:SetGridItemData({
      peacockingCharacterId = peacockingCharacterId,
      ownerName = ownerNameText,
      housingPoints = housingPoints,
      callbackSelf = self,
      callbackFn = self.OnEnterPlotButton,
      plotIndex = (not (not playerOwnsHomeOnPlot and topHouses) or #topHouses == 0) and -1 or 0,
      primaryButton = true,
      isMyHouse = false
    })
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.UpdateTimeText, playerOwnsHomeOnPlot)
  local playerCharacterId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CharacterId")
  if topHouses and 0 < #topHouses then
    local topHousesList = {}
    local startIndex = playerOwnsHomeOnPlot and 1 or 2
    for i = startIndex, #topHouses do
      local topHouse = topHouses[i]
      local houseData = {
        peacockingCharacterId = topHouse.characterId,
        housingPoints = topHouse.houseScore,
        callbackSelf = self,
        callbackFn = self.OnEnterPlotButton,
        plotIndex = i - 1,
        rankNumber = i
      }
      table.insert(topHousesList, houseData)
    end
    if #topHouses == 1 and not playerOwnsHomeOnPlot then
      self.TopList:OnListDataSet(nil, {
        label = "@ui_resident_homes_already_showing_current"
      })
    else
      self.TopList:OnListDataSet(topHousesList)
    end
  else
    self.TopList:OnListDataSet(nil, {
      label = "@ui_resident_homes_no_data"
    })
  end
  local groupHouses = {}
  local groupHouseData = HousingPlotRequestBus.Event.GetGroupHousesData(plotEntityId)
  if groupHouseData and 0 < #groupHouseData then
    for i = 1, #groupHouseData do
      local groupHouse = groupHouseData[i]
      local houseData = {
        peacockingCharacterId = groupHouse.characterId,
        housingPoints = groupHouse.houseScore,
        callbackSelf = self,
        callbackFn = self.OnEnterPlotButton,
        isGroupHouse = true,
        plotIndex = i - 1
      }
      table.insert(groupHouses, houseData)
      self.GroupList:OnListDataSet(groupHouses)
      self.PrototypeElementSmall:ShowPoints(false)
    end
  else
    self.GroupList:OnListDataSet(nil, {
      label = "@ui_group_member_homes_no_data"
    })
  end
  local groupMultiplier = 1
  local topListMultiplier = 1
  local spacing = 88
  local rowHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.PrototypeElementSmall)
  if topHouses and 0 < #topHouses then
    topListMultiplier = #topHouses
  end
  if groupHouses and 0 < #groupHouses then
    groupMultiplier = #groupHouses
  end
  local groupContainerHeight = groupMultiplier * rowHeight + spacing
  local topListContainerHeight = topListMultiplier * rowHeight + spacing
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.GroupListContainer, groupContainerHeight)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.TopListContainer, topListContainerHeight)
  local total = #groupHouses + #topHouses
  if 5 < total then
    UiElementBus.Event.SetIsEnabled(self.Properties.ScrollBar, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ScrollBar, false)
  end
end
function HousingEnter:UpdateTimeToNextRecompute()
  local timeText = "@ui_housing_time_calculating"
  if self.timeToNextRecompute then
    local timeToNextSec = self.timeToNextRecompute:Subtract(timeHelpers:ServerNow()):ToSeconds()
    local formattedTime = timeHelpers:ConvertSecondsToHrsMinSecString(timeToNextSec)
    timeText = GetLocalizedReplacementText("@ui_housing_time_to_recompute", {time = formattedTime})
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.UpdateTimeText, timeText, eUiTextSet_SetLocalized)
end
function HousingEnter:SetTicking(shouldTick)
  if shouldTick then
    if not self.tickBusHandler then
      self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
    end
  elseif self.tickBusHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBusHandler = nil
  end
end
function HousingEnter:OnTick()
  self:UpdateTimeToNextRecompute()
end
function HousingEnter:OnHomeBackButton()
  LyShineManagerBus.Broadcast.ExitState(828869394)
end
function HousingEnter:OnEnterPlotButton(enterPlotInfo)
  DynamicBus.FullScreenFader.Broadcast.ExecuteFadeInOut(0.3, 0.3, 0.4, self, function()
    PlayerHousingClientRequestBus.Broadcast.RequestEnterPlot(enterPlotInfo.plotIndex, enterPlotInfo.isGroupHouse == true, enterPlotInfo.isMyHouse == true)
    self:OnHomeBackButton()
  end)
end
function HousingEnter:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function HousingEnter:OnExit()
  LyShineManagerBus.Broadcast.ExitState(828869394)
end
return HousingEnter
