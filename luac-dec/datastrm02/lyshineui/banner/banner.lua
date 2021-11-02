local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local Banner = {
  Properties = {
    CentralBanner = {
      default = EntityId()
    },
    CentralLayout = {
      default = EntityId()
    },
    Hidden = {
      default = EntityId()
    },
    Rows = {
      BannerLevelUp = {
        default = EntityId()
      },
      WarCard = {
        default = EntityId()
      },
      TerritoryClaimedCard = {
        default = EntityId()
      },
      AchievementCard = {
        default = EntityId()
      },
      BannerTerritoryLevelUp = {
        default = EntityId()
      },
      TownStructureChanged = {
        default = EntityId()
      },
      TerritoryEnteredCard = {
        default = EntityId()
      },
      TextCard = {
        default = EntityId()
      }
    }
  },
  mBannerQueues = {
    Center = {}
  },
  mDefaultDrawOrder = 10,
  mLayoutMap = {},
  mTextRowsInUse = 0,
  mSpawnedCount = 0,
  mCanvasEnabled = false,
  isLoadingScreenShowing = true,
  isBannerDucked = false,
  mScreenStatesToDisable = {
    [2972535350] = true,
    [3349343259] = true,
    [2552344588] = true,
    [3406343509] = true,
    [2478623298] = true,
    [3024636726] = true,
    [3901667439] = true,
    [1809891471] = true,
    [4143822268] = true,
    [1628671568] = true,
    [3175660710] = true,
    [2815678723] = true,
    [3784122317] = true,
    [156281203] = true,
    [2896319374] = true,
    [828869394] = true,
    [3370453353] = true,
    [1634988588] = true,
    [319051850] = true,
    [849925872] = true,
    [921202721] = true,
    [4283914359] = true
  }
}
BaseScreen:CreateNewScreen(Banner)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(Banner)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local layouts = RequireScript("LyShineUI.Banner.Layouts")
function Banner:OnInit()
  BaseScreen.OnInit(self)
  self.TIMING = {
    bannerDuck = 0.2,
    bannerUnduck = 0.2,
    bannerRemaining = 0.3
  }
  self.triggers = require("LyShineUI.Banner.BannerTriggers")
  self.bannerHandler = DynamicBus.Banner.Connect(self.entityId, self)
  self.mDefaultDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
  for queueName, bannerQueue in pairs(self.mBannerQueues) do
    bannerQueue.bannerEntity = EntityId()
    bannerQueue.layoutEntity = EntityId()
    bannerQueue.current = nil
    bannerQueue.duration = 0
    bannerQueue.isAnimating = false
    bannerQueue.queue = {}
  end
  self.mBannerQueues.Center.bannerEntity = self.CentralBanner
  self.mBannerQueues.Center.layoutEntity = self.CentralLayout
  self:BusConnect(UiSpawnerNotificationBus, self.CentralLayout)
  self:BusConnect(UiSpawnerNotificationBus, self.Hidden)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self.isLoadingScreenShowing = LoadScreenBus.Broadcast.IsLoadingScreenShown()
  self:BusConnect(LoadScreenNotificationBus, self.entityId)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:SetIsTicking(true)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableLandBanners", function(self, enableBanners)
    self.mEnableBanners = enableBanners
  end)
  self.triggers:OnInit(self, self.dataLayer, self.ScriptedEntityTweener, self.audioHelper)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "ObjectivesComponentRequestBus.IsConnected", function(self, isConnected)
    if isConnected == nil then
      return
    end
    self.objectivesBusConnected = isConnected
    self:TryShowInitialObjectiveBanner()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ObjectiveEntityId", function(self, objectiveEntityId)
    if objectiveEntityId == nil or self.objectiveEntityId ~= nil then
      return
    end
    self.objectiveEntityId = objectiveEntityId
    self.enableObjectives = false
    if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-objectives") then
      self.enableObjectives = true
    end
    self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
    self:TryShowInitialObjectiveBanner()
  end)
end
function Banner:OnShutdown()
  self.triggers:OnShutdown()
  BaseScreen.OnShutdown(self)
  self.triggers = nil
  if self.bannerHandler then
    DynamicBus.Banner.Disconnect(self.entityId, self)
    self.bannerHandler = nil
  end
