

LoadPak("flag_zone", "/flag_zone/", "../../../OnsetModding/Plugins/flag_zone/Content")
LoadPak("flag", "/flag/", "../../../OnsetModding/Plugins/flag/Content")
local myteam = nil
local map = nil
local waypoints = {}
local flagmodels = {}
local top_flags_models = {}
local kills_textboxs = {}
local teambox = nil
local team1pointsbox = nil
local team2pointsbox = nil
local team1plynbbox = nil
local team2plynbbox = nil

local pointsboxs = nil

local function table_last_count(tbl)
    local nb = 0
    for i, v in ipairs(tbl) do
       nb = nb + 1
    end
    return nb
 end

function create_zone_flag(v, size_zone)
    zonemodel = GetWorld():SpawnActor(AStaticMeshActor.Class(), FVector(v[1], v[2], v[3]), FRotator(0, 0, 0))
    zonemodel:GetStaticMeshComponent():SetMobility(EComponentMobility.Movable)
    zonemodel:GetStaticMeshComponent():SetStaticMesh(UStaticMesh.LoadFromAsset("/flag_zone/zone"))
    zonemodel:SetActorScale3D(FVector(size_zone/1350, size_zone/1350, 15))
    zonemodel:GetStaticMeshComponent():SetMobility(EComponentMobility.Static)
    zonemodel:GetStaticMeshComponent():SetCollisionEnabled(ECollisionEnabled.NoCollision)
    zonemodel2 = GetWorld():SpawnActor(AStaticMeshActor.Class(), FVector(v[1], v[2], v[3]), FRotator(0, 0, 0))
    zonemodel2:GetStaticMeshComponent():SetMobility(EComponentMobility.Movable)
    zonemodel2:GetStaticMeshComponent():SetStaticMesh(UStaticMesh.LoadFromAsset("/flag_zone/zone2"))
    zonemodel2:SetActorScale3D(FVector(size_zone/1350, size_zone/1350, 15))
    zonemodel2:GetStaticMeshComponent():SetMobility(EComponentMobility.Static)
    zonemodel2:GetStaticMeshComponent():SetCollisionEnabled(ECollisionEnabled.NoCollision)
    table.insert(flagmodels,zonemodel)
    table.insert(flagmodels,zonemodel2)
end

function create_flag_part(v,model_path,sizex,sizey,sizez)
    flag_part = GetWorld():SpawnActor(AStaticMeshActor.Class(), FVector(v[1], v[2], v[3]-100), FRotator(0, 0, 0))
    flag_part:GetStaticMeshComponent():SetMobility(EComponentMobility.Movable)
    flag_part:GetStaticMeshComponent():SetStaticMesh(UStaticMesh.LoadFromAsset(model_path))
    flag_part:SetActorScale3D(FVector(sizex, sizey, sizez))
    flag_part:GetStaticMeshComponent():SetMobility(EComponentMobility.Static)
    return flag_part
end

AddRemoteEvent("Map_loaded",function(maptbl, team, points1, points2, flagtbl)
    myteam = team
    map = maptbl
    for i,v in ipairs (waypoints) do
        DestroyWaypoint(v)
    end
    for i,v in ipairs(flagmodels) do
        v:Destroy()
    end
    for i,v in ipairs(top_flags_models) do
        v.obj:Destroy()
    end
    flagmodels = {}
    top_flags_models = {}
    waypoints = {}
    local needtocreate = false
    if pointsboxs == nil then
        pointsboxs = {}
        needtocreate = true
    end
    for i,v in ipairs(map) do 
        if i > 2 then
            table.insert(waypoints,CreateWaypoint(v[1], v[2], v[3], tostring(i-2)))
            create_zone_flag(v, distance2d_flag_capture)
            table.insert(flagmodels,create_flag_part(v,"/flag/sandbag",0.25,0.25,0.25))
            table.insert(flagmodels,create_flag_part(v,"/flag/drapeau_base",0.5,0.5,1))
            local tbl_square = {}
            tbl_square.obj = create_flag_part(v,"/flag/drapeau_carre_blanc",1,1,1)
            tbl_square.pos = {v[1],v[2],v[3]}
            tbl_square.id = 0
            table.insert(top_flags_models,tbl_square)
            local ScreenX, ScreenY = GetScreenSize()
            local txt = " : neutral"
                if flagtbl then
                   if flagtbl[i-2]["captured"] == 0 then
                      txt = " : neutral"
                   elseif flagtbl[i-2]["captured"] ~= myteam then
                      txt = " : enemy"
                   else
                      txt = " : allied"
                   end
                end
            if needtocreate then
                local textbox = CreateTextBox(ScreenX/2-375+(150*(i-2)), 15, "flag " .. tostring(i-2) .. txt, "left")
                SetTextBoxAnchors(textbox, 0, 0, 0, 0)
               table.insert(pointsboxs,textbox)
            else
                SetTextBoxText(pointsboxs[i-2], "flag " .. tostring(i-2) .. txt)
            end
        end
     end
     if teambox == nil then
         teambox = CreateTextBox(5, 400, "Team " .. myteam, "left")
         SetTextBoxAnchors(teambox, 0, 0, 0, 0)
     else
        SetTextBoxText(teambox, "Team " .. myteam)
     end
     local ScreenX, ScreenY = GetScreenSize()
     if team1pointsbox == nil then
        team1pointsbox = CreateTextBox(ScreenX/2-200, 40, "Team 1 points : " .. points1, "left")
        team2pointsbox = CreateTextBox(ScreenX/2+300, 40, "Team 2 points : " .. points2, "left")
     else
        SetTextBoxText(team1pointsbox, "Team 1 points : " .. points1)
        SetTextBoxText(team2pointsbox, "Team 2 points : " .. points2)
     end
end)

