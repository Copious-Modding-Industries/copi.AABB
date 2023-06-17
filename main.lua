Gui = Gui or GuiCreate()
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

local types = {
    {
        typename = "AreaDamageComponent",
        color = {
            r = 1,
            g = 0,
            b = 0,
            a = 1,
        },
        aabb_fn = function (comp)
            
            --return min_x, max_x, min_y, max_y
        end
    }
}

local eid = GetUpdatedEntityID()
local px, py = EntityGetTransform(eid)

-- loop over entities
local targets = EntityGetInRadius(px, py, 256) or {}
for i = 1, #targets do
    local target = targets[i]
    local target_x, target_y = EntityGetTransform(target)
    local t_gui_x, t_gui_y = world_to_gui(Gui, target_x, target_y, VResX, VResY)

    -- loop over component types
    for j = 1, #types do
        local type = types[j]

        -- loop over components of said type
        local comps = EntityGetComponent(target, type.typename) or {}
        for k = 1, #comps do
            local comp = comps[k]
            -- Do some shit here to calculate the gui width and height of the AABB, then pass them in to 
            -- PUDY PLEASE HELP ME WITH THIS
            GuiImageNinePiece(Gui, comp, t_gui_x, t_gui_y, SOMETHING, SOMETHING, type.color.a, "mods/copi.AABB/9piece.png", "mods/copi.AABB/9piece.png")
        end
    end
end

GuiIdPop(Gui)
