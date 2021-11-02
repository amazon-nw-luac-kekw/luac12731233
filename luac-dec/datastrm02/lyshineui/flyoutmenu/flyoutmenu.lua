local FlyoutMenu = {
  Properties = {
    RowContainer = {
      default = EntityId()
    },
    PositionContainer = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    MenuBG = {
      default = EntityId()
    },
    Dimmers = {
      default = EntityId()
    },
    Dimmer1 = {
      default = EntityId()
    },
    Dimmer2 = {
      default = EntityId()
    },
    Dimmer3 = {
      default = EntityId()
    },
    Dimmer4 = {
      default = EntityId()
    },
    PointerImage1 = {
      default = EntityId()
    },
    FrameHover = {
      default = EntityId()
    },
    BgPatternMask = {
      default = EntityId()
    },
    Cache = {
      default = EntityId()
    },
    Prototypes = {
      Label = {
        default = EntityId()
      },
      DynamicTooltipSlice = {
        default = EntityId()
      },
      PlayerHeader = {
        default = EntityId()
      },
      SettlementHeader = {
        default = EntityId()
      },
      OtherGuildHeader = {
        default = EntityId()
      },
      WarStatus = {
        default = EntityId()
      },
      WarButton = {
        default = EntityId()
      },
      Button = {
        default = EntityId()
      },
      Options = {
        default = EntityId()
      },
      CircularOptions = {
        default = EntityId()
      },
      Separator = {
        default = EntityId()
      },
      StreamingStatus = {
        default = EntityId()
      },
      SimpleHeaderAndSubtext = {
        default = EntityId()
      },
      PointOfInterest = {
        default = EntityId()
      },
      CapitalInfo = {
        default = EntityId()
      },
      ControlPointStatus = {
        default = EntityId()
      },
      ProjectTask = {
        default = EntityId()
      },
      House = {
        default = EntityId()
      },
      HouseTrophies = {
        default = EntityId()
      },
      FactionMission = {
        default = EntityId()
      },
      Ability = {
        default = EntityId()
      },
      Subheader = {
        default = EntityId()
      },
      CurrencyInfo = {
        default = EntityId()
      },
      Objective = {
        default = EntityId()
      },
      AttributeThreshold = {
        default = EntityId()
      }
    }
  },
  spawnCount = 0,
  heightCallbackCount = 0,
  bottomPadding = 0,
  currentHeight = 0,
  openLocation = Vector2:CreateZero(),
  closedContext = nil,
  closedCallback = nil,
  positionYOffset = 0,
  soundOnShow = nil,
  soundOnHide = nil,
  allowPositionalExitHover = true,
  fadeInTime = 0.15,
  fadeOutTime = 0.15,
  flipBasedOnPosition = true,
  ROW_TYPE_Label = "Label",
  ROW_TYPE_PlayerHeader = "PlayerHeader",
  ROW_TYPE_SettlementHeader = "SettlementHeader",
  ROW_TYPE_OtherGuildHeader = "OtherGuildHeader",
  ROW_TYPE_WarStatus = "WarStatus",
  ROW_TYPE_WarButton = "WarButton",
  ROW_TYPE_Button = "Button",
  ROW_TYPE_Options = "Options",
  ROW_TYPE_CircularOptions = "CircularOptions",
  ROW_TYPE_Separator = "Separator",
  ROW_TYPE_StreamingStatus = "StreamingStatus",
  ROW_TYPE_SimpleHeaderAndSubtext = "SimpleHeaderAndSubtext",
  ROW_TYPE_PointOfInterest = "PointOfInterest",
  ROW_TYPE_CapitalInfo = "CapitalInfo",
  ROW_TYPE_ControlPointStatus = "ControlPointStatus",
  ROW_TYPE_ProjectTask = "ProjectTask",
  ROW_TYPE_House = "House",
  ROW_TYPE_HouseTrophies = "HouseTrophies",
  ROW_TYPE_FactionMission = "FactionMission",
  ROW_TYPE_FactionReputationBarRankIcon = "FactionReputationBarRankIcon",
  ROW_TYPE_Ability = "Ability",
  ROW_TYPE_Subheader = "Subheader",
  ROW_TYPE_CurrencyInfo = "CurrencyInfo",
  ROW_TYPE_Objective = "Objective",
  ROW_TYPE_AttributeThreshold = "AttributeThreshold",
  USE_HOTKEYS = false,
  actionMapToDisable = "quickslots",
  enableFlyoutDelay = false,
  lastHoveredItem = nil,
  tickTimer = 0,
  flyoutMenuDelay = 0.2,
  tickCount = 0,
  extraWidth = 0,
  scale = 1
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(FlyoutMenu)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(FlyoutMenu)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function FlyoutMenu:OnInit()
  BaseScreen.OnInit(self)
  self.PREFER_NONE = 0
  self.PREFER_LEFT = 1
  self.PREFER_RIGHT = 2
  self.locationPreference = self.PREFER_NONE
  self:SetSoundOnShow(self.audioHelper.OnShow)
  self:SetSoundOnHide(self.audioHelper.OnHide)
  LyShineDataLayerBus.Broadcast.SetData("Hud.FlyoutMenu.EntityId", self.entityId)
  self:BusConnect(UiSpawnerNotificationBus, self.RowContainer)
  DynamicBus.FlyoutMenuBus.Connect(self.entityId, self)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Flyout.IsVisible", self.OnVisibilityChanged)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Flyout.IgnoreHoverExit", function(self, ignoreHoverExit)
    self.ignoreHoverExit = ignoreHoverExit
  end)
  self.rowSlices = {}
  self.rowSlices[self.ROW_TYPE_Label] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_Label",
    numToCache = 4
  }
  self.rowSlices[self.ROW_TYPE_PlayerHeader] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_PlayerHeader",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_SettlementHeader] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_SettlementHeader",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_OtherGuildHeader] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_OtherGuildHeader",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_WarStatus] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_WarStatus",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_WarButton] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_WarButton",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_Button] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_Button",
    numToCache = 5
  }
  self.rowSlices[self.ROW_TYPE_Options] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_Options",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_CircularOptions] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_CircularOptions",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_Separator] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_Separator",
    numToCache = 3
  }
  self.rowSlices[self.ROW_TYPE_StreamingStatus] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_StreamingStatus",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_SimpleHeaderAndSubtext] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_SimpleHeaderAndSubtext",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_PointOfInterest] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_PointOfInterest",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_CapitalInfo] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_CapitalInfo",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_ControlPointStatus] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_ControlPointStatus",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_ProjectTask] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_ProjectTask",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_House] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_House",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_HouseTrophies] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_HouseTrophies",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_FactionMission] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_FactionMission",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_FactionReputationBarRankIcon] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_FactionReputationBarRankIcon",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_Ability] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_Ability",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_Subheader] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_Subheader",
    numToCache = 2
  }
  self.rowSlices[self.ROW_TYPE_CurrencyInfo] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_CurrencyInfo",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_Objective] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_Objective",
    numToCache = 1
  }
  self.rowSlices[self.ROW_TYPE_AttributeThreshold] = {
    sliceName = "LyShineUI\\FlyoutMenu\\FlyoutRow_AttributeThreshold",
    numToCache = 1
  }
  self.currentHeight = self.bottomPadding
  self.rowEntities = {}
  self.spawnTickets = {}
  self.hideBg = {
    ["LyShineUI\\FlyoutMenu\\FlyoutRow_AttributeThreshold"] = true,
    ["LyShineUI/Tooltip/DynamicTooltip"] = true
  }
  self.disableFrameHover = {
    ["LyShineUI/Tooltip/DynamicTooltip"] = true
  }
  self.blockUIInputOnComplete = false
  self.sourceHoverOnly = false
  self.scale = 1
  self.allowResetOfIgnoreHoverExit = true
  local originalWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  local containerWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.RowContainer)
  self.padding = originalWidth - containerWidth
  self.arrow1EntityId = UiElementBus.Event.FindChildByName(self.Properties.PositionContainer, "PointerImage1")
  self.arrow2EntityId = UiElementBus.Event.FindChildByName(self.Properties.PositionContainer, "PointerImage2")
  self:SetupCache()
  g_watchedVariables.flyoutMenu = self
