sx, sy = guiGetScreenSize()

local baseX = 1920 
local zoom = 1 
local minZoom = 2 
if sx < baseX then 
    zoom = math.min(minZoom, baseX/sx)
end

hud = {
    enabled = false,
    pos = {x=sx-10/zoom,y=10/zoom},
    colors = {
        ["background"] = tocolor(40, 40, 40,255),
        ["health"] = tocolor(182, 0, 0,255),
        ["armor"] = tocolor(156, 156, 156,255),
        ["oxygen"] = tocolor(0, 174, 255,255),
        ["money"] = tocolor(0, 166, 28, 255)
    }
}

hud.render = function()
    local data = {
        health=getElementHealth(localPlayer),
        armor=getPedArmor(localPlayer),
        oxygen=getPedOxygenLevel(localPlayer),
        money=getPlayerMoney(localPlayer),
        weapon = getPedWeapon(localPlayer),
        totalammo = getPedTotalAmmo(localPlayer),
        clip = getPedAmmoInClip(localPlayer),
    }
    dxDrawRectangle(hud.pos.x, hud.pos.y, -302/zoom, 12/zoom, hud.colors["background"])
    dxDrawRectangle(hud.pos.x-1/zoom, hud.pos.y+1/zoom, -(data.health*3)/zoom, 10/zoom, hud.colors["health"])
    hud.lines = 0
    if data.armor > 0 then
        hud.lines = hud.lines + 1
        dxDrawRectangle(hud.pos.x, hud.pos.y+(16*hud.lines)/zoom, -302/zoom, 12/zoom, hud.colors["background"])
        dxDrawRectangle(hud.pos.x-1/zoom, hud.pos.y+((16*hud.lines)+1)/zoom, -(data.armor*3)/zoom, 10/zoom, hud.colors["armor"])
    end
    if data.oxygen < 1000 then
        hud.lines = hud.lines + 1
        dxDrawRectangle(hud.pos.x, hud.pos.y+(16*hud.lines)/zoom, -302/zoom, 12/zoom, hud.colors["background"])
        dxDrawRectangle(hud.pos.x-1/zoom, hud.pos.y+((16*hud.lines)+1)/zoom, -(data.oxygen/10*3)/zoom, 10/zoom, hud.colors["oxygen"])
    end
    if data.weapon ~= 0 then
        dxDrawImage(hud.pos.x-300/zoom, hud.pos.y+((16*hud.lines)-40)/zoom, 150/zoom, 150/zoom, "img/guns/"..data.weapon..".png")
        dxDrawText(data.clip.."/"..data.totalammo, hud.pos.x-225/zoom, hud.pos.y+((16*hud.lines)+65)/zoom, hud.pos.x-225/zoom, hud.pos.y+(16*hud.lines)+65/zoom, white, 1.2/zoom, "default-bold", "center")
    end
    dxDrawText("$"..data.money, hud.pos.x, hud.pos.y+((16*hud.lines)+12)/zoom, hud.pos.x, hud.pos.y+(16*hud.lines)+12/zoom, hud.colors["money"], 2/zoom, "default-bold", "right")
end

function isPlayerHudVisible()
    return hud.enabled
end

function setPlayerHudVisible(bool)
    hud.enabled = bool or (not hud.enabled)
    if hud.enabled then
        addEventHandler("onClientRender", root, hud.render)
    else
        removeEventHandler("onClientRender", root, hud.render)
    end
end

bindKey("F7", "down", function()
    if getElementData(localPlayer, "loggedIn") then
        setPlayerHudVisible()
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    if getElementData(localPlayer, "loggedIn") then
        setPlayerHudVisible(true)
    end
end)