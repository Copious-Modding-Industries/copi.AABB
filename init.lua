function OnPlayerSpawned( player_entity ) 
    local flag = "shit"
    if GameHasFlagRun(flag) then
        return
    else
        EntityAddComponent2(player_entity, "LuaComponent", {
            script_source_file = "mods/copi.AABB/main.lua",
            execute_every_n_frame = 1,
        })
    end
end

function OnPlayerDied( player_entity ) 
    GamePrint("fuckin skill issue")
end