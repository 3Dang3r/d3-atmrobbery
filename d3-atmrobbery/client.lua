local QBCore = exports['qb-core']:GetCoreObject()


CreateThread(function()
    for _, model in pairs(Config.ATMModels) do
        exports['qb-target']:AddTargetModel(model, {
            options = {
                {
                    type = "client",
                    event = "d3-atmrobbery:tryHack",
                    icon = "fas fa-laptop-code",
                    label = "Hack ATM",
                    job = "all"
                }
            },
            distance = 1.5
        })
    end
end)


RegisterNetEvent("d3-atmrobbery:tryHack", function(data)
    local playerPed = PlayerPedId()
    local entity = data and data.entity or nil

    if not entity or not DoesEntityExist(entity) then
        local coords = GetEntityCoords(playerPed)
        for _, model in pairs(Config.ATMModels) do
            local obj = GetClosestObjectOfType(coords, 1.5, model, false, false, false)
            if obj and DoesEntityExist(obj) then
                entity = obj
                break
            end
        end
    end

    if not entity or not DoesEntityExist(entity) then
        QBCore.Functions.Notify("No valid ATM found.", "error")
        return
    end

    local atmName = "atm_" .. tostring(ObjToNet(entity))
    TryRobATM(atmName)
end)


function PlayAnim(dict, name, flag)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), dict, name, 8.0, -8.0, -1, flag or 1, 0, false, false, false)
end


function TryRobATM(atmName)
    QBCore.Functions.TriggerCallback("d3-atmrobbery:canRob", function(canRob)
        if not canRob.status then
            QBCore.Functions.Notify(canRob.msg, "error")
            return
        end


        local connectionTime = math.random(6000, 9000)
        QBCore.Functions.Progressbar("connect_device", "Connecting device to ATM...", connectionTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = 'anim@gangops@facility@servers@',
            anim = 'hotwire',
            flags = 16,
        }, {}, {}, function()
            ClearPedTasks(PlayerPedId())

 
            local success = exports['qb-lock']:Circle(1, 3.5)

            if success then

                    TriggerServerEvent("d3-dispatch:triggerAtmRobbery")

                QBCore.Functions.Progressbar("collect_money", "Collecting money...", 10000, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "anim@heists@ornate_bank@grab_cash",
                    anim = "grab",
                    flags = 16,
                }, {}, {}, function()
                    ClearPedTasks(PlayerPedId())
                    TriggerServerEvent("d3-atmrobbery:reward", atmName)
                end, function()
                    ClearPedTasks(PlayerPedId())
                    QBCore.Functions.Notify("You stopped collecting the money.", "error")
                end)
            else
                QBCore.Functions.Notify("You failed to hack the ATM.", "error")
            end
        end, function()
            ClearPedTasks(PlayerPedId())
            QBCore.Functions.Notify("You cancelled the hack.", "error")
        end)
    end, atmName)
end


