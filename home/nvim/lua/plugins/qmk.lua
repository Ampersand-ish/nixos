return {
  {
    "codethread/qmk.nvim",
    ft = { "keymap", "dts", "dtsi", "c" },
    opts = {
      -- FIXED: Targets the literal internal text segment that defines the arrays.
      -- This ensures only the code blocks within the bracket bounds are evaluated.
      name = "bindings",
      variant = "zmk",
      comment_preview = {
        position = "inside",
      },
      -- Exact 60-key configuration matching only the hardware key positions of your Sofle
      layout = {
        "x x x x x x _ _ x x x x x x", -- Row 1 (12 keys)
        "x x x x x x _ _ x x x x x x", -- Row 2 (12 keys)
        "x x x x x x _ _ x x x x x x", -- Row 3 (12 keys)
        "x x x x x x x x x x x x x x", -- Row 4 (14 keys)
        "_ _ _ x x x x x x x x _ _ _", -- Row 5 (10 keys)
      },
    },
    config = function(_, opts)
      local has_qmk, qmk = pcall(require, "qmk")
      if not has_qmk then
        return
      end

      qmk.setup(opts)

      vim.api.nvim_create_user_command("ZmkFormat", function()
        qmk.format()
      end, {})

      vim.keymap.set("n", "<leader>zk", qmk.format, { desc = "Format ZMK Keymap" })

      local zmk_group = vim.api.nvim_create_augroup("ZmkAutoFormat", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = zmk_group,
        pattern = { "*.keymap", "*.dts", "*.dtsi" },
        callback = function()
          local success, err = pcall(qmk.format)
          if not success then
            vim.notify("ZMK Autoformat delayed: " .. tostring(err), vim.log.levels.WARN)
          end
        end,
      })
    end,
  },
}
