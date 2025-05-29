local wezterm = require("wezterm")
local act = wezterm.action

-- Default configuration
local default_config = {
    model = "google/gemma-3-4b",
    keybinding = {
        key = "i",
        mods = "SUPER",
    },
    system_prompt = "you are an assistant that specializes in CLI and macOS commands. "
        .. "you will be brief and to the point, if asked for commands print them in a way that's easy to copy, "
        .. "otherwise just answer the question. concatenate commands with && or || for ease of use. "
        .. "structure your output in a JSON schema with 2 fields: message and command",
    timeout = 30, -- seconds
    show_loading = true,
}

-- Merge user config with defaults
local function merge_config(user_config)
    local config = {}
    for k, v in pairs(default_config) do
        config[k] = v
    end
    if user_config then
        for k, v in pairs(user_config) do
            config[k] = v
        end
    end
    return config
end

-- Show loading indicator
local function show_loading(pane, show)
    if show then
        pane:inject_output("\r\n🤖 AI is thinking...")
    end
end

-- Clean up AI response by removing markdown code fences
local function clean_response(response)
    if not response then return "" end
    
    -- Remove code fences
    response = response:gsub("```%w*\n?", "")
    response = response:gsub("```", "")
    
    -- Trim whitespace
    response = response:match("^%s*(.-)%s*$")
    
    return response
end

-- Parse JSON response with better error handling
local function parse_ai_response(response)
    local cleaned = clean_response(response)
    local json = wezterm.json_parse(cleaned)
    
    if json and type(json) == "table" then
        return json
    end
    
    -- Fallback: treat as plain text message
    return {
        message = cleaned,
        command = nil
    }
end

-- Send command to AI and handle response
local function handle_ai_request(window, pane, prompt, config)
    if not prompt or prompt:match("^%s*$") then
        wezterm.log_info("Empty prompt, cancelling AI request")
        return
    end

    -- Show loading indicator
    if config.show_loading then
        show_loading(pane, true)
    end

    -- Check if LMS binary exists
    local lms_exists = wezterm.run_child_process({"test", "-f", config.lms_path})
    if not lms_exists then
        if config.show_loading then
            pane:inject_output("\r\n❌ Error: LM Studio CLI not found at " .. config.lms_path)
        end
        return
    end

    local success, stdout, stderr = wezterm.run_child_process({
        config.lms_path,
        "chat",
        config.model,
        "-s", config.system_prompt,
        "-p", prompt,
    })

    if success then
        local response = parse_ai_response(stdout)
        
        -- Display message if present
        if response.message and response.message ~= "" then
            pane:inject_output("\r\n💬 " .. response.message:gsub("[\n]", "\r\n"))
        end
        
        -- Clear current line and send command if present
        pane:send_text("\u{15}") -- Ctrl+U to clear line
        pane:send_text("\r")
        
        if response.command and response.command ~= "" then
            pane:send_text(response.command)
        end
    else
        -- Handle errors
        local error_msg = "❌ AI request failed"
        if stderr and stderr ~= "" then
            error_msg = error_msg .. ": " .. stderr
            wezterm.log_error("AI Helper stderr: ", stderr)
        end
        pane:inject_output("\r\n" .. error_msg)
        
        -- Still clear the line for user convenience
        pane:send_text("\u{15}")
        pane:send_text("\r")
    end
end

-- Main function to apply configuration
local function apply_to_config(wezterm_config, user_config)
    local config = merge_config(user_config)
    
    -- Validate required configuration
    if not config.lms_path then
        wezterm.log_error("AI Helper: lms_path is required in configuration")
        return
    end
    
    if wezterm_config.keys == nil then
        wezterm_config.keys = {}
    end

    table.insert(wezterm_config.keys, {
        key = config.keybinding.key,
        mods = config.keybinding.mods,
        action = act.PromptInputLine({
            description = "🤖 Enter AI prompt:",
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    handle_ai_request(window, pane, line, config)
                else
                    wezterm.log_info("AI Helper: Request cancelled by user")
                end
            end),
        }),
    })
    
    wezterm.log_info("AI Helper plugin loaded with model: " .. config.model)
end

return {
    apply_to_config = apply_to_config,
}
