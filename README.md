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

```bash
# Install Elm (if not already installed)
npm install -g elm

# Run development server
elm reactor

# Open browser to http://localhost:8000/index.html
```

## What I Learned

- ✅ Elm Architecture (Model-Update-View)
- ✅ Immutability and pure functions
- ✅ Custom types and pattern matching
- ✅ Maybe and Result types for safe error handling
- ✅ Records and type aliases
- ✅ Commands for side effects
- ✅ Subscriptions for continuous events
- ✅ JSON decoders for type-safe parsing
- ✅ HTTP requests
- ✅ SVG rendering
- ✅ Multi-page routing
- ✅ Module organization
