# MK2 Dashboard - New Features

## 🔍 Search Bar

### Location
- Positioned below the top bar in the dashboard
- Centered, modern design with search icon

### Features
- **Real-time filtering**: Type to instantly filter features
- **Smart search**: Searches both feature names and descriptions
- **Clear button**: Appears when text is entered, click to clear
- **Visual feedback**: Border glows red when searching
- **Case-insensitive**: Works with any capitalization

### Usage
```
Type: "aimbot" → Shows only aimbot-related features
Type: "esp" → Shows all ESP features
Type: "smooth" → Shows smoothness sliders
Type: "" → Shows all features
```

### Examples
- Search "murderer" → Shows "Prioritize Murderer", "Show Murderer"
- Search "fov" → Shows "Aimbot FOV", "Show FOV Circle"
- Search "key" → Shows features with keybinds

---

## 🎮 Murders vs Sheriffs (MvS) Mode Support

### Auto-Detection
The dashboard automatically detects which game mode you're in:

#### Classic Mode
- 1 Murderer
- 1 Sheriff (if gun is picked up)
- Multiple Innocents

#### MvS Mode
- Multiple Murderers (2+)
- Multiple Sheriffs (2+)
- Team-based gameplay

### Game Mode Indicator
**Location**: First stat card in left panel

**Display**:
- **Classic Mode**: White text, "Classic Mode"
- **MvS Mode**: Orange text, "Murders vs Sheriffs"

### Real-time Updates
The system checks every 0.5 seconds and updates:
- Game mode detection
- Murderer count
- Sheriff count
- Target role display

### Murderer Status Card
**Classic Mode**: Shows single murderer name
```
Murderer Status
John_Doe
```

**MvS Mode**: Shows murderer count
```
Murderer Status
3 Murderers
```

### Target Display Enhancement
Now shows target's role in parentheses:
```
Current Target
Player123 (Murderer)
```

---

## 📊 Enhanced Stats Panel

### New Stats
1. **🎮 Game Mode** (NEW)
   - Displays current game mode
   - Color-coded for quick identification

2. **👥 Players Detected**
   - Total players in server (excluding you)

3. **🔪 Murderer Status**
   - Classic: Shows murderer name
   - MvS: Shows murderer count

4. **🎯 Current Target**
   - Shows locked target name + role
   - Updates in real-time

5. **📏 Target Distance**
   - Distance in studs to locked target
   - Updates continuously

---

## 🎯 Combat Features in MvS Mode

### Aimbot Behavior
- **PrioritizeMurderer enabled**: 
  - In Classic: Locks to THE murderer
  - In MvS: Locks to NEAREST murderer
- **PrioritizeMurderer disabled**: 
  - Locks to closest player regardless of role

### Camlock Behavior
- **PrioritizeMurderer enabled**:
  - Sheriffs will prioritize murderers
  - Murderers will target closest player
- **MvS Mode**: Handles multiple targets intelligently

### ESP in MvS Mode
- All murderers shown in RED
- All sheriffs shown in BLUE
- Innocents shown in GREEN
- Works seamlessly with multiple targets

---

## 🎨 UI Improvements

### Search Bar Design
- Modern gradient background
- Smooth animations
- Glow effect when active
- Clear button with hover effect

### Responsive Layout
- Dashboard height adjusted for search bar
- Content area properly sized
- Smooth scrolling maintained

### Visual Feedback
- Search border changes color
- Clear button appears/disappears
- Hover effects on all interactive elements

---

## 💡 Tips & Tricks

### Search Tips
1. Use partial words: "aim" finds "Aimbot", "Aimbot FOV", etc.
2. Search by category: "esp", "combat", "settings"
3. Search by action: "toggle", "slider", "enable"
4. Clear quickly with X button or delete all text

### MvS Mode Tips
1. Watch the Game Mode indicator to know which mode you're in
2. In MvS, multiple murderers means higher threat
3. Use "Prioritize Murderer" to focus on threats
4. ESP helps identify all murderers at once

### Performance
- Search is instant (no lag)
- Game mode detection is lightweight
- Stats update every 0.5s (optimized)

---

## 🔧 Technical Details

### Search Implementation
- Filters by name and description
- Case-insensitive matching
- Hides non-matching frames
- Maintains scroll position

### Game Mode Detection
```lua
if murdererCount > 1 or sheriffCount > 1 then
    GameMode = "MvS"
else
    GameMode = "Classic"
end
```

### Feature Registration
All toggles and sliders are automatically registered for search:
```lua
table.insert(FeatureFrames, {
    Frame = ToggleFrame,
    Name = name,
    Description = description
})
```

---

## 📝 Changelog

### v1.1.0 - Search & MvS Update
- ✅ Added search bar with real-time filtering
- ✅ Added Murders vs Sheriffs mode detection
- ✅ Added game mode indicator card
- ✅ Enhanced murderer status display
- ✅ Added role display to target info
- ✅ Improved stats panel layout
- ✅ Optimized UI spacing and responsiveness

---

## 🚀 Future Enhancements

Potential features for future updates:
- Search history
- Favorite features
- Custom keybind editor
- Team-based targeting options
- Advanced MvS strategies
- Stats tracking and analytics
