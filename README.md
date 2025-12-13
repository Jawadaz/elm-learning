# Elm Learning Project

An interactive Elm learning project built to explore functional programming concepts.

## Features

### 🔢 Counter Page
- Interactive counter with increment/decrement
- Random number generation
- Dice rolling simulation
- Color randomization
- History tracking with filters
- Modal dialog for custom value input

### 🐙 GitHub Repo Viewer
- Fetch GitHub repositories by username
- Display repo details (stars, forks, language, created date)
- HTTP requests with JSON decoding
- Loading states and error handling

### 🎨 Canvas Animation
- Bouncing ball animation with 60 FPS
- Physics simulation with velocity and boundaries
- Keyboard controls (Arrow keys to move the ball)
- Real-time subscriptions

### ✅ Todo List Application
- Add, edit, and delete todos
- Inline editing (double-click, Enter/Escape keys)
- Filter by All/Active/Completed
- Clear completed todos
- Active todo counter
- LocalStorage persistence via JavaScript Ports

### 📊 D3 Chart (In Progress)
- Dynamic data point management
- Add/remove data points with labels and values
- Data preparation for D3.js visualization
- Port-based JavaScript interop (coming soon)

## Tech Stack

- **Elm 0.19.1** - Functional programming language for web apps
- **elm/http** - HTTP requests
- **elm/json** - JSON decoding
- **elm/time** - Time-based subscriptions
- **elm/random** - Random number generation
- **elm/browser** - Browser events and routing

## Architecture

Built using the Elm Architecture pattern:
- **Model** - Application state
- **Update** - State transitions
- **View** - HTML rendering
- **Subscriptions** - Side effects (time, keyboard)

Multi-page SPA with URL routing.

## Running Locally

### Option 1: Using elm reactor (for basic pages)
```bash
elm reactor
# Navigate to http://localhost:8000/src/Main.elm
```

### Option 2: Compile + Open HTML (required for ports/localStorage)
```bash
elm make src/Main.elm --output=elm.js
# Then open index.html in your browser
```

**Note**: Use Option 2 if you want to test the Todo page's localStorage persistence.

## What I Learned

- ✅ Elm Architecture (Model-Update-View)
- ✅ Immutability and pure functions
- ✅ Custom types and pattern matching
- ✅ Maybe and Result types for safe error handling
- ✅ Records and type aliases
- ✅ Commands for side effects
- ✅ Subscriptions for continuous events
- ✅ JSON encoding/decoding for type-safe data transfer
- ✅ HTTP requests with RemoteData pattern
- ✅ SVG rendering
- ✅ Multi-page routing with Browser.application
- ✅ Module organization and exposing
- ✅ JavaScript Ports for interop (outgoing/incoming)
- ✅ LocalStorage integration via ports
- ✅ Custom event decoders (keyboard events)
