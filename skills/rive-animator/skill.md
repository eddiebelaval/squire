---
name: Rive Animator
slug: rive-animator
description: Create and integrate interactive, state-based animations with Rive. Build animations that respond to user input, scroll position, and application state with tiny file sizes.
category: animation
complexity: advanced
version: "1.0.0"
author: "ID8Labs"
triggers:
  - "rive"
  - "interactive animation"
  - "state machine animation"
  - "animated button"
  - "animated icon"
  - "character animation"
  - "input-driven animation"
tags:
  - rive
  - animation
  - interactive
  - state-machine
  - micro-interactions
---

# Rive Animator

Create sophisticated, interactive animations with Rive - a modern animation tool with built-in state machines. Unlike Lottie, Rive animations can respond to user input in real-time, making them perfect for interactive UI elements, games, and complex animated experiences.

## Why Rive?

- **State machines**: Built-in logic for interactive animations
- **Tiny files**: Often smaller than Lottie
- **Real-time**: Responds to inputs instantly
- **Blend states**: Smooth transitions between animations
- **Web-native**: Optimized for web performance

## Core Workflows

### Workflow 1: Setup Rive in React/Next.js

**Installation:**
```bash
npm install @rive-app/react-canvas
# or for WebGL (better performance):
npm install @rive-app/react-webgl
```

**Basic Usage:**
```tsx
'use client';

import { useRive } from '@rive-app/react-canvas';

export function RiveAnimation() {
  const { RiveComponent } = useRive({
    src: '/animations/example.riv',
    autoplay: true,
  });

  return <RiveComponent style={{ width: 500, height: 500 }} />;
}
```

**With State Machine:**
```tsx
'use client';

import { useRive, useStateMachineInput } from '@rive-app/react-canvas';

export function InteractiveRive() {
  const { rive, RiveComponent } = useRive({
    src: '/animations/button.riv',
    stateMachines: 'ButtonState',
    autoplay: true,
  });

  // Get input from state machine
  const hoverInput = useStateMachineInput(rive, 'ButtonState', 'isHovered');
  const pressInput = useStateMachineInput(rive, 'ButtonState', 'isPressed');

  return (
    <RiveComponent
      style={{ width: 200, height: 60 }}
      onMouseEnter={() => hoverInput && (hoverInput.value = true)}
      onMouseLeave={() => hoverInput && (hoverInput.value = false)}
      onMouseDown={() => pressInput && (pressInput.value = true)}
      onMouseUp={() => pressInput && (pressInput.value = false)}
    />
  );
}
```

### Workflow 2: State Machine Inputs

**Boolean Input (Toggle):**
```tsx
const toggleInput = useStateMachineInput(rive, 'StateMachine', 'isActive');

// Toggle on click
<button onClick={() => toggleInput && (toggleInput.value = !toggleInput.value)}>
  Toggle
</button>
```

**Number Input (Range):**
```tsx
const progressInput = useStateMachineInput(rive, 'StateMachine', 'progress');

// Update from slider
<input
  type="range"
  min={0}
  max={100}
  onChange={(e) => progressInput && (progressInput.value = Number(e.target.value))}
/>
```

**Trigger Input (One-shot):**
```tsx
const clickTrigger = useStateMachineInput(rive, 'StateMachine', 'onClick');

// Fire trigger
<button onClick={() => clickTrigger?.fire()}>
  Trigger Animation
</button>
```

### Workflow 3: Scroll-Driven Animation

```tsx
'use client';

import { useEffect, useRef } from 'react';
import { useRive, useStateMachineInput } from '@rive-app/react-canvas';

export function ScrollRive() {
  const containerRef = useRef<HTMLDivElement>(null);

  const { rive, RiveComponent } = useRive({
    src: '/animations/scroll-reveal.riv',
    stateMachines: 'ScrollState',
    autoplay: true,
  });

  const scrollInput = useStateMachineInput(rive, 'ScrollState', 'scrollProgress');

  useEffect(() => {
    function handleScroll() {
      if (!containerRef.current || !scrollInput) return;

      const rect = containerRef.current.getBoundingClientRect();
      const progress = Math.max(0, Math.min(100,
        ((window.innerHeight - rect.top) / (window.innerHeight + rect.height)) * 100
      ));

      scrollInput.value = progress;
    }

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [scrollInput]);

  return (
    <div ref={containerRef} className="h-[200vh]">
      <div className="sticky top-0 h-screen flex items-center justify-center">
        <RiveComponent style={{ width: 600, height: 600 }} />
      </div>
    </div>
  );
}
```

