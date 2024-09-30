-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
-- luacheck: globals vim
local nixfile = vim.fn.stdpath("config") .. "/nix.lua"
if (vim.uv or vim.loop).fs_stat(nixfile) then
	dofile(nixfile)
end

local function use_lazy_nvim()
	if not pcall(require, "lzy") then
		local lazypath
		-- ignore_pattern
		if _G.use_nix and _G.nix.lazypath then
			vim.opt.rtp:prepend(_G.nix.lazypath)
			lazypath = _G.nix.lazypath
		else
			lazypath = vim.env.LAZY or vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
			if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
                -- stylua: ignore
                vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
			end
			vim.opt.rtp:prepend(lazypath)
		end
		-- validate that lazy is available
		if not pcall(require, "lazy") then
        -- stylua: ignore
            vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
			vim.fn.getchar()
			vim.cmd.quit()
		end
	end
end

use_lazy_nvim()

require("lazy_setup")
require("polish")
