---
name: GSAP Choreographer
slug: gsap-choreographer
description: Create sophisticated scroll-triggered animations with GSAP ScrollTrigger. Build parallax effects, timeline orchestrations, pinned sections, and complex motion sequences.
category: animation
complexity: advanced
version: "1.0.0"
author: "ID8Labs"
triggers:
  - "gsap"
  - "scroll animation"
  - "parallax"
  - "scrolltrigger"
  - "timeline animation"
  - "pinned section"
  - "scroll reveal"
  - "motion choreography"
tags:
  - gsap
  - animation
  - scroll
  - parallax
  - timeline
  - motion
---

# GSAP Choreographer

Create sophisticated, scroll-driven animations with GSAP (GreenSock Animation Platform) and ScrollTrigger. GSAP is the industry standard for professional web animations, used by Apple, Google, Nike, and countless award-winning websites.

## Why GSAP?

- **Industry standard**: Powers premium web experiences
- **Performance**: Optimized for 60fps
- **ScrollTrigger**: Best-in-class scroll animations
- **Timeline**: Complex choreography made simple
- **Cross-browser**: Works everywhere
- **Easing**: Beautiful, customizable easing

## Core Workflows

### Workflow 1: Setup GSAP in Next.js

**Installation:**
```bash
npm install gsap
```

**Basic Setup:**
```tsx
'use client';

import { useEffect, useRef } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

// Register plugin
gsap.registerPlugin(ScrollTrigger);

export function AnimatedSection() {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      gsap.from(ref.current, {
        y: 100,
        opacity: 0,
        duration: 1,
        scrollTrigger: {
          trigger: ref.current,
          start: 'top 80%',
          end: 'top 50%',
          scrub: true,
        },
      });
    });

    return () => ctx.revert(); // Cleanup
  }, []);

  return (
    <div ref={ref}>
      <h2>Animated Content</h2>
    </div>
  );
}
```

### Workflow 2: ScrollTrigger Basics

**Reveal on Scroll:**
```tsx
useEffect(() => {
  const ctx = gsap.context(() => {
    // Fade in from bottom
    gsap.from('.reveal-item', {
      y: 60,
      opacity: 0,
      duration: 0.8,
      stagger: 0.2,
      scrollTrigger: {
        trigger: '.reveal-container',
        start: 'top 80%',
      },
    });
  });

  return () => ctx.revert();
}, []);
```

**Scrub Animation (linked to scroll):**
```tsx
gsap.to('.parallax-element', {
  y: -200,
  scrollTrigger: {
    trigger: '.parallax-container',
    start: 'top bottom',
    end: 'bottom top',
    scrub: 1, // Smooth scrubbing
  },
});
```

**Pinned Section:**
```tsx
gsap.to('.pinned-content', {
  x: '-100%',
  ease: 'none',
  scrollTrigger: {
    trigger: '.pinned-section',
    start: 'top top',
    end: '+=2000', // Pin for 2000px of scroll
    pin: true,
    scrub: 1,
  },
});
```

### Workflow 3: Timeline Choreography

**Basic Timeline:**
```tsx
useEffect(() => {
  const ctx = gsap.context(() => {
    const tl = gsap.timeline({
      scrollTrigger: {
        trigger: '.hero',
        start: 'top top',
        end: '+=1000',
        scrub: 1,
        pin: true,
      },
    });

    tl.from('.hero-title', { y: 100, opacity: 0 })
      .from('.hero-subtitle', { y: 50, opacity: 0 }, '-=0.3')
      .from('.hero-cta', { scale: 0, opacity: 0 }, '-=0.2')
      .to('.hero-bg', { scale: 1.2 }, 0); // Start at beginning
  });

  return () => ctx.revert();
}, []);
```

**Staggered Grid:**
```tsx
gsap.from('.grid-item', {
  scale: 0.8,
  opacity: 0,
  duration: 0.5,
  stagger: {
    amount: 0.8, // Total stagger time
    from: 'center', // Start from center
    grid: [3, 3], // 3x3 grid
  },
  scrollTrigger: {
    trigger: '.grid-container',
    start: 'top 70%',
  },
});
```

### Workflow 4: Parallax Effects

**Multi-Layer Parallax:**
```tsx
'use client';

import { useEffect, useRef } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export function ParallaxHero() {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      // Background moves slowest
      gsap.to('.parallax-bg', {
        y: '-20%',
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top top',
          end: 'bottom top',
          scrub: 1,
        },
      });

      // Midground
      gsap.to('.parallax-mid', {
        y: '-40%',
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top top',
          end: 'bottom top',
          scrub: 1,
        },
      });

      // Foreground moves fastest
      gsap.to('.parallax-fg', {
        y: '-60%',
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top top',
          end: 'bottom top',
          scrub: 1,
        },
      });
    });

    return () => ctx.revert();
  }, []);

  return (
    <div ref={containerRef} className="relative h-screen overflow-hidden">
      <div className="parallax-bg absolute inset-0 bg-cover bg-center"
           style={{ backgroundImage: 'url(/bg.jpg)' }} />
      <div className="parallax-mid absolute inset-0">
        {/* Mid elements */}
      </div>
      <div className="parallax-fg absolute inset-0 flex items-center justify-center">
        <h1 className="text-6xl font-bold">Hero Title</h1>
      </div>
    </div>
  );
}
```

