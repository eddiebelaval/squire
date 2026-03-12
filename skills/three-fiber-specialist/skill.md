---
name: Three Fiber Specialist
slug: three-fiber-specialist
description: Create premium WebGL 3D experiences with React Three Fiber. Build Stripe-style globes, particle systems, 3D product showcases, and immersive visual experiences.
category: animation
complexity: expert
version: "1.0.0"
author: "ID8Labs"
triggers:
  - "three.js"
  - "react three fiber"
  - "r3f"
  - "webgl"
  - "3D web"
  - "particle system"
  - "3D globe"
  - "shader"
  - "3D product"
tags:
  - threejs
  - r3f
  - webgl
  - 3d
  - shaders
  - particles
  - globe
---

# Three Fiber Specialist

Create stunning WebGL 3D experiences using React Three Fiber (R3F) - the React renderer for Three.js. Build Stripe-style globes, particle effects, 3D product showcases, and immersive visual experiences with the power of WebGL and the simplicity of React components.

## Why React Three Fiber?

- **React ecosystem**: Components, hooks, state management
- **Declarative**: Describe 3D scenes like UI
- **Performant**: Automatic render optimization
- **Extensible**: Full Three.js access
- **Community**: Huge ecosystem of helpers (drei, postprocessing)

## Core Workflows

### Workflow 1: Setup R3F in Next.js

**Installation:**
```bash
npm install three @react-three/fiber @react-three/drei
npm install -D @types/three
```

**next.config.js (if needed):**
```js
module.exports = {
  transpilePackages: ['three'],
}
```

**Basic Scene:**
```tsx
'use client';

import { Canvas } from '@react-three/fiber';
import { OrbitControls } from '@react-three/drei';

function Box() {
  return (
    <mesh>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="#1a3d2e" />
    </mesh>
  );
}

export function Scene() {
  return (
    <div className="w-full h-[600px]">
      <Canvas>
        <ambientLight intensity={0.5} />
        <directionalLight position={[10, 10, 5]} />
        <Box />
        <OrbitControls />
      </Canvas>
    </div>
  );
}
```

### Workflow 2: Stripe-Style Globe

```tsx
'use client';

import { useRef, useMemo } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { Sphere, Html, Line, OrbitControls } from '@react-three/drei';
import * as THREE from 'three';

// Convert lat/lng to 3D position on sphere
function latLngToVector3(lat: number, lng: number, radius: number) {
  const phi = (90 - lat) * (Math.PI / 180);
  const theta = (lng + 180) * (Math.PI / 180);
  return new THREE.Vector3(
    -radius * Math.sin(phi) * Math.cos(theta),
    radius * Math.cos(phi),
    radius * Math.sin(phi) * Math.sin(theta)
  );
}

// City marker component
function CityMarker({ lat, lng, name }: { lat: number; lng: number; name: string }) {
  const position = latLngToVector3(lat, lng, 2.02);

  return (
    <group position={position}>
      <Sphere args={[0.03, 16, 16]}>
        <meshBasicMaterial color="#b8a361" />
      </Sphere>
      <Html distanceFactor={8}>
        <div className="text-xs text-white bg-black/50 px-1 rounded whitespace-nowrap">
          {name}
        </div>
      </Html>
    </group>
  );
}

// Arc between two cities
function CityArc({ from, to }: { from: [number, number]; to: [number, number] }) {
  const points = useMemo(() => {
    const start = latLngToVector3(from[0], from[1], 2);
    const end = latLngToVector3(to[0], to[1], 2);
    const mid = start.clone().add(end).multiplyScalar(0.5).normalize().multiplyScalar(2.5);

    const curve = new THREE.QuadraticBezierCurve3(start, mid, end);
    return curve.getPoints(50);
  }, [from, to]);

  return (
    <Line
      points={points}
      color="#b8a361"
      lineWidth={1}
      transparent
      opacity={0.6}
    />
  );
}

// Main globe component
function Globe() {
  const globeRef = useRef<THREE.Mesh>(null);

  useFrame(() => {
    if (globeRef.current) {
      globeRef.current.rotation.y += 0.001;
    }
  });

  const cities = [
    { lat: 40.7128, lng: -74.006, name: 'New York' },
    { lat: 51.5074, lng: -0.1278, name: 'London' },
    { lat: 35.6762, lng: 139.6503, name: 'Tokyo' },
    { lat: 25.7617, lng: -80.1918, name: 'Miami' },
    { lat: 37.7749, lng: -122.4194, name: 'San Francisco' },
  ];

  return (
    <group ref={globeRef}>
      {/* Globe sphere */}
      <Sphere args={[2, 64, 64]}>
        <meshStandardMaterial
          color="#1a3d2e"
          roughness={0.8}
          metalness={0.2}
        />
      </Sphere>

      {/* Wireframe overlay */}
      <Sphere args={[2.01, 32, 32]}>
        <meshBasicMaterial
          color="#5c7a6b"
          wireframe
          transparent
          opacity={0.3}
        />
      </Sphere>

      {/* City markers */}
      {cities.map((city) => (
        <CityMarker key={city.name} {...city} />
      ))}

      {/* Connection arcs */}
      <CityArc from={[40.7128, -74.006]} to={[51.5074, -0.1278]} />
      <CityArc from={[40.7128, -74.006]} to={[25.7617, -80.1918]} />
      <CityArc from={[51.5074, -0.1278]} to={[35.6762, 139.6503]} />
    </group>
  );
}

export function StripeGlobe() {
  return (
    <div className="w-full h-[600px] bg-[#0d2818]">
      <Canvas camera={{ position: [0, 0, 6], fov: 45 }}>
        <ambientLight intensity={0.4} />
        <directionalLight position={[5, 5, 5]} intensity={0.8} color="#faf8f3" />
        <pointLight position={[-5, -5, -5]} intensity={0.3} color="#b8a361" />
        <Globe />
        <OrbitControls
          enableZoom={false}
          enablePan={false}
          autoRotate
          autoRotateSpeed={0.5}
        />
      </Canvas>
    </div>
  );
}
```