end
function FlyoutMenu:OnShutdown()
  DynamicBus.FlyoutMenuBus.Disconnect(self.entityId, self)
end
function FlyoutMenu:SetupCache()
  self.sliceNameToElementCache = {
    ["LyShineUI/Tooltip/DynamicTooltip"] = {
      prototype = self.Prototypes.DynamicTooltipSlice,
      elements = {
        self.Prototypes.DynamicTooltipSlice
      }
    }
  }
  for prototypeName, data in pairs(self.rowSlices) do
    self.sliceNameToElementCache[data.sliceName] = {
      prototype = self.Prototypes[prototypeName],
      elements = {
        self.Prototypes[prototypeName]
      }
    }
    if data.numToCache > 1 then
      local cache = self.sliceNameToElementCache[data.sliceName]
      for i = 2, data.numToCache do
        local clonedEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, cache.prototype.entityId, self.Properties.Cache, EntityId())
        local element = self.registrar:GetEntityTable(clonedEntityId)
        table.insert(cache.elements, element)
      end
    end
  end
end
function FlyoutMenu:DockToCursor(xOffset, lockToEntitySides)
  xOffset = xOffset or 0
  self.dockToCursor = true
  self.dockXOffset = xOffset
  self.lockToEntitySides = lockToEntitySides
  self:StartTick()
  UiElementBus.Event.SetIsEnabled(self.arrow1EntityId, false)
  UiElementBus.Event.SetIsEnabled(self.arrow2EntityId, false)
