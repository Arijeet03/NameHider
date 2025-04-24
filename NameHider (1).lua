script_name("NameHider")
script_author("Dunni")

require "lib.moonloader"
require "lib.sampfuncs"
local inicfg = require 'inicfg'
local sampev = require "lib.samp.events"

local config = inicfg.load({
    parameters = {}
}, 'namehider.ini')

nh = true

function main() 
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampAddChatMessage("{0000FF}NameHider{FFFFFF} By Dunni {ff00ff}[/nhtog]", -1)
	sampRegisterChatCommand("nhtog", function() nh = not nh sampAddChatMessage(string.format("{0000FF}NameHider{ffffff}: %s", nh and "{00FF00}Enabled" or "{FF0000}Disabled"), -1) end)
    sampRegisterChatCommand("nhset", function(params)
        if params then
            local params = split(params, " ")
            if params[1] and params[2] then
                config.parameters[params[1]] = params[2]
                sampAddChatMessage(string.format("{00FF00}Replacement set: '%s' -> '%s'",params[1], params[2]), -1)
                saveIni()
            else
                sampAddChatMessage("{FF0000}Usage: /nhset [phrase] [whattoreplacewith]", -1)
            end
        end
    end)
end
function sampev.onServerMessage(clr, msg)
    if nh then
        for k,v in pairs(config.parameters) do
            if msg:find(k) then
                local r, g, b, a = explode_argb(clr)
                msg = msg:gsub(k, v)
                sampAddChatMessage(msg, join_argb(a, r, g, b))
                return false
            end
        end
    end
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end
  
function join_argb(a, r, g, b)
    local argb = b
    argb = bit.bor(argb, bit.lshift(g, 8))
    argb = bit.bor(argb, bit.lshift(r, 16))
    argb = bit.bor(argb, bit.lshift(a, 24))
    return argb
end

function saveIni()
    inicfg.save(config, 'namehider.ini')
end

function split(str, delim)
	local input = ("([^%s]+)"):format(delim)
	local output = {}
	for k in str:gmatch(input) do
	   table.insert(output, k) 
	end
	return output
end