### Workflow 3: Particle System

```tsx
'use client';

import { useRef, useMemo } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import * as THREE from 'three';

function Particles({ count = 1000 }) {
  const mesh = useRef<THREE.Points>(null);

  const particles = useMemo(() => {
    const positions = new Float32Array(count * 3);
    const colors = new Float32Array(count * 3);

    for (let i = 0; i < count; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 10;
      positions[i * 3 + 1] = (Math.random() - 0.5) * 10;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 10;

      // Gold color with variation
      colors[i * 3] = 0.72 + Math.random() * 0.1;     // R
      colors[i * 3 + 1] = 0.64 + Math.random() * 0.1; // G
      colors[i * 3 + 2] = 0.38 + Math.random() * 0.1; // B
    }

    return { positions, colors };
  }, [count]);

  useFrame((state) => {
    if (mesh.current) {
      mesh.current.rotation.y = state.clock.elapsedTime * 0.05;
      mesh.current.rotation.x = Math.sin(state.clock.elapsedTime * 0.1) * 0.1;
    }
  });

  return (
    <points ref={mesh}>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          array={particles.positions}
          count={count}
          itemSize={3}
        />
        <bufferAttribute
          attach="attributes-color"
          array={particles.colors}
          count={count}
          itemSize={3}
        />
      </bufferGeometry>
      <pointsMaterial
        size={0.05}
        vertexColors
        transparent
        opacity={0.8}
        sizeAttenuation
      />
    </points>
  );
}

export function ParticleScene() {
  return (
    <div className="w-full h-[600px] bg-[#1a3d2e]">
      <Canvas camera={{ position: [0, 0, 5] }}>
        <Particles count={2000} />
      </Canvas>
    </div>
  );
}
```

### Workflow 4: 3D Product Showcase

```tsx
'use client';

import { Suspense, useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import {
  Environment,
  ContactShadows,
  Float,
  PresentationControls,
  useGLTF,
} from '@react-three/drei';

function Product({ url }: { url: string }) {
  const { scene } = useGLTF(url);
  const ref = useRef<THREE.Group>(null);

  useFrame((state) => {
    if (ref.current) {
      ref.current.rotation.y = Math.sin(state.clock.elapsedTime * 0.3) * 0.1;
    }
  });

  return (
    <Float speed={1.5} rotationIntensity={0.5} floatIntensity={0.5}>
      <primitive ref={ref} object={scene} scale={1} />
    </Float>
  );
}

export function ProductShowcase() {
  return (
    <div className="w-full h-[600px]">
      <Canvas camera={{ position: [0, 0, 4], fov: 50 }}>
        <ambientLight intensity={0.5} />
        <spotLight position={[10, 10, 10]} angle={0.15} penumbra={1} />

        <PresentationControls
          global
          rotation={[0.13, 0.1, 0]}
          polar={[-0.4, 0.2]}
          azimuth={[-1, 0.75]}
        >
          <Suspense fallback={null}>
            <Product url="/models/product.glb" />
          </Suspense>
        </PresentationControls>

        <ContactShadows
          position={[0, -1.4, 0]}
          opacity={0.35}
          scale={10}
          blur={2.5}
        />

        <Environment preset="city" />
      </Canvas>
    </div>
  );
}
```