### Workflow 4: Creating Animations in Rive Editor

**Access Rive Editor:**
1. Go to https://rive.app
2. Create free account
3. Start new file

**Building a Button Animation:**
1. **Artboard Setup**
   - Create artboard (200x60 px)
   - Add rectangle with rounded corners
   - Add text layer for label
   - Add icon if needed

2. **Create States**
   - Idle: Default appearance
   - Hover: Slight scale up, color change
   - Pressed: Scale down, darker color
   - Disabled: Grayed out

3. **State Machine**
   - Add state machine named "ButtonState"
   - Create boolean inputs: isHovered, isPressed, isDisabled
   - Create transitions between states
   - Set conditions: isHovered → Hover state

4. **Export**
   - File > Export > .riv file
   - Place in /public/animations/

**Building a Progress Animation:**
1. Create circular or linear progress shape
2. Animate from 0% to 100%
3. Create number input "progress" (0-100)
4. Bind animation timeline to input
5. Export

### Workflow 5: Responsive Rive

```tsx
'use client';

import { useRive, Layout, Fit, Alignment } from '@rive-app/react-canvas';

export function ResponsiveRive() {
  const { RiveComponent } = useRive({
    src: '/animations/hero.riv',
    autoplay: true,
    layout: new Layout({
      fit: Fit.Cover,
      alignment: Alignment.Center,
    }),
  });

  return (
    <div className="w-full h-[60vh] md:h-[80vh]">
      <RiveComponent />
    </div>
  );
}
```

## State Machine Design Patterns

### Button Pattern
```
Inputs:
  - isHovered (boolean)
  - isPressed (boolean)
  - isDisabled (boolean)

States:
  Idle → Hover (when isHovered && !isDisabled)
  Hover → Pressed (when isPressed)
  Pressed → Hover (when !isPressed && isHovered)
  Hover → Idle (when !isHovered)
  Any → Disabled (when isDisabled)
```

### Toggle Pattern
```
Inputs:
  - isOn (boolean)

States:
  Off → TurningOn (when isOn, play transition)
  TurningOn → On (animation complete)
  On → TurningOff (when !isOn, play transition)
  TurningOff → Off (animation complete)
```

### Progress Pattern
```
Inputs:
  - progress (number 0-100)

Timeline:
  - Bind "progress" input to animation timeline
  - 0 = start of animation
  - 100 = end of animation
```

### Multi-State Character
```
Inputs:
  - moveX (number -100 to 100)
  - moveY (number -100 to 100)
  - isJumping (trigger)
  - isAttacking (trigger)

Blend States:
  - Idle (center)
  - WalkLeft (moveX < -20)
  - WalkRight (moveX > 20)
  - WalkUp (moveY < -20)
  - WalkDown (moveY > 20)

One-shots:
  - Jump (isJumping trigger)
  - Attack (isAttacking trigger)
```

## Performance Tips

**Use WebGL Renderer:**
```tsx
import { useRive } from '@rive-app/react-webgl';
// Better performance for complex animations
```

**Lazy Load:**
```tsx
import dynamic from 'next/dynamic';

const RiveAnimation = dynamic(
  () => import('./RiveAnimation'),
  { ssr: false }
);
```

**Cleanup:**
```tsx
useEffect(() => {
  return () => {
    rive?.cleanup();
  };
}, [rive]);
```

## Quick Reference

| Hook | Purpose |
|------|---------|
| `useRive()` | Load and control Rive file |
| `useStateMachineInput()` | Access state machine inputs |
| `rive.play()` | Play animation |
| `rive.pause()` | Pause animation |
| `rive.reset()` | Reset to start |
| `input.value` | Get/set input value |
| `input.fire()` | Trigger a trigger input |

## Use Cases

### Interactive UI
- Animated buttons with hover/press states
- Toggle switches
- Checkboxes with animations
- Loading buttons

### Data Visualization
- Animated charts driven by data
- Progress indicators
- Score displays

### Characters
- Animated mascots
- Interactive tutorials
- Game characters

### Onboarding
- Step-by-step animations
- Interactive tutorials
- Feature highlights

## When to Use This Skill

Invoke this skill when:
- Need interactive animations (hover, click, drag)
- Building animated UI components
- Creating character animations
- Need state-based animation logic
- Want real-time control over animation
- Building animated tutorials/onboarding

## Resources

- **Rive App**: https://rive.app
- **Community Files**: https://rive.app/community
- **Documentation**: https://help.rive.app
- **React Package**: https://www.npmjs.com/package/@rive-app/react-canvas
- **Examples**: https://rive.app/examples
