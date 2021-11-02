local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local tweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
local ScriptedEntityTweenerCommon = {}
function ScriptedEntityTweenerCommon:OnActivate()
  tweener:OnActivate()
  self.fadeInQuadIn = tweener:CacheAnimation(0.25, {opacity = 1, ease = "QuadIn"})
  self.fadeInQuadOut = tweener:CacheAnimation(0.25, {opacity = 1, ease = "QuadOut"})
  self.fadeOutQuadIn = tweener:CacheAnimation(0.25, {opacity = 0, ease = "QuadIn"})
  self.fadeOutQuadOut = tweener:CacheAnimation(0.25, {opacity = 0, ease = "QuadOut"})
  self.fadeInQuadOutHalfSec = tweener:CacheAnimation(0.5, {opacity = 1, ease = "QuadOut"})
  self.fadeOutQuadOutHalfSec = tweener:CacheAnimation(0.5, {opacity = 0, ease = "QuadOut"})
  self.fadeInHalfSec = tweener:CacheAnimation(0.5, {opacity = 1})
  self.fadeOutHalfSec = tweener:CacheAnimation(0.5, {opacity = 0})
  self.fadeOutLinear = tweener:CacheAnimation(0.25, {opacity = 0, ease = "Linear"})
  self.textToGray50 = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_GRAY_50,
    ease = "QuadOut"
  })
  self.textToGray60 = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_GRAY_60,
    ease = "QuadOut"
  })
  self.textToGray70 = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_GRAY_70,
    ease = "QuadOut"
  })
  self.textToGray80 = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_GRAY_80,
    ease = "QuadOut"
  })
  self.textToGray90 = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_GRAY_90,
    ease = "QuadOut"
  })
  self.textToWhite = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  self.textToBlack = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_BLACK,
    ease = "QuadOut"
  })
  self.textToTan = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_TAN,
    ease = "QuadOut"
  })
  self.textToTanDark = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_TAN_DARK,
    ease = "QuadOut"
  })
  self.textToGreen = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_GREEN,
    ease = "QuadOut"
  })
  self.textToRed = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_RED,
    ease = "QuadOut"
  })
  self.textToYellowLight = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_YELLOW_LIGHT,
    ease = "QuadOut"
  })
  self.textToMastery = tweener:CacheAnimation(0.25, {
    textColor = UIStyle.COLOR_MASTERY,
    ease = "QuadOut"
  })
  self.imgToGray50 = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_GRAY_50,
    ease = "QuadOut"
  })
  self.imgToGray60 = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_GRAY_60,
    ease = "QuadOut"
  })
  self.imgToGray70 = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_GRAY_70,
    ease = "QuadOut"
  })
  self.imgToGray80 = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_GRAY_80,
    ease = "QuadOut"
  })
  self.imgToGray90 = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_GRAY_90,
    ease = "QuadOut"
  })
  self.imgToWhite = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  self.imgToRed = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_RED_MEDIUM,
    ease = "QuadOut"
  })
  self.imgToTan = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_TAN,
    ease = "QuadOut"
  })
  self.imgToBlack = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_BLACK,
    ease = "QuadOut"
  })
  self.imgToYellowLight = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_YELLOW_LIGHT,
    ease = "QuadOut"
  })
  self.imgToTanDark = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_TAN_DARK,
    ease = "QuadOut"
  })
  self.imgToMastery = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_MASTERY,
    ease = "QuadOut"
  })
  self.imgToMasteryDark = tweener:CacheAnimation(0.25, {
    imgColor = UIStyle.COLOR_MASTERY_DARK,
    ease = "QuadOut"
  })
  self.imgFillTo1 = tweener:CacheAnimation(0.25, {imgFill = 1, ease = "QuadOut"})
  self.imgFillTo1Instant = tweener:CacheAnimation(0, {imgFill = 1})
  self.imgFillTo0Instant = tweener:CacheAnimation(0, {imgFill = 0})
  self.xTo0 = tweener:CacheAnimation(0.25, {x = 0, ease = "QuadOut"})
  self.yTo0 = tweener:CacheAnimation(0.25, {y = 0, ease = "QuadOut"})
  self.opacityTo10 = tweener:CacheAnimation(0.2, {opacity = 0.1, ease = "QuadOut"})
  self.opacityTo20 = tweener:CacheAnimation(0.2, {opacity = 0.2, ease = "QuadOut"})
  self.opacityTo25 = tweener:CacheAnimation(0.2, {opacity = 0.25, ease = "QuadOut"})
  self.opacityTo30 = tweener:CacheAnimation(0.2, {opacity = 0.3, ease = "QuadOut"})
  self.opacityTo40 = tweener:CacheAnimation(0.2, {opacity = 0.4, ease = "QuadOut"})
  self.opacityTo50 = tweener:CacheAnimation(0.2, {opacity = 0.5, ease = "QuadOut"})
  self.opacityTo60 = tweener:CacheAnimation(0.2, {opacity = 0.6, ease = "QuadOut"})
  self.opacityTo70 = tweener:CacheAnimation(0.2, {opacity = 0.7, ease = "QuadOut"})
  self.opacityTo80 = tweener:CacheAnimation(0.2, {opacity = 0.8, ease = "QuadOut"})
  self.scaleTo1 = tweener:CacheAnimation(0.2, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.scaleTo0 = tweener:CacheAnimation(0.2, {
    scaleX = 0,
    scaleY = 0,
    ease = "QuadOut"
  })
  self.scaleXTo1 = tweener:CacheAnimation(0.2, {scaleX = 1, ease = "QuadOut"})
  self.scaleYTo1 = tweener:CacheAnimation(0.2, {scaleX = 1, ease = "QuadOut"})
  self.rotateCWInfinite = tweener:CacheAnimation(10, {rotation = 359, timesToPlay = -1})
  self.rotateCCWInfinite = tweener:CacheAnimation(10, {rotation = -359, timesToPlay = -1})
  local animDuration = 0.25
  local scaleGlorySmall = 0.7
  local scaleGloryMedium = 1
  local scaleGloryFull = 1
  local sizeCrestSmall = 30
  local sizeCrestMedium = 42
  local sizeCrestFull = 42
  self.markerCrestFull = tweener:CacheAnimation(animDuration, {
    opacity = 1,
    w = sizeCrestFull,
    h = sizeCrestFull,
    ease = "QuadOut"
  })
  self.markerGloryFull = tweener:CacheAnimation(animDuration, {
    scaleX = scaleGloryFull,
    scaleY = scaleGloryFull,
    ease = "QuadOut"
  })
  self.markerCrestMedium = tweener:CacheAnimation(animDuration, {
    opacity = 1,
    w = sizeCrestMedium,
    h = sizeCrestMedium,
    ease = "QuadOut"
  })
  self.markerGloryMedium = tweener:CacheAnimation(animDuration, {
    scaleX = scaleGloryMedium,
    scaleY = scaleGloryMedium,
    ease = "QuadOut"
  })
  self.PING_OFFSET_POS_Y = -65
  self.pingIntroFlash = tweener:CacheAnimation(0.4, {
    opacity = 0,
    scaleY = 0.2,
    scaleX = 0.2,
    ease = "QuadOut"
  })
  self.pingIntroIcon1 = tweener:CacheAnimation(0.8, {
    opacity = 0,
    scaleY = 1.5,
    scaleX = 1.5,
    ease = "QuadOut"
  })
  self.pingIntroIcon2 = tweener:CacheAnimation(0.5, {
    y = self.PING_OFFSET_POS_Y,
    ease = "QuadOut"
  })
  self.pingInFocus1 = tweener:CacheAnimation(0.5, {
    scaleY = 0.4,
    scaleX = 0.4,
    y = self.PING_OFFSET_POS_Y,
    ease = "QuadOut"
  })
  self.pingInFocus2 = tweener:CacheAnimation(0.5, {opacity = 1, ease = "QuadOut"})
  self.distanceTextFlashOut = tweener:CacheAnimation(0.5, {opacity = 0, ease = "QuadOut"})
  self.pingTailDrawIn = tweener:CacheAnimation(0.5, {
    opacity = 1,
    h = 75,
    ease = "QuadOut"
  })
  self.pingScaleHalf = tweener:CacheAnimation(0.5, {
    scaleY = 0.5,
    scaleX = 0.5,
    ease = "QuadOut"
  })
  self.pingScaleFull = tweener:CacheAnimation(0.5, {
    scaleY = 1,
    scaleX = 1,
    ease = "QuadOut"
  })
  self.pingTailIn = tweener:CacheAnimation(0.1, {opacity = 1, ease = "QuadOut"})
  self.pingTailOut = tweener:CacheAnimation(0.05, {opacity = 0, ease = "QuadOut"})
  self.scrollbarFocus = tweener:CacheAnimation(0.15, {
    opacity = 1,
    imgColor = UIStyle.COLOR_ORANGE_SCROLLBAR_FOCUS,
    ease = "QuadOut"
  })
  self.scrollbarUnfocus = tweener:CacheAnimation(0.25, {
    opacity = 0.8,
    imgColor = UIStyle.COLOR_ORANGE_SCROLLBAR,
    ease = "QuadOut"
  })
  self.chatWidgetIconUnseen = tweener:CacheAnimation(1.4, {
    opacity = 0,
    imgColor = UIStyle.COLOR_GRAY_50,
    ease = "QuadOut"
  })
  self.socialPaneShow = tweener:CacheAnimation(0.15, {
    opacity = 1,
    x = 0,
    ease = "QuadOut"
  })
  self.navMenuHolderIn = tweener:CacheAnimation(0.25, {y = -1, ease = "QuadOut"})
  self.vitalsMeterIn = tweener:CacheAnimation(0.3, {opacity = 1, ease = "QuadInOut"})
  self.vitalsMeterOut = tweener:CacheAnimation(0.3, {opacity = 0, ease = "QuadInOut"})
  self.tokenFadeIn = tweener:CacheAnimation(0.1, {opacity = 1, ease = "QuadOut"})
  self.tokenFadeOut = tweener:CacheAnimation(0.1, {opacity = 0, ease = "QuadIn"})
  self.tokenMoveIn = tweener:CacheAnimation(2.1, {
    x = 0,
    y = 0,
    ease = "QuadOut"
  })
  self.usedFlashFadeOut = tweener:CacheAnimation(0.85, {opacity = 0, ease = "QuadOut"})
  self.countdownOnCooldown = tweener:CacheAnimation(0.01, {opacity = 1, ease = "QuadOut"})
  self.abilityIconOnCooldown = tweener:CacheAnimation(0.01, {opacity = 0.1, ease = "QuadOut"})
  self.abilityFillOnCooldown = tweener:CacheAnimation(0.01, {
    opacity = 0.7,
    imgColor = UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  self.countdownOffCooldown = tweener:CacheAnimation(0.05, {opacity = 0, ease = "QuadIn"})
  self.abilityIconOffCooldown = tweener:CacheAnimation(0.05, {opacity = 0.9, ease = "QuadOut"})
  self.abilityDimmerOnCooldown = tweener:CacheAnimation(0.01, {opacity = 0})
  self.abilityDimmerOffCooldown = tweener:CacheAnimation(0.05, {opacity = 0.7})
  local abilityHolderInitPosX = -205
  local abilityHolderInitPosY = -15
  local abilityHolderOffsetPosX = 100
  local abilityHolderOffsetPosY = 10
  self.abilityHolderShow = tweener:CacheAnimation(0.2, {x = abilityHolderInitPosX, ease = "QuadOut"})
  self.abilityHolderHide = tweener:CacheAnimation(0.2, {
    x = abilityHolderInitPosX + abilityHolderOffsetPosX,
    ease = "QuadOut"
  })
  self.abilityHolderDimmed = tweener:CacheAnimation(0.2, {opacity = 0.5, ease = "QuadOut"})
  self.abilityHolderNotDimmed = tweener:CacheAnimation(0.2, {opacity = 1, ease = "QuadOut"})
  self.abilityHolderSmall = tweener:CacheAnimation(0.2, {
    y = abilityHolderInitPosY + abilityHolderOffsetPosY,
    scaleY = 0.8,
    scaleX = 0.8,
    ease = "QuadOut"
  })
  self.abilityHolderNotSmall = tweener:CacheAnimation(0.2, {
    y = abilityHolderInitPosY,
    scaleY = 1,
    scaleX = 1,
    ease = "QuadOut"
  })
  self.abilityHolderUp = tweener:CacheAnimation(0.2, {y = -15, ease = "QuadOut"})
  self.abilityHolderDown = tweener:CacheAnimation(0.2, {y = 0, ease = "QuadOut"})
  self.objectiveOut = tweener:CacheAnimation(0.3, {
    opacity = 0,
    x = 72,
    ease = "QuadIn"
  })
  self.taskCheckboxGlow1 = tweener:CacheAnimation(0.15, {
    opacity = 1,
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.taskCheckboxGlow2 = tweener:CacheAnimation(0.55, {
    opacity = 0,
    scaleX = 0.7,
    scaleY = 0.7,
    ease = "QuadIn"
  })
  self.taskCheckmarkShow1 = tweener:CacheAnimation(0.2, {
    scaleX = 2,
    scaleY = 2,
    ease = "QuadOut"
  })
  self.taskCheckmarkShow2 = tweener:CacheAnimation(0.4, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadInOut"
  })
  self.objectiveFlash1 = tweener:CacheAnimation(0.15, {
    opacity = 1,
    imgColor = UIStyle.COLOR_YELLOW_LIGHT,
    ease = "QuadOut"
  })
  self.objectiveFlash2 = tweener:CacheAnimation(0.2, {
    opacity = 0.5,
    imgColor = UIStyle.COLOR_YELLOW_GOLD,
    ease = "QuadInOut"
  })
  self.objectiveFlash3 = tweener:CacheAnimation(0.2, {opacity = 0, ease = "QuadOut"})
  self.containerIn = tweener:CacheAnimation(0.5, {
    opacity = 1,
    x = 0,
    ease = "QuadOut"
  })
  self.flashStart = tweener:CacheAnimation(0, {x = -2000, opacity = 0})
  self.flashEnd = tweener:CacheAnimation(0.8, {
    x = 990,
    opacity = 1,
    ease = "QuadInOut"
  })
  self.flashScaleUp = tweener:CacheAnimation(0.5, {scaleY = 3.5})
  self.flashScaleDown = tweener:CacheAnimation(0.5, {scaleY = 2.5})
  self.flashContainerScaleTo1 = tweener:CacheAnimation(2, {scaleX = 1})
  self.flashContainerY = tweener:CacheAnimation(2, {y = 96})
  self.flashGlowIn = tweener:CacheAnimation(0.1, {opacity = 1})
  self.flashGlowOut = tweener:CacheAnimation(0.83, {opacity = 0})
  self.flashEffectPosYTo0 = tweener:CacheAnimation(0.38, {y = 0})
  self.flashEffectOut = tweener:CacheAnimation(0.65, {opacity = 0})
  self.pulseShow = tweener:CacheAnimation(1.2, {
    scaleX = 3,
    scaleY = 3,
    opacity = 0,
    ease = "QuadInOut"
  })
  self.lootTickerLine = tweener:CacheAnimation(0.75, {
    opacity = 0.5,
    h = 570,
    ease = "QuintOut"
  })
  self.lootTickerItemLine = tweener:CacheAnimation(2, {w = 570, ease = "QuintOut"})
  self.lootTickerFadeHalf = tweener:CacheAnimation(0.5, {opacity = 0.5, ease = "QuadOut"})
  self.lootTickerItemHide = tweener:CacheAnimation(0.25, {opacity = 0, ease = "QuadOut"})
  self.lootTickerItemContainerHide = tweener:CacheAnimation(0.25, {opacity = 0, ease = "QuadOut"})
  self.duelSlideIn = tweener:CacheAnimation(0.1, {
    y = 63,
    opacity = 1,
    ease = "QuadOut"
  })
  self.duelFadeOut = tweener:CacheAnimation(0.5, {opacity = 0, ease = "QuadOut"})
  self.textCharacterTo250 = tweener:CacheAnimation(3, {textCharacterSpace = 250})
  self.countdownDuel = tweener:CacheAnimation(0.7, {
    scaleX = 0.7,
    scaleY = 0.7,
    opacity = 0,
    ease = "QuadIn"
  })
  self.rewardLayoutFlash1 = tweener:CacheAnimation(0.25, {
    scaleX = 1.5,
    scaleY = 0.05,
    ease = "Linear"
  })
  self.rewardLayoutFlash2 = tweener:CacheAnimation(0.15, {opacity = 0, ease = "QuadIn"})
  self.difficultyItemCross1 = tweener:CacheAnimation(0.15, {
    opacity = 1,
    imgColor = UIStyle.COLOR_RED_LIGHT,
    scaleX = 1.6,
    scaleY = 1.6,
    ease = "QuadOut"
  })
  self.difficultyItemCross2 = tweener:CacheAnimation(0.4, {
    imgColor = UIStyle.COLOR_RED_MEDIUM,
    scaleX = 1,
    scaleY = 1,
    ease = "QuadInOut"
  })
  self.afflictionBarFontSpacing = tweener:CacheAnimation(0.3, {
    textCharacterSpace = UIStyle.FONT_SPACING_AFFLICTION_ACTIVE,
    ease = "QuadOut"
  })
  self.tooltipFlashSmallIn = tweener:CacheAnimation(0.2, {opacity = 0.5, ease = "QuadOut"})
  self.tooltipFlashLargeIn = tweener:CacheAnimation(0.2, {
    opacity = 0.5,
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.baitWindowShow = tweener:CacheAnimation(0.3, {
    opacity = 1,
    y = 0,
    ease = "QuadOut"
  })
  self.baitWindowHide = tweener:CacheAnimation(0.3, {
    opacity = 0,
    y = -10,
    ease = "QuadOut"
  })
  self.releaseEffect1 = tweener:CacheAnimation(0.05, {
    scaleX = 1,
    opacity = 1,
    ease = "QuadOut"
  })
  self.releaseEffect2 = tweener:CacheAnimation(0.3, {scaleX = 2, ease = "QuadOut"})
  self.powerNode1 = tweener:CacheAnimation(0.05, {scaleX = 0.9, scaleY = 0.9})
  self.powerNode2 = tweener:CacheAnimation(0.1, {
    scaleX = 1.3,
    scaleY = 1.3,
    ease = "QuadOut"
  })
  self.powerNode3 = tweener:CacheAnimation(0.1, {
    scaleX = 1,
    scaleY = 1,
    opacity = 0,
    ease = "QuadOut"
  })
  self.indicatorHide = tweener:CacheAnimation(0.5, {
    x = 0,
    opacity = 0,
    ease = "QuadOut"
  })
  self.innerBobberShow = tweener:CacheAnimation(0.4, {
    opacity = 1,
    y = 0,
    ease = "QuadOut"
  })
  self.bobberPulse = tweener:CacheAnimation(0.05, {
    scaleX = 1.2,
    scaleY = 1.2,
    ease = "QuadOut"
  })
  self.successText = tweener:CacheAnimation(5, {textCharacterSpace = 300, ease = "QuadOut"})
  self.scaleEffect1 = tweener:CacheAnimation(1, {
    scaleX = 1,
    opacity = 1,
    ease = "QuadOut"
  })
  self.scaleEffect2 = tweener:CacheAnimation(1, {scaleX = 1.2, ease = "QuadOut"})
end
function ScriptedEntityTweenerCommon:OnDeactivate()
  tweener:OnDeactivate()
end
return ScriptedEntityTweenerCommon
