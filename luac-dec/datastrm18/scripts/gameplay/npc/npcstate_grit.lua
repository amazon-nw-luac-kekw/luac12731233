NPCState_GRIT = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  },
  FX_01 = "cFX_Players.States.GRIT.Energy_01",
  FX_02 = "cFX_Players.States.GRIT.Energy_02",
  FX_01b = "cFX_Players.States.GRIT.Energy_01b",
  FX_02b = "cFX_Players.States.GRIT.Energy_02b",
  FX_03 = "cFX_Players.States.GRIT.Energy_Embers",
  FX_04 = "cFX_Players.States.GRIT.Energy_Bust_01",
  FX_Wolf_01 = "cFX_GRIT.npc.Wolf_01",
  FX_Wolf_02 = "cFX_GRIT.npc.Wolf_02",
  FX_07 = "cFX_Players.States.GRIT.Grunt_01",
  FX_08 = "cFX_Players.States.GRIT.Grunt_02",
  FX_09 = "cFX_Players.States.GRIT.Grunt_03",
  FX_10 = "cFX_Players.States.GRIT.Ghost_Bust",
  FX_11 = "cFX_Players.States.GRIT.Elk_01",
  FX_12 = "cFX_Players.States.GRIT.Elk_02",
  FX_13 = "cFX_Players.States.GRIT.Elk_03",
  npc_FX_01 = "cFX_GRIT.npc.Grit_SM_1",
  npc_FX_02 = "cFX_GRIT.npc.Grit_MD_1",
  npc_FX_03 = "cFX_GRIT.npc.Grit_LG_1",
  JointPlayer_1 = "Forearm_roll_right",
  JointPlayer_2 = "Forearm_roll_left",
  JointPlayer_3 = "MidArm_right",
  JointPlayer_4 = "MidArm_left",
  JointPlayer_5 = "Neck",
  JointWolf_1 = "bind_neck_1_jnt",
  JointWolf_2 = "bind_spine_2_jnt",
  JointBoar_1 = "bind_neck_01",
  JointBoar_2 = "bind_spine_03",
  JointBoar_3 = "bind_spine_2_jnt",
  JointBear_1 = "head_jnt",
  JointGrunt_1 = "bind_head",
  JointGrunt_2 = "bind_right_front_elbow",
  JointGrunt_3 = "bind_left_front_elbow",
  JointGrunt_4 = "bind_spine_c",
  JointGhost_1 = "c_neck1_BND",
  JointGhost_2 = "l_arm2_BND",
  JointGhost_3 = "r_arm2_BND",
  JointBrute_1 = "bind_neck_a",
  JointBrute_2 = "bind_left_elbow",
  JointBrute_3 = "bind_right_elbow",
  JointBison_1 = "bind_head_01",
  JointTendril_1 = "bind_right_front_elbow",
  JointTendril_2 = "bind_left_front_elbow",
  JointInvasion_1 = "Neck",
  JointInvasion_2 = "UpperArm_right",
  JointInvasion_3 = "UpperArm_left",
  JointInvasion_4 = "Hand_right",
  JointInvasion_5 = "Hand_left",
  JointElk_1 = "neck_jnt",
  JointElk_2 = "left_radius_jnt",
  JointElk_3 = "right_radius_jnt",
  JointScorpion_1 = "bind_head",
  JointScorpion_2 = "bind_right_wrist",
  JointScorpion_3 = "bind_left_wrist",
  JointAttach_1 = "vfx_GRIT_01",
  JointAttach_2 = "vfx_GRIT_02"
}
function NPCState_GRIT:OnActivate()
  self.notificationBusHandler = GritEventBus.Connect(self, self.Properties.NPC)
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.HeadJointName = GetJointFromAlias(self.Properties.NPC, "Head")
  self.SpineJointName = GetJointFromAlias(self.Properties.NPC, "Spine")
  self.RightHandJointName = GetJointFromAlias(self.Properties.NPC, "RightHand")
  self.LeftHandJointName = GetJointFromAlias(self.Properties.NPC, "LeftHand")
end
function NPCState_GRIT:OnDeactivate()
  self.notificationBusHandler:Disconnect()
