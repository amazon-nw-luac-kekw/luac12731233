local g_timelineCounter = 0
local g_animationCallbackCounter = 0
local g_animationCallbacks = {}
local ScriptedEntityTweener = {}
function ScriptedEntityTweener:OnActivate()
  if self.tweenerNotificationHandler == nil then
    self.animationParameterShortcuts = {
      opacity = {
        "UiFaderComponent",
        "Fade",
        function(entityId, value)
          UiFaderBus.Event.SetFadeValue(entityId, value)
        end
      },
      saturation = {
        "UiDesaturatorComponent",
        "Saturation",
        function(entityId, value)
          UiDesaturatorBus.Event.SetSaturationValue(entityId, value)
        end
      },
      imgColor = {
        "UiImageComponent",
        "Color",
        function(entityId, value)
          UiImageBus.Event.SetColor(entityId, value)
        end
      },
      imgAlpha = {
        "UiImageComponent",
        "Alpha",
        function(entityId, value)
          UiImageBus.Event.SetAlpha(entityId, value)
        end
      },
      imgFill = {
        "UiImageComponent",
        "FillAmount",
        function(entityId, value)
          UiImageBus.Event.SetFillAmount(entityId, value)
        end
      },
      imgFillAngle = {
        "UiImageComponent",
        "RadialFillStartAngle",
        function(entityId, value)
          UiImageBus.Event.SetRadialFillStartAngle(entityId, value)
        end
      },
      layoutMinWidth = {
        "UiLayoutCellComponent",
        "MinWidth",
        function(entityId, value)
          UiLayoutCellBus.Event.SetMinWidth(entityId, value)
        end
      },
      layoutMinHeight = {
        "UiLayoutCellComponent",
        "MinHeight",
        function(entityId, value)
          UiLayoutCellBus.Event.SetMinHeight(entityId, value)
        end
      },
      layoutTargetWidth = {
        "UiLayoutCellComponent",
        "TargetWidth",
        function(entityId, value)
          UiLayoutCellBus.Event.SetTargetWidth(entityId, value)
        end
      },
      layoutTargetHeight = {
        "UiLayoutCellComponent",
        "TargetHeight",
        function(entityId, value)
          UiLayoutCellBus.Event.SetTargetHeight(entityId, value)
        end
      },
      layoutExtraWidthRatio = {
        "UiLayoutCellComponent",
        "ExtraWidthRatio",
        function(entityId, value)
          UiLayoutCellBus.Event.SetExtraWidthRatio(entityId, value)
        end
      },
      layoutExtraHeightRatio = {
        "UiLayoutCellComponent",
        "ExtraHeightRatio",
        function(entityId, value)
          UiLayoutCellBus.Event.SetExtraHeightRatio(entityId, value)
        end
      },
      layoutColumnPadding = {
        "UiLayoutColumnComponent",
        "Padding"
      },
      layoutColumnSpacing = {
        "UiLayoutColumnComponent",
        "Spacing"
      },
      layoutRowPadding = {
        "UiLayoutRowComponent",
        "Padding"
      },
      layoutRowSpacing = {
        "UiLayoutRowComponent",
        "Spacing"
      },
      scrollHandleSize = {
        "UiScrollBarComponent",
        "HandleSize"
      },
      scrollHandleMinPixelSize = {
        "UiScrollBarComponent",
        "MinHandlePixelSize"
      },
      scrollValue = {
        "UiScrollBarComponent",
        "Value"
      },
      sliderValue = {
        "UiSliderComponent",
        "Value"
      },
      sliderMinValue = {
        "UiSliderComponent",
        "MinValue"
      },
      sliderMaxValue = {
        "UiSliderComponent",
        "MaxValue"
      },
      sliderStepValue = {
        "UiSliderComponent",
        "StepValue"
      },
      textSize = {
        "UiTextComponent",
        "FontSize",
        function(entityId, value)
          UiTextBus.Event.SetFontSize(entityId, value)
        end
      },
      textColor = {
        "UiTextComponent",
        "Color",
        function(entityId, value)
          UiTextBus.Event.SetColor(entityId, value)
        end
      },
      textCharacterSpace = {
        "UiTextComponent",
        "CharacterSpacing",
        function(entityId, value)
          UiTextBus.Event.SetCharacterSpacing(entityId, value)
        end
      },
      textSpacing = {
        "UiTextComponent",
        "LineSpacing",
        function(entityId, value)
          UiTextBus.Event.SetLineSpacing(entityId, value)
        end
      },
      textInputSelectionColor = {
        "UiTextInputComponent",
        "TextSelectionColor"
      },
      textInputCursorColor = {
        "UiTextInputComponent",
        "TextCursorColor"
      },
      textInputCursorBlinkInterval = {
        "UiTextInputComponent",
        "CursorBlinkInterval"
      },
      textInputMaxStringLength = {
        "UiTextInputComponent",
        "MaxStringLength"
      },
      tooltipDelayTime = {
        "UiTooltipDisplayComponent",
        "DelayTime"
      },
      tooltipDisplayTime = {
        "UiTooltipDisplayComponent",
        "DisplayTime"
      },
      scaleX = {
        "UiTransform2dComponent",
        "ScaleX",
        function(entityId, value)
          UiTransformBus.Event.SetScaleX(entityId, value)
        end
      },
      scaleY = {
        "UiTransform2dComponent",
        "ScaleY",
        function(entityId, value)
          UiTransformBus.Event.SetScaleY(entityId, value)
        end
      },
      pivotX = {
        "UiTransform2dComponent",
        "PivotX",
        function(entityId, value)
          UiTransformBus.Event.SetPivotX(entityId, value)
        end
      },
      pivotY = {
        "UiTransform2dComponent",
        "PivotY",
        function(entityId, value)
          UiTransformBus.Event.SetPivotY(entityId, value)
        end
      },
      x = {
        "UiTransform2dComponent",
        "LocalPositionX",
        function(entityId, value)
          UiTransformBus.Event.SetLocalPositionX(entityId, value)
        end
      },
      y = {
        "UiTransform2dComponent",
        "LocalPositionY",
        function(entityId, value)
          UiTransformBus.Event.SetLocalPositionY(entityId, value)
        end
      },
      rotation = {
        "UiTransform2dComponent",
        "Rotation",
        function(entityId, value)
          UiTransformBus.Event.SetZRotation(entityId, value)
        end
      },
      w = {
        "UiTransform2dComponent",
        "LocalWidth",
        function(entityId, value)
          UiTransform2dBus.Event.SetLocalWidth(entityId, value)
        end
      },
      h = {
        "UiTransform2dComponent",
        "LocalHeight",
        function(entityId, value)
          UiTransform2dBus.Event.SetLocalHeight(entityId, value)
        end
      },
      anchors = {
        "UiTransform2dComponent",
        "Anchors"
      },
      scrollBoxOffsettX = {
        "UiScrollBoxComponent",
        "ScrollOffsetX",
        function(entityId, value)
          UiScrollBoxBus.Event.SetScrollOffsetX(entityId, value)
        end
      },
      scrollBoxOffsettY = {
        "UiScrollBoxComponent",
        "ScrollOffsetY",
        function(entityId, value)
          UiScrollBoxBus.Event.SetScrollOffsetY(entityId, value)
        end
      },
      ["3dposition"] = {
        "TransformComponent",
        "Position"
      },
      ["3drotation"] = {
        "TransformComponent",
        "Rotation"
      },
      ["3dscale"] = {
        "TransformComponent",
        "Scale"
      },
      pos3d = {
        "GameTransformComponent",
        "Position"
      },
      rot3d = {
        "GameTransformComponent",
        "Rotation"
      },
      scale3d = {
        "GameTransformComponent",
        "Scale"
      },
      camFov = {
        "CameraComponent",
        "FieldOfView"
      },
      camNear = {
        "CameraComponent",
        "NearClipDistance"
      },
      camFar = {
        "CameraComponent",
        "FarClipDistance"
      }
    }
    if not self.animationParameterShortcutToId then
      self.animationParameterShortcutToId = {}
      for shortcutStr, shortcutData in pairs(self.animationParameterShortcuts) do
        local virtualPropertyId = ScriptedEntityTweenerBus.Broadcast.CacheVirtualProperty(shortcutData[1], shortcutData[2])
        self.animationParameterShortcutToId[shortcutStr] = virtualPropertyId
      end
    end
    self.animationEaseMethodShortcuts = {
      Linear = ScriptedEntityTweenerEasingMethod_Linear,
      Quad = ScriptedEntityTweenerEasingMethod_Quad,
      Cubic = ScriptedEntityTweenerEasingMethod_Cubic,
      Quart = ScriptedEntityTweenerEasingMethod_Quart,
      Quint = ScriptedEntityTweenerEasingMethod_Quint,
      Sine = ScriptedEntityTweenerEasingMethod_Sine,
      Expo = ScriptedEntityTweenerEasingMethod_Expo,
      Circ = ScriptedEntityTweenerEasingMethod_Circ,
      Elastic = ScriptedEntityTweenerEasingMethod_Elastic,
      Back = ScriptedEntityTweenerEasingMethod_Back,
      Bounce = ScriptedEntityTweenerEasingMethod_Bounce
    }
    self.animationEaseTypeShortcuts = {
      [1] = {"InOut", ScriptedEntityTweenerEasingType_InOut},
      [2] = {"In", ScriptedEntityTweenerEasingType_In},
      [3] = {"Out", ScriptedEntityTweenerEasingType_Out}
    }
    self.tweenerNotificationHandler = ScriptedEntityTweenerNotificationBus.Connect(self)
    self.tickBusHandler = TickBus.Connect(self)
    self.activationCount = 0
    self.timelineRefs = {}
  end
  self.activationCount = self.activationCount + 1
