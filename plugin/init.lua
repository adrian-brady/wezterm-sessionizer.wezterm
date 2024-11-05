local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local is_windows = string.find(wezterm.target_triple, "windows") ~= nil

---@alias action_callback any
---@alias MuxWindow any
---@alias Pane any

---@alias workspace_ids table<string, boolean>
---@alias choice_opts {extra_args?: string, workspace_ids?: workspace_ids}
---@alias InputSelector_choices { id: string, label: string }[]

---@class public_module
---@field zoxide_path string
---@field choices {get_zoxide_elements: (fun(choices: InputSelector_choices, opts: choice_opts?): InputSelector_choices), get_workspace_elements: (fun(choices: InputSelector_choices): (InputSelector_choices, workspace_ids))}
---@field workspace_formatter fun(label: string): string
local pub = {
	zoxide_path = "zoxide",
	choices = {},
	workspace_formatter = function(label)
		return wezterm.format({
			{ Text = "󱂬 : " .. label },
		})
	end,
}

---@param cmd string
---@return string
local run_child_process = function(cmd)
	local process_args = { os.getenv("SHELL"), "-c", cmd }
	if is_windows then
		process_args = { "cmd", "/c", cmd }
	end
	local success, stdout, stderr = wezterm.run_child_process(process_args)

	if not success then
		wezterm.log_error("Child process '" .. cmd .. "' failed with stderr: '" .. stderr .. "'")
	end
	return stdout
end

function pub.run()
	local stdout = run_child_process(pub.zoxide_path .. " query -l ")
	wezterm.log_info(stdout)
end

--@param config table
function pub.apply_to_config(config)
	if config then
		if not config.keys then
			config.keys = {}
		end
	else
		config = { keys = {} }
	end
	table.insert(config.keys, {
		key = "l",
		mods = "CMD",
		action = pub.run(),
	})
end
