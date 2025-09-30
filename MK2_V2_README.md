# MK2 V2 - Murder Mystery 2 Advanced Script

## 🎯 Complete Redesign

The MK2 script has been completely redesigned with a modern multi-page dashboard similar to Mic Up, featuring improved aimbot accuracy for high ping and automatic coin collection.

---

## ✨ New Features

### 🎨 **Modern Multi-Page Dashboard**
- **6 Pages**: Home, Aimbot, Combat, ESP, Coins, Settings
- **Sidebar Navigation**: Easy page switching
- **Smooth Animations**: Professional UI transitions
- **Draggable Window**: Click and drag top bar
- **Toggle Minimize**: Hide/show dashboard
- **Gradient Theme**: Pink/red color scheme

### 🎯 **Enhanced Aimbot System**

#### **Configurable Target Parts**
Choose which body part to aim at:
- **Head** (default)
- **UpperTorso**
- **LowerTorso**
- **HumanoidRootPart**

#### **High Ping Compensation (200-300ms)**
- **Ping Compensation Toggle**: Optimized for 200-300ms latency
- **Prediction Multiplier**: 0.165 default (adjustable)
- **Movement Prediction**: Calculates target velocity
- **Always Lands**: Predicts where target will be

#### **Advanced Settings**
- **FOV Size**: 50-500 pixels
- **Smoothness**: 0.01-1 (lower = faster)
- **Visibility Check**: Only target visible players
- **Prioritize Murderer**: Auto-target murderers first
- **Show FOV Circle**: Visual field of view

### 🪙 **Coin Collection System**

#### **Auto-Collect Features**
- **Automatic Detection**: Finds coins in ReplicatedStorage
- **Instant Collection**: Teleports to each coin
- **Max Limit**: Stops at 40 coins (configurable)
- **Live Counter**: Real-time coin count display
- **Speed Control**: Adjustable delay between coins

#### **Configuration**
- **Max Coins**: 1-100 (default: 40)
- **Collection Speed**: 0.1-2 seconds delay
- **Auto-Stop**: Stops when limit reached
- **Reset Counter**: Manual reset option

### 🎮 **Combat Features**

#### **Camlock**
- **Keybind**: Press Q to lock/unlock
- **Movement Prediction**: Tracks moving targets
- **Smoothness Control**: Adjustable tracking speed
- **Prioritize Murderer**: Lock to murderers first
- **Manual Unlock**: Button to release target

### 👁️ **ESP System**
- **Skeleton ESP**: Player bone structure
- **Box ESP**: Bounding boxes
- **Tracer ESP**: Lines to players
- **Role Filters**: Show/hide murderer, sheriff, innocent
- **Thickness Control**: Adjustable line width
- **Color Coded**: Red (murderer), Blue (sheriff), Green (innocent)

---

## 📋 Dashboard Pages

### **1. Home Page**
- Welcome message
- Quick start buttons
- Feature overview
- One-click toggles for main features

### **2. Aimbot Page**
- Aimbot toggle
- Target part dropdown
- FOV size slider
- Smoothness slider
- Prediction multiplier
- Visibility check
- Prioritize murderer
- Show FOV circle
- Ping compensation

### **3. Combat Page**
- Camlock toggle
- Movement prediction
- Prioritize murderer
- Smoothness slider
- Prediction strength
- Unlock target button

### **4. ESP Page**
- ESP master toggle
- Skeleton toggle
- Box toggle
- Tracer toggle
- Role filters (murderer/sheriff/innocent)
- Thickness slider

### **5. Coins Page**
- Live coin counter
- Auto-collect toggle
- Max coins slider
- Collection speed slider
- Reset counter button
- Information panel

### **6. Settings Page**
- Keybind reference
- Reset all settings
- About information
- Performance info

---

## 🎮 Controls

### **Keybinds**
- **E** - Toggle Aimbot
- **Q** - Toggle Camlock (lock/unlock target)

### **GUI Controls**
- **Minimize** (`—`) - Hide/show dashboard
- **Close** (`✕`) - Close script
- **Drag** - Click and drag top bar

---

## 🚀 Installation

