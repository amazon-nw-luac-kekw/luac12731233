local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local CACAppearanceTab = {
  Properties = {
    TopLevelList = {
      default = EntityId()
    },
    FaceWindow = {
      default = EntityId()
    },
    SkinToneWindow = {
      default = EntityId()
    },
    HairstyleWindow = {
      default = EntityId()
    },
    FacialHairWindow = {
      default = EntityId()
    },
    EyeColorWindow = {
      default = EntityId()
    },
    FaceMarkWindow = {
      default = EntityId()
    },
    ScarWindow = {
      default = EntityId()
    },
    TattooWindow = {
      default = EntityId()
    },
    GenderList = {
      default = EntityId()
    },
    FaceList = {
      default = EntityId()
    },
    SkinToneList = {
      default = EntityId()
    },
    HairstyleList = {
      default = EntityId()
    },
    FacialHairList = {
      default = EntityId()
    },
    FaceMarkList = {
      default = EntityId()
    },
    ScarList = {
      default = EntityId()
    },
    TattooList = {
      default = EntityId()
    },
    HairstyleColorList = {
      default = EntityId()
    },
    FacialHairColorList = {
      default = EntityId()
    },
    EyeColorList = {
      default = EntityId()
    },
    TattooColorList = {
      default = EntityId()
    },
    GenderIcon = {
      default = EntityId()
    },
    FaceIcon = {
      default = EntityId()
    },
    SkinToneIcon = {
      default = EntityId()
    },
    HairstyleIcon = {
      default = EntityId()
    },
    FacialHairIcon = {
      default = EntityId()
    },
    EyeColorIcon = {
      default = EntityId()
    },
    FaceMarkIcon = {
      default = EntityId()
    },
    ScarIcon = {
      default = EntityId()
    },
    TattooIcon = {
      default = EntityId()
    },
    PlayerIconFront = {
      default = EntityId()
    },
    PlayerIconMid = {
      default = EntityId()
    },
    PlayerIconBack = {
      default = EntityId()
    },
    RandomizeCharacterPopupTitle = {
      default = "@mm_randomizetitle"
    },
    RandomizeCharacterPopupMessage = {
      default = "@mm_randomizewarning"
    },
    PrimaryTitle = {
      default = EntityId()
    },
    ButtonGender = {
      default = EntityId()
    },
    ButtonFace = {
      default = EntityId()
    },
    ButtonSkinTone = {
      default = EntityId()
    },
    ButtonHairStyle = {
      default = EntityId()
    },
    ButtonFacialHair = {
      default = EntityId()
    },
    ButtonEyeColor = {
      default = EntityId()
    },
    ButtonFaceMarks = {
      default = EntityId()
    },
    ButtonScars = {
      default = EntityId()
    },
    ButtonTattoos = {
      default = EntityId()
    },
    ListFrame = {
      default = EntityId()
    },
    RotateCharacterHolder = {
      default = EntityId()
    }
  },
  characterEntityId = EntityId(),
  customizableCharacterBus = nil,
  suppressEvents = false,
  promptOnRandomize = false,
  currentCharacterSelection = {
    gender = "",
    race = "",
    skinTone = "",
    hairstyle = "",
    facialHair = "",
    hairColor = "",
    facialHairColor = "",
    eyeColor = "",
    faceMark = "",
    scar = "",
    tattoo = "",
    tattooColor = ""
  },
  buttonGenderInitPosY = nil,
  buttonFaceInitPosY = nil,
  buttonSkinToneInitPosY = nil,
  buttonHairStyleInitPosY = nil,
  buttonFacialHairInitPosY = nil,
  buttonEyeColorInitPosY = nil,
  buttonFaceMarksInitPosY = nil,
  buttonScarsInitPosY = nil,
  buttonTattoosInitPosY = nil,
  randomizePopupId = "Popup_OnRandomizeCharacter",
  worldZ = 32,
  faceImagePath = "",
  isScreenVisible = false,
  animDelay = 0.5,
  rotateEnabled = false,
  cryActionHandlers = {},
  defaultRotation = nil,
  rotationCap = 15,
  noFaceMark = "none",
  noScar = "none",
  noTatoo = "none"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CACAppearanceTab)
function CACAppearanceTab:OnInit()
  BaseElement.OnInit(self)
  self.isIntroSceneLevel = ConfigProviderEventBus.Broadcast.GetBool("javelin.use-new-character-creation-flow")
  self.eyeColorEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-character-customization-eyecolor")
  self.faceMarksEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-character-customization-facemarks")
  self.scarsEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-character-customization-scars")
  self.tattoosEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-character-customization-tattoos")
  self:BusConnect(UiMainMenuBus, self)
  UiMainMenuRequestBus.Broadcast.RequestCustomizableCharacterEntityId()
  self.rotationBinds = {
    "rotate_character_start",
    "rotate_character_end",
    "rotate_character"
  }
  self.halfPI = math.pi / 180
  self.femaleFaceSortOrder = {
    face11 = 1,
    face06 = 2,
    face19 = 3,
    face01 = 4,
    face16 = 5,
    face03 = 6,
    face13 = 7,
    face02 = 8,
    face08 = 9,
    face14 = 10,
    face04 = 11,
    face20 = 12,
    face18 = 13,
    face12 = 14,
    face07 = 15,
    face09 = 16,
    face17 = 17,
    face10 = 18,
    face15 = 19,
    face05 = 20
  }
  self.maleFaceSortOrder = {
    face12 = 1,
    face06 = 2,
    face20 = 3,
    face03 = 4,
    face01 = 5,
    face17 = 6,
    face11 = 7,
    face07 = 8,
    face18 = 9,
    face02 = 10,
    face05 = 11,
    face13 = 12,
    face08 = 13,
    face14 = 14,
    face15 = 15,
    face09 = 16,
    face19 = 17,
    face04 = 18,
    face10 = 19,
    face16 = 20
  }
  self:SetVisualElements()