### Workflow 5: Scroll-Controlled Camera

```tsx
'use client';

import { useRef, useEffect } from 'react';
import { Canvas, useFrame, useThree } from '@react-three/fiber';
import { ScrollControls, useScroll, Scroll } from '@react-three/drei';
import * as THREE from 'three';

function CameraRig() {
  const scroll = useScroll();
  const { camera } = useThree();

  useFrame(() => {
    // Move camera based on scroll
    camera.position.z = 5 - scroll.offset * 3;
    camera.position.y = scroll.offset * 2;
    camera.lookAt(0, 0, 0);
  });

  return null;
}

function Scene() {
  return (
    <>
      <mesh position={[0, 0, 0]}>
        <boxGeometry args={[1, 1, 1]} />
        <meshStandardMaterial color="#1a3d2e" />
      </mesh>
      <mesh position={[2, 0, -2]}>
        <sphereGeometry args={[0.5, 32, 32]} />
        <meshStandardMaterial color="#b8a361" />
      </mesh>
    </>
  );
}

export function ScrollScene() {
  return (
    <div className="h-[300vh]">
      <div className="fixed inset-0">
        <Canvas>
          <ScrollControls pages={3}>
            <ambientLight />
            <directionalLight position={[5, 5, 5]} />
            <Scene />
            <CameraRig />

            <Scroll html>
              <div className="absolute top-[100vh] left-1/2 -translate-x-1/2">
                <h2 className="text-4xl font-bold">Section 2</h2>
              </div>
              <div className="absolute top-[200vh] left-1/2 -translate-x-1/2">
                <h2 className="text-4xl font-bold">Section 3</h2>
              </div>
            </Scroll>
          </ScrollControls>
        </Canvas>
      </div>
    </div>
  );
}
```

## Drei Helpers Reference

| Helper | Purpose |
|--------|---------|
| `OrbitControls` | Mouse orbit camera control |
| `PresentationControls` | Drag to rotate object |
| `ScrollControls` | Scroll-based animation |
| `Float` | Floating animation |
| `Html` | HTML inside 3D scene |
| `Environment` | HDR environment lighting |
| `ContactShadows` | Soft floor shadows |
| `useGLTF` | Load 3D models |
| `Line` | Draw lines/curves |
| `Sphere`, `Box`, etc. | Geometry helpers |

## Performance Tips

**Memoize Geometries:**
```tsx
const geometry = useMemo(() => new THREE.BoxGeometry(1, 1, 1), []);
```

**Use Instancing:**
```tsx
import { Instances, Instance } from '@react-three/drei';

<Instances limit={1000}>
  <boxGeometry />
  <meshStandardMaterial />
  {items.map((item, i) => (
    <Instance key={i} position={item.position} />
  ))}
</Instances>
```

**Lazy Load:**
```tsx
import dynamic from 'next/dynamic';

const Scene = dynamic(() => import('./Scene'), { ssr: false });
```

**Reduce Draw Calls:**
- Merge geometries
- Use texture atlases
- Limit unique materials

## When to Use This Skill

Invoke this skill when:
- Building Stripe/Linear-style 3D visuals
- Creating interactive 3D product showcases
- Making globe visualizations
- Building particle effects
- Creating scroll-driven 3D experiences
- Need full control over 3D rendering

## Resources

- **R3F Docs**: https://docs.pmnd.rs/react-three-fiber
- **Drei Docs**: https://github.com/pmndrs/drei
- **Three.js Docs**: https://threejs.org/docs
- **Examples**: https://docs.pmnd.rs/react-three-fiber/examples
- **Codrops**: https://tympanus.net/codrops (inspiration)