end
function NPCState_GRIT:OnGritActivated()
  MaterialOverrideBus.Event.StartOverride(self.Properties.NPC, 865585491)
  local ParticleNormal = Vector3(0, 0, 0)
  self.isPlayer = false
  if TagComponentRequests.Event.HasTag(self.Properties.NPC, 3696919595) then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, self.JointAttach_1, self.FX_Wolf_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, self.JointAttach_2, self.FX_Wolf_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 350849462) then
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointBoar_1, self.npc_FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointBoar_2, self.FX_Wolf_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointBoar_2, self.FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 2679838780) then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, self.JointAttach_1, self.npc_FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 427691104) then
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointBear_1, self.npc_FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 817361755) then
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointGrunt_1, self.FX_07, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointGrunt_4, self.FX_07, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointGrunt_1, self.FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointGrunt_2, self.FX_09, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointGrunt_3, self.FX_08, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 3788377626) then
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointGhost_1, self.FX_10, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointGhost_1, self.FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointGhost_2, self.FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointGhost_3, self.FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointGhost_2, self.FX_08, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointGhost_3, self.FX_09, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 583706114) then
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointBrute_1, self.FX_04, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointBrute_2, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointBrute_3, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 4123407320) then
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_1, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_2, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_3, self.FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_4, self.FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_3, self.FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_4, self.FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_5, self.FX_04, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 4177295065) then
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointTendril_1, self.FX_04, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointTendril_2, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 3602022132) then
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointInvasion_1, self.FX_04, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointInvasion_2, self.FX_02b, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointInvasion_3, self.FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointInvasion_4, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointInvasion_5, self.FX_01b, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 688399632) then
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointElk_1, self.FX_11, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointElk_2, self.FX_13, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointElk_3, self.FX_12, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 354626074) then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, self.JointAttach_1, self.npc_FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 1261577016) then
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointScorpion_1, self.npc_FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointScorpion_2, self.npc_FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointScorpion_3, self.npc_FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 1335572997) then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, self.SpineJointName, self.FX_04, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, self.RightHandJointName, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, self.LeftHandJointName, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  else
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_1, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_2, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_3, self.FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_4, self.FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_3, self.FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_4, self.FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, self.JointPlayer_5, self.FX_04, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  end
end
function NPCState_GRIT:OnGritDeactivated()
  MaterialOverrideBus.Event.StopOverride(self.Properties.NPC, 865585491)
  if TagComponentRequests.Event.HasTag(self.Properties.NPC, 3696919595) then
    ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, self.JointAttach_1, self.FX_Wolf_01, true)
    ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, self.JointAttach_2, self.FX_Wolf_02, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 350849462) then
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointBoar_1, self.npc_FX_02, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointBoar_2, self.FX_Wolf_02, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointBoar_2, self.FX_03, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 2679838780) then
    ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, self.JointAttach_1, self.npc_FX_03, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 427691104) then
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointBear_1, self.npc_FX_03, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 817361755) then
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointGrunt_1, self.FX_07, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointGrunt_4, self.FX_07, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointGrunt_1, self.FX_03, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointGrunt_2, self.FX_09, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointGrunt_3, self.FX_08, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 3788377626) then
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointGhost_1, self.FX_10, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointGhost_1, self.FX_03, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointGhost_2, self.FX_03, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointGhost_3, self.FX_03, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointGhost_2, self.FX_08, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointGhost_3, self.FX_09, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 583706114) then
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointBrute_1, self.FX_04, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointBrute_2, self.FX_01, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointBrute_3, self.FX_01, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 4123407320) then
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_1, self.FX_01, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_2, self.FX_01, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_3, self.FX_02, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_4, self.FX_02, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_3, self.FX_03, false)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_4, self.FX_03, false)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_5, self.FX_04, false)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 4177295065) then
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointTendril_1, self.FX_04, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointTendril_2, self.FX_01, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 3602022132) then
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointInvasion_1, self.FX_04, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointInvasion_2, self.FX_02b, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointInvasion_3, self.FX_02, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointInvasion_4, self.FX_01, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointInvasion_5, self.FX_01b, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 688399632) then
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointElk_1, self.FX_11, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointElk_2, self.FX_13, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointElk_3, self.FX_12, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 354626074) then
    ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, self.JointAttach_1, self.npc_FX_03, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 1261577016) then
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointScorpion_1, self.npc_FX_02, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointScorpion_2, self.npc_FX_03, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointScorpion_3, self.npc_FX_03, true)
  elseif TagComponentRequests.Event.HasTag(self.Properties.NPC, 1335572997) then
    ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, self.SpineJointName, self.FX_04, true)
    ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, self.RightHandJointName, self.FX_01, true)
    ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, self.LeftHandJointName, self.FX_01, true)
  else
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_1, self.FX_01, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_2, self.FX_01, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_3, self.FX_02, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_4, self.FX_02, true)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_3, self.FX_03, false)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_4, self.FX_03, false)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, self.JointPlayer_5, self.FX_04, false)
  end
end
return NPCState_GRIT