end
function FlyoutMenu:OnTick(deltaTime, timePoint)
  DynamicBus.CompareTooltipRequestBus.Broadcast.OnTick(deltaTime, timePoint)
  if self.enableFlyoutDelay then
    self.tickTimer = self.tickTimer + deltaTime
    if self.tickTimer > self.flyoutMenuDelay then
      self.enableFlyoutDelay = false
      if self.lastHoveredItem and self.lastHoveredItem:IsValid() then
        local rows = self.delayedFlyoutRows
        self:SetRowData(rows)
      else
        self:ClearData()
      end
      self:StopTick()
    end
  end
  if self.dockToCursor and not self.locked then
    local cursorPos = CursorBus.Broadcast.GetCursorPosition()
    self:PositionMenu(cursorPos)
  end
end
function FlyoutMenu:SetExtraWidth(extraWidth)
  self.extraWidth = extraWidth or 0
end
function FlyoutMenu:StartTick()
  if not self.tickHandler then
    self.tickHandler = self:BusConnect(TickBus)
  end
  self.tickCount = self.tickCount + 1
end
function FlyoutMenu:StopTick(forceStop)
  if self.tickCount > 0 then
    self.tickCount = self.tickCount - 1
    if forceStop then
      self.tickCount = 0
    end
    if self.tickCount <= 0 and self.tickHandler then
      self:BusDisconnect(self.tickHandler)
      self.tickHandler = nil
    end
  end
end
function FlyoutMenu:OnFlyoutOpen(entity)
  if self.enableFlyoutDelay then
    self.lastHoveredItem = entity
    self.tickTimer = 0
    self:StartTick()
  else
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", true)
  end
end
function FlyoutMenu:OnFlyoutClose()
  self:StopTick(true)
  self.lastHoveredItem = nil
  self.dockToCursor = nil
end
function FlyoutMenu:SetFadeInTime(value)
  self.fadeInTime = value
end
function FlyoutMenu:OnTransitionIn(stateName, levelName)
  self.extraWidth = 0
  if self.showScaleTween then
    local xPosition = UiTransformBus.Event.GetLocalPositionX(self.entityId)
    local yPosition = UiTransformBus.Event.GetLocalPositionY(self.entityId)
    self.ScriptedEntityTweener:Play(self.entityId, 0.2, {
      scaleX = 0,
      scaleY = 0,
      x = xPosition - 50,
      y = yPosition - 50
    }, {
      scaleX = 1,
      scaleY = 1,
      x = xPosition,
      y = yPosition,
      ease = "QuadOut"
    })
  else
    UiTransformBus.Event.SetScale(self.entityId, Vector2(1, 1))
  end
  local isHovering = self:ExitHover()
  if isHovering then
    self.audioHelper:PlaySound(self.soundOnShow)
    self.ScriptedEntityTweener:Play(self.Properties.PositionContainer, self.fadeInTime, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, self.fadeInTime, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      onComplete = function()
        local isHovering = self:ExitHover()
        if self.USE_HOTKEYS and isHovering and self.blockUIInputOnComplete then
          self.wasUIInputEnabled = UIInputRequestsBus.Broadcast.IsActionMapEnabled(self.actionMapToDisable)
          if self.wasUIInputEnabled then
            LyShineManagerBus.Broadcast.AddActionMapOverrider(self.canvasId, self.actionMapToDisable)
          end
        end
      end
    })
  else
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  end
end
function FlyoutMenu:OnTransitionOut(stateName, levelName)
  self.audioHelper:PlaySound(self.soundOnHide)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.PositionContainer, 0)
  self:ClearData()
