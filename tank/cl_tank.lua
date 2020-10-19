
local cur_model_id = replace_model_start
for i,v in ipairs(tanks) do
    LoadPak(v.pakname, "/"..v.pakname.."/", "../../../OnsetModding/Plugins/"..v.pakname.."/Content")
    ReplaceObjectModelMesh(cur_model_id, "/"..v.pakname.."/"..v.basepath)
    ReplaceObjectModelMesh(cur_model_id+1, "/"..v.pakname.."/"..v.cannonpath)
    ReplaceObjectModelMesh(cur_model_id+2, "/"..v.pakname.."/"..v.turretpath)
    cur_model_id = cur_model_id + 3
end

--local dlt = ImportPackage("debuglinetrace")

local canshoot = true

local tanktimer = nil
local objcanon = nil
local objtourelle = nil
local objbase = nil
local canonactor = nil
local tourelleactor = nil
local statcanon = nil
local stattourelle = nil

local firex = 0
local firey = 0
local firez = 0
local firetype = 0
local fireid = 0

function timer_tanks()
   for i,v in ipairs(GetStreamedVehicles()) do
      if GetVehiclePropertyValue(v, "istank") == true then
        GetVehicleActor(v):SetActorHiddenInGame(true)
      end
   end
end

function tank_timer(bool)
    if bool then
        if tanktimer ~= nil then 
           DestroyTimer(tanktimer)
        end
        tanktimer = CreateTimer(tank_control,10)
    else
        if tanktimer ~= nil then 
            DestroyTimer(tanktimer)
            objcanon = nil
            objtourelle = nil
            objbase = nil
            canonactor = nil
            tourelleactor = nil
            statcanon = nil
            stattourelle = nil
            tanktimer = nil
            firex = 0
            firey = 0
            firez = 0
            firetype = 0
            fireid = 0
         end
    end
end

AddEvent("OnPlayerLeaveVehicle", function(ply, veh, seat)
    if ply == GetPlayerId() then
        tank_timer(false)
    end
end)

function reverse_angle(angle)
    local reverse = false
    if angle<0 then
       angle = angle*-1
    else
        reverse = true
    end
    reversed = 180-angle
    if reverse then 
        reversed = reversed*-1
    end
   return reversed
end


local compteur_sync = 1

function tank_control()
   if (GetPlayerVehicle(GetPlayerId()) ~= 0 and GetVehicleHealth(GetPlayerVehicle(GetPlayerId()))>0) then
       local relcold = statcanon:GetRelativeRotation()
       local reltold = stattourelle:GetRelativeRotation()
       local rx,ry,rz = GetCameraRotation(false)
       local trx,try,trz = GetObjectRotation(objtourelle)
       local rxa = (rx/2*-1)-10
       if rxa>trx+12 then
          rxa = trx+12
       end
       if rxa<trx-12 then
          rxa = trx-12
       end
       reversedry = reverse_angle(ry)
       canonactor:SetActorRotation(FRotator(rxa, reversedry,0))
       local relcnew = statcanon:GetRelativeRotation()
       statcanon:SetRelativeRotation(FRotator(relcnew.Pitch,relcnew.Yaw,relcold.Roll))
       local plyactor = GetPlayerActor(GetPlayerId())
       local sync_crx,sync_cry,sync_crz = GetObjectRotation(objcanon)
       local reversed_sync_crz = reverse_angle(sync_crz)
       plyactor:SetActorRotation(FRotator(rxa*-1, ry,sync_crz*-1 ))
       tourelleactor:SetActorRotation(FRotator(0, reversedry,0))
       stattourelle:SetRelativeRotation(FRotator(reltold.Pitch,relcnew.Yaw,reltold.Roll))
       local x,y,z = GetVehicleLocation(GetPlayerVehicle(GetPlayerId()))
       local fx,fy,fz = GetPlayerForwardVector(GetPlayerId())
       local ux,uy,uz = GetPlayerUpVector(GetPlayerId())
       local zadded = 265
       ux = ux*zadded
       uy = uy*zadded
       uz = uz*zadded
       local mult2 = 50000
       local hittype, hitid, impactX, impactY, impactZ
       if canshoot then
        hittype, hitid, impactX, impactY, impactZ = LineTrace(x+ux, y+uy, z+uz, x+fx*mult2, y+fy*mult2, z+fz*mult2, 1)
           --hittype, hitid, impactX, impactY, impactZ = dlt.Debug_LineTrace(x+ux, y+uy, z+uz, x+fx*mult2, y+fy*mult2, z+fz*mult2, 1)
       end
       if (hittype == 3 and hitid == GetPlayerVehicle(GetPlayerId()) or not canshoot) then
        firex = 0
        firey = 0
        firez = 0
        firetype = 0
        fireid = 0
       else
        firex = impactX
        firey = impactY
        firez = impactZ
        firetype = hittype
        fireid = hitid
       end
       compteur_sync = compteur_sync+1
       if compteur_sync>=sync_interval_ms/10 then
          compteur_sync = 0
          local sync_trx,sync_try,sync_trz = GetObjectRotation(objtourelle)
          CallRemoteEvent("sync_tourelle_canon",GetPlayerVehicle(GetPlayerId()),sync_trx,sync_crx,sync_try,sync_trz)
       end
   else
       tank_timer(false)
   end