end
function CACAppearanceTab:OnShutdown()
  if self.customizableCharacterBus ~= nil then
    self.customizableCharacterBus:Disconnect()
    self.customizableCharacterBus = nil
  end
end
function CACAppearanceTab:OnCryAction(actionName, value)
  if actionName == "rotate_character_start" then
    self.rotateEnabled = true
    self.audioHelper:PlaySound(self.audioHelper.OnRotationStart)
  elseif actionName == "rotate_character_end" then
    self.rotateEnabled = false
    self.audioHelper:PlaySound(self.audioHelper.OnRotationEnd)
  end
  if self.rotateEnabled and actionName == "rotate_character" then
    if value >= self.rotationCap then
      value = self.rotationCap
    elseif value <= -self.rotationCap then
      value = -self.rotationCap
    end
    TransformBus.Event.RotateAroundLocalZ(self.characterEntityId, value * self.halfPI)
    AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("UX_Rotation", value)
  end
end
function CACAppearanceTab:SetVisualElements()
  SetTextStyle(self.PrimaryTitle, self.UIStyle.FONT_STYLE_HEADER_SMALL_CAPS_BIG)
  UiTextBus.Event.SetTextWithFlags(self.Properties.PrimaryTitle, "@ui_appearance", eUiTextSet_SetLocalized)
  self.ButtonGender:SetText("@ui_gender")
  self.ButtonFace:SetText("@ui_face")
  self.ButtonSkinTone:SetText("@ui_skintone")
  self.ButtonHairStyle:SetText("@ui_hairstyle")
  self.ButtonFacialHair:SetText("@ui_facialhair")
  local frameHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ListFrame)
  local buttonHeight = UiLayoutCellBus.Event.GetTargetHeight(self.Properties.ButtonGender)
  local buttonSpacing = UiLayoutColumnBus.Event.GetSpacing(self.Properties.TopLevelList)
  if self.eyeColorEnabled then
    UiElementBus.Event.Reparent(self.Properties.ButtonEyeColor, self.Properties.TopLevelList, EntityId())
    self.ButtonEyeColor:SetText("@ui_eyecolor")
    frameHeight = frameHeight + buttonHeight + buttonSpacing
  end
  if self.faceMarksEnabled then
    UiElementBus.Event.Reparent(self.Properties.ButtonFaceMarks, self.Properties.TopLevelList, EntityId())
    self.ButtonFaceMarks:SetText("@ui_facemarks")
    frameHeight = frameHeight + buttonHeight + buttonSpacing
  end
  if self.scarsEnabled then
    UiElementBus.Event.Reparent(self.Properties.ButtonScars, self.Properties.TopLevelList, EntityId())
    self.ButtonScars:SetText("@ui_scars")
    frameHeight = frameHeight + buttonHeight + buttonSpacing
  end
  if self.tattoosEnabled then
    UiElementBus.Event.Reparent(self.Properties.ButtonTattoos, self.Properties.TopLevelList, EntityId())
    self.ButtonTattoos:SetText("@ui_tattoos")
    frameHeight = frameHeight + buttonHeight + buttonSpacing
  end
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.ListFrame, frameHeight)
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  UiCanvasBus.Event.RecomputeChangedLayouts(canvasId)
  self.listFrameInitPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ListFrame)
  self.buttonGenderInitPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ButtonGender)
  self.buttonFaceInitPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ButtonFace)
  self.buttonSkinToneInitPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ButtonSkinTone)
  self.buttonHairStyleInitPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ButtonHairStyle)
  self.buttonFacialHairInitPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ButtonFacialHair)
  self.buttonEyeColorInitPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ButtonEyeColor)
  self.buttonFaceMarksInitPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ButtonFaceMarks)
  self.buttonScarsInitPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ButtonScars)
  self.buttonTattoosInitPosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ButtonTattoos)
  self.ListFrame:SetLineAlpha(0.5)
  self.ListFrame:SetFrameTextureVisible(false)
  UiRadioButtonGroupBus.Event.SetAllowUncheck(self.Properties.TopLevelList, true)
