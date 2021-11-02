local MarkerData = {}
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local playerMarkerFadeDistance = 50
local playerMarkerFadeStartDistance = playerMarkerFadeDistance - 0.1
MarkerData.playerMarkerFadeDistance = playerMarkerFadeDistance
MarkerData.playerMarkerWarFadeDistance = 150
MarkerData.distancePriorities = {
  10,
  35,
  1000
}
MarkerData.types = {
  Health = {
    wX = 0,
    wY = 0,
    wZ = 1.2,
    lockedZ = 1.4,
    sX = 0,
    sY = 0,
    minScale = 0.5,
    maxScale = 1,
    minAlpha = 0,
    maxAlpha = 1,
    scaleStart = 7,
    scaleDistance = 10,
    fadeStart = 7,
    fadeDistance = 8.5,
    barVFXDelay = 0.3,
    timeToFadeHealth = 10,
    States = {},
    SubTypes = {
      Player = {
        wZ = 1.9,
        lockedZ = 1.4,
        minScale = 0.8,
        scaleStart = 1,
        scaleDistance = playerMarkerFadeDistance,
        fadeStart = playerMarkerFadeStartDistance,
        fadeDistance = playerMarkerFadeDistance,
        allowWorldOcclusion = true,
        occlusionInterval = 0.33,
        hasGuildWarData = true,
        usePlayerDistancePriorities = true,
        offsetOnDeath = true,
        deathPosOffset = 0.5,
        States = {
          Screen_Enter = {
            callbackFunction = function(tableSelf)
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.ScreenStates.OnScreen, true)
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.ScreenStates.OffScreen, false)
            end
          },
          Screen_Exit = {
            callbackFunction = function(tableSelf)
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.ScreenStates.OnScreen, false)
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.ScreenStates.OffScreen, true)
            end
          },
          Focus_Enter = {
            callbackFunction = function(tableSelf)
              tableSelf:SetPlayerNamePosition()
            end
          },
          Focus_Exit = {
            callbackFunction = function(tableSelf)
              tableSelf:SetPlayerNamePosition()
            end
          },
          Alive = {
            callbackFunction = function(tableSelf)
              tableSelf:RestoreCurrentState(tableSelf.states.onScreen)
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.OffscreenPartyIcon, true)
            end
          },
          Dead = {
            callbackFunction = function(tableSelf)
              tableSelf:RestoreCurrentState(tableSelf.states.onScreen)
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.OffscreenPartyIcon, true)
            end
          },
          EnterDeathsDoor = {
            callbackFunction = function(tableSelf)
              tableSelf.tweener:Play(tableSelf.Properties.HealthBar, 0.25, {
                opacity = 0,
                onComplete = function()
                  UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, false)
                  tableSelf:UpdateSecondRowGuildNameOrHealthbar(true)
                end
              })
              local offsetPosY = -60
              if tableSelf.Properties.Player.IsLowDetail then
                offsetPosY = -40
              elseif tableSelf.Properties.Player.IsFullDetail then
                offsetPosY = -50
              end
              tableSelf.tweener:Set(tableSelf.Properties.ScreenStates.OnScreen, {y = offsetPosY})
              local isOffscreen = tableSelf:IsInState(tableSelf.states.onScreen, "Screen_Exit")
              if isOffscreen then
                tableSelf.tweener:Set(tableSelf.Properties.Player.DeathsDoor.DeathsDoorContainer, {
                  scaleX = 0.5,
                  scaleY = 0.5,
                  y = -2
                })
                UiElementBus.Event.SetIsEnabled(tableSelf.Properties.OffscreenPartyIcon, false)
              end
              local fullImageFill = 0.78
              local emptyImageFill = 0.06
              local fullDeathsDoorTime = tableSelf.deathsDoorFullTime
              local percentage = math.min(1, tableSelf.deathsDoorTime / fullDeathsDoorTime)
              tableSelf.tweener:Set(tableSelf.Properties.Player.DeathsDoor.DeathsDoorTimer, {
                imgFill = (fullImageFill - emptyImageFill) * percentage + emptyImageFill
              })
              tableSelf.tweener:Play(tableSelf.Properties.Player.DeathsDoor.DeathsDoorTimer, tableSelf.deathsDoorTime / 1000, {imgFill = 0.06})
            end
          },
          ExitDeathsDoor = {
            callbackFunction = function(tableSelf)
              tableSelf.tweener:Set(tableSelf.Properties.ScreenStates.OnScreen, {y = 0})
              tableSelf:UpdateSecondRowGuildNameOrHealthbar(true)
              local offsetScale = 0.8
              if tableSelf.Properties.Player.IsLowDetail then
                offsetScale = 0.4
              elseif tableSelf.Properties.Player.IsFullDetail then
                offsetScale = 0.5
                tableSelf:UpdateIsShowingGuildCrest()
              end
              tableSelf.tweener:Set(tableSelf.Properties.Player.DeathsDoor.DeathsDoorContainer, {
                scaleX = offsetScale,
                scaleY = offsetScale,
                y = 0
              })
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.OffscreenPartyIcon, true)
              tableSelf.tweener:Stop(tableSelf.Properties.Player.DeathsDoor.DeathsDoorTimer)
              tableSelf:RestoreCurrentState(tableSelf.states.onScreen)
            end
          },
          MyPvpFlagOn = {
            callbackFunction = function(tableSelf)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
            end
          },
          MyPvpFlagOff = {
            callbackFunction = function(tableSelf)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
            end
          },
          TargetPvpFlagOn = {
            callbackFunction = function(tableSelf)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
            end
          },
          TargetPvpFlagOff = {
            callbackFunction = function(tableSelf)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
            end
          },
          GuildMate = {
            callbackFunction = function(tableSelf)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
            end
          },
          NotGuildMate = {
            callbackFunction = function(tableSelf)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
            end
          },
          Group_Enter = {
            callbackFunction = function(tableSelf)
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.PartyIcon, true)
              UiImageBus.Event.SetSpritePathname(tableSelf.Properties.PartyIcon, tableSelf.groupMemberIcon)
              UiImageBus.Event.SetColor(tableSelf.Properties.PartyIcon, tableSelf.groupMemberColor)
              UiImageBus.Event.SetColor(tableSelf.Properties.OffscreenPartyIcon, tableSelf.groupMemberColor)
              UiImageBus.Event.SetColor(tableSelf.Properties.Player.ArrowIndicator, tableSelf.groupMemberColor)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
              tableSelf.typeInfo.isInGroup = true
              tableSelf:UpdateOnScreenState()
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Distance, true)
              tableSelf.tweener:Set(tableSelf.Properties.Title, {x = 26})
            end
          },
          Group_Exit = {
            callbackFunction = function(tableSelf)
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.PartyIcon, false)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
              tableSelf.typeInfo.isInGroup = nil
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Distance, false)
              tableSelf.tweener:Set(tableSelf.Properties.Title, {x = 1})
            end
          },
          Duel_Enter = {
            callbackFunction = function(tableSelf)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
            end
          },
          Duel_Exit = {
            callbackFunction = function(tableSelf)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
            end
          },
          GuildWarPreWar = {
            callbackFunction = function(tableSelf)
              tableSelf:UpdateSecondRowGuildNameOrHealthbar(nil, true)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
            end
          },
          GuildWarOn = {
            callbackFunction = function(tableSelf)
              tableSelf:UpdateSecondRowGuildNameOrHealthbar(nil, true)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
            end
          },
          GuildWarOff = {
            callbackFunction = function(tableSelf)
              local showGuildName = true
              tableSelf:UpdateSecondRowGuildNameOrHealthbar(nil, showGuildName)
              tableSelf:SetPrioritizedPlayerNameTextColor()
              tableSelf:SetPrioritizedPlayerHealthBarColor()
            end
          },
          Idle_Health_Start = {
            callbackFunction = function(tableSelf)
              tableSelf:UpdateSecondRowGuildNameOrHealthbar(true, nil)
            end
          },
          Idle_Health_End = {
            callbackFunction = function(tableSelf)
              tableSelf:UpdateSecondRowGuildNameOrHealthbar(true, nil)
            end
          },
          Critical_Health = {
            callbackFunction = function(tableSelf)
              tableSelf:UpdateSecondRowGuildNameOrHealthbar(true, nil)
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBarPulse, true)
              tableSelf.timeline = tableSelf.tweener:TimelineCreate()
              tableSelf.timeline:Add(tableSelf.Properties.HealthBarPulse, 0.4, {opacity = 0.9})
              tableSelf.timeline:Add(tableSelf.Properties.HealthBarPulse, 0.05, {opacity = 0.9})
              tableSelf.timeline:Add(tableSelf.Properties.HealthBarPulse, 0.35, {
                opacity = 0.1,
                onComplete = function()
                  tableSelf.timeline:Play()
                end
              })
              tableSelf.timeline:Play()
            end
          },
          LessHalf_Health = {
            callbackFunction = function(tableSelf)
              if tableSelf.timeline then
                tableSelf.timeline:Stop()
              end
              tableSelf:UpdateSecondRowGuildNameOrHealthbar(true, nil)
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBarPulse, false)
            end
          },
          Full_Health = {
            callbackFunction = function(tableSelf)
              if tableSelf.timeline then
                tableSelf.timeline:Stop()
              end
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBarPulse, false)
              tableSelf:RestoreCurrentState(tableSelf.states.healthIdleStates)
            end
          },
          GreaterHalf_Health = {
            callbackFunction = function(tableSelf)
              tableSelf:UpdateSecondRowGuildNameOrHealthbar(true, nil)
              if tableSelf.timeline then
                tableSelf.timeline:Stop()
              end
              UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBarPulse, false)
            end
          },
          NotStreaming = {
            callbackFunction = function(tableSelf)
              if tableSelf.Properties.Player.Streaming.StreamingContainer:IsValid() then
                UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Player.Streaming.StreamingContainer, false)
                tableSelf:UpdateSecondRowGuildNameOrHealthbar(nil, nil, false)
                tableSelf.dataLayer:UnregisterObserver(tableSelf, tableSelf.dataPathPrefix .. ".ViewerCount")
              end
              tableSelf:SetPrioritizedPlayerNameTextColor()
            end
          },
          Streaming = {
            callbackFunction = function(tableSelf)
              if tableSelf.Properties.Player.Streaming.StreamingContainer:IsValid() then
                UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Player.Streaming.StreamingContainer, true)
                tableSelf:UpdateSecondRowGuildNameOrHealthbar(nil, nil, true)
                tableSelf.dataLayer:RegisterAndExecuteDataObserver(tableSelf, tableSelf.dataPathPrefix .. ".ViewerCount", function(tableSelf, count)
                  local viewerCount = count or 0
                  local text = GetLocalizedNumber(viewerCount)
                  UiTextBus.Event.SetText(tableSelf.Properties.Player.Streaming.ViewerCountText, text)
                end)
              end
              tableSelf:SetPrioritizedPlayerNameTextColor()
            end
          },
          TargetActive = {},
          TargetInactive = {}
        }
      }
    }
  },
  AI = {
    wX = 0,
    wY = 0,
    wZ = 1.2,
    lockedZ = 0.6,
    sX = 0,
    sY = 0,
    minScale = 0.6,
    maxScale = 1,
    minAlpha = 0,
    maxAlpha = 1,
    scaleStart = 1,
    scaleDistance = 15,
    fadeStart = 10,
    fadeDistance = 15,
    barVFXDelay = 0.3,
    timeToFadeHealth = 10,
    allowWorldOcclusion = true,
    occlusionInterval = 0.33,
    useEntityName = true,
    scaleHealthBar = true,
    minHealthWidth = 200,
    maxHealthWidth = 250,
    useGatherableInteract = true,
    offsetOnDeath = true,
    deathPosOffset = 0,
    delayBeforeApplyDeathOffset = 4,
    clampYToScreen = true,
    States = {
      Critical_Health = {
        callbackFunction = function(tableSelf)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Title, true)
          tableSelf.tweener:Stop(tableSelf.Properties.HealthBar)
          tableSelf.tweener:Set(tableSelf.Properties.HealthBar, {opacity = 1})
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, true)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBarPulse, true)
          tableSelf.timeline = tableSelf.tweener:TimelineCreate()
          tableSelf.timeline:Add(tableSelf.Properties.HealthBarPulse, 0.4, {opacity = 0.9})
          tableSelf.timeline:Add(tableSelf.Properties.HealthBarPulse, 0.05, {opacity = 0.9})
          tableSelf.timeline:Add(tableSelf.Properties.HealthBarPulse, 0.35, {
            opacity = 0.1,
            onComplete = function()
              tableSelf.timeline:Play()
            end
          })
          tableSelf.timeline:Play()
        end
      },
      LessHalf_Health = {
        callbackFunction = function(tableSelf)
          if tableSelf.timeline then
            tableSelf.timeline:Stop()
          end
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Title, true)
          tableSelf.tweener:Stop(tableSelf.Properties.HealthBar)
          tableSelf.tweener:Set(tableSelf.Properties.HealthBar, {opacity = 1})
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, true)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBarPulse, false)
        end
      },
      Full_Health = {
        callbackFunction = function(tableSelf)
          if tableSelf.timeline then
            tableSelf.timeline:Stop()
          end
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Title, true)
          tableSelf.tweener:Stop(tableSelf.Properties.HealthBar)
          tableSelf.tweener:Set(tableSelf.Properties.HealthBar, {opacity = 1})
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, true)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBarPulse, false)
        end
      },
      GreaterHalf_Health = {
        callbackFunction = function(tableSelf)
          if tableSelf.timeline then
            tableSelf.timeline:Stop()
          end
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Title, true)
          tableSelf.tweener:Stop(tableSelf.Properties.HealthBar)
          tableSelf.tweener:Set(tableSelf.Properties.HealthBar, {opacity = 1})
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, true)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBarPulse, false)
        end
      },
      No_Health = {
        callbackFunction = function(tableSelf)
          if tableSelf.timeline then
            tableSelf.timeline:Stop()
          end
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Title, false)
          tableSelf.tweener:Play(tableSelf.Properties.HealthBar, 0.3, {opacity = 0, delay = 1})
        end
      },
      TargetActive = {},
      TargetInactive = {}
    },
    SubTypes = {
      Bear = {
        wZ = 3.5,
        lockedZ = 1.25,
        interactWorldZOffset = 1
      },
      Wolf = {
        wZ = 1.5,
        lockedZ = 0.75,
        interactWorldZOffset = 0.4
      },
      Cat = {
        wZ = 2,
        lockedZ = 0.75,
        interactWorldZOffset = 0.4
      },
      Alligator = {
        wZ = 2.3,
        lockedZ = 1.25,
        interactWorldZOffset = 0.9
      },
      Turkey = {
        wZ = 1.5,
        lockedZ = 0,
        interactWorldZOffset = 0.5
      },
      Boar = {
        wZ = 1.3,
        lockedZ = -0.2,
        interactWorldZOffset = 0.75
      },
      Cow = {
        wZ = 1.7,
        lockedZ = -0.2,
        interactWorldZOffset = 0.5
      },
      Goat = {
        wZ = 1.2,
        lockedZ = -0.2,
        interactWorldZOffset = 0.5
      },
      Hound = {wZ = 0.7, lockedZ = 0.5},
      Commander = {wZ = 3, lockedZ = 1.4},
      HumanAITall = {wZ = 2.7, lockedZ = 1.4},
      SprigganAITall = {wZ = 4.4, lockedZ = 1.4},
      Brute = {wZ = 4.4, lockedZ = 1.4},
      HumanAI = {wZ = 1.9, lockedZ = 1.4},
      HumanAICrawl = {wZ = 1, lockedZ = 0},
      Tendril = {wZ = 3.6, lockedZ = 1.4},
      Elk = {
        wZ = 2.5,
        wY = 0,
        lockedZ = 1.1,
        interactWorldZOffset = 0.3
      },
      Bison = {
        wZ = 2.25,
        lockedZ = 1,
        interactWorldZOffset = 0.15
      },
      Ghost = {wZ = 2.9, lockedZ = 1.4},
      Rabbit_snowshoe = {wZ = 1, lockedZ = 1.4},
      Rabbit_spotted = {wZ = 1, lockedZ = 1.4},
      Empress = {wZ = 3.4, lockedZ = 1.4},
      Isabella = {wZ = 3.3, lockedZ = 1.4},
      Naga = {wZ = 5.1, lockedZ = 1.4},
      Naga_AngryEarth = {wZ = 4.4, lockedZ = 1.4},
      Grunt = {wZ = 1.9, lockedZ = 1.4},
      IceGauntlet = {
        wZ = 1.7,
        lockedZ = 1.7,
        fadeStart = 4,
        fadeDistance = 6,
        timeToFadeHealth = 5,
        scaleHealthBar = true,
        minHealthWidth = 100,
        maxHealthWidth = 140,
        useGatherableInteract = false
      }
    }
  },
  Structures = {
    wX = 0,
    wY = 0,
    wZ = 1.2,
    sX = 0,
    sY = 0,
    minScale = 0.8,
    maxScale = 1,
    minAlpha = 0,
    maxAlpha = 1,
    scaleStart = 4,
    scaleDistance = 10,
    fadeStart = 4,
    fadeDistance = 8,
    barVFXDelay = 0.3,
    timeToFadeHealth = 5,
    hasGuildWarData = true,
    changeHealthVisibilityWithVitalsInfo = true,
    showHealthBar = true,
    States = {
      Focus_Enter = {
        callbackFunction = function(tableSelf)
          tableSelf.tweener:Play(tableSelf.Properties.Dot, 0.25, {scaleX = 0, scaleY = 0})
          if tableSelf.hasVitals and tableSelf.typeInfo.showHealthBar then
            do
              local isHealthBarEnabled = false
              tableSelf.tweener:Play(tableSelf.Properties.HealthBar, 0.15, {
                w = 310,
                x = 50,
                onUpdate = function(percent, value)
                  if 0.25 < percent and not isHealthBarEnabled then
                    UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, true)
                    isHealthBarEnabled = true
                  end
                end
              })
              if tableSelf.Properties.HealthBarFrame:IsValid() then
                tableSelf.tweener:Play(tableSelf.Properties.HealthBarFrame, 0.15, {
                  w = 342.5,
                  x = 12.5,
                  opacity = 1
                })
              end
            end
          else
            UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, false)
          end
        end
      },
      Focus_Exit = {
        callbackFunction = function(tableSelf)
          tableSelf.tweener:Play(tableSelf.Properties.Dot, 0.25, {scaleX = 1, scaleY = 1})
          if tableSelf.hasVitals and tableSelf.typeInfo.showHealthBar then
            tableSelf.tweener:Play(tableSelf.Properties.HealthBar, 0.15, {
              w = 80,
              x = 15,
              onComplete = function()
                local healthStates = tableSelf.states.healthStates
                local healthIdleStates = tableSelf.states.healthIdleStates
                local shouldHealthBarShow = healthStates.currentState == healthStates.stateNames.Critical_Health or healthStates.currentState == healthStates.stateNames.LessHalf_Health or healthIdleStates.currentState == healthIdleStates.stateNames.Idle_Health_End
                UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, shouldHealthBarShow)
              end
            })
            if tableSelf.Properties.HealthBarFrame:IsValid() then
              tableSelf.tweener:Play(tableSelf.Properties.HealthBarFrame, 0.15, {w = 90.3, opacity = 0})
            end
          else
            UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, false)
          end
        end
      },
      Full_Health = {
        callbackFunction = function(tableSelf)
          local interactState = tableSelf.states.interactFocusState
          if interactState.currentState ~= interactState.stateNames.Focus_Enter then
            UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, false)
          end
        end
      },
      GreaterHalf_Health = {
        callbackFunction = function(tableSelf)
          local interactState = tableSelf.states.interactFocusState
          if interactState.currentState ~= interactState.stateNames.Focus_Enter then
            UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, false)
          end
        end
      },
      LessHalf_Health = {
        callbackFunction = function(tableSelf)
          if tableSelf.typeInfo.showHealthBar then
            UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, true)
          end
        end
      },
      Idle_Health_Start = {
        callbackFunction = function(tableSelf)
          local healthStates = tableSelf.states.healthStates
          local shouldHealthBarShow = (healthStates.currentState == healthStates.stateNames.Critical_Health or healthStates.currentState == healthStates.stateNames.LessHalf_Health) and tableSelf.typeInfo.showHealthBar
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, shouldHealthBarShow)
        end
      },
      Idle_Health_End = {
        callbackFunction = function(tableSelf)
          if tableSelf.typeInfo.showHealthBar then
            UiElementBus.Event.SetIsEnabled(tableSelf.Properties.HealthBar, true)
          end
        end
      },
      GuildWarPreWar = {
        callbackFunction = function(tableSelf)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Dot, not tableSelf.showWarInteractHealthIcon)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Structure.WarDot, tableSelf.showWarInteractHealthIcon)
          UiImageBus.Event.SetColor(tableSelf.Properties.Structure.WarDot, tableSelf.UIStyle.COLOR_WAR_PHASE_SCOUTING)
          UiImageBus.Event.SetColor(tableSelf.Properties.HealthBarFill, tableSelf.originalHealthBarFillColor)
        end
      },
      GuildWarOn = {
        callbackFunction = function(tableSelf)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Dot, not tableSelf.showWarInteractHealthIcon)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Structure.WarDot, tableSelf.showWarInteractHealthIcon)
          UiImageBus.Event.SetColor(tableSelf.Properties.Structure.WarDot, tableSelf.UIStyle.COLOR_WAR_PHASE_BATTLE)
          UiImageBus.Event.SetColor(tableSelf.Properties.HealthBarFill, tableSelf.UIStyle.COLOR_RED)
        end
      },
      GuildWarOff = {
        callbackFunction = function(tableSelf)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Dot, true)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.Structure.WarDot, false)
          UiImageBus.Event.SetColor(tableSelf.Properties.HealthBarFill, tableSelf.originalHealthBarFillColor)
        end
      }
    },
    SubTypes = {
      NoOffset = {wZ = 0},
      HigherDot = {wZ = 1.6},
      Camp = {
        wZ = 1.6,
        scaleStart = 4,
        scaleDistance = 15,
        fadeStart = 10,
        fadeDistance = 15
      },
      OutpostRush = {showHealthBar = false}
    }
  },
  Gatherable = {
    wX = 0,
    wY = 0,
    wZ = 1.2,
    sX = 0,
    sY = 0,
    minScale = 0.8,
    maxScale = 1,
    minAlpha = 0,
    maxAlpha = 1,
    scaleStart = 2,
    scaleDistance = 10,
    fadeDelta = 1,
    barVFXDelay = 0.3,
    useGatherableInteract = true,
    States = {
      Focus_Enter = {
        callbackFunction = function(tableSelf)
          tableSelf.tweener:Play(tableSelf.Properties.Dot, 0.25, {scaleX = 0, scaleY = 0})
        end
      },
      Focus_Exit = {
        callbackFunction = function(tableSelf)
          tableSelf.tweener:Play(tableSelf.Properties.Dot, 0.25, {scaleX = 1, scaleY = 1})
        end
      }
    },
    SubTypes = {
      LowerDot = {wZ = 0},
      MediumLowerDot = {wZ = 0.5}
    }
  },
  LoreReader = {
    wX = 0,
    wY = 0,
    wZ = 1.2,
    sX = 0,
    sY = 0,
    minScale = 0.8,
    maxScale = 1,
    minAlpha = 0,
    maxAlpha = 1,
    scaleStart = 4,
    scaleDistance = 10,
    fadeStart = 4,
    fadeDistance = 8,
    barVFXDelay = 0.3,
    States = {
      Focus_Enter = {
        callbackFunction = function(tableSelf)
          tableSelf.tweener:Play(tableSelf.Properties.Dot, 0.25, {scaleX = 0, scaleY = 0})
        end
      },
      Focus_Exit = {
        callbackFunction = function(tableSelf)
          tableSelf.tweener:Play(tableSelf.Properties.Dot, 0.25, {scaleX = 1, scaleY = 1})
        end
      }
    },
    SubTypes = {
      LowerDot = {wZ = 0},
      MediumLowerDot = {wZ = 0.2}
    }
  },
  TownCenter = {
    wX = 0,
    wY = 0,
    wZ = 0,
    sX = 0,
    sY = 0,
    minScale = 0.3,
    maxScale = 1,
    minAlpha = 1,
    maxAlpha = 1,
    scaleStart = 4,
    scaleDistance = 120,
    fadeStart = 120,
    fadeDistance = 120,
    barVFXDelay = 0.3,
    keepOnScreen = true
  },
  SiegeStructure = {
    wX = 0,
    wY = 0,
    wZ = 1.2,
    sX = 0,
    sY = 0,
    minScale = 1,
    maxScale = 1,
    minAlpha = 0,
    maxAlpha = 1,
    scaleStart = 4,
    scaleDistance = 120,
    fadeStart = 120,
    fadeDistance = 120,
    barVFXDelay = 0.3,
    keepOnScreen = false,
    allowWorldOcclusion = true,
    occlusionInterval = 0.33,
    States = {
      Screen_Enter = {
        callbackFunction = function(tableSelf)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.ScreenStates.OffScreen, false)
        end
      },
      Screen_Exit = {
        callbackFunction = function(tableSelf)
          UiElementBus.Event.SetIsEnabled(tableSelf.Properties.ScreenStates.OffScreen, true)
        end
      }
    }
  },
  SiegeWeapon = {
    wX = 0,
    wY = 0,
    wZ = 1.2,
    sX = 0,
    sY = 0,
    minScale = 0.3,
    maxScale = 1,
    minAlpha = 1,
    maxAlpha = 1,
    scaleStart = 4,
    scaleDistance = 120,
    fadeStart = 120,
    fadeDistance = 120,
    barVFXDelay = 0.3,
    keepOnScreen = false,
    allowWorldOcclusion = true,
    occlusionInterval = 0.33,
    tickInteractPositionInLua = true
  },
  Conversation = {
    wX = 0,
    wY = 0,
    wZ = 1.9,
    sX = 0,
    sY = 0,
    minScale = 0.35,
    maxScale = 1,
    minAlpha = 0,
    maxAlpha = 1,
    scaleStart = 0,
    scaleDistance = 40,
    fadeStart = 125,
    fadeDistance = 125,
    barVFXDelay = 0.3,
    interactWorldZOffset = 1.1,
    allowWorldOcclusion = false,
    States = {},
    SubTypes = {
      FTUEConversation = {wY = -0.5, wZ = 1.8}
    }
  },
  None = {
    wX = 0,
    wY = 0,
    wZ = 1.2,
    sX = 0,
    sY = 0,
    minScale = 0.7,
    maxScale = 1,
    minAlpha = 0,
    maxAlpha = 1,
    scaleStart = 7,
    scaleDistance = 10,
    fadeStart = 7,
    fadeDistance = 10,
    barVFXDelay = 0.3,
    timeToFadeHealth = 5,
    States = {}
  }
}
MarkerData.cachedTypes = {}
function MarkerData:CacheType(typeName, typeInfo)
  self.cachedTypes[typeName] = typeInfo
end
function MarkerData:GetTypeInfo(typeName)
  local typeInfo = self.cachedTypes[typeName]
  if typeInfo ~= nil then
    return typeInfo
  else
    Debug.Log("Warning, retrieved unknown marker type - " .. tostring(typeName))
    for typeName, typeInfo in pairs(self.cachedTypes) do
      Debug.Log("Using typeInfo from " .. tostring(typeName))
      return typeInfo
    end
  end
end
return MarkerData
