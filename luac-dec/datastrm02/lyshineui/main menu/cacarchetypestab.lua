local CACArchetypesTab = {
  Properties = {
    PrimaryTitle = {
      default = EntityId()
    },
    SecondaryTitle = {
      default = EntityId()
    },
    BackstoryText = {
      default = EntityId()
    },
    CarouselContent = {
      default = EntityId()
    },
    ArchetypesList = {
      default = EntityId()
    },
    ArchetypeSpawner = {
      default = EntityId()
    },
    ArrowButtonLeft = {
      default = EntityId()
    },
    ArrowButtonRight = {
      default = EntityId()
    },
    ArrowImageLeft = {
      default = EntityId()
    },
    ArrowImageRight = {
      default = EntityId()
    },
    ScrollBox = {
      default = EntityId()
    },
    NextButton = {
      default = EntityId()
    },
    Scrim = {
      default = EntityId()
    }
  },
  ArchetypeSlicePath = "LyShineUI\\Main Menu\\ArchetypeScreenItem",
  ArchetypeData = nil,
  ArchetypeItemEntities = {},
  itemWidth = 330,
  itemSpacing = 12,
  spawnerBusHandler = nil,
  mainMenuNotificationBus = nil,
  selectedIndex = 0,
  archetypeText = "",
  characterEntityId = EntityId(),
  maxChoicesToTrack = 5,
  archetypeChoiceOrder = {},
  isScreenVisible = false,
  animDelay = 0.4
}
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(CACArchetypesTab)
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CACArchetypesTab)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function CACArchetypesTab:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  self.ArchetypeData = {
    {
      name = "@ftue_archetypes_name_covenant",
      id = "Backstory1",
      description = "@ftue_archetypes_desc_covenant",
      attribute = "@ftue_archetypes_attr_covenant",
      imgPath = "LyShineUI\\Images\\Climax\\Backstory\\ArchetypeImages\\Backstory_Image_Covenant.png"
    },
    {
      name = "@ftue_archetypes_name_marauders",
      id = "Backstory2",
      description = "@ftue_archetypes_desc_marauders",
      attribute = "@ftue_archetypes_attr_marauders",
      imgPath = "LyShineUI\\Images\\Climax\\Backstory\\ArchetypeImages\\Backstory_Image_Marauders.png"
    },
    {
      name = "@ftue_archetypes_name_syndicate",
      id = "Backstory3",
      description = "@ftue_archetypes_desc_syndicate",
      attribute = "@ftue_archetypes_attr_syndicate",
      imgPath = "LyShineUI\\Images\\Climax\\Backstory\\ArchetypeImages\\Backstory_Image_Syndicate.png"
    }
  }
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.ArchetypeSpawner)
  self:BusConnect(UiMainMenuBus)
  UiMainMenuRequestBus.Broadcast.RequestCustomizableCharacterEntityId()
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  for i = 1, #self.ArchetypeData do
    local data = self.ArchetypeData[i]
    data.itemIndex = i
    self:SpawnSlice(self.Properties.ArchetypeSpawner, self.ArchetypeSlicePath, self.OnArchetypeSpawned, data)
  end
  self:SetVisuaElements()
end
function CACArchetypesTab:OnShutdown()
  for i, entity in pairs(self.ArchetypeItemEntities) do
    UiElementBus.Event.DestroyElement(entity.entityId)
    self.ArchetypeItemEntities[i] = nil
  end
  if self.arrowLeftTimeline ~= nil then
    self.arrowLeftTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.arrowLeftTimeline)
  end
  if self.arrowRightTimeline ~= nil then
    self.arrowRightTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.arrowRightTimeline)
  end
end
function CACArchetypesTab:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.Properties.Scrim, self.canvasId)
  end
end
function CACArchetypesTab:SetVisuaElements()
  local secondaryStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 26,
    fontColor = self.UIStyle.COLOR_GRAY_70,
    fontEffect = self.UIStyle.FONT_EFFECT_DROPSHADOW
  }
  local backstoryTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 28,
    fontColor = self.UIStyle.COLOR_GRAY_90,
    fontEffect = self.UIStyle.FONT_EFFECT_DROPSHADOW
  }
  SetTextStyle(self.PrimaryTitle, self.UIStyle.FONT_STYLE_HEADER_SMALL_CAPS_BIG)
  SetTextStyle(self.SecondaryTitle, secondaryStyle)
  SetTextStyle(self.BackstoryText, backstoryTextStyle)
  UiTextBus.Event.SetTextWithFlags(self.PrimaryTitle, "@ftue_archetypes_title", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.SecondaryTitle, "", eUiTextSet_SetLocalized)
  self.arrowLeftTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.arrowLeftTimeline:Add(self.Properties.ArrowImageLeft, 0.4, {x = 0, ease = "QuadOut"})
  self.arrowLeftTimeline:Add(self.Properties.ArrowImageLeft, 0.1, {x = 0})
  self.arrowLeftTimeline:Add(self.Properties.ArrowImageLeft, 0.4, {
    x = -15,
    ease = "QuadIn",
    onComplete = function()
      self.arrowLeftTimeline:Play()
    end
  })
  self.arrowLeftTimeline:Play()
  self.arrowRightTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.arrowRightTimeline:Add(self.Properties.ArrowImageRight, 0.4, {x = 15, ease = "QuadOut"})
  self.arrowRightTimeline:Add(self.Properties.ArrowImageRight, 0.1, {x = 15})
  self.arrowRightTimeline:Add(self.Properties.ArrowImageRight, 0.4, {
    x = 0,
    ease = "QuadIn",
    onComplete = function()
      self.arrowRightTimeline:Play()
    end
  })
  self.arrowRightTimeline:Play()