end
function ScriptedEntityTweener:OnDeactivate()
  if self.tweenerNotificationHandler then
    self.activationCount = self.activationCount - 1
    if self.activationCount == 0 then
      self.tweenerNotificationHandler:Disconnect()
      self.tweenerNotificationHandler = nil
      self.tickBusHandler:Disconnect()
      self.tickBusHandler = nil
    end
  end
end
function ScriptedEntityTweener:Reset()
  ClearTable(g_animationCallbacks)
  g_animationCallbackCounter = 0
  g_timelineCounter = 0
end
function ScriptedEntityTweener:Stop(id)
  ScriptedEntityTweenerBus.Broadcast.Stop(0, id)
end
function ScriptedEntityTweener:Set(id, args)
  for arg, paramTarget in pairs(args) do
    local componentData = self.animationParameterShortcuts[arg]
    if componentData then
      local func = componentData[3]
      if func then
        func(id, paramTarget)
      else
        self:StartAnimation(id, 0, args)
        return
      end
    end
  end
end
function ScriptedEntityTweener:Play(id, duration, args, toArgs)
  self:StartAnimation(id, duration, args, toArgs, false)
end
function ScriptedEntityTweener:CacheAnimation(duration, args, toArgs)
  if toArgs ~= nil then
    Debug.Log("Warning: ScriptedEntityTweener cacheAnimation doesn't support FromTo animations")
    Debug.Log(debug.traceback())
    return
  end
  return self:StartAnimation(nil, duration, args, toArgs, true)
