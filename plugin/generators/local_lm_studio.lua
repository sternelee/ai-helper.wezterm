local wezterm = require("wezterm")

local function generate_content(config, prompt)
    local success, stdout, stderr = wezterm.run_child_process({
        config.lms_path,
        "chat",
        config.model,
        "-s",
        config.system_prompt,
        "-p",
        prompt,
    })

    return {
        success = success,
        result = stdout,
        err = stderr,
    }
end

return {
    generate_content = generate_content,
}
