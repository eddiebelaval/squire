---
name: Spline Scene Builder
slug: spline-scene-builder
description: Create premium 3D scenes and animations using Spline. Build Stripe-style globes, floating objects, isometric illustrations, and interactive 3D elements that export directly to React.
category: animation
complexity: advanced
version: "1.0.0"
author: "ID8Labs"
triggers:
  - "3D animation"
  - "spline"
  - "3D scene"
  - "globe animation"
  - "3D house"
  - "isometric"
  - "floating objects"
  - "interactive 3D"
  - "premium animation"
  - "stripe globe"
tags:
  - 3d
  - spline
  - animation
  - webgl
  - interactive
  - premium
  - globe
  - isometric
---

# Spline Scene Builder

Create stunning, premium 3D animations using Spline - a browser-based 3D design tool that exports directly to React. Perfect for Stripe-style globes, floating product showcases, isometric illustrations, and interactive 3D elements.

Spline provides the visual quality of professional 3D software with the ease of web integration, making it ideal for premium landing pages and product showcases.

## Why Spline?

- **Browser-based**: No Blender/Cinema 4D needed
- **React integration**: Direct export to `@splinetool/react-spline`
- **Interactive**: Built-in state machines for hover/click effects
- **Lightweight**: Optimized for web performance
- **Real-time**: Changes update instantly in your app

## Core Workflows

### Workflow 1: Setup Spline in React/Next.js

**Installation:**
```bash
npm install @splinetool/react-spline @splinetool/runtime
```

**Basic Integration:**
```tsx
'use client';

import Spline from '@splinetool/react-spline';

export function SplineScene() {
  return (
    <div className="w-full h-[600px]">
      <Spline scene="https://prod.spline.design/YOUR-SCENE-ID/scene.splinecode" />
    </div>
  );
}
```

**With Loading State:**
```tsx
'use client';

import { useState } from 'react';
import Spline from '@splinetool/react-spline';

export function SplineScene() {
  const [isLoading, setIsLoading] = useState(true);

  return (
    <div className="relative w-full h-[600px]">
      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center bg-gray-100">
          <div className="animate-spin w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full" />
        </div>
      )}
      <Spline
        scene="https://prod.spline.design/YOUR-SCENE-ID/scene.splinecode"
        onLoad={() => setIsLoading(false)}
      />
    </div>
  );
}
```

### Workflow 2: Interactive Spline with Events

**Handling Object Events:**
```tsx
'use client';

import { useRef } from 'react';
import Spline from '@splinetool/react-spline';
import { Application, SPEObject } from '@splinetool/runtime';

export function InteractiveScene() {
  const splineRef = useRef<Application>();

  function onLoad(spline: Application) {
    splineRef.current = spline;
  }

  function onMouseDown(e: any) {
    if (e.target.name === 'Button') {
      console.log('Button clicked!');
      // Trigger animation or state change
    }
  }

  function triggerAnimation() {
    const obj = splineRef.current?.findObjectByName('Globe');
    if (obj) {
      // Manually rotate or transform
      obj.rotation.y += 0.5;
    }
  }

  return (
    <Spline
      scene="https://prod.spline.design/YOUR-SCENE-ID/scene.splinecode"
      onLoad={onLoad}
      onMouseDown={onMouseDown}
    />
  );
}
```

### Workflow 3: Scroll-Triggered Spline Animation

**Sync with Scroll Position:**
```tsx
'use client';

import { useEffect, useRef } from 'react';
import Spline from '@splinetool/react-spline';
import { Application } from '@splinetool/runtime';

export function ScrollSplineScene() {
  const splineRef = useRef<Application>();
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleScroll() {
      if (!splineRef.current || !containerRef.current) return;

      const rect = containerRef.current.getBoundingClientRect();
      const scrollProgress = Math.max(0, Math.min(1,
        (window.innerHeight - rect.top) / (window.innerHeight + rect.height)
      ));

      const globe = splineRef.current.findObjectByName('Globe');
      if (globe) {
        // Rotate based on scroll
        globe.rotation.y = scrollProgress * Math.PI * 2;
      }
    }

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div ref={containerRef} className="h-[100vh] sticky top-0">
      <Spline
        scene="https://prod.spline.design/YOUR-SCENE-ID/scene.splinecode"
        onLoad={(spline) => { splineRef.current = spline; }}
      />
    </div>
  );
}
```

### Workflow 4: Creating Premium Scenes in Spline