end
function Banner:OnLoadingScreenShown()
  self.isLoadingScreenShowing = true
end
function Banner:OnLoadingScreenDismissed()
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  self.isLoadingScreenShowing = false
end
function Banner:SetIsTicking(isTicking)
  if isTicking ~= self.isTicking then
    self.isTicking = isTicking
    if self.isTicking then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    else
      self:BusDisconnect(self.tickHandler)
    end
  end
end
function Banner:OnTick(deltaTime, timePoint)
  for queueName, bannerQueue in pairs(self.mBannerQueues) do
    self:TickBannerQueue(bannerQueue, deltaTime)
  end
end
function Banner:TickBannerQueue(bannerQueue, deltaTime)
  if not bannerQueue then
    return
  end
  if self.isLoadingScreenShowing then
    return
  end
  if not bannerQueue.current then
    self:DequeueBanner(bannerQueue)
  else
    bannerQueue.duration = bannerQueue.duration - deltaTime
    if bannerQueue.duration <= 0 and not bannerQueue.isAnimating then
      if not bannerQueue.current.keepDisplayed then
        bannerQueue.isAnimating = true
        do
          local layoutName = bannerQueue.current.layoutName
          self:AnimateOut(bannerQueue, function(bannerQueue)
            if not bannerQueue.current then
              Debug.Log("ERROR: BannerQueue.current is nil, likely this callback was called twice. Add layout " .. tostring(layoutName) .. " to BannerTriggers.layoutsWithCustomAnimateOutCallback duplicate callback check")
              Debug.Log(debug.traceback())
              return
            end
            if bannerQueue.current.onHide then
              bannerQueue.current.onHide(bannerQueue.current.tableSelf)
            end
            bannerQueue.current = nil
            bannerQueue.isAnimating = false
            DynamicBus.BannerNotificationsBus.Broadcast.OnBannerHidden()
          end)
        end
      elseif 0 < #bannerQueue.queue then
        self:EnqueueBannerWithParameters(bannerQueue.current)
        bannerQueue.isAnimating = true
        self:AnimateOut(bannerQueue, function(bannerQueue)
          if bannerQueue.current.onHide then
            bannerQueue.current.onHide()
          end
          bannerQueue.current = nil
          bannerQueue.isAnimating = false
          DynamicBus.BannerNotificationsBus.Broadcast.OnBannerHidden()
        end)
      end
    end
  end
end
function Banner:GetRow(layoutName, index)
  if layoutName and index then
    local entity = self.mLayoutMap[layoutName] and self.mLayoutMap[layoutName][index] or nil
    if entity ~= nil then
      return entity
    end
  end
  return EntityId()
end
function Banner:GetNextRow(layoutName, index)
  for i = index + 1, #layouts:GetRows(layoutName) do
    local entity = self.mLayoutMap[layoutName][i]
    if entity ~= nil then
      return entity
    end
  end
  return EntityId()
end
function Banner:SetRowVisible(layoutName, index, visible)
  local currentParent = UiElementBus.Event.GetParent(self:GetRow(layoutName, index))
  local bannerQueue = self:GetBannerQueue(layoutName)
  local row = self:GetRow(layoutName, index)
  if visible == true and currentParent ~= bannerQueue.layoutEntity and bannerQueue.current and bannerQueue.current.layoutName == layoutName then
    UiElementBus.Event.Reparent(row, bannerQueue.layoutEntity, self:GetNextRow(layoutName, index))
  elseif visible == false and currentParent ~= self.Hidden then
    UiElementBus.Event.Reparent(row, self.Hidden, EntityId())
  end
  UiElementBus.Event.SetIsEnabled(row, visible)
end
function Banner:GetLayoutContainer(layoutName)
  local bannerQueue = self:GetBannerQueue(layoutName)
  return bannerQueue.layoutEntity
end
function Banner:GetBannerQueue(layoutName)
  local displayContainer = layouts:GetDisplayContainer(layoutName) or "Center"
  return self.mBannerQueues[displayContainer]
end
function Banner:IsBannerVisible(layoutName, uuid)
  local bannerQueue = self:GetBannerQueue(layoutName)
  return bannerQueue.current and bannerQueue.current.uuid == uuid