end
function ScriptedEntityTweener:PlayC(entityId, duration, animationId, delay, onComplete, onUpdate, onLoop)
  delay = delay or 0
  local onCompleteCbId = 0
  if onComplete then
    onCompleteCbId = self:CreateCallback(onComplete)
  end
  local onUpdateCbId = 0
  if onUpdate then
    onUpdateCbId = self:CreateCallback(onUpdate)
  end
  local onLoopCbId = 0
  if onLoop then
    onLoopCbId = self:CreateCallback(onLoop)
  end
  ScriptedEntityTweenerBus.Broadcast.StartCachedAnimation(entityId, animationId, duration, delay, onCompleteCbId, onUpdateCbId, onLoopCbId)
end
function ScriptedEntityTweener:PlayFromC(entityId, duration, fromAnims, animationId, delay, onComplete, onUpdate, onLoop)
  self:Set(entityId, fromAnims)
  self:PlayC(entityId, duration, animationId, delay, onComplete, onUpdate, onLoop)
end
ScriptedEntityTweener.optionalParams = {}
ScriptedEntityTweener.nullUuid = Uuid.CreateNull()
ScriptedEntityTweener.easeCache = {}
function ScriptedEntityTweener:StartAnimation(id, duration, args, toArgs, cacheAnim)
  if self.animationParameterShortcuts == nil then
    Debug.Log("ScriptedEntityTweener: Make sure to call OnActivate() and OnDeactivate() for this table when requiring this file")
    return
  end
  if type(id) == "table" and duration == nil and args == nil then
    args = id
  end
  if toArgs then
    self:Set(id, args)
    self:Play(id, duration, toArgs)
    return
  end
  local easeMethod = args.easeMethod
  local easeType = args.easeType
  if args.ease then
    if args.easeMethod then
      Debug.Log("ScriptedEntityTweener: Warning, easeMethod will be overriden by ease parameter")
    end
    if args.easeType then
      Debug.Log("ScriptedEntityTweener: Warning, easeType will be overriden by ease parameter")
    end
    local easeData = self.easeCache[args.ease]
    if easeData then
      easeMethod = easeData[1]
      easeType = easeData[2]
    else
      for easeName, easeValue in pairs(self.animationEaseMethodShortcuts) do
        if string.match(args.ease, easeName) then
          easeMethod = easeValue
          break
        end
      end
      for i, easeTypeData in ipairs(self.animationEaseTypeShortcuts) do
        local easeStr = easeTypeData[1]
        if string.match(args.ease, easeStr) then
          easeType = easeTypeData[2]
          break
        end
      end
      self.easeCache[args.ease] = {easeMethod, easeType}
    end
  end
  local optionalParams_timelineId
  local optionalParams_timeIntoTween = args.timeIntoTween or 0
  local optionalParams_duration = duration or args.duration or 0
  local optionalParams_easeMethod = easeMethod or ScriptedEntityTweenerEasingMethod_Linear
  local optionalParams_easeType = easeType or ScriptedEntityTweenerEasingType_Out
  local optionalParams_delay = args.delay or 0
  local optionalParams_timesToPlay = args.timesToPlay or 1
  local optionalParams_isFrom = args.isFrom
  local optionalParams_isPlayingBackward = args.isPlayingBackward
  local optionalParams_uuid = args.uuid or self.nullUuid
  local optionalParams_onComplete, optionalParams_onUpdate, optionalParams_onLoop
  if args.timelineParams ~= nil then
    optionalParams_delay = optionalParams_delay + args.timelineParams.initialStartTime
    optionalParams_timeIntoTween = optionalParams_timeIntoTween + args.timelineParams.timeIntoTween
    optionalParams_timelineId = args.timelineParams.timelineId
    optionalParams_uuid = args.timelineParams.uuidOverride
    if args.timelineParams.durationOverride ~= nil then
      optionalParams_duration = args.timelineParams.durationOverride
    end
    if args.timelineParams.seekDelayOverride ~= nil then
      optionalParams_delay = args.timelineParams.seekDelayOverride
    end
    if args.timelineParams.reversePlaybackOverride then
      if optionalParams_isPlayingBackward == nil then
        optionalParams_isPlayingBackward = false
      end
      optionalParams_isPlayingBackward = not optionalParams_isPlayingBackward
    end
  end
  if args.onComplete ~= nil then
    optionalParams_onComplete = self:CreateCallback(args.onComplete)
  end
  if args.onUpdate ~= nil then
    optionalParams_onUpdate = self:CreateCallback(args.onUpdate)
  end
  if args.onLoop ~= nil then
    optionalParams_onLoop = self:CreateCallback(args.onLoop)
  end
  local animationId
  ScriptedEntityTweenerBus.Broadcast.SetOptionalParams(optionalParams_timeIntoTween, optionalParams_duration, optionalParams_easeMethod, optionalParams_easeType, optionalParams_delay, optionalParams_timesToPlay, optionalParams_isFrom == true, optionalParams_isPlayingBackward == true, optionalParams_uuid, optionalParams_timelineId or 0, optionalParams_onComplete or 0, optionalParams_onUpdate or 0, optionalParams_onLoop or 0)
  for shortcutName, paramTarget in pairs(args) do
    local virtualPropertyId = self.animationParameterShortcutToId[shortcutName]
    if virtualPropertyId then
      if cacheAnim then
        animationId = ScriptedEntityTweenerBus.Broadcast.CacheAnimation(virtualPropertyId, paramTarget, animationId == nil)
      else
        ScriptedEntityTweenerBus.Broadcast.AnimateEntity(args.id or id, virtualPropertyId, paramTarget)
      end
    end
  end
  return animationId
