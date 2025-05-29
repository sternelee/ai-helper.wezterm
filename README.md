# AI Helper for WezTerm

A simple WezTerm plugin that lets you ask an AI for CLI help using LM Studio.

## Setup

1. Make sure you have [LM Studio](https://lmstudio.ai/) installed with CLI tools
2. Add to your `wezterm.lua`:

```lua
local ai_helper = require("path.to.plugin")
local config = wezterm.config_builder()
ai_helper.apply_to_config(config)
```

## Usage

Press `Cmd+I`, type your question, get help.

Example: "find large files" → AI explains and gives you the command.

## Configuration

```lua
ai_helper.apply_to_config(config, {
    model = "your-model-name",
    lms_path = "/path/to/lms",
    keybinding = { key = "a", mods = "SUPER" },
})
```

That's it.
