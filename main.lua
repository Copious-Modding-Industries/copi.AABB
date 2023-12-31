dofile_once("data/scripts/debug/keycodes.lua")
local display = GlobalsGetValue("copi.aabb.display", "true")
if InputIsKeyJustDown(ModSettingGet("copi.aabb.show_key")) then
    local flip = {
        ["true"] = "false",
        ["false"] = "true",
    }
    GlobalsSetValue("copi.aabb.display", flip[display])
end
if display == "true" then
    Gui = Gui or GuiCreate()
    GuiZSet(Gui, 100)
    GuiStartFrame(Gui)
    GuiIdPushString(Gui, "copi.AABB")
    VResX = VResX or tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_X")) or 0
    VResY = VResY or tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_Y")) or 0

    --- Converts a world coordinate to a GUI coordinate
    ---@param gui userdata The current Gui
    ---@param world_x number The X coordinate to convert
    ---@param world_y number The Y coordinate to convert
    ---@param res_x number The virtual X resolution
    ---@param res_y number The virtual Y resolution
    ---@return number gui_x The resulting GUI X coordinate
    ---@return number gui_y The resulting GUI Y coordinate
    local function world_to_gui(gui, world_x, world_y, res_x, res_y)
        local cam_x, cam_y = GameGetCameraPos()
        local s_w, s_h = GuiGetScreenDimensions(gui)
        local vx = world_x - cam_x + res_x / 2
        local vy = world_y - cam_y + res_y / 2
        local gui_x = vx * s_w / res_x
        local gui_y = vy * s_h / res_y
        return gui_x, gui_y
    end

    local function world_to_gui_scale(gui, world_w, world_h, res_x, res_y)
        local s_w, s_h = GuiGetScreenDimensions(gui)
        local gui_x = world_w * s_w / res_x
        local gui_y = world_h * s_h / res_y
        return gui_x, gui_y
    end

    local function rect_on_screen(gui, x, y, w, h)
        local s_w, s_h = GuiGetScreenDimensions(gui)
        return x + w >= 0 and x < s_w and y + h >= 0 and y < s_h
    end

    local types = {
        {
            typename = "AreaDamageComponent",
            filepath = "mods/copi.AABB/9piece_hurt.png",
            aabb_fn = function(comp)
                local min_x, min_y = ComponentGetValue2(comp, "aabb_min")
                local max_x, max_y = ComponentGetValue2(comp, "aabb_max")
                local width = max_x - min_x
                local height = max_y - min_y
                return min_x, min_y, width, height
            end
        },
        {
            typename = "HitboxComponent",
            filepath = function ( entity, comp )
                if EntityHasTag(entity, "workshop") then
                    return "mods/copi.AABB/9piece_workshop.png"
                elseif ComponentHasTag(comp, "hitbox_weak_spot") then
                    return "mods/copi.AABB/9piece_weakspot.png"
                end
                return "mods/copi.AABB/9piece.png"
            end,
            aabb_fn = function(comp)
                local min_x = ComponentGetValue2(comp, "aabb_min_x")
                local min_y = ComponentGetValue2(comp, "aabb_min_y")
                local max_x = ComponentGetValue2(comp, "aabb_max_x")
                local max_y = ComponentGetValue2(comp, "aabb_max_y")
                local width = max_x - min_x
                local height = max_y - min_y
                return min_x, min_y, width, height
            end
        },
        {
            typename = "MaterialAreaCheckerComponent",
            filepath = "mods/copi.AABB/9piece_material.png",
            aabb_fn = function(comp)
                local min_x, min_y, max_x, max_y = ComponentGetValue2(comp, "area_aabb")
                local width = max_x - min_x
                local height = max_y - min_y
                return min_x, min_y, width, height
            end
        },
        {
            typename = "CollisionTriggerComponent",
            filepath = "mods/copi.AABB/9piece_collision.png",
            aabb_fn = function(comp)
                local width = ComponentGetValue2(comp, "width")
                local height = ComponentGetValue2(comp, "height")
                return width * -0.5, height * -0.5, width, height
            end
        },
    }

    local eid = GetUpdatedEntityID()
    local px, py = EntityGetTransform(eid)

    -- loop over entities
    local targets = EntityGetInRadius(px, py, 1024) or {}
    for i = 1, #targets do
        local target = targets[i]
        local target_x, target_y = EntityGetTransform(target)

        -- loop over component types
        for j = 1, #types do
            local thistype = types[j]

            -- loop over components of said thistype
            local comps = EntityGetComponent(target, thistype.typename) or {}
            for k = 1, #comps do
                local comp = comps[k]
                local left, top, width, height = thistype.aabb_fn(comp)
                local guiLeft, guiTop = world_to_gui(Gui, left + target_x, top + target_y, VResX, VResY)
                local guiWidth, guiHeight = world_to_gui_scale(Gui, width, height, VResX, VResY)
                if rect_on_screen(Gui, guiLeft, guiTop, guiWidth, guiHeight) then
                    local filepath = thistype.filepath
                    if type(thistype.filepath) == "function" then
                        filepath = thistype.filepath(target, comp)
                    end
                    GuiImageNinePiece(Gui, comp, guiLeft, guiTop, guiWidth, guiHeight, 1, filepath, filepath)
                end
            end
        end
    end

    GuiIdPop(Gui)
end