end
function ScriptedEntityTweener:ValidateAnimationParameters(args, isCache)
  if args == nil then
    Debug.Log("ScriptedEntityTweener: animation with invalid args, args == nil")
    return false
  end
  if args.id == nil and not isCache then
    Debug.Log("ScriptedEntityTweener: animation with no id specified " .. self:DumpTable(args))
    return false
  end
  if not isCache and not args.id:IsValid() then
    return
  end
  return true
end
function ScriptedEntityTweener:DumpTable(inputTable)
  if type(inputTable) == "table" then
    local s = "{ "
    for k, v in pairs(inputTable) do
      if type(k) ~= "number" then
        k = "\"" .. k .. "\""
      end
      s = s .. "[" .. k .. "] = " .. self:DumpTable(v) .. ","
    end
    return s .. "} "
  else
    return tostring(inputTable)
  end
end
function ScriptedEntityTweener:ConvertShortcutsToVirtualProperties(args)
  if args.virtualProperties == nil then
    args.virtualProperties = {}
  end
  for shortcutName, paramTarget in pairs(args) do
    local virtualPropertyId = self.animationParameterShortcutToId[shortcutName]
    if virtualPropertyId then
      args.virtualProperties[virtualPropertyId] = paramTarget
    end
  end
end
function ScriptedEntityTweener:CreateCallback(fnCallback)
  g_animationCallbackCounter = g_animationCallbackCounter + 1
  g_animationCallbacks[g_animationCallbackCounter] = fnCallback
  return g_animationCallbackCounter