end
function FlyoutMenu:ExecuteClosedCallback()
  if self.closedContext and self.closedCallback and type(self.closedCallback) == "function" then
    self.closedCallback(self.closedContext)
  end
end
function FlyoutMenu:ClearData()
  self:ExecuteClosedCallback()
  self.ScriptedEntityTweener:Stop(self.entityId)
  self:ClearRows()
  self:SetBackgroundVisibility(true)
  self:SetFlipBasedOnPosition(true)
  self.spawnCount = 0
  self.closedContext = nil
  self.closedCallback = nil
  self.blockUIInputOnComplete = false
  self.sourceHoverOnly = false
  self.enableFlyoutDelay = false
  self.delayedFlyoutRows = nil
  self.openLocation = Vector2:CreateZero()
  self.invokingEntityId = nil
  self.openingContext = nil
  self.allowPositionalExitHover = true
  if self.allowResetOfIgnoreHoverExit then
    self.ignoreHoverExit = false
  end
  self.showArrows = true
  self.showScaleTween = false
  self.fadeOutTime = 0.15
  self.fadeInTime = 0.15
  self.flyoutMenuDelay = 0.2
  self.scale = 1
  UiExitHoverEventBus.Event.Reset(self.entityId)
  UiExitHoverEventBus.Event.Reset(self.Properties.PositionContainer)
end
function FlyoutMenu:SetIgnoreHoverExit(ignoreHoverExit)
  self.ignoreHoverExit = ignoreHoverExit
end
function FlyoutMenu:SetAllowResetOfIgnoreHoverExit(allowReset)
  self.allowResetOfIgnoreHoverExit = allowReset
end
function FlyoutMenu:SetAllowPositionalExitHover(isAllow)
  self.allowPositionalExitHover = isAllow
end
function FlyoutMenu:SetFlipBasedOnPosition(doFlip)
  self.flipBasedOnPosition = doFlip
end
function FlyoutMenu:SetBackgroundVisibility(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Frame, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.MenuBG, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.BgPatternMask, isVisible)
end
function FlyoutMenu:SetArrowVisibility(isVisible)
  self.showArrows = isVisible
end
function FlyoutMenu:SetScaleTween(doTween)
  self.showScaleTween = doTween
end
function FlyoutMenu:SetExitOnHoverEnd(isExitOnHoverEnd)
  self.exitOnHoverEnd = isExitOnHoverEnd
end
function FlyoutMenu:ClearRows()
  for index, ticket in pairs(self.spawnTickets) do
    self.Spawner.m_callbacks[ticket].data.deleteOnSpawn = true
  end
  ClearTable(self.spawnTickets)
  local childElements = UiElementBus.Event.GetChildren(self.Properties.RowContainer)
  for i = 1, #childElements do
    local element = self.registrar:GetEntityTable(childElements[i])
    self:ReturnElementToCache(element)
  end
  ClearTable(self.rowEntities)
  self.heightCallbackCount = 0
  self.currentHeight = self.bottomPadding
