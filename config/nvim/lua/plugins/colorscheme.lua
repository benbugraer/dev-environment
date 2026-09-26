return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = function()
      local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")

      local scheme = handle and handle:read("*a") or ""
      if handle then
        handle:close()
      end

      local flavour = scheme:match("prefer%-dark") and "macchiato" or "latte"

      return {
        flavour = flavour,
        background = {
          light = "latte",
          dark = "macchiato",
        },
      }
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
