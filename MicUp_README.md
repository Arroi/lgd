# Mic Up - Voice Chat Bypass & Movement Hub

**Educational White-Hat Hacking Demonstration**

## 🎤 Overview

Mic Up is a comprehensive Roblox script featuring voice chat bypass capabilities and advanced movement tools, packaged in a modern multi-page dashboard interface.

---

## ✨ Features

### 🔊 Voice Chat Bypass
- **Bypass Suspension**: Attempts to bypass voice chat restrictions
- **Multiple Methods**: Uses hooking and spoofing techniques
- **Toggle Control**: Easy enable/disable from dashboard or command bar

### 🚀 Movement Features

#### Flying
- **Keybind**: Press `F` to toggle
- **WASD Controls**: Navigate in any direction
- **Space/Shift**: Move up/down
- **Adjustable Speed**: Slider in settings (0-200)

#### TP Tool
- **Keybind**: Press `T` to toggle
- **Click to Teleport**: Click anywhere to teleport instantly
- **Equip/Unequip**: Toggle on/off as needed

#### Follow Player
- **Auto Follow**: Automatically follow any player
- **Distance Control**: Maintains set distance (default: 5 studs)
- **Command**: `follow [playername]`

#### Orbit Player
- **Circular Orbit**: Orbit around a target player
- **Adjustable Radius**: Default 10 studs
- **Adjustable Speed**: Smooth orbital movement
- **Command**: `orbit [playername]`

#### Spin
- **Character Spin**: Rotate your character continuously
- **Adjustable Speed**: Control rotation speed
- **Toggle**: Enable/disable anytime

#### Sit
- **Force Sit**: Make your character sit
- **Toggle**: Quick enable/disable

#### Baseplate
- **Personal Platform**: Creates a baseplate under you
- **Follows You**: Moves with your character
- **Customizable**: Size, color, transparency settings

---

## 🎨 Dashboard Interface

### Password Gateway
- **Secure Access**: Password: `MicUp2025`
- **Animated Entry**: Smooth blur and animation effects
- **Error Feedback**: Shake animation on wrong password

### Multi-Page Layout

#### 1. 🏠 Home Page
- Welcome message
- Quick start buttons
- Most-used features

#### 2. 🎤 Voice Page
- Voice bypass toggle
- Status information
- Configuration options

#### 3. 🚀 Movement Page
- Flying toggle
- Spin toggle
- Sit toggle
- Baseplate toggle
- TP Tool button

#### 4. 👥 Players Page
- Live player list
- Follow button per player
- Orbit button per player
- TP to player button
- Refresh list button
- Stop all tracking button

#### 5. ⚙️ Settings Page
- Flying speed slider
- Command list
- Reset all features

### Command Bar
- **Location**: Below top bar
- **Prefix**: `>` symbol
- **Auto-complete**: Smart command processing
- **History**: Previous commands remembered

### Notifications
- **Position**: Bottom-right corner
- **Auto-dismiss**: Configurable duration
- **Color-coded**: Success (green), error (red), info (blue)
- **Animated**: Smooth slide-in/out

---

## 🎮 Controls & Keybinds

### Keybinds
- **F**: Toggle Flying
- **T**: Toggle TP Tool
- **WASD**: Movement (when flying)
- **Space**: Move up (when flying)
- **Left Shift**: Move down (when flying)

### GUI Controls
- **Minimize Button**: `—` (Hide/show dashboard)
- **Close Button**: `✕` (Close script)
- **Draggable**: Click and drag top bar to move

---

## 💻 Commands

### Command Bar Usage
Type commands in the command bar (below top bar) and press Enter.

### Available Commands

#### Movement
```
fly                    - Toggle flying
tp / tptool           - Toggle TP tool
spin                  - Toggle spin
sit                   - Toggle sit
baseplate / bp        - Toggle baseplate
```

#### Player Interaction
```
follow [player]       - Follow a player (partial name works)
orbit [player]        - Orbit around a player
follow                - Stop following (no player name)
orbit                 - Stop orbiting (no player name)
```