end
function CACAppearanceTab:SetScreenVisible(isVisible)
  if isVisible and self.isScreenVisible == false then
    self.isScreenVisible = true
    self:SetButtonIsHandlingEvents(true)
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    local animDuration = 0.4
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.Properties.PrimaryTitle, animDuration, {opacity = 0, y = 30}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.1
    })
    self.ScriptedEntityTweener:Play(self.Properties.ListFrame, animDuration, {
      opacity = 0,
      y = self.listFrameInitPosY + 30
    }, {
      opacity = 1,
      y = self.listFrameInitPosY,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ListFrame:SetLineVisible(true, 1.4, {delay = 0.2})
    local animDelay = 0.2
    local delayIncrement = 0.05
    self.ScriptedEntityTweener:Play(self.Properties.ButtonGender, animDuration, {
      opacity = 0,
      y = self.buttonGenderInitPosY + 30
    }, {
      opacity = 1,
      y = self.buttonGenderInitPosY,
      ease = "QuadOut",
      delay = animDelay
    })
    animDelay = animDelay + delayIncrement
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFace, animDuration, {
      opacity = 0,
      y = self.buttonFaceInitPosY + 30
    }, {
      opacity = 1,
      y = self.buttonFaceInitPosY,
      ease = "QuadOut",
      delay = animDelay
    })
    animDelay = animDelay + delayIncrement
    self.ScriptedEntityTweener:Play(self.Properties.ButtonSkinTone, animDuration, {
      opacity = 0,
      y = self.buttonSkinToneInitPosY + 30
    }, {
      opacity = 1,
      y = self.buttonSkinToneInitPosY,
      ease = "QuadOut",
      delay = animDelay
    })
    animDelay = animDelay + delayIncrement
    self.ScriptedEntityTweener:Play(self.Properties.ButtonHairStyle, animDuration, {
      opacity = 0,
      y = self.buttonHairStyleInitPosY + 30
    }, {
      opacity = 1,
      y = self.buttonHairStyleInitPosY,
      ease = "QuadOut",
      delay = animDelay
    })
    animDelay = animDelay + delayIncrement
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFacialHair, animDuration, {
      opacity = 0,
      y = self.buttonFacialHairInitPosY + 30
    }, {
      opacity = 1,
      y = self.buttonFacialHairInitPosY,
      ease = "QuadOut",
      delay = animDelay
    })
    animDelay = animDelay + delayIncrement
    if self.eyeColorEnabled then
      self.ScriptedEntityTweener:Play(self.Properties.ButtonEyeColor, animDuration, {
        opacity = 0,
        y = self.buttonEyeColorInitPosY + 30
      }, {
        opacity = 1,
        y = self.buttonEyeColorInitPosY,
        ease = "QuadOut",
        delay = animDelay
      })
      animDelay = animDelay + delayIncrement
    end
    if self.faceMarksEnabled then
      self.ScriptedEntityTweener:Play(self.Properties.ButtonFaceMarks, animDuration, {
        opacity = 0,
        y = self.buttonFaceMarksInitPosY + 30
      }, {
        opacity = 1,
        y = self.buttonFaceMarksInitPosY,
        ease = "QuadOut",
        delay = animDelay
      })
      animDelay = animDelay + delayIncrement
    end
    if self.scarsEnabled then
      self.ScriptedEntityTweener:Play(self.Properties.ButtonScars, animDuration, {
        opacity = 0,
        y = self.buttonScarsInitPosY + 30
      }, {
        opacity = 1,
        y = self.buttonScarsInitPosY,
        ease = "QuadOut",
        delay = animDelay
      })
      animDelay = animDelay + delayIncrement
    end
    if self.tattoosEnabled then
      self.ScriptedEntityTweener:Play(self.Properties.ButtonTattoos, animDuration, {
        opacity = 0,
        y = self.buttonTattoosInitPosY + 30
      }, {
        opacity = 1,
        y = self.buttonTattoosInitPosY,
        ease = "QuadOut",
        delay = animDelay
      })
      animDelay = animDelay + delayIncrement
    end
    self.ScriptedEntityTweener:Play(self.Properties.RotateCharacterHolder, animDuration, {opacity = 0, y = 30}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.45
    })
    for _, bind in ipairs(self.rotationBinds) do
      table.insert(self.cryActionHandlers, self:BusConnect(CryActionNotificationsBus, bind))
    end
    self.defaultRotation = TransformBus.Event.GetLocalRotation(self.characterEntityId)
  elseif isVisible == false and self.isScreenVisible == true then
    self.isScreenVisible = false
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
    self.ListFrame:SetLineVisible(false, 0.6)
    self:SetButtonIsHandlingEvents(false)
    for _, handler in ipairs(self.cryActionHandlers) do
      self:BusDisconnect(handler)
    end
    ClearTable(self.cryActionHandlers)
    TransformBus.Event.SetLocalRotation(self.characterEntityId, self.defaultRotation)
  end
end
function CACAppearanceTab:SetButtonIsHandlingEvents(isHandlingEvents)
  self:ClearAppearanceRadioGroup()
  local childList = UiElementBus.Event.GetChildren(self.Properties.TopLevelList)
  for i = 1, #childList do
    local childEntityId = childList[i]
    UiInteractableBus.Event.SetIsHandlingEvents(childEntityId, isHandlingEvents)
  end
end
function CACAppearanceTab:GetAnimDelay()
  return self.animDelay
