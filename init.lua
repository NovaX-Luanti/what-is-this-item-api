-- what_is_this_item · API by NovaX

local S = minetest.settings
local show_debug = S:get_bool("witi_debug_chat", true)
local show_itemstring = S:get_bool("witi_show_itemstring", true)
local show_description = S:get_bool("witi_show_description", true)
local show_params = S:get_bool("witi_show_params", false)

witi_api = {}

-- Helper function to extract stack from object
local function get_stack_from_drop(obj)
    if not obj then return end
    if obj.get_luaentity then
        local ent = obj:get_luaentity()
        if ent and ent.itemstring then
            return ItemStack(ent.itemstring)
        end
    end
    if obj.get_item then
        local stack = obj:get_item()
        if stack and not stack:is_empty() then
            return stack
        end
    end
end

-- Return item information (API)
function witi_api.get_info(obj)
    local stack = get_stack_from_drop(obj)
    if not stack then return end

    local name = stack:get_name()
    local def = minetest.registered_items[name] or {}

    local info = {
        itemstring = stack:to_string(),
        name = name,
        description = def.description or "(no description)",
        inventory_image = def.inventory_image or "unknown_item.png"
    }

    if show_params then
        info.count = stack:get_count()
        info.wear = stack:get_wear()
        info.metadata = stack:get_metadata()
        info.groups = def.groups or {}
    end

    return info
end

-- Optional: debug chat loop
if show_debug then
    local function send_info(player, info)
        if not info then return end
        local lines = {}
        if show_description then table.insert(lines, "Name: " .. info.description) end
        if show_itemstring then table.insert(lines, "Itemstring: " .. info.itemstring) end
        if show_params then
            table.insert(lines, "Count: " .. info.count)
            table.insert(lines, "Wear: " .. info.wear)
            table.insert(lines, "Metadata: " .. (info.metadata or ""))
            for k, v in pairs(info.groups or {}) do
                table.insert(lines, ("Group %s: %s"):format(k, v))
            end
        end
        for _, line in ipairs(lines) do
            minetest.chat_send_player(player:get_player_name(), "[WhatIsThis] " .. line)
        end
    end

    local timer = 0
    minetest.register_globalstep(function(dtime)
        timer = timer + dtime
        if timer < 1 then return end
        timer = 0

        for _, player in ipairs(minetest.get_connected_players()) do
            local eye = vector.add(player:get_pos(), {x=0, y=1.5, z=0})
            local dir = player:get_look_dir()
            local ray = minetest.raycast(eye, vector.add(eye, vector.multiply(dir, 6)), false, true)

            for pointed in ray do
                if pointed.type == "object" then
                    local info = witi_api.get_info(pointed.ref)
                    if info then
                        send_info(player, info)
                        break
                    end
                end
            end
        end
    end)
end