end
function CACArchetypesTab:OnArchetypeSpawned(entity, data)
  entity:SetName(data.name)
  entity:SetAttribute(data.attribute)
  entity:SetPortrait(data.imgPath)
  entity:SetItemIndex(data.itemIndex)
  entity:SetTooltip(data.description)
  entity:SetState(EArchetypeItemState.Idle)
  self.ArchetypeItemEntities[data.itemIndex] = entity
end
function CACArchetypesTab:OnIndexSelected(index)
  selectedIndex = index
end
function CACArchetypesTab:UpdateArchetypeText()
  UiTextBus.Event.SetText(self.Properties.BackstoryText, self.archetypeText)
  if UiTextBus.Event.GetText(self.Properties.BackstoryText) ~= "" then
    self.animDelay = 0.5
  end
end
function CACArchetypesTab:GetBackstoryIDFromIndex(index)
  local data = self.ArchetypeData[index]
  return data.id
end
function CACArchetypesTab:SetCustomizableCharacterEntityId(entityId)
  self.characterEntityId = entityId
end
function CACArchetypesTab:ValidateArchetype()
  local isEnabled = self:IsArchetypeSelected()
  self.NextButton:SetEnabled(isEnabled)
end
function CACArchetypesTab:IsArchetypeSelected()
  return self.selectedIndex > 0
