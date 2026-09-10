return {
  {
    "chomosuke/typst-preview.nvim",
    opts = {
      -- Projects like the Flow paper use root-absolute paths ("/figures/...")
      -- and are compiled with `typst compile --root <project>`. The plugin's
      -- default root is the previewed file's own directory, which breaks
      -- those paths, so climb to the git root when there is one.
      get_root = function(path_of_main_file)
        local root = vim.fs.root(path_of_main_file, ".git")
        if root then
          return root
        end
        return vim.fn.fnamemodify(path_of_main_file, ":p:h")
      end,
    },
  },
}
