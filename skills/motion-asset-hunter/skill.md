---
name: Motion Asset Hunter
slug: motion-asset-hunter
description: Find and adapt premium animation assets from CodePen, GitHub, Dribbble, and animation libraries. Discover reference implementations and open-source animations to use or learn from.
category: animation
complexity: moderate
version: "1.0.0"
author: "ID8Labs"
triggers:
  - "find animation"
  - "animation reference"
  - "codepen animation"
  - "animation inspiration"
  - "motion reference"
  - "animation library"
  - "open source animation"
tags:
  - animation
  - assets
  - reference
  - codepen
  - inspiration
  - open-source
---

# Motion Asset Hunter

Find, evaluate, and adapt premium animation assets from across the web. This skill helps you discover production-ready animations, reference implementations, and open-source code to use or learn from.

## Why Hunt for Assets?

- **Don't reinvent**: Someone likely built what you need
- **Learn patterns**: Study professional implementations
- **Save time**: Adapt existing code vs building from scratch
- **Quality reference**: See how experts solve problems
- **Legal clarity**: Find properly licensed assets

## Core Workflows

### Workflow 1: Search CodePen

**Best Search Strategies:**

| Goal | Search Terms |
|------|--------------|
| Globe animations | "3d globe webgl", "earth animation three.js" |
| Scroll effects | "scrolltrigger gsap", "parallax scroll" |
| Text animations | "text reveal gsap", "split text animation" |
| Particles | "particles three.js", "particle system webgl" |
| Loading states | "loading animation css", "skeleton loader" |
| Micro-interactions | "button hover animation", "toggle animation" |
| Charts | "animated chart d3", "data visualization" |

**Evaluating CodePen Quality:**
1. Check hearts/views (popularity indicator)
2. Look at code cleanliness
3. Test responsiveness
4. Check for dependencies
5. Verify license (most CodePens are MIT)

**Top Animation Authors:**
- @GreenSock (GSAP official)
- @aaroniker (micro-interactions)
- @chriscoyier (CSS tricks)
- @sdras (Vue animations)
- @cassie-codes (SVG animations)

### Workflow 2: Search GitHub

**Search Queries:**
```
# React animation libraries
react animation component stars:>100

# Three.js examples
three.js animation example stars:>50

# GSAP implementations
gsap scrolltrigger example

# Specific effects
"globe animation" react stars:>20
"particle system" typescript stars:>30
```

**Top Repositories:**
| Repo | Description |
|------|-------------|
| pmndrs/drei | R3F helpers with examples |
| airbnb/lottie-web | Lottie player + examples |
| greensock/GSAP | GSAP with demos |
| mrdoob/three.js | Three.js examples folder |
| animate-css/animate.css | CSS animations |
| framer/motion | Framer Motion examples |

### Workflow 3: Curated Animation Libraries

**CSS Animation Libraries:**
```bash
# Animate.css - Classic CSS animations
npm install animate.css

# Hover.css - Hover effects
# Download from https://ianlunn.github.io/Hover/

# Magic.css - Unique animations
npm install magic.css
```

**React Animation Libraries:**
```bash
# Framer Motion - Production-ready
npm install framer-motion

# React Spring - Physics-based
npm install @react-spring/web

# Auto-Animate - Automatic animations
npm install @formkit/auto-animate
```

**SVG Animation:**
```bash
# Vivus - SVG drawing animation
npm install vivus

# SVG.js - SVG manipulation
npm install @svgdotjs/svg.js
```

### Workflow 4: Premium Asset Sources

**Free Resources:**
| Source | Type | License |
|--------|------|---------|
| LottieFiles | Lottie animations | Free/Premium |
| useAnimations | React icons | MIT |
| Lordicon | Animated icons | Free tier |
| Rive Community | Rive files | Various |
| Sketchfab | 3D models | Various |
| Mixamo | Character animations | Free |
| HDRI Haven | Environment maps | CC0 |

**Premium Resources:**
| Source | Type | Price |
|--------|------|-------|
| Motion.page | Webflow animations | $$ |
| LottieFiles Pro | Premium Lotties | $/mo |
| Envato Elements | Various | $/mo |
| Iconfinder | Animated icons | $$ |
| TurboSquid | 3D models | $$$ |

### Workflow 5: Animation Inspiration Sites

**Design Galleries:**
- **Awwwards**: Award-winning sites with motion
- **Dribbble**: UI animation concepts
- **Behance**: Motion design case studies
- **Codrops**: CSS/JS experiments

**Specific Collections:**
- **Stripe.com**: Globe, gradients, micro-interactions
- **Linear.app**: Smooth page transitions
- **Vercel.com**: Subtle, elegant motion
- **Apple.com**: Scroll-driven storytelling

### Workflow 6: Adapting Found Code

**Step 1: Evaluate License**
```
MIT License → Free to use commercially
Apache 2.0 → Free with attribution
GPL → Must open-source your code
CC-BY → Attribution required
No License → Contact author
```

**Step 2: Extract Core Logic**
```tsx
// Original CodePen (often vanilla JS)
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
// ... animation logic

// Adapted for React
export function Animation() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    const ctx = canvas?.getContext('2d');
    if (!ctx) return;

    // ... same animation logic

    return () => {
      // cleanup
    };
  }, []);

  return <canvas ref={canvasRef} />;
}
```

**Step 3: Adapt Styling**
```tsx
// Original colors
const BLUE = '#0066ff';
const WHITE = '#ffffff';

// Your brand colors
const FOREST = '#1a3d2e';
const GOLD = '#b8a361';
const PARCHMENT = '#faf8f3';

// Find/replace in animation code
```

**Step 4: Make Responsive**
```tsx
// Add resize handler
useEffect(() => {
  function handleResize() {
    const canvas = canvasRef.current;
    if (canvas) {
      canvas.width = canvas.offsetWidth * window.devicePixelRatio;
      canvas.height = canvas.offsetHeight * window.devicePixelRatio;
    }
  }

  window.addEventListener('resize', handleResize);
  handleResize();

  return () => window.removeEventListener('resize', handleResize);
}, []);
```

## Quick Reference: Finding Specific Effects

| Effect | Best Sources |
|--------|--------------|
| 3D Globe | Three.js examples, Stripe's globe CodePen |
| Particle systems | Three.js, Pixi.js examples |
| Text reveals | GSAP CodePens, Codrops |
| Scroll parallax | GSAP ScrollTrigger demos |
| SVG morphing | Flubber, GSAP MorphSVG |
| Chart animations | D3.js gallery, Chart.js |
| Loading states | LottieFiles, CSS Loaders |
| Page transitions | Framer Motion, Barba.js |
| Mouse followers | Codrops, cursor-effects |
| Noise/gradients | Grainy Gradients, meshgradient.com |

## Legal Checklist

Before using found code:
- [ ] Check license file/header
- [ ] MIT/Apache → safe for commercial
- [ ] Attribution required? Add comment
- [ ] GPL → consult legal
- [ ] No license → contact author or don't use
- [ ] Modified substantially → document changes

## When to Use This Skill

Invoke this skill when:
- Looking for animation inspiration
- Need reference implementations
- Want to find existing solutions
- Evaluating animation libraries
- Need specific effect examples
- Looking for open-source assets

## Top Bookmarks

**Must-Follow:**
- https://codepen.io/GreenSock
- https://codrops.com
- https://tympanus.net/codrops
- https://docs.pmnd.rs/react-three-fiber
- https://www.awwwards.com/websites/animation
- https://dribbble.com/search/animation

**Search Engines:**
- https://codepen.io/search
- https://github.com/search
- https://lottiefiles.com/search
- https://rive.app/community
