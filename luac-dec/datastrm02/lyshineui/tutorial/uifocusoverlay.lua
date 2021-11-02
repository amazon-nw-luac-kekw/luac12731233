local UIFocusOverlay = {
  Properties = {
    Overlays = {
      Compass = {
        default = EntityId()
      },
      Inventory = {
        default = EntityId()
      },
      Paperdoll = {
        default = EntityId()
      },
      InventoryWithArrow = {
        default = EntityId()
      },
      PaperdollWithArrow = {
        default = EntityId()
      },
      InventoryLoot = {
        default = EntityId()
      },
      Quickbar = {
        default = EntityId()
      },
      QuickbarWeapons = {
        default = EntityId()
      },
      QuickbarItems = {
        default = EntityId()
      },
      QuickbarWeaponsMid = {
        default = EntityId()
      },
      QuickbarItemsMid = {
        default = EntityId()
      },
      EquipShield = {
        default = EntityId()
      },
      StaminaBar = {
        default = EntityId()
      },
      HydrationBar = {
        default = EntityId()
      },
      HungerBar = {
        default = EntityId()
      },
      HealthBar = {
        default = EntityId()
      },
      Crafting_BandageSelect = {
        default = EntityId()
      },
      Crafting_BandageSelectTier = {
        default = EntityId()
      },
      Crafting_BandageCraft = {
        default = EntityId()
      },
      MasteryBanner = {
        default = EntityId()
      },
      MasteryTreeSelect = {
        default = EntityId()
      },
      MasterySkillSelect = {
        default = EntityId()
      },
      MasteryConfirm = {
        default = EntityId()
      },
      MasteryEquipRemind = {
        default = EntityId()
      }
    },
    MasterySkillText = {
      default = EntityId()
    },
    MasteryTreeSelectTitle = {
      default = EntityId()
    },
    MasterySkillSelectTitle = {
      default = EntityId()
    },
    MasteryEquipRemindTitle = {
      default = EntityId()
    },
    Alpha = {default = 0.2},
    FadeDuration = 0.6
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(UIFocusOverlay)
function UIFocusOverlay:OnInit()
  BaseScreen.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.tutorialBusHandler = TutorialComponentNotificationsBus.Connect(self, self.canvasId)
  UiFaderBus.Event.SetFadeValue(self.entityId, 0)
  self:ResetOverlayFades()
  DynamicBus.FocusOverlayBus.Connect(self.entityId, self)
  local masterySkillPoints = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@TUT_Mastery_Points", "1")
  UiTextBus.Event.SetTextWithFlags(self.Properties.MasterySkillText, masterySkillPoints, eUiTextSet_SetAsIs)
  if self.timeline1 == nil then
    self.timeline1 = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline1:Add(self.Properties.MasteryTreeSelectTitle, 0.4, {opacity = 1})
    self.timeline1:Add(self.Properties.MasteryTreeSelectTitle, 0.05, {opacity = 1})
    self.timeline1:Add(self.Properties.MasteryTreeSelectTitle, 0.35, {
      opacity = 0.3,
      onComplete = function()
        self.timeline1:Play()
      end
    })
  end
  if self.timeline2 == nil then
    self.timeline2 = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline2:Add(self.Properties.MasterySkillSelectTitle, 0.4, {opacity = 1})
    self.timeline2:Add(self.Properties.MasterySkillSelectTitle, 0.05, {opacity = 1})
    self.timeline2:Add(self.Properties.MasterySkillSelectTitle, 0.35, {
      opacity = 0.3,
      onComplete = function()
        self.timeline2:Play()
      end
    })
  end
  if self.timeline3 == nil then
    self.timeline3 = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline3:Add(self.Properties.MasteryConfirmTitle, 0.4, {opacity = 1})
    self.timeline3:Add(self.Properties.MasteryConfirmTitle, 0.05, {opacity = 1})
    self.timeline3:Add(self.Properties.MasteryConfirmTitle, 0.35, {
      opacity = 0.3,
      onComplete = function()
        self.timeline3:Play()
      end
    })
  end
end
function UIFocusOverlay:OnShutdown()
  if self.tutorialBusHandler ~= nil then
    self.tutorialBusHandler:Disconnect()
    self.tutorialBusHandler = nil
  end
  self:ClearTimelines()
  DynamicBus.FocusOverlayBus.Disconnect(self.entityId, self)
  BaseScreen.OnShutdown(self)
end
function UIFocusOverlay:ShowOverlay(elementName, delayTime)
  if self.Properties.Overlays[elementName] == nil then
    Debug.Log("UIFocusOverlay:ShowOverlay Error - Overlay with name " .. elementName .. " not found.")
  end
  for k, v in pairs(self.Properties.Overlays) do
    UiElementBus.Event.SetIsEnabled(v, k == elementName)
    if k == elementName then
      UiFaderBus.Event.SetFadeValue(v, 1)
    end
  end
  if elementName == "MasteryTreeSelect" then
    self.timeline1:Play()
    self.timeline2:Play()
    self.timeline3:Play()
  end
  local animDelay = delayTime ~= nil and delayTime or 0
  self.ScriptedEntityTweener:Play(self.entityId, self.Properties.FadeDuration, {opacity = 0}, {
    opacity = 1,
    ease = "QuadIn",
    delay = animDelay
  })
end
function UIFocusOverlay:ClearTimelines()
  if self.timeline1 ~= nil then
    self.timeline1:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline1)
  end
  if self.timeline2 ~= nil then
    self.timeline2:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline2)
  end
  if self.timeline3 ~= nil then
    self.timeline3:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline3)
  end
end
function UIFocusOverlay:OnTutorialFocusUIElementByName(name, returnId)
  self:ShowOverlay(name)
end
function UIFocusOverlay:OnTutorialStopFocusUIElement()
  self.ScriptedEntityTweener:Play(self.entityId, self.Properties.FadeDuration, {opacity = 1}, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      self:OnTransitionOutCompleted()
    end
  })
  self:ClearTimelines()
end
function UIFocusOverlay:OnTransitionOutCompleted()
  local tutorialComponentId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  TutorialUIRequestsBus.Event.OnTransitionOutCompleted(tutorialComponentId)
  self:ResetOverlayFades()
end
function UIFocusOverlay:ResetOverlayFades()
  for k, v in pairs(self.Properties.Overlays) do
    UiFaderBus.Event.SetFadeValue(v, 0)
    UiElementBus.Event.SetIsEnabled(v, false)
  end
end
return UIFocusOverlay