end
function ScriptedEntityTweener:RemoveCallback(callbackId)
  g_animationCallbacks[callbackId] = nil
end
function ScriptedEntityTweener:CallCallback(callbackId)
  local callbackFn = g_animationCallbacks[callbackId]
  if callbackFn ~= nil then
    callbackFn()
  end
end
function ScriptedEntityTweener:OnComplete(callbackId)
  self:CallCallback(callbackId)
  self:RemoveCallback(callbackId)
end
function ScriptedEntityTweener:OnUpdate(callbackId, currentValue, progressPercent)
  local callbackFn = g_animationCallbacks[callbackId]
  if callbackFn ~= nil then
    callbackFn(currentValue, progressPercent)
  end
end
function ScriptedEntityTweener:OnLoop(callbackId)
  self:CallCallback(callbackId)
end
function ScriptedEntityTweener:OnTick(deltaTime, timePoint)
  for timelineId, timeline in pairs(self.timelineRefs) do
    timeline.currentSeekTime = timeline.currentSeekTime + deltaTime
  end
end
function ScriptedEntityTweener:GetUniqueTimelineId()
  g_timelineCounter = g_timelineCounter + 1
  return g_timelineCounter
end
function ScriptedEntityTweener:TimelineCreate()
  local timeline = {}
  timeline.animations = {}
  timeline.labels = {}
  timeline.duration = 0
  timeline.isPaused = false
  timeline.timelineId = self:GetUniqueTimelineId()
  timeline.currentSeekTime = 0
  function timeline.GetDurationOfAnim(timelineSelf, animParams)
    return (animParams.duration or 0) - (animParams.timeIntoTween or 0) + (animParams.delay or 0)
  end
  function timeline.Add(timelineSelf, id, duration, animParams, timelineParams)
    if timelineSelf == nil then
      Debug.Log("ScriptedEntityTweener:TimelineAdd no timeline")
      return
    end
    animParams.id = id
    animParams.duration = duration
    if self:ValidateAnimationParameters(animParams) == false then
      Debug.Log("ScriptedEntityTweener:TimelineAdd invalid animation parameters for timline uuid " .. self:DumpTable(animParams))
      return
    end
    local optionalParams_offset = 0
    local optionalParams_initialStartTime
    if timelineParams ~= nil then
      if timelineParams.label then
        optionalParams_initialStartTime = timelineSelf.labels[timelineParams.label]
      else
        optionalParams_initialStartTime = timelineParams.initialStartTime
      end
      optionalParams_offset = timelineParams.offset or 0
    end
    animParams.timelineParams = {}
    animParams.timelineParams.initialStartTime = optionalParams_initialStartTime or timelineSelf.duration
    animParams.timelineParams.initialStartTime = animParams.timelineParams.initialStartTime + optionalParams_offset
    animParams.timelineParams.timeIntoTween = 0
    animParams.timelineParams.seekDelayOverride = nil
    animParams.timelineParams.durationOverride = nil
    animParams.timelineParams.timelineId = timelineSelf.timelineId
    animParams.timelineParams.uuidOverride = Uuid.Create()
    self:ConvertShortcutsToVirtualProperties(animParams)
    animParams.timelineParams.initialValues = {}
    for virtualPropertyId, paramTarget in pairs(animParams.virtualProperties) do
      animParams.timelineParams.initialValues[virtualPropertyId] = ScriptedEntityTweenerBus.Broadcast.GetVirtualPropertyValue(animParams.id, virtualPropertyId)
    end
    timelineSelf.animations[#timelineSelf.animations + 1] = animParams
    timelineSelf.duration = timelineSelf.duration + timelineSelf:GetDurationOfAnim(animParams)
    table.sort(timelineSelf.animations, function(first, second)
      return first.timelineParams.initialStartTime < second.timelineParams.initialStartTime
    end)
  end
  function timeline.AddLabel(timelineSelf, labelId, labelTime)
    if labelId == nil then
      Debug.Log("Warning: TimelineLabel: labelId is nil")
      return
    end
    if labelTime == nil then
      Debug.Log("TimelineLabel: label " .. labelId .. " doesn't have a labelTime")
      return
    end
    if timelineSelf.labels[labelId] ~= nil then
      Debug.Log("Warning: TimelineLabel: label " .. labelId .. " already exists")
    end
    timeline.labels[labelId] = labelTime
  end
  function timeline.Play(timelineSelf, labelOrTime)
    timelineSelf:Resume()
    local startTime = 0
    if labelOrTime ~= nil then
      local typeInfo = type(labelOrTime)
      if typeInfo == "string" then
        startTime = timelineSelf.labels[labelOrTime] or 0
      elseif typeInfo == "number" then
        startTime = labelOrTime
      end
    end
    timelineSelf:Seek(startTime)
  end
  function timeline.Stop(timelineSelf)
    for i = 1, #timelineSelf.animations do
      local animParams = timelineSelf.animations[i]
      ScriptedEntityTweenerBus.Broadcast.Stop(timelineSelf.timelineId, animParams.id)
    end
  end
  function timeline.Pause(timelineSelf)
    timelineSelf.isPaused = true
    for i = 1, #timelineSelf.animations do
      local animParams = timelineSelf.animations[i]
      for virtualPropertyId, paramTarget in pairs(animParams.virtualProperties) do
        ScriptedEntityTweenerBus.Broadcast.Pause(timelineSelf.timelineId, animParams.id, virtualPropertyId)
      end
    end
  end
  function timeline.Resume(timelineSelf)
    timelineSelf.isPaused = false
    for i = 1, #timelineSelf.animations do
      local animParams = timelineSelf.animations[i]
      for virtualPropertyId, paramTarget in pairs(animParams.virtualProperties) do
        ScriptedEntityTweenerBus.Broadcast.Resume(timelineSelf.timelineId, animParams.id, virtualPropertyId)
      end
    end
  end
  function timeline.ResetRuntimeVars(timelineSelf, animParams)
    animParams.timelineParams.timeIntoTween = 0
    animParams.timelineParams.reversePlaybackOverride = nil
    animParams.timelineParams.seekDelayOverride = nil
    animParams.timelineParams.durationOverride = nil
  end
  function timeline.Seek(timelineSelf, seekTime)
    local typeInfo = type(seekTime)
    if typeInfo == "string" then
      seekTime = timelineSelf.labels[seekTime] or 0
    end
    timelineSelf.currentSeekTime = seekTime
    local runningDuration = 0
    for i = 1, #timelineSelf.animations do
      local animParams = timelineSelf.animations[i]
      local prevCompletionState = seekTime > runningDuration
      runningDuration = runningDuration + timelineSelf:GetDurationOfAnim(animParams)
      local currentCompletionState = seekTime > runningDuration
      timelineSelf:ResetRuntimeVars(animParams)
      if seekTime >= runningDuration then
        animParams.timelineParams.seekDelayOverride = 0
        animParams.timelineParams.durationOverride = 0
      elseif prevCompletionState ~= currentCompletionState then
        local diff = runningDuration - seekTime
        animParams.timelineParams.timeIntoTween = timelineSelf:GetDurationOfAnim(animParams) - diff
        animParams.timelineParams.seekDelayOverride = 0
      elseif seekTime < runningDuration then
        animParams.timelineParams.seekDelayOverride = (animParams.delay or 0) + (animParams.timelineParams.initialStartTime - seekTime)
      end
    end
    for i = 1, #timelineSelf.animations do
      local animParams = timelineSelf.animations[i]
      self:StartAnimation(nil, nil, animParams)
    end
  end
  function timeline.PlayBackwards(timelineSelf, specificSeekTime)
    local seekTime = specificSeekTime
    if seekTime == nil then
      seekTime = timelineSelf.currentSeekTime
    end
    local animsToPlay = {}
    local runningDuration = 0
    for i = 1, #timelineSelf.animations do
      local animParams = timelineSelf.animations[i]
      runningDuration = runningDuration + timelineSelf:GetDurationOfAnim(animParams)
      timelineSelf:ResetRuntimeVars(animParams)
      if seekTime >= runningDuration then
        animParams.timelineParams.timeIntoTween = timelineSelf:GetDurationOfAnim(animParams)
        animParams.timelineParams.seekDelayOverride = seekTime - runningDuration
        animParams.timelineParams.reversePlaybackOverride = true
        if not timelineSelf.isPaused then
          animsToPlay[#animsToPlay + 1] = animParams
        end
      else
        for virtualPropertyId, paramTarget in pairs(animParams.virtualProperties) do
          ScriptedEntityTweenerBus.Broadcast.SetPlayDirectionReversed(timelineSelf.timelineId, animParams.id, virtualPropertyId, true)
        end
      end
    end
    table.sort(animsToPlay, function(first, second)
      return first.timelineParams.initialStartTime < second.timelineParams.initialStartTime
    end)
    for i = 1, #animsToPlay do
      local animParams = animsToPlay[i]
      local initialValues = {}
      for virtualPropertyId, paramInitial in pairs(animParams.timelineParams.initialValues) do
        initialValues[virtualPropertyId] = paramInitial
      end
      self:StartAnimation(animParams)
      for virtualPropertyId, paramInitial in pairs(initialValues) do
        ScriptedEntityTweenerBus.Broadcast.SetInitialValue(animParams.timelineParams.uuidOverride, animParams.id, virtualPropertyId, paramInitial)
      end
    end
  end
  function timeline.SetSpeed(timelineSelf, multiplier)
    for i = 1, #timelineSelf.animations do
      local animParams = timelineSelf.animations[i]
      for virtualPropertyId, paramTarget in pairs(animParams.virtualProperties) do
        ScriptedEntityTweenerBus.Broadcast.SetSpeed(timelineSelf.timelineId, animParams.id, virtualPropertyId, multiplier)
      end
    end
  end
  function timeline.SetCompletion(timelineSelf, percentage)
    timelineSelf:Seek(timelineSelf.duration * percentage)
  end
  function timeline.GetCurrentSeekTime(timelineSelf)
    return timelineSelf.currentSeekTime
  end
  self.timelineRefs[timeline.timelineId] = timeline
  return timeline
end
function ScriptedEntityTweener:TimelineDestroy(timeline)
  self.timelineRefs[timeline.timelineId] = nil
end
function ScriptedEntityTweener:OnTimelineAnimationStart(timelineId, animUuid, virtualPropertyId)
  local timeline = self.timelineRefs[timelineId]
  if timeline == nil then
    return
  end
  for i = 1, #timeline.animations do
    local animParams = timeline.animations[i]
    if animParams.timelineParams.uuidOverride == animUuid then
      for propertyId, paramTarget in pairs(animParams.virtualProperties) do
        if propertyId == virtualPropertyId then
          animParams.timelineParams.initialValues[propertyId] = ScriptedEntityTweenerBus.Broadcast.GetVirtualPropertyValue(animParams.id, virtualPropertyId)
          break
        end
      end
    end
  end
end
return ScriptedEntityTweener