end
function FlyoutMenu:SetOpenLocation(entityId, locationPreference, scale)
  if not entityId or not entityId:IsValid() then
    Log("[FlyoutMenu] Invalid entityId passed to SetOpenLocation()")
    return
  end
  self.scale = scale or 1
  local entityViewportRect = UiTransformBus.Event.GetViewportSpaceRect(entityId)
  local callerHeight = entityViewportRect:GetHeight()
  local left = entityViewportRect:GetCenterX() - entityViewportRect:GetWidth() / 2
  local right = left + entityViewportRect:GetWidth() * self.scale
  local topOffset = callerHeight / 2
  local bottomOffset = callerHeight
  if not self.sourceHoverOnly then
    topOffset = callerHeight
    bottomOffset = callerHeight * 2
  end
  local top = entityViewportRect:GetCenterY() - topOffset
  local bottom = top + bottomOffset * self.scale
  self.locationPreference = locationPreference or self.PREFER_NONE
  self.invokingEntityId = entityId
  UiTransform2dBus.Event.SetOffsets(self.Properties.PositionContainer, UiOffsets(left, top, right, bottom))
  if not self.sourceHoverOnly then
    top = top + callerHeight / 2
    bottom = bottom - callerHeight / 2
  end
  local paddingTop = 2
  local top = entityViewportRect:GetCenterY() - callerHeight / 2 + paddingTop
  self.openLocation = Vector2(entityViewportRect:GetCenterX() + entityViewportRect:GetWidth() / 2, top)
  local viewportSize = LyShineScriptBindRequestBus.Broadcast.GetViewportSize()
  UiTransform2dBus.Event.SetOffsets(self.Properties.Dimmer1, UiOffsets(0, 0, right, top))
  UiTransform2dBus.Event.SetOffsets(self.Properties.Dimmer2, UiOffsets(right, 0, viewportSize.x, bottom))
  UiTransform2dBus.Event.SetOffsets(self.Properties.Dimmer3, UiOffsets(left, bottom, viewportSize.x, viewportSize.y))
  UiTransform2dBus.Event.SetOffsets(self.Properties.Dimmer4, UiOffsets(0, top, left, viewportSize.y))
end
function FlyoutMenu:AdjustPositionContainerToInvokingEntity()
  if not self.invokingEntityId then
    return
  end
  local entityViewportRect = UiTransformBus.Event.GetViewportSpaceRect(self.invokingEntityId)
  local callerHeight = entityViewportRect:GetHeight()
  local left = entityViewportRect:GetCenterX() - entityViewportRect:GetWidth() / 2
  local right = left + entityViewportRect:GetWidth() * self.scale
  local top = entityViewportRect:GetCenterY() - callerHeight / 2
  local bottom = top + callerHeight * self.scale
  UiTransform2dBus.Event.SetOffsets(self.Properties.PositionContainer, UiOffsets(left, top, right, bottom))
end
function FlyoutMenu:EnableFlyoutDelay(isEnabled, delay)
  self.enableFlyoutDelay = isEnabled
  if delay ~= nil then
    self.flyoutMenuDelay = delay
  end
end
function FlyoutMenu:SetClosedCallback(callingSelf, callback)
  self.closedContext = callingSelf
  self.closedCallback = callback
end
function FlyoutMenu:BlockUIInput()
  if self.USE_HOTKEYS then
    self.blockUIInputOnComplete = true
  end
end
function FlyoutMenu:SourceHoverOnly()
  self.sourceHoverOnly = true
  self:AdjustPositionContainerToInvokingEntity()
end
function FlyoutMenu:SetSourceHoverOnly(sourceHoverOnly)
  self.sourceHoverOnly = sourceHoverOnly
  for i, rowEntity in ipairs(self.rowEntities) do
    local rowTable = self.registrar:GetEntityTable(rowEntity)
    if rowTable and rowTable.OnChangeSourceHoverOnly then
      rowTable:OnChangeSourceHoverOnly(sourceHoverOnly)
    end
  end
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, not sourceHoverOnly)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.Dimmer1, not sourceHoverOnly)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.Dimmer2, not sourceHoverOnly)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.Dimmer3, not sourceHoverOnly)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.Dimmer4, not sourceHoverOnly)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.Frame, not sourceHoverOnly)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.FrameHover, not sourceHoverOnly)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Prototypes.DynamicTooltipSlice.Properties.Column2InputBlocker, not sourceHoverOnly)
  if sourceHoverOnly then
    self:AdjustPositionContainerToInvokingEntity()
  end
end
function FlyoutMenu:OnVisibilityChanged(isVisible)
  if isVisible == self.isVisible then
    if not isVisible and self.enableFlyoutDelay then
      self:OnFlyoutClose()
      self:ClearData()
    end
    return
  end
  self.isVisible = isVisible
  if self.USE_HOTKEYS and self.wasUIInputEnabled and not isVisible then
    LyShineManagerBus.Broadcast.RemoveActionMapOverrider(self.canvasId, self.actionMapToDisable)
  end
  self:Unlock()
  self:SetEnabled(isVisible)
  if not isVisible then
    DynamicBus.CompareTooltipRequestBus.Broadcast.HideTooltip()
    DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  end