### Workflow 5: Horizontal Scroll

```tsx
'use client';

import { useEffect, useRef } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export function HorizontalScroll() {
  const containerRef = useRef<HTMLDivElement>(null);
  const panelsRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      const panels = gsap.utils.toArray<HTMLElement>('.panel');

      gsap.to(panels, {
        xPercent: -100 * (panels.length - 1),
        ease: 'none',
        scrollTrigger: {
          trigger: containerRef.current,
          pin: true,
          scrub: 1,
          snap: 1 / (panels.length - 1),
          end: () => '+=' + panelsRef.current!.offsetWidth,
        },
      });
    });

    return () => ctx.revert();
  }, []);

  return (
    <div ref={containerRef} className="overflow-hidden">
      <div ref={panelsRef} className="flex">
        {[1, 2, 3, 4].map((i) => (
          <div key={i} className="panel w-screen h-screen flex-shrink-0 flex items-center justify-center">
            <h2 className="text-4xl">Panel {i}</h2>
          </div>
        ))}
      </div>
    </div>
  );
}
```

### Workflow 6: Text Animations

**Split Text Animation:**
```tsx
'use client';

import { useEffect, useRef } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export function AnimatedText({ text }: { text: string }) {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      // Animate each word
      gsap.from('.word', {
        y: 100,
        opacity: 0,
        duration: 0.8,
        stagger: 0.05,
        ease: 'power3.out',
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top 80%',
        },
      });
    });

    return () => ctx.revert();
  }, []);

  return (
    <div ref={containerRef} className="overflow-hidden">
      {text.split(' ').map((word, i) => (
        <span key={i} className="word inline-block mr-2">
          {word}
        </span>
      ))}
    </div>
  );
}
```

**Character-by-Character:**
```tsx
{text.split('').map((char, i) => (
  <span key={i} className="char inline-block">
    {char === ' ' ? '\u00A0' : char}
  </span>
))}

// Animation
gsap.from('.char', {
  y: 50,
  opacity: 0,
  rotateX: -90,
  stagger: 0.02,
  duration: 0.5,
});
```

## ScrollTrigger Reference

| Option | Type | Description |
|--------|------|-------------|
| `trigger` | Element | Element that triggers animation |
| `start` | String | When animation starts ("top 80%") |
| `end` | String | When animation ends ("bottom top") |
| `scrub` | Bool/Number | Link to scroll (true or smoothing value) |
| `pin` | Bool | Pin trigger element |
| `markers` | Bool | Show debug markers |
| `snap` | Number/Array | Snap to positions |
| `toggleClass` | String | Toggle CSS class |
| `onEnter` | Function | Callback on enter |
| `onLeave` | Function | Callback on leave |

## Easing Reference

```tsx
// Built-in
'power1.out'  // Subtle
'power2.out'  // Medium
'power3.out'  // Strong
'power4.out'  // Very strong
'elastic.out' // Bouncy
'back.out'    // Overshoot
'bounce.out'  // Bouncing

// Custom
gsap.to(el, {
  ease: 'power2.inOut',
  // or
  ease: CustomEase.create('custom', 'M0,0 C0.5,0 0.5,1 1,1'),
});
```

## Best Practices

**Always Cleanup:**
```tsx
useEffect(() => {
  const ctx = gsap.context(() => {
    // animations
  });
  return () => ctx.revert();
}, []);
```

**Use matchMedia for Responsive:**
```tsx
const mm = gsap.matchMedia();

mm.add('(min-width: 768px)', () => {
  // Desktop animations
});

mm.add('(max-width: 767px)', () => {
  // Mobile animations
});
```

**Batch Similar Animations:**
```tsx
ScrollTrigger.batch('.batch-item', {
  onEnter: (elements) => {
    gsap.from(elements, {
      y: 60,
      opacity: 0,
      stagger: 0.15,
    });
  },
});
```

## When to Use This Skill

Invoke this skill when:
- Building scroll-triggered animations
- Creating parallax effects
- Making pinned/horizontal scroll sections
- Orchestrating complex animation sequences
- Need precise control over timing
- Building award-winning motion experiences

## Resources

- **GSAP Docs**: https://greensock.com/docs
- **ScrollTrigger**: https://greensock.com/scrolltrigger
- **Easing Visualizer**: https://greensock.com/docs/v3/Eases
- **CodePen Examples**: https://codepen.io/GreenSock
- **GSAP Forum**: https://greensock.com/forums
