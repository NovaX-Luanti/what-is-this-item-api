# What Is This Item – API

A lightweight Minetest/Luanti helper‑mod that lets **other mods** fetch detailed
information about a dropped item entity. Optionally, it can print those details
to chat while you’re looking at the drop — fully configurable via
`settings.conf`.

---

## Installation

1. Copy the folder **`what_is_this_item`** into your `mods/` directory.
2. Ensure it contains **`init.lua`**, **`mod.conf`** and **`settings.conf`**.
3. Enable the mod in your world.

No hard dependencies.

---

## Configuration (`settings.conf`)

| Key | Default | Description |
| --- | :---: | --- |
| `witi_debug_chat` | `true` | Enables live chat debug. Set to `false` to keep API only. |
| `witi_show_itemstring` | `true` | Show the full itemstring (`default:torch 1`). |
| `witi_show_description` | `true` | Show the readable description (`Torch`). |
| `witi_show_params` | `false` | Also print **count, wear, metadata, groups**. |

Place the file next to `init.lua` or merge the keys into `minetest.conf`.

---

## API

```lua
local info = witi_api.get_info(object_ref)
```

### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| `object_ref` | `ObjectRef` | An entity ref. If it’s a dropped‑item entity, returns info; else `nil`. |

### Returned table

| Field | Example | Notes |
| ----- | ------- | ----- |
| `itemstring` | `default:torch 1` | Full stack string. |
| `name` | `default:torch` | Registered item name. |
| `description` | `Torch` | Human–readable description. |
| `inventory_image` | `torch.png` | 32×32 inventory icon. |
| `count` / `wear` / `metadata` / `groups` | — | Only present if `witi_show_params = true`. |

---

## Usage Examples

### Print a message when punching a drop

```lua
minetest.register_on_punchnode(function(pos, node, player, pointed)
    if pointed.type ~= "object" then return end
    local info = witi_api.get_info(pointed.ref)
    if info then
        minetest.chat_send_player(player:get_player_name(),
            ("Drop: %s (%s)"):format(info.description, info.itemstring))
    end
end)
```

### Show a custom HUD label while aiming at a drop

```lua
local hud_id
minetest.register_globalstep(function()
    local player = minetest.get_player_by_name("singleplayer")
    local eye    = vector.add(player:get_pos(), {x=0, y=1.5, z=0})
    local ray    = minetest.raycast(eye, vector.add(eye, {x=0, y=0, z=10}), false, true)

    for hit in ray do
        if hit.type == "object" then
            local info = witi_api.get_info(hit.ref)
            if info then
                if not hud_id then
                    hud_id = player:hud_add({
                        type = "text",
                        position = {x=0.5, y=0.1},
                        text = info.description,
                        alignment = {x=0, y=0},
                    })
                else
                    player:hud_change(hud_id, "text", info.description)
                end
                return
            end
        end
    end

    -- no drop
    if hud_id then player:hud_remove(hud_id); hud_id = nil end
end)
```

---

## FAQ

**Toggle debug chat in‑game**

```
/set witi_debug_chat false
/reload
```

**Works with custom entities?**  
Yes— they just need an `itemstring` field. The engine entity
`__builtin:item` is handled automatically.

**Integrate with WiTT?**  
If `witt` or `fbt_witt` is installed the mod auto‑registers as a provider:
point at a drop, WiTT shows its own HUD.

---

## License

* Code: **MIT**
