local wezterm = require("wezterm")
local act = wezterm.action

local function apply_to_config(config)
    config.keys = {
        {
            key = "i",
            mods = "SUPER",
            action = act.PromptInputLine({
                description = "Enter new prompt:",
                action = wezterm.action_callback(function(window, pane, line)
                    if line then
                        local success, stdout, stderr = wezterm.run_child_process({
                            "/Users/mickl/.lmstudio/bin/lms",
                            "chat",
                            "google/gemma-3-4b",
                            "-s",
                            "you are an assistant that specializes in CLI and macOs commands"
                                .. "you will be brief and to the point, if asked for commands print them in a way that's easy to copy, otherwise just answer the question,"
                                .. "concatenate commands with && or || for ease of use, structure your output in a JSON schema with 2 fields: message and command",
                            "-p",
                            line,
                        })
                        if success then
                            stdout = stdout:gsub("```%w*\n?", "") -- Remove opening fence with optional language
                            stdout = stdout:gsub("```", "") -- Remove closing fence
                            local json = wezterm.json_parse(stdout)
                            if json then
                                if json.message then
                                    pane:inject_output("\r\n" .. json.message:gsub("[\n]", "\r\n"))
                                end
                                pane:send_text("\u{15}") -- Ctrl+U (ASCII 21/0x15)
                                pane:send_text("\r")
                                if json.command then
                                    pane:send_text(json.command)
                                end
                            else
                                wezterm.log_error("Failed to parse JSON response: ", stdout)
                                pane:inject_output("\r\n" .. stdout:gsub("[\n]", "\r\n"))
                                pane:send_text("\u{15}") -- Ctrl+U (ASCII 21/0x15)
                                pane:send_text("\r")
                            end
                        end
                        if stderr and stderr ~= "" then
                            wezterm.log_error("stderr: ", stderr)
                        end
                    else
                        wezterm.log_info("AI call cancelled by user.")
                    end
                end),
            }),
        },
    }
end

return {
    apply_to_config = apply_to_config,
}
