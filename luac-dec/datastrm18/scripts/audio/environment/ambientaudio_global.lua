local AmbientAudioScript = {
  Properties = {},
  AudioManagerId = EntityId(),
  AmbientControl = {
    CurveSpreadRatio = 0.5,
    RTPC = {
      SpeakerX = "SpeakerX_FL",
      SpeakerY = "SpeakerY_FL"
    }
  },
  AmbientData = {
    {
      AmbientType = "Cattail",
      Activate = true,
      Range = {From = 0, To = 10},
      Triggers = {
        Play = "Play_AMB_EXT_4D_Cattail",
        Stop = "Stop_AMB_EXT_4D_Cattail"
      },
      RTPCs = {
        FL = "Weight_Cattail_FL",
        FR = "Weight_Cattail_FR",
        BR = "Weight_Cattail_BR",
        BL = "Weight_Cattail_BL"
      }
    },
    {
      AmbientType = "Bush",
      Activate = true,
      Range = {From = 0, To = 10},
      Triggers = {
        Play = "Play_AMB_EXT_4D_Bush",
        Stop = "Stop_AMB_EXT_4D_Bush"
      },
      RTPCs = {
        FL = "Weight_Bush_FL",
        FR = "Weight_Bush_FR",
        BR = "Weight_Bush_BR",
        BL = "Weight_Bush_BL"
      }
    },
    {
      AmbientType = "BeechTree",
      Activate = true,
      Range = {From = 0, To = 60},
      Triggers = {
        Play = "Play_AMB_EXT_4D_BeechTree",
        Stop = "Stop_AMB_EXT_4D_BeechTree"
      },
      RTPCs = {
        FL = "Weight_BeechTree_FL",
        FR = "Weight_BeechTree_FR",
        BR = "Weight_BeechTree_BR",
        BL = "Weight_BeechTree_BL"
      }
    },
    {
      AmbientType = "PoplarTree",
      Activate = true,
      Range = {From = 3, To = 60},
      Triggers = {
        Play = "Play_AMB_EXT_4D_PoplarTree",
        Stop = "Stop_AMB_EXT_4D_PoplarTree"
      },
      RTPCs = {
        FL = "Weight_PoplarTree_FL",
        FR = "Weight_PoplarTree_FR",
        BR = "Weight_PoplarTree_BR",
        BL = "Weight_PoplarTree_BL"
      }
    },
    {
      AmbientType = "OakTree",
      Activate = true,
      Range = {From = 0, To = 50},
      Triggers = {
        Play = "Play_AMB_EXT_4D_OakTree",
        Stop = "Stop_AMB_EXT_4D_OakTree"
      },
      RTPCs = {
        FL = "Weight_OakTree_FL",
        FR = "Weight_OakTree_FR",
        BR = "Weight_OakTree_BR",
        BL = "Weight_OakTree_BL"
      }
    },
    {
      AmbientType = "DeadTree",
      Activate = true,
      Range = {From = 0, To = 60},
      Triggers = {
        Play = "Play_AMB_EXT_4D_DeadTree",
        Stop = "Stop_AMB_EXT_4D_DeadTree"
      },
      RTPCs = {
        FL = "Weight_DeadTree_FL",
        FR = "Weight_DeadTree_FR",
        BR = "Weight_DeadTree_BR",
        BL = "Weight_DeadTree_BL"
      }
    },
    {
      AmbientType = "PineTree",
      Activate = true,
      Range = {From = 0, To = 60},
      Triggers = {
        Play = "Play_AMB_EXT_4D_PineTree",
        Stop = "Stop_AMB_EXT_4D_PineTree"
      },
      RTPCs = {
        FL = "Weight_PineTree_FL",
        FR = "Weight_PineTree_FR",
        BR = "Weight_PineTree_BR",
        BL = "Weight_PineTree_BL"
      }
    },
    {
      AmbientType = "BananaTree",
      Activate = true,
      Range = {From = 0, To = 10},
      Triggers = {
        Play = "Play_AMB_EXT_4D_BananaTree",
        Stop = "Stop_AMB_EXT_4D_BananaTree"
      },
      RTPCs = {
        FL = "Weight_BananaTree_FL",
        FR = "Weight_BananaTree_FR",
        BR = "Weight_BananaTree_BR",
        BL = "Weight_BananaTree_BL"
      }
    },
    {
      AmbientType = "BaldCypressTree",
      Activate = true,
      Range = {From = 0, To = 60},
      Triggers = {
        Play = "Play_AMB_EXT_4D_BaldCypressTree",
        Stop = "Stop_AMB_EXT_4D_BaldCypressTree"
      },
      RTPCs = {
        FL = "Weight_BaldCypressTree_FL",
        FR = "Weight_BaldCypressTree_FR",
        BR = "Weight_BaldCypressTree_BR",
        BL = "Weight_BaldCypressTree_BL"
      }
    },
    {
      AmbientType = "KapokTree",
      Activate = true,
      Range = {From = 0, To = 60},
      Triggers = {
        Play = "Play_AMB_EXT_4D_KapokTree",
        Stop = "Stop_AMB_EXT_4D_KapokTree"
      },
      RTPCs = {
        FL = "Weight_KapokTree_FL",
        FR = "Weight_KapokTree_FR",
        BR = "Weight_KapokTree_BR",
        BL = "Weight_KapokTree_BL"
      }
    },
    {
      AmbientType = "MysticTree",
      Activate = true,
      Range = {From = 0, To = 60},
      Triggers = {
        Play = "Play_AMB_EXT_4D_MysticTree",
        Stop = "Stop_AMB_EXT_4D_MysticTree"
      },
      RTPCs = {
        FL = "Weight_MysticTree_FL",
        FR = "Weight_MysticTree_FR",
        BR = "Weight_MysticTree_BR",
        BL = "Weight_MysticTree_BL"
      }
    },
    {
      AmbientType = "CorruptionClicky",
      Activate = true,
      Range = {From = 0, To = 30},
      Triggers = {
        Play = "Play_AMB_Corruption_Clicky",
        Stop = "Stop_AMB_Corruption_Clicky"
      },
      RTPCs = {
        FL = "Weight_CorruptionClicky_FL",
        FR = "Weight_CorruptionClicky_FR",
        BR = "Weight_CorruptionClicky_BR",
        BL = "Weight_CorruptionClicky_BL"
      }
    },
    {
      AmbientType = "CorruptionSquishy",
      Activate = true,
      Range = {From = 0, To = 30},
      Triggers = {
        Play = "Play_AMB_Corruption_Squishy",
        Stop = "Stop_AMB_Corruption_Squishy"
      },
      RTPCs = {
        FL = "Weight_CorruptionSquishy_FL",
        FR = "Weight_CorruptionSquishy_FR",
        BR = "Weight_CorruptionSquishy_BR",
        BL = "Weight_CorruptionSquishy_BL"
      }
    }
  }
}
function AmbientAudioScript:OnActivate()
  self.AudioManagerId = AmbientAudioSystemBus.Broadcast.GetEntityAmbientAudioManagerId()
  if self.AudioManagerId == nil then
    Debug.Error("Cannot find Ambient Audio System Id")
    return
  end
  Debug.Log("Initializing ambient audio")
  for i, data in ipairs(self.AmbientData) do
    Debug.Log("Initializing " .. data.AmbientType)
    self:SetAmbientSource(data)
  end
  Debug.Log("Initialize audio control")
  AmbientAudioManagerBus.Broadcast.SetCurveSpreadRatio(self.AmbientControl.CurveSpreadRatio)
  AmbientAudioSystemBus.Broadcast.SetSpeakerXYRtpcNames(self.AmbientControl.RTPC.SpeakerX, self.AmbientControl.RTPC.SpeakerY)