end
function CACAppearanceTab:OnAction(entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function CACAppearanceTab:OnTransitionIn(stateName, levelName)
  if not self.isIntroSceneLevel then
    self:OnEntityActivated()
  end
end
function CACAppearanceTab:OnTransitionOut(stateName, levelName)
  if self.customizableCharacterBus ~= nil then
    self.customizableCharacterBus:Disconnect()
    self.customizableCharacterBus = nil
  end
end
function CACAppearanceTab:SetCustomizableCharacterEntityId(entityId)
  self.characterEntityId = entityId
  if self.customizableCharacterBus == nil and self.characterEntityId ~= nil then
    self.customizableCharacterBus = CustomizableCharacterNotificationsBus.Connect(self, self.characterEntityId)
    if self.isIntroSceneLevel then
      self:BusConnect(EntityBus, self.characterEntityId)
    end
  end
end
function CACAppearanceTab:OnEntityActivated()
  self:ClearAppearanceRadioGroup()
  CustomizableCharacterRequestBus.Event.ClearEquipment(self.characterEntityId)
  self:RandomizeCharacter(true, false, false)
end
function CACAppearanceTab:OnPopupResult(result, eventId)
  if eventId == self.randomizePopupId and result == ePopupResult_Yes then
    self:ClearAppearanceRadioGroup()
    self:RandomizeCharacter(true, true, true)
  end
end
function CACAppearanceTab:RandomizeCharacter(randomizeGender, randomizeSkinTone, randomizeAllFacialHair)
  if randomizeGender then
    self.currentCharacterSelection.gender = CustomizableCharacterRequestBus.Event.RandomGender(self.characterEntityId)
  end
  self.currentCharacterSelection.race = CustomizableCharacterRequestBus.Event.RandomRace(self.characterEntityId, self.currentCharacterSelection.gender)
  if randomizeSkinTone then
    self.currentCharacterSelection.skinTone = CustomizableCharacterRequestBus.Event.RandomSkinTone(self.characterEntityId, self.currentCharacterSelection.gender, self.currentCharacterSelection.race)
  else
    self.currentCharacterSelection.skinTone = CustomizableCharacterRequestBus.Event.DefaultSkinTone(self.characterEntityId, self.currentCharacterSelection.gender, self.currentCharacterSelection.race)
  end
  self.currentCharacterSelection.hairstyle = CustomizableCharacterRequestBus.Event.RandomHairstyle(self.characterEntityId, self.currentCharacterSelection.gender, self.currentCharacterSelection.race)
  self.currentCharacterSelection.hairColor = CustomizableCharacterRequestBus.Event.RandomHairColor(self.characterEntityId, self.currentCharacterSelection.gender, self.currentCharacterSelection.race)
  self.currentCharacterSelection.facialHairColor = self.currentCharacterSelection.hairColor
  local useFacialHair = false
  if self.currentCharacterSelection.gender == "Male" or randomizeAllFacialHair then
    local maleBeardChance = 0.7
    local femaleBeardChance = 0.1
    local random = math.random()
    if self.currentCharacterSelection.gender == "Male" and maleBeardChance >= random then
      useFacialHair = true
    elseif self.currentCharacterSelection.gender ~= "Male" and femaleBeardChance >= random then
      useFacialHair = true
    end
  end
  if useFacialHair then
    self.currentCharacterSelection.facialHair = CustomizableCharacterRequestBus.Event.RandomFacialHair(self.characterEntityId, self.currentCharacterSelection.gender, self.currentCharacterSelection.race)
  else
    self.currentCharacterSelection.facialHair = "None"
  end
  if self.eyeColorEnabled then
    self.currentCharacterSelection.eyeColor = CustomizableCharacterRequestBus.Event.RandomEyeColor(self.characterEntityId, self.currentCharacterSelection.gender, self.currentCharacterSelection.race)
  end
  if self.faceMarksEnabled then
    self.currentCharacterSelection.faceMark = self.noFaceMark
  end
  if self.scarsEnabled then
    self.currentCharacterSelection.scar = self.noScar
  end
  if self.tattoosEnabled then
    self.currentCharacterSelection.tattoo = self.noTatoo
    self.currentCharacterSelection.tattooColor = CustomizableCharacterRequestBus.Event.RandomTattooColor(self.characterEntityId, self.currentCharacterSelection.gender, self.currentCharacterSelection.race)
  end
  self:SetCharacterGender(self.currentCharacterSelection.gender, false)
end
function CACAppearanceTab:setGender(entityId, actionName)
  if not self.suppressEvents then
    local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.GenderList)
    local entity = Entity(selectedItem)
    local entityName = entity:GetName()
    self:SetCharacterGender(entityName, true)
  end
end
function CACAppearanceTab:setFace(entityId, actionName)
  if not self.suppressEvents then
    local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.FaceList)
    local entity = Entity(selectedItem)
    local entityName = entity:GetName()
    self:SetCharacterRace(entityName)
    self:UpdateCACSelectionOptions()
  end
end
function CACAppearanceTab:setSkinTone(entityId, actionName)
  if not self.suppressEvents then
    local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.SkinToneList)
    local entity = Entity(selectedItem)
    local entityName = entity:GetName()
    self:SetCharacterSkinTone(entityName)
    local selectedImagePath = self:GetSkinToneImage(self.currentCharacterSelection.skinTone)
    UiImageBus.Event.SetSpritePathname(self.Properties.SkinToneIcon, selectedImagePath)
    self.faceImagePath = selectedImagePath
    UiImageBus.Event.SetSpritePathname(self.Properties.PlayerIconBack, selectedImagePath)
    self:UpdateCACSelectionOptions()
  end
end
function CACAppearanceTab:setHairstyle(entityId, actionName)
  if not self.suppressEvents then
    local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.HairstyleList)
    local entity = Entity(selectedItem)
    local entityName = entity:GetName()
    self:SetCharacterHairstyle(entityName)
    local selectedImagePath = self:GetHairstyleImage(self.currentCharacterSelection.hairstyle)
    UiCACImageBus.Event.SetCACImage(self.Properties.HairstyleIcon, self.faceImagePath, selectedImagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.PlayerIconMid, selectedImagePath)
  end
end
function CACAppearanceTab:setFacialHair(entityId, actionName)
  if not self.suppressEvents then
    local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.FacialHairList)
    local entity = Entity(selectedItem)
    local entityName = entity:GetName()
    self:SetCharacterFacialHair(entityName)
    local selectedImagePath = self:GetFacialHairImage(self.currentCharacterSelection.facialHair)
    UiCACImageBus.Event.SetCACImage(self.Properties.FacialHairIcon, self.faceImagePath, selectedImagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.PlayerIconFront, selectedImagePath)
  end
end
function CACAppearanceTab:selectHairColor(entityId, actionName)
  if not self.suppressEvents then
    local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.HairstyleColorList)
    local entity = Entity(selectedItem)
    local entityName = entity:GetName()
    self:SetCharacterHairstyleColor(entityName)
    local selectedImagePath = self:GetHairstyleImage(self.currentCharacterSelection.hairstyle)
    UiCACImageBus.Event.SetCACImage(self.Properties.HairstyleIcon, self.faceImagePath, selectedImagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.PlayerIconMid, selectedImagePath)
    self:UpdateCACSelectionOptions()
  end
end
function CACAppearanceTab:selectFacialHairColor(entityId, actionName)
  if not self.suppressEvents then
    local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.FacialHairColorList)
    local entity = Entity(selectedItem)
    local entityName = entity:GetName()
    self:SetCharacterFacialHairColor(entityName)
    local selectedImagePath = self:GetFacialHairImage(self.currentCharacterSelection.facialHair)
    UiCACImageBus.Event.SetCACImage(self.Properties.FacialHairIcon, self.faceImagePath, selectedImagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.PlayerIconFront, selectedImagePath)
    self:UpdateCACSelectionOptions()
  end