**Globe Animation (Stripe-style):**
1. Open Spline (spline.design)
2. Create new project
3. Add Sphere primitive
4. Apply material:
   - Matcap or Glass material
   - Subtle gradient
   - Low roughness for shine
5. Add point markers:
   - Small spheres for cities
   - Use Spline's "Clone" for consistency
6. Create connection lines:
   - Use 3D paths or cylinders
   - Animate with Spline states
7. Add lighting:
   - Soft ambient light
   - One directional for highlights
8. Set camera:
   - Subtle orbit animation
   - Depth of field for premium feel
9. Export: File > Export > Code (React)

**Isometric House:**
1. Use Spline's shape tools for walls
2. Extrude for 3D depth
3. Add roof with custom mesh
4. Material: Matte with brand colors
5. Add floating labels with 3D text
6. Animate: Open/close with states
7. Export to React

**Floating Product:**
1. Import 3D model or build in Spline
2. Add subtle float animation (Y position)
3. Rotation on hover
4. Particle effects for premium feel
5. Glass platform beneath

## Common Scene Templates

### Stripe-Style Globe
```
Scene structure:
├── Globe (Sphere)
│   ├── Material: Glass/Gradient
│   ├── Animation: Slow rotation (Y-axis)
│   └── Scale: 1.0
├── Markers (Group)
│   ├── Marker_NYC (Sphere, small)
│   ├── Marker_London
│   ├── Marker_Tokyo
│   └── ... (positioned on globe surface)
├── Connections (Group)
│   ├── Arc_1 (3D Path with glow material)
│   ├── Arc_2
│   └── ... (animated draw-on)
├── Ambient Light (soft white)
├── Directional Light (gold accent)
└── Camera
    ├── FOV: 45
    ├── Orbit animation: subtle
    └── DOF: enabled
```

### Isometric Building
```
Scene structure:
├── Building (Group)
│   ├── Base (Box)
│   ├── Walls (Extruded shapes)
│   ├── Roof (Custom mesh)
│   ├── Windows (Glass material)
│   └── Door (with open/close state)
├── Floating Labels (Group)
│   ├── Label_History (3D Text)
│   ├── Label_Stories
│   └── ... (with float animation)
├── Platform (Box with shadow)
├── Ambient Light
└── Camera (isometric angle: 45° X, 45° Y)
```

## Spline Design Tips

### Materials
- **Glass**: For premium, modern look
- **Matcap**: Fast rendering, good for stylized
- **Gradient**: Brand colors, smooth transitions
- **Noise**: Add subtle texture for depth

### Lighting
- Always use ambient + one directional
- Gold/warm accent light adds premium feel
- Avoid harsh shadows for clean look

### Animation
- Subtle is better - 0.5-2 second loops
- Ease-in-out for natural movement
- Combine rotation + position for interest

### Performance
- Keep polygon count under 50k
- Use instances for repeated objects
- Optimize textures (512px max)
- Enable compression on export

## Integration Patterns

### With Framer Motion
```tsx
import { motion } from 'framer-motion';
import Spline from '@splinetool/react-spline';

export function AnimatedSpline() {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.8 }}
      className="w-full h-[600px]"
    >
      <Spline scene="YOUR_SCENE_URL" />
    </motion.div>
  );
}
```

### Responsive Container
```tsx
export function ResponsiveSpline() {
  return (
    <div className="w-full aspect-[16/9] md:aspect-[21/9] lg:h-[600px]">
      <Spline
        scene="YOUR_SCENE_URL"
        style={{ width: '100%', height: '100%' }}
      />
    </div>
  );
}
```

## Quick Reference

| Feature | Spline Method |
|---------|--------------|
| Find object | `spline.findObjectByName('Name')` |
| Hide object | `obj.visible = false` |
| Move object | `obj.position.set(x, y, z)` |
| Rotate | `obj.rotation.y = Math.PI` |
| Scale | `obj.scale.set(1.5, 1.5, 1.5)` |
| Trigger state | `spline.emitEvent('mouseDown', 'ObjectName')` |

## When to Use This Skill

Invoke this skill when:
- Creating Stripe/Linear-style 3D animations
- Building interactive product showcases
- Making globe visualizations with markers
- Creating isometric illustrations
- Adding premium 3D elements to landing pages
- Building scroll-triggered 3D scenes

## Resources

- **Spline Website**: https://spline.design
- **Spline Community**: https://spline.design/community
- **Examples Gallery**: https://spline.design/examples
- **React Package**: https://www.npmjs.com/package/@splinetool/react-spline