#### Voice & Utility
```
voice                 - Toggle voice bypass
help                  - Show command list
```

### Command Examples
```
> fly
> follow john
> orbit player123
> tp
> baseplate
> voice
```

---

## 📋 Installation

### Method 1: Direct Load
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/lgd/refs/heads/main/MicUp_Dashboard.lua"))()
```

### Method 2: Manual Load
1. Copy `MicUp_Core.lua` content
2. Copy `MicUp_Dashboard.lua` content
3. Execute `MicUp_Dashboard.lua` in your executor

---

## 🔧 Configuration

### Default Settings
```lua
Password = "MicUp2025"
Flying Speed = 50
Follow Distance = 5
Orbit Radius = 10
Orbit Speed = 2
Spin Speed = 5
Baseplate Size = 50
```

### Customization
Edit the `Config` table in `MicUp_Core.lua`:

```lua
Config = {
    Password = "YourPassword",
    Flying = {
        Speed = 75,  -- Change flying speed
        Keybind = Enum.KeyCode.F
    },
    Follow = {
        Distance = 10  -- Change follow distance
    },
    Orbit = {
        Radius = 15,  -- Change orbit radius
        Speed = 3     -- Change orbit speed
    }
}
```

---

## 🎯 Usage Guide

### Getting Started
1. Execute the script
2. Enter password: `MicUp2025`
3. Dashboard opens automatically

### Using Flying
1. Click "Flying" toggle on Movement page, OR
2. Press `F` key, OR
3. Type `fly` in command bar
4. Use WASD + Space/Shift to navigate

### Following a Player
1. Go to Players page
2. Click "Follow" next to player name, OR
3. Type `follow playername` in command bar
4. To stop: Click "Stop Follow/Orbit" or type `follow`

### Using TP Tool
1. Click "Get TP Tool" on Movement page, OR
2. Press `T` key, OR
3. Type `tp` in command bar
4. Click anywhere to teleport

### Voice Bypass
1. Go to Voice page
2. Toggle "Voice Chat Bypass", OR
3. Type `voice` in command bar
4. Check status message

---

## 🎨 UI Features

### Modern Design
- **Gradient Backgrounds**: Blue theme
- **Smooth Animations**: All transitions animated
- **Rounded Corners**: Modern aesthetic
- **Glow Effects**: Border highlights

### Interactive Elements
- **Hover Effects**: All buttons respond to hover
- **Toggle Switches**: Smooth sliding indicators
- **Sliders**: Drag to adjust values
- **Scrollable Pages**: Handle any amount of content

### Responsive Layout
- **Sidebar Navigation**: Easy page switching
- **Scrollable Content**: Never cut off
- **Draggable Window**: Position anywhere
- **Minimize/Close**: Full control

---

## 🔍 Troubleshooting

### Voice Bypass Not Working
- Voice bypass effectiveness varies by game
- Some games have stronger protections
- Try toggling off and on again
- Check if you're actually suspended

### Flying Not Working
1. Make sure toggle is enabled
2. Check if game has anti-fly
3. Try adjusting speed
4. Respawn and try again

### TP Tool Not Appearing
1. Check your backpack
2. Try toggling off and on
3. Use command bar: `tp`
4. Check if game allows tools

### Follow/Orbit Not Working
1. Make sure player exists
2. Check if player has character loaded
3. Try using full player name
4. Refresh player list

### GUI Not Showing
1. Check if you entered correct password
2. Look for minimize button (GUI might be hidden)
3. Re-execute script
4. Check executor compatibility

---

## 📊 Technical Details

### Architecture
- **Modular Design**: Separate core and GUI
- **Event-Driven**: Efficient connection management
- **Memory Safe**: Proper cleanup on disconnect
- **Optimized**: Minimal performance impact

### Voice Bypass Methods
1. **Metamethod Hooking**: Hooks `__namecall`
2. **Function Spoofing**: Returns fake enabled state
3. **State Manipulation**: Modifies voice state enum

### Movement Systems
- **BodyVelocity**: Flying implementation
- **BodyGyro**: Rotation control
- **CFrame Manipulation**: Teleportation
- **Heartbeat Connection**: Smooth updates

### GUI Framework
- **Custom Built**: No external libraries
- **TweenService**: Smooth animations
- **UIListLayout**: Auto-sizing pages
- **ScrollingFrame**: Dynamic content

---

## ⚠️ Warnings

### Use Responsibly
- This is an educational demonstration
- Do not use to harass other players
- Respect game rules and ToS
- May result in account action

### Known Limitations
- Voice bypass may not work in all games
- Anti-cheat may detect movement features
- Some games block tool creation
- Effectiveness varies by executor

### Performance
- Minimal FPS impact
- Efficient memory usage
- Optimized rendering
- Clean disconnection

---

## 🎓 Educational Value

### Learning Concepts
- **Metamethod Hooking**: Advanced Lua technique
- **GUI Development**: Creating interfaces
- **Event Handling**: Managing connections
- **State Management**: Tracking configurations
- **Animation**: Smooth transitions
- **User Input**: Keyboard and mouse handling

### White-Hat Techniques
- Understanding game security
- Identifying vulnerabilities
- Responsible disclosure
- Ethical testing

---

## 📝 Changelog

### v1.0.0 - Initial Release
- ✅ Voice chat bypass system
- ✅ Flying with WASD controls
- ✅ TP Tool implementation
- ✅ Follow player feature
- ✅ Orbit player feature
- ✅ Spin character feature
- ✅ Sit toggle
- ✅ Baseplate creation
- ✅ Multi-page dashboard
- ✅ Command bar system
- ✅ Password gateway
- ✅ Notification system
- ✅ Draggable GUI
- ✅ Toggle minimize
- ✅ Settings page with sliders
- ✅ Player list with actions

---

## 🚀 Future Features

Potential additions:
- Custom keybind editor
- Saved configurations
- Multiple baseplate styles
- Advanced orbit patterns
- Speed presets
- Favorite players list
- Command aliases
- Macro system
- Theme customization

---

## 💡 Tips & Tricks

### Pro Tips
1. **Use Command Bar**: Faster than clicking buttons
2. **Adjust Flying Speed**: Lower for precision, higher for speed
3. **Minimize GUI**: Use `—` button when not needed
4. **Partial Names**: `follow john` works for "john123"
5. **Quick Reset**: Settings page has reset all button

### Shortcuts
- Type `help` to see all commands
- Press `F` for instant flying
- Press `T` for instant TP tool
- Use arrow keys in command bar for history

### Best Practices
- Test features in private servers first
- Don't spam teleportation
- Be respectful to other players
- Use voice bypass ethically

---

## 🔐 Security

### Password Protection
- Default: `MicUp2025`
- Change in `Config.Password`
- Prevents unauthorized access
- Animated feedback

### Safe Practices
- Don't share your modified version
- Keep password secure
- Use in appropriate environments
- Understand the risks

---

## 📞 Support

### Common Issues
Check troubleshooting section first

### Script Not Loading
1. Verify executor compatibility
2. Check internet connection
3. Try alternative load method
4. Update executor

### Features Not Working
1. Check if feature is enabled
2. Look for error notifications
3. Try resetting all features
4. Respawn character

---

## 🎬 Credits

- **Developer**: MicUp Development Team
- **Language**: LUAU (Roblox Lua)
- **Framework**: Custom GUI System
- **Inspiration**: Community feedback

---

## ⚖️ Disclaimer

This script is created for **educational purposes only** to demonstrate:
- LUAU programming techniques
- GUI development in Roblox
- Game security concepts
- White-hat hacking methodologies

**DO NOT** use this script to:
- Violate Roblox Terms of Service
- Harass or grief other players
- Gain unfair advantages
- Disrupt game experiences

The creator is not responsible for any consequences resulting from misuse of this script.

---

## 📄 License

Educational use only. Not for commercial distribution.

---

**Remember**: With great power comes great responsibility. Use ethically!
