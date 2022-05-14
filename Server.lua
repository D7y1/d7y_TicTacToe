
local Games = {}


RegisterServerEvent("d7y_TicTacToe:StartGame")
AddEventHandler("d7y_TicTacToe:StartGame", function(inviter)
   local src = source
   local inviter = inviter
   local GameID = makeid(12)
   Games[GameID] = {
       x = inviter,
       o = src,

   }
   TriggerClientEvent("d7y_TicTacToe:StartGame",inviter,GetPlayerName(src),GameID,true)
   TriggerClientEvent("d7y_TicTacToe:StartGame",src,GetPlayerName(inviter),GameID,false)
end)

RegisterServerEvent("d7y_TicTacToe:EndGame")
AddEventHandler("d7y_TicTacToe:EndGame", function(GameID)
   if Games[GameID] then
    TriggerClientEvent("d7y_TicTacToe:StopGame", Games[GameID].x)
    TriggerClientEvent("d7y_TicTacToe:StopGame", Games[GameID].o)
    Games[GameID] = nil
   end
end)

RegisterServerEvent("d7y_TicTacToe:PlaceChecked")
AddEventHandler("d7y_TicTacToe:PlaceChecked", function(GameID,player,place)
    local player,place = player,place
    if Games[GameID] then
        TriggerClientEvent("d7y_TicTacToe:CheckPlace", Games[GameID].x,player,place)
        TriggerClientEvent("d7y_TicTacToe:CheckPlace", Games[GameID].o,player,place)
    end
end)

RegisterServerEvent("d7y_TicTacToe:Win")
AddEventHandler("d7y_TicTacToe:Win", function(GameID,status)
    local GameID = GameID
    local Winner = status
    if Games[GameID] then
        if Winner == 'x' then
            Config.OnXWin(Games[GameID].x,Games[GameID].o)
        elseif Winner == "o" then
            Config.OnOWin(Games[GameID].o,Games[GameID].x)
        elseif Winner == "Tie" then
            Config.OnTie(Games[GameID].x,Games[GameID].o)
        end
        SetTimeout(Config.GameEndedTimeOut, function()
            TriggerEvent("d7y_TicTacToe:EndGame", GameID)
        end)
    end
end)

RegisterServerEvent("d7y_TicTacToe:SendInvite")
AddEventHandler("d7y_TicTacToe:SendInvite", function(player)
   TriggerClientEvent("d7y_TicTacToe:SendInvite", player, source)
end)

RegisterServerEvent("d7y_TicTacToe:Refused")
AddEventHandler("d7y_TicTacToe:Refused", function(inviter)
    TriggerClientEvent("d7y_TicTacToe:Refused", inviter, source)
   
end)


function makeid(length)
    local upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local lowerCase = "abcdefghijklmnopqrstuvwxyz"
    local numbers = "0123456789"
    
    local characterSet = upperCase .. lowerCase .. numbers
    
    local keyLength = length
    local output = ""
    
    for	i = 1, keyLength do
        local rand = math.random(#characterSet)
        output = output .. string.sub(characterSet, rand, rand)
    end
    return output
end