end
function CACArchetypesTab:SetScreenVisible(isVisible)
  if isVisible and self.isScreenVisible == false then
    self.isScreenVisible = true
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    local animDuration = 0.4
    self.ScriptedEntityTweener:Play(self.Properties.Scrim, 0.6, {opacity = 0}, {opacity = 0.6, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.PrimaryTitle, animDuration, {opacity = 0, y = 30}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.SecondaryTitle, animDuration, {opacity = 0, y = 30}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.CarouselContent, animDuration, {opacity = 0, y = 216}, {
      opacity = 1,
      y = 186,
      ease = "QuadOut",
      delay = 0.3
    })
    self.ScriptedEntityTweener:Play(self.Properties.BackstoryText, animDuration, {opacity = 0, y = 30}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.4
    })
    self:SetButtonIsHandlingEvents(true)
  elseif isVisible == false and self.isScreenVisible == true then
    self.isScreenVisible = false
    local animDuration = 0.3
    self.ScriptedEntityTweener:Play(self.Properties.Scrim, 0.6, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.PrimaryTitle, animDuration, {
      opacity = 0,
      y = 30,
      ease = "QuadIn",
      delay = 0.2,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.SecondaryTitle, animDuration, {
      opacity = 0,
      y = 30,
      ease = "QuadIn",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.CarouselContent, animDuration, {
      opacity = 0,
      y = 206,
      ease = "QuadIn",
      delay = 0.1
    })
    self.ScriptedEntityTweener:Play(self.Properties.BackstoryText, animDuration, {
      opacity = 0,
      y = 30,
      ease = "QuadIn",
      delay = 0
    })
    self:SetButtonIsHandlingEvents(false)
  end
end
function CACArchetypesTab:SetButtonIsHandlingEvents(isHandlingEvents)
  for i = 1, #self.ArchetypeItemEntities do
    local currentItem = self.ArchetypeItemEntities[i].entityId
    UiInteractableBus.Event.SetIsHandlingEvents(currentItem, isHandlingEvents)
  end
end
function CACArchetypesTab:GetAnimDelay()
  return self.animDelay
end
function CACArchetypesTab:OnAction(entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function CACArchetypesTab:OnRollover(entityId, actionName)
  local item = self.registrar:GetEntityTable(entityId)
  if self.selectedIndex ~= item.itemIndex then
    item:SetState(EArchetypeItemState.Hover)
  end
end
function CACArchetypesTab:OnRollout(entityId, actionName)
  local item = self.registrar:GetEntityTable(entityId)
  if self.selectedIndex ~= item.itemIndex then
    item:SetState(EArchetypeItemState.Idle)
  end
end
function CACArchetypesTab:OnClick(entityId, actionName)
  local item = self.registrar:GetEntityTable(entityId)
  if self.selectedIndex ~= item.itemIndex then
    if self.selectedIndex > 0 then
      local oldItem = self.ArchetypeItemEntities[self.selectedIndex]
      oldItem:SetState(EArchetypeItemState.Idle)
    end
    self.selectedIndex = item.itemIndex
    item:SetState(EArchetypeItemState.Selected)
    self.archetypeText = LyShineScriptBindRequestBus.Broadcast.LocalizeText(self.ArchetypeData[item.itemIndex].description)
    self:UpdateArchetypeText()
    IntroControllerComponentRequestBus.Broadcast.SetCurrentArchetypeIndex(item.itemIndex)
    CustomizableCharacterRequestBus.Event.SetBackstory(self.characterEntityId, self:GetBackstoryIDFromIndex(self.selectedIndex))
    self:ValidateArchetype()
    table.insert(self.archetypeChoiceOrder, LyShineScriptBindRequestBus.Broadcast.LocalizeText(self.ArchetypeData[self.selectedIndex].name))
    if #self.archetypeChoiceOrder > self.maxChoicesToTrack then
      table.remove(self.archetypeChoiceOrder, 1)
    end
  end
end
function CACArchetypesTab:OnArrowRightClicked()
  self.scrollPosXmax = UiScrollBoxBus.Event.GetScrollOffsetMax(self.Properties.ScrollBox).x
  self.scrollPosXmin = UiScrollBoxBus.Event.GetScrollOffsetMin(self.Properties.ScrollBox).x
  local currentPos = UiScrollBoxBus.Event.GetScrollOffset(self.Properties.ScrollBox)
  if self.scrollPosX == nil then
    self.scrollPosX = currentPos.x
  end
  self.scrollPosX = self.scrollPosXmin
  if currentPos.x ~= self.scrollPosX then
    self.ScriptedEntityTweener:Play(self.Properties.ScrollBox, 0.4, {
      scrollBoxOffsettX = self.scrollPosX,
      ease = "QuadInOut"
    })
    if self.scrollPosX == self.scrollPosXmin then
      self.ScriptedEntityTweener:Play(self.Properties.ArrowImageRight, 0.3, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ArrowButtonRight, false)
        end
      })
    end
    if self.scrollPosX ~= self.scrollPosXmax then
      self.ScriptedEntityTweener:Play(self.Properties.ArrowImageLeft, 0.3, {opacity = 1, ease = "QuadOut"})
      local isHandlingEvents = UiInteractableBus.Event.IsHandlingEvents(self.Properties.ArrowButtonLeft)
      if not isHandlingEvents then
        UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ArrowButtonLeft, true)
      end
    end
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function CACArchetypesTab:OnArrowLeftClicked()
  self.scrollPosXmax = UiScrollBoxBus.Event.GetScrollOffsetMax(self.Properties.ScrollBox).x
  self.scrollPosXmin = UiScrollBoxBus.Event.GetScrollOffsetMin(self.Properties.ScrollBox).x
  local currentPos = UiScrollBoxBus.Event.GetScrollOffset(self.Properties.ScrollBox)
  if self.scrollPosX == nil then
    self.scrollPosX = currentPos.x
  end
  self.scrollPosX = self.scrollPosXmax
  if self.scrollPosX > self.scrollPosXmax then
    self.scrollPosX = self.scrollPosXmax
  end
  if currentPos.x ~= self.scrollPosX then
    self.ScriptedEntityTweener:Play(self.Properties.ScrollBox, 0.4, {
      scrollBoxOffsettX = self.scrollPosX,
      ease = "QuadInOut"
    })
    if self.scrollPosX ~= self.scrollPosXmin then
      self.ScriptedEntityTweener:Play(self.Properties.ArrowImageRight, 0.3, {opacity = 1, ease = "QuadOut"})
      local isHandlingEvents = UiInteractableBus.Event.IsHandlingEvents(self.Properties.ArrowButtonRight)
      if not isHandlingEvents then
        UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ArrowButtonRight, true)
      end
    end
    if self.scrollPosX == self.scrollPosXmax then
      self.ScriptedEntityTweener:Play(self.Properties.ArrowImageLeft, 0.3, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ArrowButtonLeft, false)
        end
      })
    end
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function CACArchetypesTab:OnArrowFocus()
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnNextHover)
end
function CACArchetypesTab:SendArchetypeTelemetry()
  local choicesList = ""
  for i = 1, #self.archetypeChoiceOrder do
    choicesList = choicesList .. ";" .. self.archetypeChoiceOrder[i]
  end
  if self.selectedIndex > 0 and self.selectedIndex <= #self.ArchetypeData then
    local event = UiAnalyticsEvent("ftue_backstory_selection")
    event:AddAttribute("ChoiceId", self.ArchetypeData[self.selectedIndex].id)
    event:AddAttribute("ChoiceName", LyShineScriptBindRequestBus.Broadcast.LocalizeText(self.ArchetypeData[self.selectedIndex].name))
    event:AddAttribute("ChoiceList", choicesList)
    event:Send()
  end
end
return CACArchetypesTab