### **Load Script**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/lgd/refs/heads/main/MK2_GUI_Dashboard_V2.lua"))()
```

### **Password**
```
MK2_2025
```

---

## 🎯 Aimbot Configuration Guide

### **For 200-300ms Ping**

**Recommended Settings**:
- **Target Part**: Head
- **FOV**: 150-200
- **Smoothness**: 0.03-0.05
- **Ping Compensation**: ON
- **Prediction Multiplier**: 0.165-0.20
- **Visibility Check**: ON

**How It Works**:
1. Aimbot detects target within FOV
2. Calculates target velocity
3. Predicts position based on ping (200-300ms)
4. Aims at predicted location
5. Smoothly tracks target movement

**Tips**:
- Higher ping = increase prediction multiplier
- Moving targets = increase prediction
- Stationary targets = decrease prediction
- Adjust smoothness for natural aim

---

## 🪙 Coin Collection Guide

### **How to Use**

1. **Navigate to Coins Page**
2. **Set Max Coins** (default: 40)
3. **Adjust Speed** (default: 0.5s)
4. **Toggle Auto Collect**
5. **Watch Live Counter**

### **How It Works**
```lua
1. Checks ReplicatedStorage.Coins folder
2. Finds all coin objects
3. Teleports to each coin
4. Waits specified delay
5. Increments counter
6. Stops at max limit
```

### **Configuration**
- **Max Coins**: 1-100
  - Default: 40
  - Recommended: 40 (game limit)
  
- **Collection Speed**: 0.1-2 seconds
  - Fast: 0.1-0.3s (may be detected)
  - Medium: 0.5s (recommended)
  - Slow: 1-2s (safer)

### **Safety Tips**
- Use medium speed (0.5s)
- Don't exceed 40 coins per round
- Toggle off when done
- Reset counter between rounds

---

## 🎨 UI Features

### **Modern Design**
- Gradient backgrounds (pink/red theme)
- Smooth animations on all interactions
- Rounded corners and borders
- Glow effects on active elements
- Professional typography

### **Interactive Elements**
- **Toggles**: Smooth sliding switches
- **Sliders**: Drag to adjust values
- **Dropdowns**: Click to expand options
- **Buttons**: Hover effects and feedback
- **Notifications**: Auto-dismiss alerts

### **Responsive Layout**
- Scrollable pages
- Auto-sizing content
- Proper spacing and padding
- Clean organization

---

## 📊 Technical Details

### **Aimbot Improvements**

**Ping Compensation Algorithm**:
```lua
-- Calculate predicted position
local velocity = target.HumanoidRootPart.AssemblyLinearVelocity
local predictedPos = targetPos + (velocity * predictionMultiplier)

-- predictionMultiplier = 0.165 for 200-300ms
-- Adjusts based on target movement speed
```

**Target Part Selection**:
- Dropdown menu with 4 options
- Instant switching
- Saved preference
- Works with all body parts

**Smoothness**:
- Range: 0.01 - 1.0
- Lower = faster aim
- Higher = smoother aim
- Default: 0.05 (very responsive)

### **Coin Collection**

**Detection Method**:
```lua
ReplicatedStorage:FindFirstChild("Coins")
-- Finds all children in Coins folder
-- Supports Model and Part instances
```

**Collection Process**:
1. Teleport to coin position
2. Wait for collection delay
3. Increment counter
4. Check if max reached
5. Continue or stop

**Safety Features**:
- Max limit enforcement
- Auto-stop at limit
- Manual stop option
- Counter reset

---

## 💡 Tips & Tricks

### **Aimbot Tips**
1. **High Ping**: Increase prediction multiplier
2. **Fast Targets**: Increase FOV and prediction
3. **Accuracy**: Lower smoothness for instant lock
4. **Natural Look**: Higher smoothness (0.1-0.2)
5. **Murderer Priority**: Enable for sheriff gameplay

### **Camlock Tips**
1. **Press Q**: Locks to closest player
2. **Press Q Again**: Unlocks target
3. **Movement Prediction**: Enable for moving targets
4. **Smoothness**: Adjust for camera feel

### **ESP Tips**
1. **Skeleton Only**: Best performance
2. **All Features**: Most information
3. **Role Filters**: Hide innocents, show threats
4. **Thickness**: Increase for visibility

### **Coin Tips**
1. **Start Early**: Collect at round start
2. **Speed**: 0.5s is optimal
3. **Limit**: Stop at 40 coins
4. **Reset**: Reset counter each round

---

## 🔧 Troubleshooting

### **Aimbot Not Working**
- Check if enabled
- Verify FOV is large enough
- Disable visibility check if needed
- Increase prediction for high ping

### **Coins Not Collecting**
- Check ReplicatedStorage for Coins folder
- Verify coins are spawned
- Increase collection speed
- Check if max limit reached

### **ESP Not Showing**
- Enable ESP master toggle
- Check role filters
- Verify players are in game
- Increase thickness

### **High Ping Issues**
- Enable ping compensation
- Increase prediction multiplier (0.20-0.25)
- Lower smoothness (0.03-0.05)
- Increase FOV

---

## 📝 Changelog

### **V2.0 - Complete Redesign**
- ✅ Multi-page dashboard (6 pages)
- ✅ Configurable aimbot target parts
- ✅ Ping compensation (200-300ms)
- ✅ Prediction multiplier slider
- ✅ Coin collection system
- ✅ Live coin counter
- ✅ Dropdown menus
- ✅ Modern UI design
- ✅ Improved animations
- ✅ Better organization

### **V1.0 - Original**
- Basic aimbot
- ESP features
- Camlock
- Simple GUI

---

## ⚠️ Disclaimer

**Educational purposes only**. This script demonstrates:
- Advanced LUAU programming
- GUI development
- Game mechanics understanding
- White-hat hacking concepts

**Do not use to**:
- Violate Roblox ToS
- Harass other players
- Gain unfair advantages
- Disrupt gameplay

---

## 🎯 Quick Start Guide

### **3 Steps to Get Started**

**Step 1**: Load & Login
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/lgd/refs/heads/main/MK2_GUI_Dashboard_V2.lua"))()
```
Password: `MK2_2025`

**Step 2**: Configure Aimbot
- Go to Aimbot page
- Select target part (Head recommended)
- Enable ping compensation
- Set FOV to 150-200
- Toggle aimbot ON

**Step 3**: Start Features
- Press E to toggle aimbot
- Press Q to lock target
- Go to Coins page to collect
- Navigate pages for more features

---

**Enjoy MK2 V2! 🎯**