end
function FlyoutMenu:Lock()
  if not UiCanvasBus.Event.GetEnabled(self.canvasId) then
    return false
  end
  if self.locked then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Dimmers, true)
  self.ScriptedEntityTweener:Stop(self.Properties.Dimmers)
  self.ScriptedEntityTweener:Set(self.Properties.Dimmers, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.Dimmers, 0.2, {
    delay = 0.3,
    opacity = 1,
    ease = "QuadOut"
  })
  self.locked = true
  if self.dockToCursor then
    self:PositionMenu()
  end
  local offsets = UiTransform2dBus.Event.GetOffsets(self.Properties.PositionContainer)
  local width = offsets.right - offsets.left
  offsets.top = offsets.top - width
  offsets.bottom = offsets.bottom + width
  UiTransform2dBus.Event.SetOffsets(self.Properties.PositionContainer, offsets)
  for k, rowEntity in pairs(self.rowEntities) do
    local rowTable = self.registrar:GetEntityTable(rowEntity)
    if rowTable and type(rowTable.OnFlyoutLocked) == "function" then
      rowTable:OnFlyoutLocked()
    end
  end
  return true
end
function FlyoutMenu:Unlock()
  UiElementBus.Event.SetIsEnabled(self.Properties.Dimmers, false)
  self.locked = false
end
function FlyoutMenu:IsLocked()
  return UiCanvasBus.Event.GetEnabled(self.canvasId) and self.locked
end
function FlyoutMenu:SetEnabled(isEnabled)
  self.isEnabled = isEnabled
  if isEnabled then
    LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
  else
    self:OnFlyoutClose()
    self.invokingEntityId = nil
    LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
    self.lastClosedTime = timeHelpers:ServerNow()
  end
end
function FlyoutMenu:ReturnElementToCache(element)
  if not element.slicePath then
    Log("ERROR: slicePath not defined in FlyoutMenu row element!")
    return
  end
  local cache = self.sliceNameToElementCache[element.slicePath]
  if not cache then
    Log("ERROR: cache does not exist for slicePath %s!", element.slicePath)
    return
  end
  UiElementBus.Event.SetIsEnabled(element.entityId, false)
  UiElementBus.Event.Reparent(element.entityId, self.Properties.Cache, EntityId())
  table.insert(cache.elements, element)
end
function FlyoutMenu:SetRowData(rows)
  if not rows or not type(rows) == "table" or #rows == 0 then
    Log("[FlyoutMenu] Invalid rows passed to SetRowData()")
    return
  end
  if self.enableFlyoutDelay then
    self.delayedFlyoutRows = rows
    self:OnFlyoutOpen(self.invokingEntityId)
    return
  else
    self.delayedFlyoutRows = nil
  end
  self:ClearRows()
  self.spawnCount = #rows
  for index, rowData in ipairs(rows) do
    local slicePath
    if rowData.type and rowData.type ~= "" then
      slicePath = self.rowSlices[rowData.type].sliceName
    else
      slicePath = rowData.slicePath
    end
    if slicePath then
      UiElementBus.Event.SetIsEnabled(self.Properties.BgPatternMask, not self.hideBg[slicePath])
      if self.hideBg[slicePath] then
        self:SetBackgroundVisibility(false)
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.FrameHover, not self.disableFrameHover[slicePath])
      local data = {
        rowData = rowData,
        index = index,
        slicePath = slicePath,
        spawned = false
      }
      local cache = self.sliceNameToElementCache[slicePath]
      if not cache then
        cache = {
          prototype = nil,
          elements = {}
        }
        self.sliceNameToElementCache[slicePath] = cache
      end
      if 0 < #cache.elements then
        local element = table.remove(self.sliceNameToElementCache[slicePath].elements)
        self:OnRowSpawned(element, data)
      elseif cache.prototype then
        Log("[FlyoutMenu] Cloning %s. Add another copy of this slice to the FlyoutMenu canvas to prevent spikes.", slicePath)
        local clonedEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, cache.prototype.entityId, self.Properties.Cache, EntityId())
        local element = self.registrar:GetEntityTable(clonedEntityId)
        self:OnRowSpawned(element, data)
      else
        rowData.deleteOnSpawn = false
        data.spawned = true
        Log("[FlyoutMenu] Spawning %s. Add this slice to the FlyoutMenu canvas to prevent spikes.", slicePath)
        self.spawnTickets[index] = self:SpawnSlice(self.RowContainer, slicePath, self.OnRowSpawned, data)
      end
    else
      Log("[FlyoutMenu] No slice path set for row type " .. rowData.type)
    end
  end