end
function CACAppearanceTab:selectEyeColor(entityId, actionName)
  if self.suppressEvents or not self.eyeColorEnabled then
    return
  end
  local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.EyeColorList)
  local entity = Entity(selectedItem)
  local entityName = entity:GetName()
  self:SetCharacterEyeColor(entityName)
  self:UpdateCACSelectionOptions()
end
function CACAppearanceTab:selectFaceMark(entityId, actionName)
  if self.suppressEvents or not self.faceMarksEnabled then
    return
  end
  local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.FaceMarkList)
  local entity = Entity(selectedItem)
  local entityName = entity:GetName()
  self:SetCharacterFaceMark(entityName)
  self:UpdateCACSelectionOptions()
end
function CACAppearanceTab:selectScar(entityId, actionName)
  if self.suppressEvents or not self.scarsEnabled then
    return
  end
  local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.ScarList)
  local entity = Entity(selectedItem)
  local entityName = entity:GetName()
  self:SetCharacterScar(entityName)
  self:UpdateCACSelectionOptions()
end
function CACAppearanceTab:selectTattoo(entityId, actionName)
  if self.suppressEvents or not self.tattoosEnabled then
    return
  end
  local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.TattooList)
  local entity = Entity(selectedItem)
  local entityName = entity:GetName()
  self:SetCharacterTattoo(entityName)
  self:UpdateCACSelectionOptions()
end
function CACAppearanceTab:selectTattooColor(entityId, actionName)
  if self.suppressEvents or not self.tattoosEnabled then
    return
  end
  local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.TattooColorList)
  local entity = Entity(selectedItem)
  local entityName = entity:GetName()
  self:SetCharacterTattooColor(entityName)
  self:UpdateCACSelectionOptions()
end
function CACAppearanceTab:SetCharacterGender(gender, shouldPromptOnRandomize)
  self.currentCharacterSelection.gender = gender
  if self.currentCharacterSelection.gender == CustomizableCharacterRequestBus.Event.GetGender(self.characterEntityId) then
    self:OnSkinnedMeshCreated()
  else
    CustomizableCharacterRequestBus.Event.SetGender(self.characterEntityId, self.currentCharacterSelection.gender)
  end
  self.promptOnRandomize = shouldPromptOnRandomize
end
function CACAppearanceTab:SetCharacterRace(race)
  CustomizableCharacterRequestBus.Event.SetRace(self.characterEntityId, race)
  self.currentCharacterSelection.race = race
  self.promptOnRandomize = true
end
function CACAppearanceTab:SetCharacterSkinTone(skinTone)
  CustomizableCharacterRequestBus.Event.SetSkinTone(self.characterEntityId, skinTone)
  self.currentCharacterSelection.skinTone = skinTone
  self.promptOnRandomize = true
end
function CACAppearanceTab:SetCharacterHairstyle(hairstyle)
  CustomizableCharacterRequestBus.Event.SetHairstyle(self.characterEntityId, hairstyle)
  self.currentCharacterSelection.hairstyle = hairstyle
  self.promptOnRandomize = true
end
function CACAppearanceTab:SetCharacterFacialHair(hairstyle)
  CustomizableCharacterRequestBus.Event.SetFacialHair(self.characterEntityId, hairstyle)
  self.currentCharacterSelection.facialHair = hairstyle
  self.promptOnRandomize = true
end
function CACAppearanceTab:SetCharacterHairstyleColor(color)
  CustomizableCharacterRequestBus.Event.SetHairColor(self.characterEntityId, color)
  self.currentCharacterSelection.hairColor = color
  self.promptOnRandomize = true
end
function CACAppearanceTab:SetCharacterFacialHairColor(color)
  CustomizableCharacterRequestBus.Event.SetFacialHairColor(self.characterEntityId, color)
  self.currentCharacterSelection.facialHairColor = color
  self.promptOnRandomize = true
end
function CACAppearanceTab:SetCharacterEyeColor(color)
  if not self.eyeColorEnabled then
    return
  end
  CustomizableCharacterRequestBus.Event.SetEyeColor(self.characterEntityId, color)
  self.currentCharacterSelection.eyeColor = color
  self.promptOnRandomize = true
end
function CACAppearanceTab:SetCharacterFaceMark(faceMark)
  if not self.faceMarksEnabled then
    return
  end
  CustomizableCharacterRequestBus.Event.SetFaceMark(self.characterEntityId, faceMark)
  self.currentCharacterSelection.faceMark = faceMark
  self.promptOnRandomize = true
end
function CACAppearanceTab:SetCharacterScar(scar)
  if not self.scarsEnabled then
    return
  end
  CustomizableCharacterRequestBus.Event.SetScar(self.characterEntityId, scar)
  self.currentCharacterSelection.scar = scar
  self.promptOnRandomize = true
end
function CACAppearanceTab:SetCharacterTattoo(tattoo)
  if not self.tattoosEnabled then
    return
  end
  CustomizableCharacterRequestBus.Event.SetTattoo(self.characterEntityId, tattoo)
  self.currentCharacterSelection.tattoo = tattoo
  self.promptOnRandomize = true
end
function CACAppearanceTab:SetCharacterTattooColor(color)
  if not self.tattoosEnabled then
    return
  end
  CustomizableCharacterRequestBus.Event.SetTattooColor(self.characterEntityId, color)
  self.currentCharacterSelection.tattooColor = color
  self.promptOnRandomize = true
end
function CACAppearanceTab:GetFaceImage(itemName)
  local imagePath = CustomizableCharacterRequestBus.Event.GetRaceImagePath(self.characterEntityId, itemName)
  return imagePath
