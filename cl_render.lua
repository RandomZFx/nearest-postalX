-- === OPTIMIZATIONS ===
local vec = vec
local Wait = Citizen.Wait
local format = string.format
local RemoveBlip = RemoveBlip
local PlayerPedId = PlayerPedId
local IsHudHidden = IsHudHidden
local SetTextFont = SetTextFont
local SetTextScale = SetTextScale
local SetTextOutline = SetTextOutline
local GetEntityCoords = GetEntityCoords
local EndTextCommandDisplayText = EndTextCommandDisplayText
local BeginTextCommandDisplayText = BeginTextCommandDisplayText
local AddTextComponentSubstringPlayerName = AddTextComponentSubstringPlayerName
local SetResourceKvp = SetResourceKvp
local GetResourceKvpString = GetResourceKvpString
-- === END OPTIMIZATIONS ===

local nearestPostalText = ""
local isEditing = false
local nearest = nil
local pBlip = nil

-- === NUI CALLBACK TO SAVE POSITION ===
RegisterNUICallback("savePosition", function(data, cb)
    SetResourceKvp("postalUI_x", tostring(data.x))
    SetResourceKvp("postalUI_y", tostring(data.y))
    cb({})
end)

-- === TOGGLE EDIT MODE ===
RegisterCommand("editpostal", function()
    isEditing = not isEditing
    SetNuiFocus(isEditing, isEditing)
    SendNUIMessage({
        type = isEditing and "enableEdit" or "disableEdit"
    })
end, false)

RegisterCommand("postalon", function()
    SendNUIMessage({ type = "toggleUI", show = true })
end, false)

RegisterCommand("postaloff", function()
    SendNUIMessage({ type = "toggleUI", show = true })
end, false)



-- === LOAD SAVED UI POSITION ON RESOURCE START ===
Citizen.CreateThread(function()
    Wait(500)
    if config.useEnhanced then
        local x = tonumber(GetResourceKvpString("postalUI_x")) or 40
        local y = tonumber(GetResourceKvpString("postalUI_y")) or 40
        SendNUIMessage({
            type = "loadPosition",
            x = x,
            y = y
        })
    end
end)

-- === NEAREST POSTAL CALCULATION ===
Citizen.CreateThread(function()
    while postals == nil do Wait(1) end

    local delay = math.max(config.updateDelay and tonumber(config.updateDelay) or 300, 50)
    local postals = postals
    local deleteDist = config.blip.distToDelete
    local formatTemplate = config.text.format
    local _total = #postals

    while true do
        local coords = GetEntityCoords(PlayerPedId())
        local _nearestIndex, _nearestD
        coords = vec(coords[1], coords[2])

        for i = 1, _total do
            local D = #(coords - postals[i][1])
            if not _nearestD or D < _nearestD then
                _nearestIndex = i
                _nearestD = D
            end
        end

        if pBlip and #(pBlip.p[1] - coords) < deleteDist then
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0 },
                args = {
                    'Postals',
                    "You've reached your postal destination!"
                }
            })
            RemoveBlip(pBlip.hndl)
            pBlip = nil
        end

        local _code = postals[_nearestIndex].code
        nearest = { code = _code, dist = _nearestD }
        nearestPostalText = format(formatTemplate, _code, _nearestD)

        if config.useEnhanced then
            SendNUIMessage({
                type = "updatePostal",
                postal = _code,
                distance = string.format("%.2f", _nearestD)
            })
        end

        Wait(delay)
    end
end)

-- === NATIVE DRAW TEXT (IF HTML DISABLED) ===
if not config.useEnhanced then
    Citizen.CreateThread(function()
        local posX = config.text.posX
        local posY = config.text.posY
        local _string = "STRING"
        local _scale = 0.42
        local _font = 4

        while true do
            if nearest and not IsHudHidden() then
                SetTextScale(_scale, _scale)
                SetTextFont(_font)
                SetTextOutline()
                BeginTextCommandDisplayText(_string)
                AddTextComponentSubstringPlayerName(nearestPostalText)
                EndTextCommandDisplayText(posX, posY)
            end
            Wait(0)
        end
    end)
end



RegisterNUICallback("exitEditMode", function(_, cb)
    isEditing = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "disableEdit" })
    cb({})
end)