function check_weaps_timer()
   if GetPlayerWeapon(1) == 1 then
      CallRemoteEvent("givemeweapons")
   end
end

AddEvent("OnPackageStart",function()
    local ScreenX, ScreenY = GetScreenSize()
    team1plynbbox = CreateTextBox(ScreenX/2-200, 60, "Team 1 players : " .. "...", "left")
    team2plynbbox = CreateTextBox(ScreenX/2+300, 60, "Team 2 players : " .. "...", "left")
    CreateTimer(check_weaps_timer,1000)
end)

AddRemoteEvent("Update_ui",function(t1points,t2points,flagtbl)
    if team1pointsbox then
        SetTextBoxText(team1pointsbox, "Team 1 points : " .. t1points)
        SetTextBoxText(team2pointsbox, "Team 2 points : " .. t2points)
        for i,v in ipairs(flagtbl) do 
            local txt = ""
            if v["captured"] == 0 then
                txt = " : neutral"
                if top_flags_models[i].id ~= 0 then
                    top_flags_models[i].id = 0
                    top_flags_models[i].obj:Destroy()
                    top_flags_models[i].obj = create_flag_part(top_flags_models[i].pos,"/flag/drapeau_carre_blanc",1,1,1)
                end
            elseif v["captured"] ~= myteam then
                txt = " : enemy"
                if top_flags_models[i].id ~= 2 then
                    top_flags_models[i].id = 2
                    top_flags_models[i].obj:Destroy()
                    top_flags_models[i].obj = create_flag_part(top_flags_models[i].pos,"/flag/drapeau_carre_rouge",1,1,1)
                end
            else
                txt = " : allied"
                if top_flags_models[i].id ~= 1 then
                    top_flags_models[i].id = 1
                    top_flags_models[i].obj:Destroy()
                    top_flags_models[i].obj = create_flag_part(top_flags_models[i].pos,"/flag/drapeau_carre_bleu",1,1,1)
                end
            end
            local txtperc = tostring(v["percentage"]) .. "%"
            if v["percentage"]==0 then
                txtperc = ""
            end
            SetTextBoxText(pointsboxs[i], "flag " .. tostring(i) .. txt .. " " .. txtperc)
        end
    else
        AddPlayerChat("Please rejoin")
    end
end)

CreateTextBox(5, 450, "Version " .. version, "left")

AddRemoteEvent("Update_nb_players",function(t1nb, t2nb)
    SetTextBoxText(team1plynbbox, "Team 1 players : " .. t1nb)
    SetTextBoxText(team2plynbbox, "Team 2 players : " .. t2nb)
end)

AddEvent("OnRenderHUD",function()
    DrawText(5, 500, "Ping : " .. tostring(GetPing()))
end)

AddRemoteEvent("conquest_win",function(nb)
    local text = "Team " .. nb .. " won !"
    if nb == 0 then
       text = "No team won..."
    end
    local ScreenX,ScreenY = GetScreenSize()
    local winbox = CreateTextBox(ScreenX/2, ScreenY/2-ScreenY/4, text)
    Delay(time_win_label_ms,function()
        DestroyTextBox(winbox)
    end)
end)

local counter = 0
AddRemoteEvent("OnPlayerDeathConquest", function(ply, killer, plyname, killername)
    local killtext = nil
    if (not ply and not killer) then
       killtext = "ERROR"
    elseif (ply == killer) then
        killtext = plyname .. " died"
    else
        killtext = killername .. " killed " .. plyname
    end
    if killtext then
         local ScreenX, ScreenY = GetScreenSize()
         local textbox = CreateTextBox(ScreenX - 200, 220, killtext, "left")
         local count = 20
         local interval = 10
         local addedy = 30
         local tbl = {}
         tbl.box = textbox
         tbl.x = ScreenX - 200
         tbl.y = 220
         tbl.text = killtext
         tbl.id = counter
         local id = counter
         counter = counter + 1
         table.insert(kills_textboxs, tbl)
         CreateCountTimer(function()
            for i, v in ipairs(kills_textboxs) do
                if v.id ~= id then
                   DestroyTextBox(v.box)
                   local textbox = CreateTextBox(v.x, math.floor((v.y + addedy/count)+0.5), v.text, "left")
                   v.box = textbox
                   v.y = v.y + addedy/count
                   --SetTextBoxAlignment(v.box, 0, addedy/count)
                end
            end
         end, interval, count)
         Delay(kill_indicator_show_time_ms,function()
            for i, v in ipairs(kills_textboxs) do
                if v.id == id then
                   DestroyTextBox(v.box)
                   table.remove(kills_textboxs,i)
                end
            end
         end)
    end
end)

if dev then
function OnScriptError(message)
    AddPlayerChat('<span color="#ff0000bb" style="bold" size="10">'..message..'</>')
end
AddEvent("OnScriptError", OnScriptError)
end

