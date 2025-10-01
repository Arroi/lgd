# Mic Up - LinoriaLib Inspired UI

## 🎨 Complete UI Redesign

The Mic Up script has been completely redesigned with a LinoriaLib-inspired interface featuring modern design, enhanced voice bypass, admin commands, and fixed flying.

---

## ✨ New Features

### 🎨 **LinoriaLib-Style Interface**

**Modern Design Elements**:
- Clean, minimalist layout
- Dark theme with accent colors
- Smooth animations and transitions
- Proper padding and spacing
- Professional typography

**UI Components**:
- **Tabs**: Sidebar navigation with 5 tabs
- **Toggles**: Smooth sliding switches
- **Buttons**: Hover effects and feedback
- **Sliders**: Drag to adjust values
- **Dropdowns**: Click to expand options
- **Labels**: Information text
- **Sections**: Organized categories

**Theme Colors**:
- Background: Dark gray (#141419)
- Secondary: Lighter gray (#19191E)
- Accent: Blue (#6464FF)
- Text: White (#FFFFFF)
- Success: Green (#32C864)
- Error: Red (#FF5050)

### 🎤 **Enhanced Voice Chat Bypass**

**4 Bypass Methods**:

1. **__namecall Hook**:
   - Hooks `IsVoiceEnabledForUserIdAsync`
   - Hooks `GetVoiceState`
   - Hooks `GetVoiceEnabled`
   - Hooks `IsVoiceEnabled`
   - Returns true/Talking for all

2. **__index Hook**:
   - Hooks `VoiceEnabled` property
   - Hooks `VoiceState` property
   - Spoofs voice status

3. **VoiceChatService Spoof**:
   - Sets `EnableDefaultVoice = true`
   - Direct service manipulation

4. **TextChatService Hook**:
   - Sets `ChatVersion` to TextChatService
   - Ensures compatibility

**Why It Works Better**:
- Multiple bypass layers
- Hooks both metamethods
- Spoofs service properties
- More reliable than single method

### ✈️ **Fixed Flying System**

**Improvements**:
- Added `BodyGyro.D = 500` (damping)
- Added `BodyVelocity.P = 1250` (power)
- Smooth deceleration when no input
- Better rotation handling
- No more bouncing or jittering
- Stable hovering

**Controls**:
- **W/A/S/D** - Directional movement
- **Space** - Fly up
- **Shift** - Fly down
- **F** - Toggle flying

### 👑 **Admin Commands**

**New Admin Tab**:
- Player selection dropdown
- Kick player
- Kill player
- Teleport to player
- Bring player to you

**How to Use**:
1. Go to Admin tab
2. Select player from dropdown
3. Click desired action
4. Confirmation notification

**Commands Available**:
- **Kick**: Remove player from game
- **Kill**: Set player health to 0
- **Teleport**: Go to player location
- **Bring**: Bring player to you

---

## 📋 Tab Overview

### **1. Home Tab**
- Welcome message
- Quick start buttons
- Flying toggle
- Voice bypass button

### **2. Voice Tab**
- Voice bypass toggle
- Status information
- Warning labels

### **3. Movement Tab**
**Sections**:
- Flying (toggle + speed slider)
- Teleportation (TP tool button)
- Other Movement (spin, sit, baseplate)

**Features**:
- Flying toggle with keybind indicator
- Speed slider (10-200)
- TP tool button
- Spin toggle
- Sit toggle
- Baseplate toggle

### **4. Admin Tab** ⭐ NEW
**Player Management**:
- Player selection dropdown
- Kick button
- Kill button
- Teleport to player
- Bring player

**Requirements**:
- Select player first
- Some commands need admin/owner
- Works in most games

### **5. Settings Tab**
- Reset all settings button
- Keybind reference
- Version information

---

## 🎮 Controls

### **Keybinds**
- **F** - Toggle Flying
- **T** - Get TP Tool

### **GUI Controls**
- **Drag** - Click top bar to move window
- **Close** - Red X button to close
- **Tabs** - Click sidebar buttons to switch

---

## 🚀 Installation

### **Load Script**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/lgd/refs/heads/main/mic%20up/MicUp_LinoriaUI.lua"))()
```

**No Password Required** - Instant load!

---

## 🎨 UI Features

### **Padding System**
- Main frame: 8px padding all sides
- Tab container: 6px padding
- Content area: 6px padding
- Proper spacing between elements

### **Animations**
- Smooth 0.2s transitions
- Hover effects on all buttons
- Toggle switch animations
- Dropdown expand/collapse
- Notification slide-in/out

### **Notifications**
- Bottom-right positioning
- Auto-dismiss after 3 seconds
- Color-coded by type
- Smooth animations
- Multiple notifications stack

### **Responsive Design**
- Scrollable content areas
- Auto-sizing canvas
- Proper element spacing
- Clean organization

---

## 🔧 Technical Details

### **Voice Bypass Implementation**

**Method 1 - __namecall Hook**:
```lua
hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "IsVoiceEnabledForUserIdAsync" then
        return true
    end
    return oldNamecall(self, ...)
end)
```

**Method 2 - __index Hook**:
```lua
hookmetamethod(game, "__index", function(self, key)
    if key == "VoiceEnabled" then
        return true
    end
    return oldIndex(self, key)
end)
```

### **Flying System**

**BodyGyro Configuration**:
```lua
MaxTorque = Vector3.new(9e9, 9e9, 9e9)
P = 9e4  -- Power
D = 500  -- Damping (prevents oscillation)
```

**BodyVelocity Configuration**:
```lua
MaxForce = Vector3.new(9e9, 9e9, 9e9)
P = 1250  -- Power
Velocity = MoveDirection.Unit * Speed
```

**Deceleration**:
```lua
if no input then
    Velocity = Velocity * 0.9  -- 10% slowdown per frame
end
```

### **Admin Commands**

**Kick Implementation**:
```lua
pcall(function()
    selectedPlayer:Kick("Kicked by Mic Up")
end)
```

**Kill Implementation**:
```lua
pcall(function()
    selectedPlayer.Character.Humanoid.Health = 0
end)
```

**Teleport Implementation**:
```lua
pcall(function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = 
        selectedPlayer.Character.HumanoidRootPart.CFrame
end)
```

---

## 💡 Usage Tips

### **Voice Bypass**
1. Enable toggle in Voice tab
2. Wait 2-3 seconds
3. Check if voice works
4. If not, try rejoining

### **Flying**
1. Press F or toggle in Movement tab
2. Use WASD + Space/Shift
3. Adjust speed with slider
4. Smooth and stable flight

### **Admin Commands**
1. Go to Admin tab
2. Select player from dropdown
3. Click desired action
4. Works best with FE games

### **UI Navigation**
1. Click tabs to switch pages
2. Drag top bar to move window
3. All settings auto-save
4. Notifications show confirmations

---

## 🎯 Comparison: Old vs New

### **Old UI**
- Basic multi-page layout
- Simple toggles
- Limited features
- No admin commands
- Basic voice bypass

### **New LinoriaLib UI** ⭐
- Professional LinoriaLib design
- Modern components
- Enhanced voice bypass (4 methods)
- Admin commands tab
- Fixed flying system
- Better padding and spacing
- Smooth animations
- Color-coded notifications
- Dropdown menus
- Section headers

---

## 📊 Feature Matrix

| Feature | Old UI | LinoriaLib UI |
|---------|--------|---------------|
| Design | Basic | Professional |
| Padding | Minimal | Proper (8px) |
| Voice Bypass | 2 methods | 4 methods |
| Flying | Buggy | Fixed & Smooth |
| Admin Commands | ❌ | ✅ |
| Dropdowns | ❌ | ✅ |
| Sections | ❌ | ✅ |
| Animations | Basic | Smooth |
| Notifications | Simple | Color-coded |
| Keybinds | F, T | F, T |

---

## ⚠️ Known Limitations

### **Voice Bypass**
- May not work in all games
- Some games have server-side checks
- Requires executor with metamethod hooks
- May need rejoin to fully activate

### **Admin Commands**
- Kick: Requires admin/owner
- Kill: Works in FE games
- Teleport: Works everywhere
- Bring: May not work in some games

### **Flying**
- Some games have anti-fly
- May be detected in competitive games
- Use at your own risk

---

## 🔄 Migration Guide

### **From Old Mic Up to LinoriaLib UI**

**What's Different**:
1. New UI design (LinoriaLib style)
2. Better voice bypass
3. Fixed flying
4. Admin commands added
5. Proper padding

**What's the Same**:
- All original features
- Same keybinds (F, T)
- Same core functionality
- Compatible with all games

**How to Switch**:
1. Load new LinoriaLib script
2. All settings reset to default
3. Configure as needed
4. Enjoy improved UI!

---

## 📝 Changelog

### **V3.0 - LinoriaLib UI**
- ✅ Complete UI redesign (LinoriaLib style)
- ✅ Enhanced voice bypass (4 methods)
- ✅ Fixed flying system
- ✅ Added admin commands
- ✅ Added proper padding (8px)
- ✅ Added dropdown menus
- ✅ Added section headers
- ✅ Improved animations
- ✅ Color-coded notifications
- ✅ Better organization

### **V2.0 - Multi-Page**
- Multi-page dashboard
- Basic toggles and sliders
- Simple voice bypass
- Basic flying

### **V1.0 - Original**
- Single page UI
- Basic features
- Simple design

---

## 🎯 Quick Start

### **3 Steps to Get Started**

**Step 1**: Load Script
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/lgd/refs/heads/main/mic%20up/MicUp_LinoriaUI.lua"))()
```

**Step 2**: Enable Features
- Go to Voice tab → Enable voice bypass
- Go to Movement tab → Toggle flying
- Press F to start flying

**Step 3**: Explore
- Check out Admin tab for player management
- Adjust flying speed in Movement tab
- Use Settings tab to reset if needed

---

**Enjoy the new LinoriaLib UI! 🎤✨**