end
function FlyoutMenu:OnRowSpawned(element, data)
  self.spawnTickets[data.index] = nil
  element.slicePath = data.slicePath
  if element.slicePath == "LyShineUI/Tooltip/DynamicTooltip" then
    self.dynamicTooltipTable = element
  end
  if data.spawned and not self.sliceNameToElementCache[element.slicePath].prototype then
    self.sliceNameToElementCache[element.slicePath].prototype = element
  end
  if data.deleteOnSpawn then
    self:ReturnElementToCache(element)
    return
  end
  self.rowEntities[data.index] = element.entityId
  local deferHeightAdjustment = element.SetRowHeightCallback and type(element.SetRowHeightCallback) == "function"
  if deferHeightAdjustment then
    self.heightCallbackCount = self.heightCallbackCount + 1
    element:SetRowHeightCallback(self.RowHeightCallback, self)
  end
  element:SetData(data.rowData)
  if element.blockUIInput then
    self:BlockUIInput()
  end
  if not deferHeightAdjustment then
    local rowHeight = UiTransform2dBus.Event.GetLocalHeight(element.entityId)
    self.currentHeight = self.currentHeight + rowHeight
  end
  self.spawnCount = self.spawnCount - 1
  self:CheckLayoutComplete()
end
function FlyoutMenu:GetDynamicTooltipTable()
  return self.dynamicTooltipTable
end
function FlyoutMenu:RowHeightCallback(rowHeight)
  self.currentHeight = self.currentHeight + rowHeight
  self.heightCallbackCount = self.heightCallbackCount - 1
  self:CheckLayoutComplete()
end
function FlyoutMenu:CheckLayoutComplete()
  if self.spawnCount == 0 and self.heightCallbackCount == 0 then
    local maxWidth = 0
    for i = 1, #self.rowEntities do
      maxWidth = math.max(maxWidth, UiTransform2dBus.Event.GetLocalWidth(self.rowEntities[i]))
      UiElementBus.Event.SetIsEnabled(self.rowEntities[i], true)
      UiElementBus.Event.Reparent(self.rowEntities[i], self.RowContainer, EntityId())
    end
    self.maxWidth = maxWidth
    UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.currentHeight)
    UiTransform2dBus.Event.SetLocalWidth(self.entityId, maxWidth + self.padding)
    self:PositionMenu()
    self:OnFlyoutOpen(self.invokingEntityId)
  end