end

local needtodrive = false

AddEvent("OnPlayerEnterVehicle",function(ply,veh,seat)
    if (ply == GetPlayerId() and needtodrive) then
       needtodrive = false
       CallRemoteEvent("change_seat_to_driver")
    end
    if (ply == GetPlayerId() and seat == 1) then
       if GetVehiclePropertyValue(veh,"istank") then
        while true do
            local canon = GetVehiclePropertyValue(veh, "canonobj")
            local tourelle = GetVehiclePropertyValue(veh, "tourelleobj")
            local base = GetVehiclePropertyValue(veh, "baseobj")
            if (IsValidObject(canon) and IsValidObject(tourelle) and IsValidObject(base)) then
              objcanon = canon
              objtourelle = tourelle
              objbase = base
              canonactor = GetObjectActor(objcanon)
              tourelleactor = GetObjectActor(objtourelle)
              statcanon = GetObjectStaticMeshComponent(objcanon)
              stattourelle = GetObjectStaticMeshComponent(objtourelle)
              tank_timer(true)
              break
            end
        end
       end
    end
end)

AddEvent("OnPlayerStartEnterVehicle", function(veh, seat)
    if GetVehiclePropertyValue(veh,"istank") == true then
        if GetVehicleHealth(veh) ~= 0 then
           if seat ~= 1 then
               if not IsVehicleSeatOccupied(veh, 1) then
                  needtodrive = true
               end
            end
        else
            return false -- ....
        end
    end 
end)

AddEvent("OnPackageStart",function()
    CreateTimer(timer_tanks,500)
end)

AddEvent("OnRenderHUD",function()
    if GetPlayerVehicle(GetPlayerId())~=0 then
        if GetVehiclePropertyValue(GetPlayerVehicle(GetPlayerId()), "istank") == true then
            local ScreenX, ScreenY = GetScreenSize()
            DrawText(ScreenX/2-50, ScreenY-35, "Tank Health : " .. tostring(GetVehicleHealth(GetPlayerVehicle(GetPlayerId()))))
            if (firex ~= 0 and firey ~= 0 and firez ~= 0 and canshoot) then
                local br, ScreenX,ScreenY = WorldToScreen(firex, firey, firez)
                if br then
                   DrawBox(ScreenX-25, ScreenY-25, 50, 50)
                end
            end
        end
    end
end)

AddEvent("OnKeyPress",function(key)
    if GetPlayerVehicle(GetPlayerId())~=0 then
        if key == "Left Mouse Button" then
            if (firex ~= 0 and firey ~= 0 and firez ~= 0 and canshoot) then
               CallRemoteEvent("Create_tank_Explosion",firex,firey,firez,firetype,fireid)
               local esound = CreateSound("tank/tank_explosion.mp3")
               SetSoundVolume(esound, 0.5)
               local rsound = CreateSound("tank/tank_reload.mp3")
               SetSoundVolume(rsound, 0.5)
               canshoot = false
               Delay(reload_time_ms,function()
                   if IsValidSound(rsound) then
                     DestroySound(rsound)
                   end
                   canshoot = true
               end)
            end
        end
    end
end)

function LerpRotator(t,xa,ya,za,xb,yb,zb)
    if (ya > 90 and yb < -90) then
       local diff = ya-90
       local diff2 = 90-diff
       ya = -180-diff2
    elseif (ya < -90 and yb > 90) then
        local diff = ya+90
        local diff2 = 90+diff
        ya = 180+diff2
    end
    local rx,ry,rz = LerpVector(t, xa, ya, za, xb, yb, zb)
    if ry > 180 then
       local diff = (ry-180)*-1 
       ry = 90+diff
       ry = -90-ry
    elseif ry < -180 then
        local diff = (ry+180)*-1
        ry = 90-diff
        ry = 90+ry
    end
    return rx,ry,rz
end

AddEvent("OnVehicleNetworkUpdatePropertyValue", function(veh, propertyName, val) 
    if (GetPlayerVehicle(GetPlayerId())~=veh and GetVehiclePropertyValue(veh, "istank") and IsValidVehicle(veh)) then
        local obj
        local objactor
        if propertyName == "sync_to_cannon" then
           obj = GetVehiclePropertyValue(veh, "canonobj")
           if IsValidObject(obj) then
              objactor = GetObjectActor(obj)
           end
        elseif propertyName == "sync_to_turret" then
            obj  = GetVehiclePropertyValue(veh, "tourelleobj")
            if IsValidObject(obj) then
               objactor = GetObjectActor(obj)
            end
        end
        if (objactor) then
            local step = 1
            local frac = 1/(sync_interval_ms/10)
            CreateCountTimer(function()
                if IsValidObject(obj) then
                    local rx,ry,rz = LerpRotator(step*frac, val[4], val[5], val[6], val[1], val[2], val[3])
                    objactor:SetActorRotation(FRotator(rx,ry,rz))
                end
                step = step + 1
            end, 10, sync_interval_ms/10)
        end
    end
end)