end
function Banner:EnqueueExternalBanner(tableSelf, layoutName, duration, priority, onShowCallback, onHideCallback)
  local params = {
    layoutName = layoutName,
    tableSelf = tableSelf,
    duration = duration,
    onShow = onShowCallback,
    onHide = onHideCallback,
    priority = priority
  }
  return self:EnqueueBannerWithParameters(params)
end
function Banner:EnqueueBanner(layoutName, data, duration, onShow, onHide, keepDisplayed, priority, drawOrder)
  if self.isFtue and (layoutName == layouts.LAYOUT_TERRITORY_CLAIMED or layoutName == layouts.LAYOUT_TERRITORY_LEVEL_UP_BANNER or layoutName == layouts.LAYOUT_TERRITORY_ENTERED or layoutName == layouts.LAYOUT_WAR_CARD or layoutName == layouts.LAYOUT_CLAIM_TAKEN_MESSAGE or layoutName == layouts.LAYOUT_TOWN_STRUCTURE_CHANGED) then
    return
  end
  local params = {
    layoutName = layoutName,
    data = data,
    duration = duration,
    onShow = onShow,
    onHide = onHide,
    keepDisplayed = keepDisplayed,
    priority = priority,
    drawOrder = drawOrder
  }
  return self:EnqueueBannerWithParameters(params)
end
function Banner:EnqueueBannerWithParameters(params)
  if not params.layoutName and not params.tableSelf then
    Log("Banner:EnqueueBannerWithParameters(): layoutName is invalid")
    return
  end
  if params.uuid then
    self:RescindBanner(params.uuid)
  end
  local compare = function(first, second)
    if first.priority ~= second.priority then
      return first.priority > second.priority
    end
    return first.timestamp < second.timestamp
  end
  local banner = {
    uuid = params.uuid or Uuid:Create(),
    timestamp = timeHelpers:ServerSecondsSinceEpoch(),
    priority = params.priority or 1,
    drawOrder = params.drawOrder or self.mDefaultDrawOrder,
    layoutName = params.layoutName,
    data = params.data,
    duration = params.duration or layouts.DEFAULT_DISPLAY_DURATION,
    onShow = params.onShow,
    onHide = params.onHide,
    keepDisplayed = params.keepDisplayed,
    tableSelf = params.tableSelf
  }
  local bannerQueue = self:GetBannerQueue(banner.layoutName)
  table.insert(bannerQueue.queue, banner)
  table.sort(bannerQueue.queue, compare)
  return banner.uuid
end
function Banner:DequeueBanner(bannerQueue)
  if self.disabledByScreen then
    return
  end
  if #bannerQueue.queue > 0 then
    local banner = bannerQueue.queue[1]
    table.remove(bannerQueue.queue, 1)
    bannerQueue.current = banner
    bannerQueue.isAnimating = true
    self:SwitchLayout(bannerQueue)
    DynamicBus.BannerNotificationsBus.Broadcast.OnBannerShowing()
  end
end
function Banner:RescindBanner(bannerId)
  for _, bannerQueue in pairs(self.mBannerQueues) do
    self:RescindBannerFromQueue(bannerQueue, bannerId)
  end
end
function Banner:RescindBannerFromQueue(bannerQueue, bannerId)
  local result = false
  if bannerQueue.current and bannerQueue.current.uuid == bannerId then
    bannerQueue.current.keepDisplayed = false
    bannerQueue.duration = 0
    result = true
  else
    for i = 1, #bannerQueue.queue do
      if bannerQueue.queue[i].uuid == bannerId then
        table.remove(bannerQueue.queue, i)
        return true
      end
    end
  end
  return result
end
function Banner:SwitchLayout(bannerQueue)
  if self.mEnableBanners ~= true then
    return nil
  end
  if not self.disabledByScreen then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  end
  self.mCanvasEnabled = true
  if bannerQueue.current.tableSelf then
    self:HideCurrentLayout(bannerQueue.layoutEntity)
    bannerQueue.current.onShow(bannerQueue.current.tableSelf)
    bannerQueue.isAnimating = false
    bannerQueue.duration = bannerQueue.current.duration
  else
    self:SpawnLayout(bannerQueue)
  end
