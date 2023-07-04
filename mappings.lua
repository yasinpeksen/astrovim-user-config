--- Table based API for setting keybindings
---@param map_table table A nested table where the first key is the vim mode, the second key is the key to map, and the value is the function to set the mapping to
---@param base? table A base set of options to set on every keybinding
function set_mappings(map_table, base)
    -- iterate over the first keys for each mode
    base = base or {}
    for mode, maps in pairs(map_table) do
        -- iterate over each keybinding set in the current mode
        for keymap, options in pairs(maps) do
            -- build the options for the command accordingly
            if options then
                local cmd = options
                local keymap_opts = base
                if type(options) == "table" then
                    cmd = options[1]
                    keymap_opts = vim.tbl_deep_extend("force", keymap_opts,
                                                      options)
                    keymap_opts[1] = nil
                end
                if not cmd or keymap_opts.name then -- if which-key mapping, queue it
                    if not M.which_key_queue then
                        M.which_key_queue = {}
                    end
                    if not M.which_key_queue[mode] then
                        M.which_key_queue[mode] = {}
                    end
                    M.which_key_queue[mode][keymap] = keymap_opts
                else -- if not which-key mapping, set it
                    vim.keymap.set(mode, keymap, cmd, keymap_opts)
                end
            end
        end
    end
    if package.loaded["which-key"] then M.which_key_register() end -- if which-key is loaded already, register
end

-- Terminal Esc to normal mode
-- vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true })

local maps = {i = {}, n = {}, v = {}, t = {}}
-- Buffers
maps.n[">>"] = {
    function()
        require("astronvim.utils.buffer").nav(
            vim.v.count > 0 and vim.v.count or 1)
    end,
    desc = "Next buffer"
}
maps.n["<<"] = {
    function()
        require("astronvim.utils.buffer").nav(
            -(vim.v.count > 0 and vim.v.count or 1))
    end,
    desc = "Previous buffer"
}
-- maps.n["<C-w>"] = "<cmd>Bdelete<cr>"

-- Terminal
maps.t["<C-x>"] = "<C-\\><C-n>"
maps.n["<leader>t1"] = "<cmd>1ToggleTerm direction=horizontal<cr>"
maps.n["<leader>t2"] = "<cmd>2ToggleTerm direction=horizontal<cr>"
maps.n["<leader>t3"] = "<cmd>3ToggleTerm direction=horizontal<cr>"
maps.n["<leader>t4"] = "<cmd>4ToggleTerm direction=horizontal<cr>"

-- OSC52 Copy to clipboard
maps.n["<C-M-c>"] = require('osc52').copy_operator
maps.v["<C-M-c>"] = require('osc52').copy_visual

-- Misc
maps.n["x"] = "\"_x"
maps.n["d"] = "\"_d"
maps.n["D"] = "\"_D"
maps.v["d"] = "\"_d"
maps.n["dd"] = "\"_dd"

set_mappings(maps)