end
function CACAppearanceTab:GetSkinToneImage(itemName)
  local imagePath = CustomizableCharacterRequestBus.Event.GetSkinToneImagePath(self.characterEntityId, itemName)
  return imagePath
end
function CACAppearanceTab:GetHairstyleImage(itemName)
  local imagePath = CustomizableCharacterRequestBus.Event.GetHairstyleImagePath(self.characterEntityId, itemName)
  return imagePath
end
function CACAppearanceTab:GetFacialHairImage(itemName)
  local imagePath = CustomizableCharacterRequestBus.Event.GetFacialHairImagePath(self.characterEntityId, itemName)
  return imagePath
end
function CACAppearanceTab:GetHairColorImage(itemName)
  local imagePath = CustomizableCharacterRequestBus.Event.GetHairColorImagePath(self.characterEntityId, itemName)
  return imagePath
end
function CACAppearanceTab:GetFacialHairColorImage(itemName)
  local imagePath = CustomizableCharacterRequestBus.Event.GetFacialHairColorImagePath(self.characterEntityId, itemName)
  return imagePath
end
function CACAppearanceTab:GetEyeColorImage(itemName)
  local imagePath = CustomizableCharacterRequestBus.Event.GetEyeColorImagePath(self.characterEntityId, itemName)
  return imagePath
end
function CACAppearanceTab:GetFaceMarkImage(itemName)
  return CustomizableCharacterRequestBus.Event.GetFaceMarkImagePath(self.characterEntityId, itemName)
end
function CACAppearanceTab:GetScarImage(itemName)
  return CustomizableCharacterRequestBus.Event.GetScarImagePath(self.characterEntityId, itemName)
end
function CACAppearanceTab:GetTattooImage(itemName)
  return CustomizableCharacterRequestBus.Event.GetTattooImagePath(self.characterEntityId, itemName)
end
function CACAppearanceTab:GetTattooColorImage(itemName)
  return CustomizableCharacterRequestBus.Event.GetTattooColorImagePath(self.characterEntityId, itemName)
end
function CACAppearanceTab:GetImagePathForSelection(listEntity, entryName)
  local childList = UiElementBus.Event.GetChildren(listEntity)
  for i = 1, #childList do
    local childName = GameEntityContextRequestBus.Broadcast.GetEntityName(childList[i])
    if childName == entryName then
      return UiImageBus.Event.GetSpritePathname(childList[i])
    end
  end
  return nil
end
function CACAppearanceTab:ClearAppearanceRadioGroup()
  if self.Properties.TopLevelList:IsValid() then
    local childList = UiElementBus.Event.GetChildren(self.Properties.TopLevelList)
    for i = 1, #childList do
      local childEntityId = childList[i]
      if childEntityId:IsValid() then
        UiRadioButtonGroupBus.Event.SetState(self.Properties.TopLevelList, childEntityId, false)
        local buttonTable = self.registrar:GetEntityTable(childEntityId)
        buttonTable:OnUnselected()
      end
    end
  end
end
function CACAppearanceTab:GetSortedRaceKeys()
  local raceKeys = CustomizableCharacterRequestBus.Event.GetRaces(self.characterEntityId)
  local nonChromaRaces = {}
  for i = 1, #raceKeys do
    if raceKeys[i] ~= "Chroma" and raceKeys[i] ~= "ChromaCutout" then
      table.insert(nonChromaRaces, raceKeys[i])
    end
  end
  local sortOrder = self.currentCharacterSelection.gender == "Male" and self.maleFaceSortOrder or self.femaleFaceSortOrder
  table.sort(nonChromaRaces, function(a, b)
    local aSortOrder = sortOrder[a]
    local bSortOrder = sortOrder[b]
    if aSortOrder and bSortOrder then
      if aSortOrder ~= bSortOrder then
        return aSortOrder < bSortOrder
      end
    else
      if aSortOrder and not bSortOrder then
        return true
      end
      if not aSortOrder and bSortOrder then
        return false
      end
    end
    return a < b
  end)
  return nonChromaRaces