end
function Banner:SpawnLayout(bannerQueue)
  self:HideCurrentLayout(bannerQueue.layoutEntity)
  local layoutName = bannerQueue.current.layoutName
  local data = bannerQueue.current.data
  local duration = bannerQueue.current.duration
  local onShow = bannerQueue.current.onShow
  local onHide = bannerQueue.current.onHide
  local keepDisplayed = bannerQueue.current.keepDisplayed
  local drawOrder = bannerQueue.current.drawOrder
  local backgroundColor = layouts:GetBackground(layoutName)
  UiImageBus.Event.SetColor(bannerQueue.bannerEntity, backgroundColor)
  local layout = layouts:GetRows(layoutName)
  local total = #layout
  self.mTextRowsInUse = 0
  if self.mLayoutMap[layoutName] == nil or #self.mLayoutMap[layoutName] == 0 then
    self.mLayoutMap[layoutName] = {}
    self.mSpawnedCount = 0
    local rowDataCounters = {}
    for i = 1, total do
      local rowTypeIndex = rowDataCounters[layout[i].rowType] or 1
      local rowData = data[layout[i].rowType .. rowTypeIndex] or {}
      self:SpawnLayoutRow(layoutName, i, total, layout[i], rowData, duration, onShow, onHide, keepDisplayed, drawOrder)
      rowDataCounters[layout[i].rowType] = rowTypeIndex + 1
    end
  else
    self.mSpawnedCount = #self.mLayoutMap[layoutName]
    local rowDataCounters = {}
    for i = 1, self.mSpawnedCount do
      local rowTypeIndex = rowDataCounters[layout[i].rowType] or 1
      local rowData = data[layout[i].rowType .. rowTypeIndex] or {}
      self:UpdateRow(self.mLayoutMap[layoutName][i], layout[i], rowData)
      if rowData.visible ~= false then
        self:SetRowVisible(layoutName, i, true)
      end
      rowDataCounters[layout[i].rowType] = rowTypeIndex + 1
    end
    self:OnSpawnLayoutComplete(layoutName, duration, onShow, onHide, keepDisplayed, drawOrder)
  end
end
function Banner:SpawnLayoutRow(layoutName, index, total, row, data, duration, onShow, onHide, keepDisplayed, drawOrder)
  local combinedData = {
    layoutName = layoutName,
    index = index,
    total = total,
    row = row,
    data = data,
    duration = duration,
    onShow = onShow,
    onHide = onHide,
    keepDisplayed = keepDisplayed,
    drawOrder = drawOrder
  }
  for rowType, slicePath in pairs(layouts.slicePaths) do
    if row.rowType == rowType then
      local entity = self.Rows[rowType]
      if rowType == "Text" then
        entity = self.Rows.Text[self.mTextRowsInUse]
        self.mTextRowsInUse = self.mTextRowsInUse + 1
      end
      if entity then
        self:OnRowSpawned(entity, combinedData)
      else
        Log("Banner Error - Trying to use a row (" .. rowType .. ") that doesn't exist!")
      end
    end
  end
end
function Banner:UpdateRow(entity, row, data)
  if not entity:IsValid() then
    return
  end
  local rowEntity = self.registrar:GetEntityTable(entity)
  if rowEntity ~= nil then
    rowEntity:UpdateRow(row, data)
  end
end
function Banner:TransitionRow(entity, isTransitioningIn, callback)
  if not entity:IsValid() then
    return
  end
  local rowEntity = self.registrar:GetEntityTable(entity)
  if rowEntity ~= nil then
    if isTransitioningIn then
      rowEntity:TransitionIn(callback)
    else
      rowEntity:TransitionOut(callback)
    end
  end
end
function Banner:OnRowSpawned(entity, data)
  self:UpdateRow(entity.entityId, data.row, data.data)
  self.mLayoutMap[data.layoutName][data.index] = entity.entityId
  self.mSpawnedCount = self.mSpawnedCount + 1
  local bannerQueue = self:GetBannerQueue(data.layoutName)
  if data.data.visible ~= false and bannerQueue.current and data.layoutName == bannerQueue.current.layoutName then
    self:SetRowVisible(data.layoutName, data.index, true)
  end
  if self.mSpawnedCount == data.total then
    self:OnSpawnLayoutComplete(data.layoutName, data.duration, data.onShow, data.onHide, data.keepDisplayed, data.drawOrder)
  end