end
function FlyoutMenu:PositionMenu(locationOverride)
  locationOverride = locationOverride or self.openLocation
  local menuRect = UiTransformBus.Event.GetViewportSpaceRect(self.entityId)
  local menuHeight = menuRect:GetHeight()
  local menuWidth = menuRect:GetWidth()
  local containerRect = UiTransformBus.Event.GetViewportSpaceRect(self.Properties.PositionContainer)
  local arrowHeight = containerRect:GetHeight()
  local containerWidth = containerRect:GetWidth()
  local viewportSize = LyShineScriptBindRequestBus.Broadcast.GetViewportSize()
  locationOverride.x = Clamp(locationOverride.x, 0, viewportSize.x)
  locationOverride.y = Clamp(locationOverride.y, 0, viewportSize.y)
  local xOverride = {
    left = locationOverride.x,
    right = locationOverride.x
  }
  if self.lockToEntitySides and self.invokingEntityId then
    local invokingEntityRect = UiTransformBus.Event.GetViewportSpaceRect(self.invokingEntityId)
    xOverride.left = invokingEntityRect:GetCenterX() - invokingEntityRect:GetWidth() / 2
    xOverride.right = xOverride.left + invokingEntityRect:GetWidth()
  end
  self.isOnRight = true
  local flip = false
  if self.locationPreference == self.PREFER_RIGHT then
    if xOverride.right + menuWidth + self.extraWidth > viewportSize.x then
      flip = true
    end
  elseif self.locationPreference == self.PREFER_LEFT then
    if 0 <= xOverride.left - menuWidth then
      flip = true
    end
  else
    flip = locationOverride.x > viewportSize.x / 2
  end
  if self.lockToEntitySides then
    locationOverride.x = flip and xOverride.left or xOverride.right
  end
  local flipAdjustment = 0
  if self.flipBasedOnPosition and flip then
    if not self.locked and self.dockToCursor or self.lockToEntitySides then
      containerWidth = 0
    end
    flipAdjustment = menuWidth + containerWidth
    self.isOnRight = false
  end
  local xOffset = 0
  if self.dockToCursor then
    xOffset = (self.isOnRight and -1 or 1) * self.dockXOffset
  end
  local openOffsetY = self.dockToCursor and 0 or math.max(menuHeight / 2, menuHeight - arrowHeight) / 2
  local openOffset = locationOverride - Vector2(flipAdjustment + xOffset, openOffsetY)
  openOffset.y = Clamp(openOffset.y, 0, viewportSize.y - menuHeight)
  for k, rowEntity in pairs(self.rowEntities) do
    local rowTable = self.registrar:GetEntityTable(rowEntity)
    if rowTable and type(rowTable.SetFlyoutOnRight) == "function" then
      rowTable:SetFlyoutOnRight(self.isOnRight)
    end
  end
  UiElementBus.Event.SetIsEnabled(self.arrow1EntityId, not self.dockToCursor and self.isOnRight and self.showArrows)
  UiElementBus.Event.SetIsEnabled(self.arrow2EntityId, not self.dockToCursor and not self.isOnRight and self.showArrows)
  UiTransformBus.Event.SetLocalPosition(self.entityId, openOffset)
  DynamicBus.TooltipsRequestBus.Broadcast.SetFlyoutInfo(Vector2(openOffset.x, openOffset.y), UiTransform2dBus.Event.GetLocalWidth(self.entityId), self.isOnRight)
end
function FlyoutMenu:ExitHoverPositional()
  if self.allowPositionalExitHover then
    self:ExitHover()
  end
end
function FlyoutMenu:ExitHover()
  if self.ignoreHoverExit or self.locked then
    return true
  end
  local point, width, height
  local screenPoint = CursorBus.Broadcast.GetCursorPosition()
  if not self.sourceHoverOnly then
    point = UiTransformBus.Event.ViewportPointToLocalPoint(self.entityId, screenPoint)
    width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
    height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
    if point.x > 0 and width > point.x and 0 < point.y and height > point.y then
      return true
    end
  end
  point = UiTransformBus.Event.ViewportPointToLocalPoint(self.Properties.PositionContainer, screenPoint)
  width = UiTransform2dBus.Event.GetLocalWidth(self.Properties.PositionContainer)
  height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.PositionContainer)
  if point.x > 0 and width > point.x and 0 < point.y and height > point.y then
    return true
  end
  DynamicBus.CompareTooltipRequestBus.Broadcast.HideTooltip()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  self.ScriptedEntityTweener:Play(self.Properties.PositionContainer, self.fadeOutTime, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.entityId, self.fadeOutTime, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    end
  })
  return false
end
function FlyoutMenu:SetFadeOutTime(timeSeconds)
  self.fadeOutTime = timeSeconds
end
function FlyoutMenu:OnOpenFlyoutWork()
  self.dataLayer:SetScreenEnabled("FlyoutMenuWork", true)
end
function FlyoutMenu:SetSoundOnShow(value)
  self.soundOnShow = value
end
function FlyoutMenu:SetSoundOnHide(value)
  self.soundOnHide = value
end
function FlyoutMenu:OnClickBackground()
  self.ScriptedEntityTweener:Play(self.Properties.Dimmers, self.fadeOutTime, {
    delay = 0,
    opacity = 0,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.PositionContainer, self.fadeOutTime, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.entityId, self.fadeOutTime, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    end
  })
end
return FlyoutMenu
