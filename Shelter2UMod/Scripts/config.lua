--[[
┌─────────────────────────────────────────────────────────┐
│ Filename    : config.lua                                │
│ Author      : Faith001                                  │
│ Description : Configuration file for the Shelter2U mod. │
│─────────────────────────────────────────────────────────│
│ History                                                 │
│ 2025-09-21  : Initial creation                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
]]

local _shelter2u_mod_config = {
    -- A slight delay needed for the shelter to finish constructing
    -- before being teleported to the player.
    -- Value is in milliseconds, set higher if teleportation fails on first attempt.
    -- 200 by default.
    shelter_teleport_delay_ms = 200,

    -- Keybind to use for triggering the mod, F1 by default.
    -- For possible values please see below:
    -- https://raw.githubusercontent.com/UE4SS-RE/RE-UE4SS/1c8ef66cfc1a33cec904a2787c2483c30c786a37/assets/Mods/shared/Types.lua
    keybind_key = Key.F1,

    -- Modifier key to use for the keybind, CONTROL by default.
    -- Valid values: SHIFT, CONTROL, ALT
    keybind_modkey = ModifierKey.CONTROL
}
return _shelter2u_mod_config
