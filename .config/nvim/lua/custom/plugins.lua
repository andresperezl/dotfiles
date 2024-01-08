local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
  -- In order to modify the `lspconfig` configuration:
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },

  {
    "stevearc/conform.nvim",
    --  for users those who want auto-save conform + lazyloading!
    -- event = "BufWritePre"
    config = function()
      require "custom.configs.conform"
    end,
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    lazy = false,
    config = function()
      local actions = require "telescope.actions"
      local action_state = require "telescope.actions.state"
      local harpoon = require "harpoon"
      harpoon:setup {}

      -- basic telescope configuration
      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require("telescope.pickers")
          .new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table {
              results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
            -- Make telescope select buffer from harpoon list
            attach_mappings = function(_, map)
              local function list_find(list, func)
                for i, v in ipairs(list) do
                  if func(v, i, list) then
                    return i, v
                  end
                end
              end

              actions.select_default:replace(function(prompt_bufnr)
                local curr_picker = action_state.get_current_picker(prompt_bufnr)
                local curr_entry = action_state.get_selected_entry()
                if not curr_entry then
                  return
                end
                actions.close(prompt_bufnr)

                local idx, _ = list_find(curr_picker.finder.results, function(v)
                  if curr_entry.value == v.value then
                    return true
                  end
                  return false
                end)
                harpoon:list():select(idx)
              end)
              -- Delete entries from harpoon list with <C-d>
              map({ "n", "i" }, "<C-d>", function(prompt_bufnr)
                local current_picker = action_state.get_current_picker(prompt_bufnr)

                current_picker:delete_selection(function(selection)
                  harpoon:list():removeAt(selection.index)
                end)
              end)
              return true
            end,
          })
          :find()
      end

      vim.keymap.set("n", "<leader>z", function()
        toggle_telescope(harpoon:list())
      end, { desc = "Open harpoon window" })
    vim.keymap.set("n", "<leader>a", function()
        harpoon:list():append()
      end, { desc = "Append current file to harpoon" })
      vim.keymap.set("n", "<leader>1", function()
        harpoon:list():select(1)
      end, { desc = "Select 1st harpoon window" })
      vim.keymap.set("n", "<leader>2", function()
        harpoon:list():select(2)
      end, { desc = "Select 2nd harpoon window" })
      vim.keymap.set("n", "<leader>3", function()
        harpoon:list():select(3)
      end, { desc = "Select 3rd harpoon window" })
      vim.keymap.set("n", "<leader>4", function()
        harpoon:list():select(4)
      end, { desc = "Select 4th harpoon window" })

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set("n", "<leader>,", function()
        harpoon:list():prev()
      end)
      vim.keymap.set("n", "<leader>.", function()
        harpoon:list():next()
      end)
    end,
  },
  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },

  -- All NvChad plugins are lazy-loaded by default
  -- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
  -- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
  -- }
  { "NvChad/nvterm", enabled = false },
}

return plugins
