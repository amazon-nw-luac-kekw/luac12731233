local EntityRegistrar = {}
function EntityRegistrar:RegisterEntity(t)
  if t and type(t) == "table" and t.entityId and type(t.entityId) == "userdata" and type(t.entityId.IsValid) == "function" and t.entityId:IsValid() then
    g_entityTables[tostring(t.entityId)] = t
  else
    Debug.Log("Invalid table passed to EntityRegistrar")
  end
end
function EntityRegistrar:UnregisterEntity(t)
  if t and type(t) == "table" and t.entityId and type(t.entityId) == "userdata" and type(t.entityId.IsValid) == "function" and t.entityId:IsValid() then
    g_entityTables[tostring(t.entityId)] = nil
  end
end
function EntityRegistrar:GetEntityTable(entity, tableName)
  return g_entityTables[tostring(entity)]
end
return EntityRegistrar