end
function CACAppearanceTab:UpdateCACSelectionOptions()
  local childList = UiElementBus.Event.GetChildren(self.Properties.GenderList)
  for i = 1, #childList do
    local childName = GameEntityContextRequestBus.Broadcast.GetEntityName(childList[i])
    local isSelected = self.currentCharacterSelection.gender == childName
    UiRadioButtonGroupBus.Event.SetState(self.Properties.GenderList, childList[i], isSelected)
    local currentEntityTable = self.registrar:GetEntityTable(childList[i])
    if isSelected then
      currentEntityTable:OnSelected(true)
    else
      currentEntityTable:OnUnselected()
    end
  end
  local selectedImagePath = self:GetImagePathForSelection(self.Properties.GenderList, self.currentCharacterSelection.gender)
  UiImageBus.Event.SetSpritePathname(self.Properties.GenderIcon, selectedImagePath)
  local raceKeys = self:GetSortedRaceKeys()
  local existingFaceValid = CustomizableCharacterRequestBus.Event.IsRaceEnabled(self.characterEntityId, self.currentCharacterSelection.gender, self.currentCharacterSelection.race)
  if not existingFaceValid and 0 < #raceKeys then
    self:SetCharacterRace(raceKeys[1])
  end
  self:PopulateCACSelectionList(self.Properties.FaceWindow, self.Properties.FaceList, raceKeys, self.currentCharacterSelection.race, self.GetFaceImage)
  selectedImagePath = self:GetFaceImage(self.currentCharacterSelection.race)
  UiImageBus.Event.SetSpritePathname(self.Properties.FaceIcon, selectedImagePath)
  local skinKeys = CustomizableCharacterRequestBus.Event.GetSkintones(self.characterEntityId)
  self:PopulateCACSelectionList(self.Properties.SkinToneWindow, self.Properties.SkinToneList, skinKeys, self.currentCharacterSelection.skinTone, self.GetSkinToneImage)
  selectedImagePath = self:GetSkinToneImage(self.currentCharacterSelection.skinTone)
  if selectedImagePath == nil then
    self.currentCharacterSelection.skinTone = CustomizableCharacterRequestBus.Event.RandomSkinTone(self.characterEntityId, self.currentCharacterSelection.gender, self.currentCharacterSelection.race)
    selectedImagePath = self:GetSkinToneImage(self.currentCharacterSelection.skinTone)
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.SkinToneIcon, selectedImagePath)
  self.faceImagePath = selectedImagePath
  UiImageBus.Event.SetSpritePathname(self.Properties.PlayerIconBack, selectedImagePath)
  local hairColorKeys = CustomizableCharacterRequestBus.Event.GetHairColors(self.characterEntityId)
  self:PopulateCACColorList(self.Properties.HairstyleColorList, hairColorKeys, self.currentCharacterSelection.hairColor, self.GetHairColorImage)
  local hairKeys = CustomizableCharacterRequestBus.Event.GetHairstyles(self.characterEntityId)
  self:PopulateCACSelectionList(self.Properties.HairstyleWindow, self.Properties.HairstyleList, hairKeys, self.currentCharacterSelection.hairstyle, self.GetHairstyleImage)
  selectedImagePath = self:GetHairstyleImage(self.currentCharacterSelection.hairstyle)
  UiCACImageBus.Event.SetCACImage(self.Properties.HairstyleIcon, self.faceImagePath, selectedImagePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.PlayerIconMid, selectedImagePath)
  local facialHairColorKeys = CustomizableCharacterRequestBus.Event.GetFacialHairColors(self.characterEntityId)
  self:PopulateCACColorList(self.Properties.FacialHairColorList, facialHairColorKeys, self.currentCharacterSelection.facialHairColor, self.GetFacialHairColorImage)
  local facialHairKeys = CustomizableCharacterRequestBus.Event.GetFacialHairs(self.characterEntityId)
  self:PopulateCACSelectionList(self.Properties.FacialHairWindow, self.Properties.FacialHairList, facialHairKeys, self.currentCharacterSelection.facialHair, self.GetFacialHairImage)
  selectedImagePath = self:GetFacialHairImage(self.currentCharacterSelection.facialHair)
  UiCACImageBus.Event.SetCACImage(self.Properties.FacialHairIcon, self.faceImagePath, selectedImagePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.PlayerIconFront, selectedImagePath)
  if self.eyeColorEnabled then
    local eyeColorKeys = CustomizableCharacterRequestBus.Event.GetEyeColors(self.characterEntityId)
    self:PopulateCACColorList(self.Properties.EyeColorList, eyeColorKeys, self.currentCharacterSelection.eyeColor, self.GetEyeColorImage, self.Properties.EyeColorWindow)
    local selectedImagePath = self:GetEyeColorImage(self.currentCharacterSelection.eyeColor)
    UiImageBus.Event.SetSpritePathname(self.Properties.EyeColorIcon, selectedImagePath)
  end
  if self.faceMarksEnabled then
    local faceMarkKeys = CustomizableCharacterRequestBus.Event.GetFaceMarks(self.characterEntityId)
    self:PopulateCACSelectionList(self.Properties.FaceMarkWindow, self.Properties.FaceMarkList, faceMarkKeys, self.currentCharacterSelection.faceMark, self.GetFaceMarkImage)
    local selectedImagePath = self:GetFaceMarkImage(self.currentCharacterSelection.faceMark)
    UiImageBus.Event.SetSpritePathname(self.Properties.FaceMarkIcon, selectedImagePath)
  end
  if self.scarsEnabled then
    local scarKeys = CustomizableCharacterRequestBus.Event.GetScars(self.characterEntityId)
    self:PopulateCACSelectionList(self.Properties.ScarWindow, self.Properties.ScarList, scarKeys, self.currentCharacterSelection.scar, self.GetScarImage)
    local selectedImagePath = self:GetScarImage(self.currentCharacterSelection.scar)
    UiImageBus.Event.SetSpritePathname(self.Properties.ScarIcon, selectedImagePath)
  end
  if self.tattoosEnabled then
    local tattooColorKeys = CustomizableCharacterRequestBus.Event.GetTattooColors(self.characterEntityId)
    self:PopulateCACColorList(self.Properties.TattooColorList, tattooColorKeys, self.currentCharacterSelection.tattooColor, self.GetTattooColorImage)
    local tattooKeys = CustomizableCharacterRequestBus.Event.GetTattoos(self.characterEntityId)
    self:PopulateCACSelectionList(self.Properties.TattooWindow, self.Properties.TattooList, tattooKeys, self.currentCharacterSelection.tattoo, self.GetTattooImage)
    local selectedImagePath = self:GetTattooImage(self.currentCharacterSelection.tattoo)
    UiImageBus.Event.SetSpritePathname(self.Properties.TattooIcon, selectedImagePath)
  end