end
function AmbientAudioScript:GetAmbientWeight(ambientType)
  local array4 = array_float_4()
  AmbientAudioManagerBus.Event.GetAmbientWeightForType(self.AudioManagerId, ambientType, array4)
  local output = {
    array4[1],
    array4[2],
    array4[3],
    array4[4]
  }
  return output
end
function AmbientAudioScript:SetAmbientSource(data)
  Debug.Log("SetAmbientSource")
  if self.AudioManagerId == nil then
    Debug.Error("Cannot find Ambient Audio System Id")
    return
  end
  if data.Activate then
    local container = array_basic_string_char_char_traits_char__4()
    AmbientAudioManagerBus.Event.AddAmbientData(self.AudioManagerId, eAmbientDataType_EntitySource, data.AmbientType, data.Triggers.Play, data.Triggers.Stop, container)
    AmbientAudioManagerBus.Event.SetRangeInfoForType(self.AudioManagerId, data.AmbientType, data.Range.From, data.Range.To)
  else
    AmbientAudioManagerBus.Event.RemoveAmbientData(self.AudioManagerId, data.AmbientType)
  end
  if data.Triggers.Play ~= "" then
    AmbientAudioManagerBus.Event.UpdateTriggerNameForType(self.AudioManagerId, data.AmbientType, data.Triggers.Play, true)
  end
  if data.Triggers.Stop ~= "" then
    AmbientAudioManagerBus.Event.UpdateTriggerNameForType(self.AudioManagerId, data.AmbientType, data.Triggers.Stop, false)
  end
  if data.RTPCs.FL ~= "" then
    AmbientAudioManagerBus.Event.UpdateRtpcNameForType(self.AudioManagerId, data.AmbientType, 0, data.RTPCs.FL)
  end
  if data.RTPCs.FR ~= "" then
    AmbientAudioManagerBus.Event.UpdateRtpcNameForType(self.AudioManagerId, data.AmbientType, 1, data.RTPCs.FR)
  end
  if data.RTPCs.BR ~= "" then
    AmbientAudioManagerBus.Event.UpdateRtpcNameForType(self.AudioManagerId, data.AmbientType, 2, data.RTPCs.BR)
  end
  if data.RTPCs.BL ~= "" then
    AmbientAudioManagerBus.Event.UpdateRtpcNameForType(self.AudioManagerId, data.AmbientType, 3, data.RTPCs.BL)
  end
end
return AmbientAudioScript
