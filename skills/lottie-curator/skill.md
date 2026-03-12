---
name: Lottie Curator
slug: lottie-curator
description: Find, customize, and integrate premium Lottie animations from LottieFiles library. Search 100k+ animations, adapt colors to brand palette, and implement in React with optimal performance.
category: animation
complexity: moderate
version: "1.0.0"
author: "ID8Labs"
triggers:
  - "lottie"
  - "lottie animation"
  - "find animation"
  - "animated icon"
  - "loading animation"
  - "micro animation"
  - "json animation"
  - "after effects animation"
tags:
  - lottie
  - animation
  - micro-interactions
  - icons
  - loading
  - premium
---

# Lottie Curator

Find and integrate premium Lottie animations from the world's largest animation library. Lottie animations are vector-based, tiny in file size, and infinitely scalable - perfect for icons, loading states, illustrations, and micro-interactions.

## Why Lottie?

- **Tiny files**: 10-50KB vs MB for video/GIF
- **Vector quality**: Crisp at any size
- **100k+ animations**: LottieFiles has massive library
- **Customizable**: Change colors without re-exporting
- **Performant**: GPU-accelerated rendering

## Core Workflows

### Workflow 1: Setup Lottie in React/Next.js

**Installation:**
```bash
npm install lottie-react
# or for more control:
npm install @lottiefiles/react-lottie-player
```

**Basic Usage:**
```tsx
'use client';

import Lottie from 'lottie-react';
import animationData from './animation.json';

export function LottieAnimation() {
  return (
    <Lottie
      animationData={animationData}
      loop={true}
      autoplay={true}
      style={{ width: 300, height: 300 }}
    />
  );
}
```

**With URL (no local file):**
```tsx
'use client';

import { Player } from '@lottiefiles/react-lottie-player';

export function LottieFromURL() {
  return (
    <Player
      src="https://lottie.host/xxx/animation.json"
      loop
      autoplay
      style={{ width: 300, height: 300 }}
    />
  );
}
```

### Workflow 2: Finding Animations on LottieFiles

**Search Strategy:**
1. Go to https://lottiefiles.com/search
2. Use specific terms:
   - "globe earth" for world animations
   - "house home building" for property
   - "network nodes connection" for graphs
   - "balance scale justice" for scales
   - "loading spinner" for loaders
   - "success check" for confirmations
3. Filter by:
   - Free/Premium
   - Style (flat, 3D, outline)
   - Background (transparent)
4. Preview before downloading
5. Download JSON or copy URL

**Premium Sources:**
- LottieFiles.com (largest library)
- IconScout (curated premium)
- Lordicon (icon animations)
- useAnimations (React-ready)

### Workflow 3: Customizing Colors

**Method 1: LottieFiles Editor**
1. Open animation on LottieFiles
2. Click "Edit Layer Colors"
3. Change colors to brand palette
4. Download customized JSON

**Method 2: Runtime Color Change**
```tsx
'use client';

import { useEffect, useRef } from 'react';
import Lottie, { LottieRefCurrentProps } from 'lottie-react';
import animationData from './animation.json';

// Deep clone and replace colors
function customizeColors(
  data: any,
  colorMap: Record<string, string>
): any {
  const json = JSON.stringify(data);
  let result = json;

  Object.entries(colorMap).forEach(([from, to]) => {
    // Convert hex to Lottie RGB format (0-1 range)
    const fromRgb = hexToLottieRgb(from);
    const toRgb = hexToLottieRgb(to);
    result = result.replaceAll(
      JSON.stringify(fromRgb),
      JSON.stringify(toRgb)
    );
  });

  return JSON.parse(result);
}

function hexToLottieRgb(hex: string): number[] {
  const r = parseInt(hex.slice(1, 3), 16) / 255;
  const g = parseInt(hex.slice(3, 5), 16) / 255;
  const b = parseInt(hex.slice(5, 7), 16) / 255;
  return [r, g, b];
}

export function BrandedLottie() {
  const customData = customizeColors(animationData, {
    '#000000': '#1a3d2e', // Black to forest green
    '#ffffff': '#faf8f3', // White to parchment
    '#ffd700': '#b8a361', // Gold to antique gold
  });

  return <Lottie animationData={customData} loop autoplay />;
}
```

### Workflow 4: Controlled Playback

**Play on Scroll:**
```tsx
'use client';

import { useRef, useEffect } from 'react';
import Lottie, { LottieRefCurrentProps } from 'lottie-react';
import { useInView } from 'framer-motion';
import animationData from './animation.json';

export function ScrollTriggeredLottie() {
  const lottieRef = useRef<LottieRefCurrentProps>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const isInView = useInView(containerRef, { once: true });

  useEffect(() => {
    if (isInView) {
      lottieRef.current?.play();
    }
  }, [isInView]);

  return (
    <div ref={containerRef}>
      <Lottie
        lottieRef={lottieRef}
        animationData={animationData}
        autoplay={false}
        loop={false}
      />
    </div>
  );
}
```

