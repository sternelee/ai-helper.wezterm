# AI Helper for WezTerm

I really liked Warp but due to my company's AI policy I had to move to something else. WezTerm is 90% of what I need and I decided to build the remaining 10% myself.
And so here it is: a very simple WezTerm plugin that lets you ask an AI for CLI help using either LM Studio (local) or Google Gemini (cloud).

## Setup

### Option 1: Local with LM Studio (default)
1. Make sure you have [LM Studio](https://lmstudio.ai/) installed with CLI tools
2. Find your LM Studio CLI path (usually `/Applications/LM Studio.app/Contents/Resources/lms` on macOS)
3. Add to your `wezterm.lua`:

```lua
local ai_helper = require("path.to.plugin")
local config = wezterm.config_builder()
ai_helper.apply_to_config(config, {
    lms_path = "/path/to/lms", -- type = "local" is the default
})
```

### Option 2: Cloud with Google Gemini
1. Get a Google API key from [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Add to your `wezterm.lua`:

```lua
local ai_helper = require("path.to.plugin")
local config = wezterm.config_builder()
ai_helper.apply_to_config(config, {
    type = "google",
    api_key = "your-google-api-key",
})
```

## Usage

Press `Cmd+I` (default keybinding), type your question, get help.

Example: "find large files" → AI explains and gives you the command.

## Configuration

All configuration options with their defaults:

```lua
ai_helper.apply_to_config(config, {
    -- Provider type: "local" for LM Studio, "google" for Gemini (default: "local")
    type = "local",
    
    -- For local LM Studio: Path to LM Studio CLI binary (required when type = "local")
    lms_path = "/path/to/lms",
    
    -- For Google Gemini: API key (required when type = "google")
    api_key = "your-google-api-key",
    
    -- AI model to use (default: "google/gemma-3-4b")
    model = "your-model-name",
    
    -- Keybinding configuration (default: Cmd+I)
    keybinding = { 
        key = "i", 
        mods = "SUPER" 
    },
    
    -- System prompt for the AI (default: CLI/macOS specialist prompt)
    system_prompt = "you are an assistant that specializes in CLI and macOS commands. "
        .. "you will be brief and to the point, if asked for commands print them in a way that's easy to copy, "
        .. "otherwise just answer the question. concatenate commands with && or || for ease of use. ",
    
    -- Request timeout in seconds (default: 30)
    timeout = 30,
    
    -- Show loading indicator while AI is thinking (default: true)
    show_loading = true,
})
```

### Configuration Details

- **`type`**: Choose between "local" (LM Studio) or "google" (Gemini)
- **`lms_path`** (required for local): Full path to the LM Studio CLI binary
- **`api_key`** (required for google): Your Google API key for Gemini
- **`model`**: The AI model name (for LM Studio) or Gemini model
- **`keybinding`**: Key combination to trigger the AI helper
  - `key`: The key to press
  - `mods`: Modifier keys (e.g., "SUPER", "CTRL", "ALT", "SHIFT")
- **`system_prompt`**: Instructions for the AI on how to behave and format responses
- **`timeout`**: How long to wait for AI response before timing out
- **`show_loading`**: Whether to display "🤖 AI is thinking..." while waiting

### Example Output

When you ask "what's my public IP?", you might see:

```
🤖 AI is thinking...
💬 Your public IP address is
➜  ai-helper.wezterm git:(master) ✗ curl ifconfig.me
```

The output consists of:
1. **Loading indicator**: Shows while the AI processes your request
2. **AI message**: Plain text explanation or context
3. **Command**: Ready-to-execute command that appears in your terminal

That's it.