end
function CACAppearanceTab:PopulateCACSelectionList(windowId, listId, itemList, selectedItem, getImagePathFunc)
  UiDynamicLayoutBus.Event.SetNumChildElements(listId, #itemList)
  local childList = UiElementBus.Event.GetChildren(listId)
  local itemWidth = -1
  for i = 1, #childList do
    if i > #itemList then
      UiElementBus.Event.SetIsEnabled(childList[i], false)
    else
      UiElementBus.Event.SetIsEnabled(childList[i], true)
      local isSelected = selectedItem == itemList[i]
      UiRadioButtonGroupBus.Event.SetState(listId, childList[i], isSelected)
      local currentEntityTable = self.registrar:GetEntityTable(childList[i])
      if isSelected then
        currentEntityTable:OnSelected(true)
      else
        currentEntityTable:OnUnselected()
      end
      if itemWidth < 0 then
        local offsets = UiTransform2dBus.Event.GetOffsets(childList[i])
        itemWidth = offsets.right - offsets.left
      end
      local entity = Entity(childList[i])
      entity:SetName(itemList[i])
      local imagePath = getImagePathFunc(self, itemList[i])
      UiCACImageBus.Event.SetCACImage(childList[i], self.faceImagePath, imagePath)
    end
  end
  local offsetPosY
  local contentOffsets = UiTransform2dBus.Event.GetOffsets(windowId)
  local cellSize = UiLayoutGridBus.Event.GetCellSize(listId)
  local spacing = UiLayoutGridBus.Event.GetSpacing(listId)
  local gridWidth = contentOffsets.right - contentOffsets.left
  local gridHorizontalItemCount = math.floor((gridWidth + spacing.x) / (cellSize.x + spacing.x))
  local rows = math.floor(#itemList / gridHorizontalItemCount)
  if 0 < #itemList % gridHorizontalItemCount then
    rows = rows + 1
  end
  local colorGridHeight = 0
  if listId == self.Properties.HairstyleList then
    colorGridHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.HairstyleColorList)
    offsetPosY = 20
  elseif listId == self.Properties.FacialHairList then
    colorGridHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.FacialHairColorList)
    offsetPosY = -15
  elseif listId == self.Properties.ScarList then
    offsetPosY = -15
  elseif listId == self.Properties.TattooList then
    colorGridHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.TattooColorList)
    offsetPosY = -225
  end
  local gridHeight = rows * cellSize.y + (rows - 1) * spacing.y + 36 + colorGridHeight
  contentOffsets.top = -gridHeight / 2
  contentOffsets.bottom = gridHeight / 2
  UiTransform2dBus.Event.SetOffsets(windowId, contentOffsets)
  if offsetPosY then
    self.ScriptedEntityTweener:Set(windowId, {y = offsetPosY})
  end
end
function CACAppearanceTab:PopulateCACColorList(listId, itemList, selectedItem, getImagePathFunc, windowIdToResize)
  UiDynamicLayoutBus.Event.SetNumChildElements(listId, #itemList)
  local childList = UiElementBus.Event.GetChildren(listId)
  if childList ~= nil then
    for i = 1, #childList do
      local isSelected = selectedItem == itemList[i]
      UiRadioButtonGroupBus.Event.SetState(listId, childList[i], isSelected)
      local currentEntityTable = self.registrar:GetEntityTable(childList[i])
      if isSelected then
        currentEntityTable:OnSelected(true)
      else
        currentEntityTable:OnUnselected()
      end
      local entity = Entity(childList[i])
      entity:SetName(itemList[i])
      local imagePath = getImagePathFunc(self, itemList[i])
      UiImageBus.Event.SetSpritePathname(childList[i], imagePath)
    end
  end
  if windowIdToResize then
    local contentOffsets = UiTransform2dBus.Event.GetOffsets(windowIdToResize)
    local colorGridHeight = UiTransform2dBus.Event.GetLocalHeight(listId)
    local height = 24 + colorGridHeight
    contentOffsets.top = -height / 2
    contentOffsets.bottom = height / 2
    UiTransform2dBus.Event.SetOffsets(windowIdToResize, contentOffsets)
  end
end
function CACAppearanceTab:OnRandomize()
  if self.promptOnRandomize == true then
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, self.Properties.RandomizeCharacterPopupTitle, self.Properties.RandomizeCharacterPopupMessage, self.randomizePopupId, self, self.OnPopupResult)
  else
    self:ClearAppearanceRadioGroup()
    self:RandomizeCharacter(true, true, true)
  end
end
function CACAppearanceTab:OnSkinnedMeshCreated()
  CustomizableCharacterRequestBus.Event.ShowDefaultEquipment(self.characterEntityId)
  CustomizableCharacterRequestBus.Event.SetRace(self.characterEntityId, self.currentCharacterSelection.race)
  CustomizableCharacterRequestBus.Event.SetSkinTone(self.characterEntityId, self.currentCharacterSelection.skinTone)
  CustomizableCharacterRequestBus.Event.SetHairstyle(self.characterEntityId, self.currentCharacterSelection.hairstyle)
  CustomizableCharacterRequestBus.Event.SetFacialHair(self.characterEntityId, self.currentCharacterSelection.facialHair)
  CustomizableCharacterRequestBus.Event.SetHairColor(self.characterEntityId, self.currentCharacterSelection.hairColor)
  CustomizableCharacterRequestBus.Event.SetFacialHairColor(self.characterEntityId, self.currentCharacterSelection.facialHairColor)
  if self.eyeColorEnabled then
    CustomizableCharacterRequestBus.Event.SetEyeColor(self.characterEntityId, self.currentCharacterSelection.eyeColor)
  end
  if self.faceMarksEnabled then
    CustomizableCharacterRequestBus.Event.SetFaceMark(self.characterEntityId, self.currentCharacterSelection.faceMark)
  end
  if self.scarsEnabled then
    CustomizableCharacterRequestBus.Event.SetScar(self.characterEntityId, self.currentCharacterSelection.scar)
  end
  if self.tattoosEnabled then
    CustomizableCharacterRequestBus.Event.SetTattoo(self.characterEntityId, self.currentCharacterSelection.tattoo)
    CustomizableCharacterRequestBus.Event.SetTattooColor(self.characterEntityId, self.currentCharacterSelection.tattooColor)
  end
  self:UpdateCACSelectionOptions()
  IntroControllerComponentRequestBus.Broadcast.RequestPlayFaceCreationAnim()
end
return CACAppearanceTab