**Play on Hover:**
```tsx
'use client';

import { useRef } from 'react';
import Lottie, { LottieRefCurrentProps } from 'lottie-react';
import animationData from './animation.json';

export function HoverLottie() {
  const lottieRef = useRef<LottieRefCurrentProps>(null);

  return (
    <div
      onMouseEnter={() => lottieRef.current?.play()}
      onMouseLeave={() => {
        lottieRef.current?.stop();
        lottieRef.current?.goToAndStop(0, true);
      }}
    >
      <Lottie
        lottieRef={lottieRef}
        animationData={animationData}
        autoplay={false}
        loop={false}
      />
    </div>
  );
}
```

**Scrub with Scroll:**
```tsx
'use client';

import { useRef, useEffect } from 'react';
import Lottie, { LottieRefCurrentProps } from 'lottie-react';
import animationData from './animation.json';

export function ScrollScrubLottie() {
  const lottieRef = useRef<LottieRefCurrentProps>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleScroll() {
      if (!lottieRef.current || !containerRef.current) return;

      const rect = containerRef.current.getBoundingClientRect();
      const progress = Math.max(0, Math.min(1,
        1 - (rect.top / window.innerHeight)
      ));

      const totalFrames = lottieRef.current.getDuration(true) || 0;
      const frame = progress * totalFrames;
      lottieRef.current.goToAndStop(frame, true);
    }

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div ref={containerRef} className="h-[200vh]">
      <div className="sticky top-1/2 -translate-y-1/2">
        <Lottie
          lottieRef={lottieRef}
          animationData={animationData}
          autoplay={false}
        />
      </div>
    </div>
  );
}
```

### Workflow 5: Performance Optimization

**Lazy Loading:**
```tsx
'use client';

import dynamic from 'next/dynamic';
import { Suspense } from 'react';

const LottieAnimation = dynamic(
  () => import('lottie-react').then((mod) => mod.default),
  { ssr: false }
);

export function LazyLottie() {
  return (
    <Suspense fallback={<div className="w-[300px] h-[300px] bg-gray-100" />}>
      <LottieAnimation
        animationData={require('./animation.json')}
        loop
        autoplay
      />
    </Suspense>
  );
}
```

**Reduce Quality for Performance:**
```tsx
<Lottie
  animationData={animationData}
  rendererSettings={{
    preserveAspectRatio: 'xMidYMid slice',
    progressiveLoad: true,
    hideOnTransparent: true,
  }}
/>
```

## Recommended Animations by Use Case

### Loading States
- Search: "loading spinner minimal"
- Search: "dots loading"
- Search: "skeleton loader"

### Success/Error
- Search: "success checkmark"
- Search: "error cross"
- Search: "celebration confetti"

### Navigation
- Search: "hamburger menu"
- Search: "arrow down scroll"
- Search: "back arrow"

### Data Visualization
- Search: "globe earth"
- Search: "network nodes"
- Search: "chart graph"
- Search: "growth arrow"

### Real Estate (Homer)
- Search: "house building home"
- Search: "key unlock"
- Search: "location pin"
- Search: "document paper"

### Premium/Trust
- Search: "certificate badge"
- Search: "shield security"
- Search: "star rating"

## Quick Reference

| Method | Purpose |
|--------|---------|
| `play()` | Start animation |
| `pause()` | Pause animation |
| `stop()` | Stop and reset |
| `goToAndStop(frame, true)` | Jump to frame |
| `goToAndPlay(frame, true)` | Jump and play |
| `setSpeed(2)` | Change speed |
| `setDirection(-1)` | Reverse |
| `getDuration(true)` | Get total frames |

## File Size Guidelines

| Complexity | Max Size | Example |
|------------|----------|---------|
| Icon | < 10KB | Checkmark, arrow |
| Illustration | < 50KB | Character, scene |
| Complex | < 100KB | Full animation |

## When to Use This Skill

Invoke this skill when:
- Adding micro-interactions (button hovers, transitions)
- Creating loading/success states
- Finding animated icons
- Adding illustrations that move
- Need lightweight animations
- Want to customize existing animations

## Resources

- **LottieFiles**: https://lottiefiles.com
- **Lordicon**: https://lordicon.com
- **useAnimations**: https://useanimations.com
- **IconScout**: https://iconscout.com/lottie-animations
- **Documentation**: https://airbnb.io/lottie