end
function Banner:OnSpawnLayoutComplete(layoutName, duration, onShow, onHide, keepDisplayed, drawOrder)
  if onShow ~= nil then
    onShow()
  end
  local bannerQueue = self:GetBannerQueue(layoutName)
  if 0 < duration then
    bannerQueue.duration = duration
  end
  local currentDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
  if currentDrawOrder ~= drawOrder then
    UiCanvasBus.Event.SetDrawOrder(self.canvasId, drawOrder)
  end
  self:AnimateIn(bannerQueue, function(bannerQueue)
    bannerQueue.isAnimating = false
  end)
end
function Banner:HideCurrentLayout(layoutContainer)
  if not layoutContainer then
    return
  end
  local children = UiElementBus.Event.GetChildren(layoutContainer)
  for i = 1, #children do
    UiElementBus.Event.Reparent(children[i], self.Hidden, EntityId())
  end
end
function Banner:AnimateIn(bannerQueue, unboundCallback)
  if not bannerQueue.current then
    return
  end
  local function callback()
    return unboundCallback(bannerQueue)
  end
  local bannerContainer = bannerQueue.bannerEntity
  if not self.triggers:AnimateIn(bannerContainer, bannerQueue.current.layoutName, callback) then
    self.ScriptedEntityTweener:Set(bannerContainer, {opacity = 0})
    local duration = 1
    local fadeValue = UiFaderBus.Event.GetFadeValue(bannerContainer)
    duration = (1 - fadeValue) * duration
    self.ScriptedEntityTweener:StartAnimation({
      id = bannerContainer,
      duration = duration,
      opacity = 1,
      onComplete = callback
    })
  end
end
function Banner:AnimateOut(bannerQueue, unboundCallback)
  if not bannerQueue.current then
    return
  end
  local function callback()
    return unboundCallback(bannerQueue)
  end
  local bannerContainer = bannerQueue.bannerEntity
  if not self.triggers:AnimateOut(bannerContainer, bannerQueue.current.layoutName, callback) then
    local duration = 1
    local fadeValue = UiFaderBus.Event.GetFadeValue(bannerContainer)
    duration = fadeValue * duration
    self.ScriptedEntityTweener:StartAnimation({
      id = bannerContainer,
      duration = duration,
      opacity = 0,
      onComplete = callback
    })
  end
end
function Banner:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.entityId, self.canvasId)
  end
end
function Banner:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.mScreenStatesToDisable[toState] then
    self.disabledByScreen = true
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
  self:SetIsTicking(not self.disabledByScreen)
end
function Banner:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.mScreenStatesToDisable[toState] then
    self.disabledByScreen = true
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  else
    self.disabledByScreen = false
    UiCanvasBus.Event.SetEnabled(self.canvasId, self.mCanvasEnabled)
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self:SetIsTicking(not self.disabledByScreen)
end
function Banner:OnNotificationShowing(centered)
  if not centered then
    return
  end
  local bannerQueue = self.mBannerQueues.Center
  if bannerQueue.current and bannerQueue.duration <= self.TIMING.bannerRemaining then
    bannerQueue.duration = 0
    return
  end
  self.isBannerDucked = true
  self:SetIsTicking(false)
  self.ScriptedEntityTweener:PlayC(bannerQueue.bannerEntity, self.TIMING.bannerDuck, tweenerCommon.fadeOutQuadOut)
end
function Banner:OnNotificationHidden(centered)
  if not self.isBannerDucked or not centered then
    return
  end
  local bannerQueue = self.mBannerQueues.Center
  if bannerQueue.duration < 0 then
    self.isBannerDucked = false
    self:SetIsTicking(true)
  else
    self.ScriptedEntityTweener:PlayC(bannerQueue.bannerEntity, self.TIMING.bannerUnduck, tweenerCommon.fadeInQuadIn, nil, function()
      self.isBannerDucked = false
      self:SetIsTicking(true)
    end)
  end
end
function Banner:TryShowInitialObjectiveBanner()
  if self.objectivesBusConnected and self.enableObjectives and not self.isFtue then
    local objectives = ObjectivesComponentRequestBus.Event.GetTrackedObjectives(self.objectiveEntityId)
    for i = 1, #objectives do
      local objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(objectives[i])
      if objectiveData and objectiveData.id == "S_getoffbeach" then
        self.triggers:OnObjectiveAdded(objectives[i])
      end
    end
  end
end
return Banner
