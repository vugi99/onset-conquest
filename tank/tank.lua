
function spawntank(id,x,y,z,roty)
   local veh = CreateVehicle(13, x,y,z,roty)
   modelidbase = replace_model_start
   modelidcanon = replace_model_start+1
   modelidtourelle = replace_model_start+2
   if id > 1 then
    modelidbase = modelidbase+3*(id-1)
    modelidcanon = modelidcanon+3*(id-1)
    modelidtourelle = modelidtourelle+3*(id-1)
   end
   local obj = CreateObject(modelidbase, x, y, 0)
    SetObjectAttached(obj, ATTACH_VEHICLE, veh, 0, 0, 0,0,180,0)
    local objcanon = CreateObject(modelidcanon, x, y, 0)
    SetObjectAttached(objcanon, ATTACH_VEHICLE, veh, 0, 0, 0,0,180,0)
    local objtourelle = CreateObject(modelidtourelle, x, y, 0)
    SetObjectAttached(objtourelle, ATTACH_VEHICLE, veh, 0, 0, 0,0,180,0)
    SetVehiclePropertyValue(veh, "istank", true, true)
    SetVehiclePropertyValue(veh, "tankid", id, true)
    SetVehiclePropertyValue(veh, "canonobj", objcanon, true)
    SetVehiclePropertyValue(veh, "tourelleobj", objtourelle, true)
    SetVehiclePropertyValue(veh, "baseobj", obj, true)
    return veh,objcanon,objtourelle,obj
end

function TransformToTank(id,veh)
    local x,y,z = GetVehicleLocation(veh)
    modelidbase = replace_model_start
    modelidcanon = replace_model_start+1
    modelidtourelle = replace_model_start+2
   if id > 1 then
    modelidbase = modelidbase+3*(id-1)
    modelidcanon = modelidcanon+3*(id-1)
    modelidtourelle = modelidtourelle+3*(id-1)
   end
   local obj = CreateObject(modelidbase, x, y, 0)
    SetObjectAttached(obj, ATTACH_VEHICLE, veh, 0, 0, 0,0,180,0)
    local objcanon = CreateObject(modelidcanon, x, y, 0)
    SetObjectAttached(objcanon, ATTACH_VEHICLE, veh, 0, 0, 0,0,180,0)
    local objtourelle = CreateObject(modelidtourelle, x, y, 0)
    SetObjectAttached(objtourelle, ATTACH_VEHICLE, veh, 0, 0, 0,0,180,0)
    SetVehiclePropertyValue(veh, "istank", true, true)
    SetVehiclePropertyValue(veh, "tankid", id, true)
    SetVehiclePropertyValue(veh, "canonobj", objcanon, true)
    SetVehiclePropertyValue(veh, "tourelleobj", objtourelle, true)
    SetVehiclePropertyValue(veh, "baseobj", obj, true)
    return objcanon,objtourelle,obj
end

AddRemoteEvent("change_seat_to_driver",function(ply)
    SetPlayerInVehicle(ply, GetPlayerVehicle(ply) ,1)
end)

AddCommand("sethp_0",function(ply)
    if GetPlayerVehicle(ply)~=0 then
        SetVehicleHealth(GetPlayerVehicle(ply), 0)
    end
end)

AddRemoteEvent("Create_tank_Explosion",function(ply,x,y,z,type,id)
    if type == 3 then
       SetVehicleHealth(id,GetVehicleHealth(id)-damage_on_vehicles)
    end
    CreateExplosion(16, x, y, z)
end)

--[[AddCommand("stank",function(ply,tid)
    if GetPlayerVehicle(ply)==0 then
        tid = tonumber(tid)
        if (tid > 0 and tid <= #tanks) then
          local x,y,z = GetPlayerLocation(ply)
          local h = GetPlayerHeading(ply)
          local veh,objcanon,objtourelle,base = spawntank(tid,x,y,z,h)
          SetPlayerInVehicle(ply, veh ,1)
        else
            AddPlayerChat(ply,"/stank (id 1-"..tostring(#tanks)..")")
        end
    end
end)]]--

AddRemoteEvent("sync_tourelle_canon",function(ply,veh,trx,crx,try,trz)
    local oldtrx,oldtry,oldtrz
    local oldcrx,oldcry,oldcrz
    if (not GetVehiclePropertyValue(veh,"sync_to_turret") and not GetVehiclePropertyValue(veh,"sync_to_cannon")) then
        local tourelle  = GetVehiclePropertyValue(veh, "tourelleobj")
        oldtrx,oldtry,oldtrz = GetObjectRotation(tourelle)
        oldcrx,oldcry,oldcrz = GetObjectRotation(tourelle)
    else
        local oldturret_vector = GetVehiclePropertyValue(veh,"sync_to_turret")
        local oldcannon_vector = GetVehiclePropertyValue(veh,"sync_to_cannon")
        oldtrx,oldtry,oldtrz = oldturret_vector[1],oldturret_vector[2],oldturret_vector[3]
        oldcrx,oldcry,oldcrz = oldcannon_vector[1],oldcannon_vector[2],oldcannon_vector[3]
    end
    SetVehiclePropertyValue(veh,"sync_to_turret",{trx,try,trz,oldtrx,oldtry,oldtrz},true)
    SetVehiclePropertyValue(veh,"sync_to_cannon",{crx,try,trz,oldcrx,oldcry,oldcrz},true)
end)

function check_tanks_life()
   for i,v in ipairs(GetAllVehicles()) do
      if GetVehiclePropertyValue(v, "istank") == true then
         if (GetVehicleHealth(v) == 0 and GetVehiclePropertyValue(v, "istankdead")==nil) then
            SetVehiclePropertyValue(v,"istankdead",true,false)
            local x,y,z = GetVehicleLocation(v)
            CreateExplosion(13, x, y, z)
            for ip,vp in ipairs(GetAllPlayers()) do
                if GetPlayerVehicle(vp) == v then
                   SetPlayerHealth(vp,0)
                end
            end
         end
      end
   end
end

AddEvent("OnVehicleRespawn", function(veh)
    local rx,ry,rz = GetVehicleRotation(veh)
    SetVehicleRotation(veh, 0, ry, 0)
    if GetVehiclePropertyValue(veh, "istank") == true then
       local canon = GetVehiclePropertyValue(veh, "canonobj")
       local tourelle  = GetVehiclePropertyValue(veh, "tourelleobj")
       local base = GetVehiclePropertyValue(veh, "baseobj")
       local tankid = GetVehiclePropertyValue(veh, "tankid")
       DestroyObject(canon)
       DestroyObject(tourelle)
       DestroyObject(base)
       TransformToTank(tankid,veh)
    end
end)

AddEvent("OnPackageStart",function()
    CreateTimer(check_tanks_life,1000)
end)





