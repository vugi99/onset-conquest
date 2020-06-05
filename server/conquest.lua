
local curmap = 0

local started = false

teams = {}
teams[1] = {}
teams[2] = {}

local team1points = startpoints+startpoints_added_per_player
local team2points = startpoints+startpoints_added_per_player

local vehiclesobjects = {}
local flags = {}
local capturingplayers = {}
local invincible_players = {}

function changemap(new_start)
   if not new_start then
      local nbwon = 0
      if team1points > team2points then
         nbwon = 1
      elseif team2points > team1points then
         nbwon = 2
      end
      for i,v in ipairs(GetAllPlayers()) do
         CallRemoteEvent(v,"conquest_win",nbwon)
      end
   end
   if curmap == #maps then
      curmap = 1
   else
      curmap = curmap + 1
   end
   team1points = startpoints+GetPlayerCount()*startpoints_added_per_player
   team2points = startpoints+GetPlayerCount()*startpoints_added_per_player
   flags = {}
   for i,v in ipairs(maps[curmap]) do 
      if i > 2 then
         local flagtable = {}
         flagtable["captured"] = 0
         flagtable["percentage"] = 0
         table.insert(flags,flagtable)
      end
   end
   for i,v in ipairs(GetAllVehicles()) do
      DestroyVehicle(v)
   end
   vehiclesobjects = {}
   if vehiclesspawns[curmap] then
       for i,v in ipairs(vehiclesspawns[curmap]) do
         local veh
         if v[1] > 0 then
            veh = CreateVehicle(v[1], v[2], v[3], v[4] , v[5])
         else
            veh = spawntank(v[1]*-1, v[2], v[3], v[4] , v[5])
         end
         SetVehicleRespawnParams(veh, true , veh_respawn_time_ms, true)
         table.insert(vehiclesobjects,veh)
       end
   end
   local teamselected = 1
   teams[1] = {}
   teams[2] = {}
   for i,v in ipairs(GetAllPlayers()) do
      SetPlayerSpawnLocation(v, maps[curmap][teamselected][1], maps[curmap][teamselected][2], maps[curmap][teamselected][3], maps[curmap][teamselected][4])
      table.insert(teams[teamselected],v)
      CallRemoteEvent(v,"Map_loaded",maps[curmap],teamselected,team1points,team2points,flags,#teams[1],#teams[2],distance2d_flag_capture)
      if teamselected == 2 then
         SetPlayerNetworkedClothingPreset(v,clothes_team2)
         teamselected = 1
      else
         SetPlayerNetworkedClothingPreset(v,clothes_team1)
         teamselected = 2
      end
      SetPlayerHealth(v, 0)
   end
   started = true
end

function jointeam(ply)
   local teamselected = 0
   if #teams[1] <= #teams[2] then
      teamselected = 1
      SetPlayerNetworkedClothingPreset(ply,clothes_team1)
   else
      teamselected = 2
      SetPlayerNetworkedClothingPreset(ply,clothes_team2)
   end
   SetPlayerSpawnLocation(ply, maps[curmap][teamselected][1], maps[curmap][teamselected][2], maps[curmap][teamselected][3], maps[curmap][teamselected][4])
   table.insert(teams[teamselected],ply)
   CallRemoteEvent(ply,"Map_loaded",maps[curmap],teamselected,team1points,team2points,flags,#teams[1],#teams[2],distance2d_flag_capture)
   for k,v in ipairs(GetAllPlayers()) do
      if ply ~= v then
         CallRemoteEvent(v,"Update_nb_players",#teams[1],#teams[2])
      end
   end
end

AddEvent("OnPlayerJoin", function(ply)
   SetPlayerRespawnTime(ply, 250)
    if not started then
       changemap(true)
    else
       jointeam(ply)
    end
end)

AddEvent("OnPlayerQuit",function(ply)
    for i,v in ipairs(teams[1]) do
       if v == ply then
          table.remove(teams[1],i)
       end
    end
    for i,v in ipairs(teams[2]) do
      if v == ply then
         table.remove(teams[2],i)
      end
   end
   for i,v in ipairs(capturingplayers) do
      if v.ply == ply then
         table.remove(capturingplayers,i)
      end
   end
   for i,v in ipairs(invincible_players) do
      if v.ply == ply then
         table.remove(invincible_players,i)
      end
   end
   for k,v in ipairs(GetAllPlayers()) do
      if ply ~= v then
         CallRemoteEvent(v,"Update_nb_players",#teams[1],#teams[2])
      end
   end
   if (#teams[1] == 0 and #teams[2] == 0) then
      started = false
   end
end)

function give_weapons(ply)
   SetPlayerWeapon(ply, weapon_id, 400, true, 1 ,true)
   SetPlayerWeapon(ply, weapon_id2, 50, false, 2 ,true)
end
AddRemoteEvent("givemeweapons",give_weapons)

if dev then
   AddCommand("killme",function(ply)
       SetPlayerHealth(ply,0)
   end)
   AddCommand("changemap",function(ply)
       changemap()
   end)
   AddCommand("changeteam",function(ply,cteam)
      for i,v in ipairs(teams[1]) do
         if v == ply then
            table.remove(teams[1],i)
         end
      end
      for i,v in ipairs(teams[2]) do
        if v == ply then
           table.remove(teams[2],i)
        end
     end
     cteam = tonumber(cteam)
       if cteam then
         SetPlayerSpawnLocation(ply, maps[curmap][cteam][1], maps[curmap][cteam][2], maps[curmap][cteam][3], maps[curmap][cteam][4])
         table.insert(teams[cteam],ply)
         CallRemoteEvent(ply,"Map_loaded",maps[curmap],cteam,team1points,team2points,flags,#teams[1],#teams[2],distance2d_flag_capture)
         SetPlayerHealth(ply, 0)
       end
   end)
end

function getplyteam(ply)
   local plyteam = 0
         for i2,v2 in ipairs(teams[1]) do
            if v2==ply then
               plyteam = 1
            end
         end
         for i2,v2 in ipairs(teams[2]) do
            if v2==ply then
               plyteam = 2
            end
         end
   return plyteam
end

function clamp(val,minval,maxval,valadded)
   if val+valadded <= maxval then
      if val+valadded >= minval then
         val = val+valadded
      else
         val = minval
      end
   else
      val = maxval
   end
   return val
end

local compteur = 0

function timer_flags()
   for ifl,vfl in ipairs(flags) do
      --print(ifl.." "..vfl["percentage"])
      for i,v in ipairs(GetAllPlayers()) do
         local plyteam = getplyteam(v)
         if plyteam ~= 0 then
            local x,y,z = GetPlayerLocation(v)
            local xf = maps[curmap][ifl+2][1]
            local yf = maps[curmap][ifl+2][2]
            local dist2d = GetDistance2D(x, y, xf, yf)
            if dist2d<distance2d_flag_capture then
               if GetPlayerHealth(v) > 0 then
               local capturing = false
               for ic,vc in ipairs(capturingplayers) do
                  if vc.ply == v then
                     capturing = true
                  end
               end
               if not capturing then
                  local tbl = {}
                  tbl.ply = v
                  tbl.capturing = ifl
                  table.insert(capturingplayers,tbl)
               end
            else
               for ic,vc in ipairs(capturingplayers) do
                  if vc.ply == v then
                     table.remove(capturingplayers,ic)
                  end
               end
            end
            else
               for ic,vc in ipairs(capturingplayers) do
                  if (vc.ply == v and vc.capturing == ifl) then
                     table.remove(capturingplayers,ic)
                  end
               end
            end
         end
      end
   end
   local alreadychecked = {}
   for i,v in ipairs(capturingplayers) do
      local wasalreadychecked = false
      for i2,v2 in ipairs(alreadychecked) do
         if v2 == v.ply then
            wasalreadychecked = true
         end
      end
      if not wasalreadychecked then
      ifl = v.capturing
      vfl = flags[v.capturing]
      local plyteam = getplyteam(v.ply)
      if vfl.percentage ~= 100 then
      if vfl.captured ~= plyteam then
         if vfl.captured == 0 then
            local numbt1 = 0
            local numbt2 = 0
            for i,v in ipairs(capturingplayers) do
               if v.capturing == ifl then
                  local plyteam = getplyteam(v.ply)
                  if plyteam == 1 then
                      numbt1=numbt1+1
                      table.insert(alreadychecked,v.ply)
                  elseif plyteam == 2 then
                     numbt2=numbt2+1
                     table.insert(alreadychecked,v.ply)
                  end
               end
            end
            if numbt1 > numbt2 then
               vfl.captured = 1
               vfl.percentage = vfl.percentage+numbt1-numbt2
            elseif numbt2 > numbt1 then
               vfl.captured = 2
               vfl.percentage = vfl.percentage+numbt2-numbt1
            end
         else
            vfl.percentage = vfl.percentage-1
         end
      else
         vfl.percentage = vfl.percentage+1
      end
   elseif vfl.captured ~= plyteam then
      vfl.percentage = vfl.percentage-1
      end
   end
   for ifl,vfl in ipairs(flags) do
      vfl.percentage = clamp(vfl.percentage,0,100,0)
   if vfl.percentage == 0 then
      vfl.captured = 0
   end
   end
   end
   if (team1points <= 0 or team2points <= 0) then
     changemap()
   else
       if compteur==10 then
         compteur = 0
         for ifl,vfl in ipairs(flags) do
            if vfl.percentage == 100 then
               if vfl.captured == 1 then
                 team2points = team2points-1
               elseif vfl.captured == 2 then
                  team1points = team1points-1
               end
            end
         end
         for i,v in ipairs(GetAllPlayers()) do
            local plyteam = getplyteam(v)
            if plyteam ~= 0 then
               CallRemoteEvent(v,"Update_ui",team1points,team2points,flags)
            end
         end
       else
         compteur = compteur + 1
       end
   end
   for i,v in ipairs(GetAllPlayers()) do
      local x,y,z = GetPlayerLocation(v)
      if z<=0 then
         SetPlayerHealth(v,0)
      end
   end
   for i,v in ipairs(GetAllPlayers()) do
      local x,y,z = GetPlayerLocation(v)
      if z>max_z then
         if GetPlayerVehicle(v) ~= 0 then
            local x,y,z = GetVehicleLocation(GetPlayerVehicle(v))
            SetVehicleLocation(GetPlayerVehicle(v),x,y,max_z-250)
            SetVehicleLinearVelocity(GetPlayerVehicle(v), 0, 0, 0, true)
         else
            SetPlayerLocation(v,x,y,max_z-250)
         end
      end
   end
end

AddEvent("OnPackageStart",function()
    CreateTimer(timer_flags,100)
end)

AddEvent("OnPlayerDeath",function(ply,insti)
    plyteam = getplyteam(ply)
    if plyteam ~= 0 then
        if plyteam == 1 then
          team1points = team1points-1
        elseif plyteam == 2 then
            team2points = team2points-1
        end
    end
end)

AddEvent("OnPlayerWeaponShot", function(ply, weapon, hittype, hitid)
    if hittype == 2 then
      local plyteam = getplyteam(ply)
      local hitplyteam = getplyteam(hitid)
      if plyteam == hitplyteam then
         AddPlayerChat(ply,"Don't shoot at your team")
         return false
      elseif GetPlayerPropertyValue(hitid, "conquest_invincible") then
         AddPlayerChat(ply,"Don't spawnkill")
         return false
      end
    end
end)

AddEvent("OnVehicleRespawn", function(veh)
    local rx,ry,rz = GetVehicleRotation(veh)
    SetVehicleRotation(veh,0,ry,0)
end)

AddEvent("OnPlayerLeaveVehicle",function(ply, veh, seat)
    if (GetVehicleModel(veh) == 10 or GetVehicleModel(veh) == 20 or GetVehicleModel(veh) == 26) then
      AttachPlayerParachute(ply, true)
    end
end)

AddEvent("OnPlayerEnterVehicle",function(ply, veh, seat)
   if (GetVehiclePropertyValue(veh, "istank") == true and seat ~= 1) then
    local plyteam = getplyteam(ply)
    for i,v in ipairs(GetAllPlayers()) do
       if GetPlayerVehicle(v) == veh then
          if GetPlayerVehicleSeat(v) == 1 then
              local driverteam = getplyteam(v)
              if driverteam ~= plyteam then
                  RemovePlayerFromVehicle(ply)
              end
           end
       end
    end
   end
end)

AddEvent("OnPlayerSpawn",function(ply)
   local isintable = false
   local index = nil
   for i,v in ipairs(invincible_players) do
      if v.ply == ply then
         isintable = true
         index = i
      end
   end
   if not isintable then
      local tbl = {}
      tbl.ply = ply
      tbl.numb = 0
      table.insert(invincible_players,tbl)
      index = #invincible_players
   end
   SetPlayerPropertyValue(ply, "conquest_invincible", true,false)
   AddPlayerChat(ply,"You are invincible for " .. tostring(15000/1000) .. " seconds")
   invincible_players[index].numb = invincible_players[index].numb + 1
   local curnumber = invincible_players[index].numb
   Delay(invincible_time_respawn_ms,function()
      if invincible_players[index] then
         if curnumber == invincible_players[index].numb then
            SetPlayerPropertyValue(ply, "conquest_invincible", nil,false)
            AddPlayerChat(ply,"You are no longer invincible")
         end
      end
   end)
end)

AddEvent("OnPlayerDeath",function(ply,killer)
    for i,v in ipairs(GetAllPlayers()) do
       CallRemoteEvent(v,"OnPlayerDeathConquest",ply,killer,GetPlayerName(ply),GetPlayerName(killer))
    end
end)
