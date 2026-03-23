import React from 'react';
import * as THREE from 'three';

export const EventHorizon: React.FC = () => {
  const r_s = 2; // Schwarzschild radius in our normalized units

  return (
    <mesh>
      <sphereGeometry args={[r_s, 64, 64]} />
      <meshBasicMaterial color="#000000" />
      
      {/* Subtle outer glow layer */}
      <mesh scale={1.05}>
        <sphereGeometry args={[r_s, 32, 32]} />
        <meshBasicMaterial color="#111111" transparent opacity={0.3} side={THREE.BackSide} />
      </mesh>
    </mesh>
  );
};
