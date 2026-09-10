return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        kdl = { "kdlfmt" },
      },
      formatters = {
        kdlfmt = {
          inherit = false,
          command = "kdlfmt",
          -- This ensures kdlfmt runs in the directory containing kdlfmt.kdl
          cwd = require("conform.util").root_file({ "kdlfmt.kdl" }),
          args = function(self, ctx)
            local args = { "format", "--stdin", "--kdl-version", "v1" }

            -- Look for a local config file and tell kdlfmt to use it explicitly
            local config_path = require("conform.util").root_file({ "kdlfmt.kdl" })(self, ctx)
            if config_path then
              table.insert(args, "--config")
              table.insert(args, config_path .. "/kdlfmt.kdl")
            end

            return args
          end,
          stdin = true,
        },
      },
    },
  },
}
