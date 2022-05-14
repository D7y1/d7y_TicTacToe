-- // LOCALS \\ --
local toggle = false
local GameActive = false


-- // FUNCTIONS \\ --

function StartGame(OtherPlayer,GameID,meinv) 
    SendNUIMessage({
        Start = true,
        OtherPlayer = OtherPlayer,
        GameID = GameID,
        meinv = meinv
    })
    GameActive = true
    toggle = true
    SetNuiFocus(toggle,toggle)
    SetNuiFocusKeepInput(toggle)
end

function CheckPlace(player,place)
    SendNUIMessage({
        CheckPlace = true,
        Pplayer = player,
        Pplace = place
    })
end

function StopGame()
    SendNUIMessage({
        Stop = true,
    })
    GameActive = false
    toggle = false
    SetNuiFocus(toggle,toggle)
    SetNuiFocusKeepInput(toggle)
end


-- // Commands \\ --

RegisterCommand(Config.Command, function(source, args, RawCommand)
    local player,closestDistance = GetClosestPlayer()
    if player ~= -1 and closestDistance <= Config.ClosestPlayer then
        TriggerServerEvent("d7y_TicTacToe:SendInvite", GetPlayerServerId(player))
        Notify(Config.Notifys["succInvite"]..GetPlayerName(player))
    else
        Notify(Config.Notifys["noOneAround"])
    end
end)

RegisterCommand('togglemouse', function(source, args, RawCommand)
    if GameActive then
        toggle = not toggle
        SetNuiFocus(toggle,toggle)
        SetNuiFocusKeepInput(toggle)
    end
end)
RegisterKeyMapping("togglemouse", "To Toggle Mouse In TicTacToe Game (X - O)", "keyboard", Config.ToggleMouse)


-- // NUICALLBACk \\ --

RegisterNUICallback("checked", function(data)
    TriggerServerEvent("d7y_TicTacToe:PlaceChecked", data.GameID,data.player,data.place)
end)
RegisterNUICallback("win", function(data)
    TriggerServerEvent("d7y_TicTacToe:Win", data.GameID,data.status)
end)

RegisterNUICallback("exit", function(data)
    StopGame()
    GameActive = false -- just to make shure :)
    TriggerServerEvent("d7y_TicTacToe:EndGame", data.GameID)
end)



-- // Events \\ --


RegisterNetEvent("d7y_TicTacToe:StartGame")
AddEventHandler("d7y_TicTacToe:StartGame", StartGame)

RegisterNetEvent("d7y_TicTacToe:StopGame")
AddEventHandler("d7y_TicTacToe:StopGame", StopGame)

RegisterNetEvent("d7y_TicTacToe:SendInvite")
AddEventHandler("d7y_TicTacToe:SendInvite", function(inviter)
    local inviter = inviter
    Notify(Config.Notifys["InviteFrom"]..GetPlayerName(GetPlayerFromServerId(inviter)))
    Notify(Config.Notifys["Accept"])
    local state;
    local TimeOut = Config.TimeOut
    SetTimeout(Config.TimeOut, function()
        if not state then
            state = false
            TriggerServerEvent("d7y_TicTacToe:Refused",inviter)
        end
    end)
    while state == nil do
        Wait(1)
        if IsControlJustPressed(0, Keys[Config.AcceptKey]) then
            state = true
            TriggerServerEvent("d7y_TicTacToe:StartGame", inviter)
        end
    end
end)

RegisterNetEvent("d7y_TicTacToe:Refused")
AddEventHandler("d7y_TicTacToe:Refused", function(Refuser)
    local Refuser = GetPlayerFromServerId(Refuser)
   Notify(GetPlayerName(Refuser)..Config.Notifys["Refuse"])
end)

RegisterNetEvent("d7y_TicTacToe:CheckPlace")
AddEventHandler("d7y_TicTacToe:CheckPlace", CheckPlace)

RegisterNetEvent("d7y_TicTacToe:WinNotify")
AddEventHandler("d7y_TicTacToe:WinNotify", function()
    Notify(Config.Notifys["Win"])
end)

RegisterNetEvent("d7y_TicTacToe:LooseNotify")
AddEventHandler("d7y_TicTacToe:LooseNotify", function()
    Notify(Config.Notifys["Loose"])
end)

RegisterNetEvent("d7y_TicTacToe:TieNotify")
AddEventHandler("d7y_TicTacToe:TieNotify", function()
    Notify(Config.Notifys["Tie"])
end)


-- // Some Useful Things \\ --

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)
    
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end


function GetPlayers()
    local players = {}
    
    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end
    
    return players
end

function Notify(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(0,1)
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if toggle then
            DisableControlAction(0, 142, true)
        end
    end
end)