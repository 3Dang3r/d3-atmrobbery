local QBCore = exports['qb-core']:GetCoreObject()
local atmCooldowns = {}


Config = Config or {}

QBCore.Functions.CreateCallback("d3-atmrobbery:canRob", function(source, cb, atmName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({ status = false, msg = "Player not found." }) end


    local cops = 0
    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local ply = QBCore.Functions.GetPlayer(id)
        if ply and ply.PlayerData.job.name == "police" and ply.PlayerData.job.onduty then
            cops = cops + 1
        end
    end

    if cops < Config.MinimumPolice then
        return cb({ status = false, msg = "Not enough police on duty." })
    end


    if not Player.Functions.GetItemByName(Config.RequiredItem) then
        return cb({ status = false, msg = "You need a " .. Config.RequiredItem .. " to hack this ATM." })
    end


    local currentTime = os.time()
    local lastRobbed = atmCooldowns[atmName] or 0
    local cooldown = Config.ATMCooldown or 300

    if currentTime - lastRobbed < cooldown then
        local timeLeft = cooldown - (currentTime - lastRobbed)
        return cb({ status = false, msg = ("This ATM was recently hacked. Try again in %d seconds."):format(timeLeft) })
    end

    cb({ status = true })
end)

RegisterNetEvent("d3-atmrobbery:reward", function(atmName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local rewardMin = Config.Reward and Config.Reward.Min or 500
    local rewardMax = Config.Reward and Config.Reward.Max or 1500
    local reward = math.random(rewardMin, rewardMax)

    Player.Functions.AddMoney("cash", reward, "atm-robbery")
    atmCooldowns[atmName] = os.time()

    TriggerClientEvent('QBCore:Notify', src, "You hacked the ATM and got $" .. reward, "success")
end)
