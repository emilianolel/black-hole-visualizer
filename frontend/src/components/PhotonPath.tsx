import React, { useMemo } from 'react';
import * as THREE from 'three';

interface PhotonPathProps {
  id: number;
  data: {
    r: number;
    theta: number;
    phi: number;
  }[];
  color?: string;
}

export const PhotonPath: React.FC<PhotonPathProps> = ({ data, color = "#ffaa00" }) => {
  const points = useMemo(() => {
    return data.map((step) => {
      // Coordinate transformation: Schwarzschild to Cartesian
      // r is radial distance, theta is polar, phi is azimuthal
      const { r, theta, phi } = step;
      const x = r * Math.sin(theta) * Math.cos(phi);
      const z = r * Math.sin(theta) * Math.sin(phi);
      const y = r * Math.cos(theta); // Swapping Y/Z for Three.js coordinate system if needed
      return new THREE.Vector3(x, y, z);
    });
  }, [data]);

  const lineGeometry = useMemo(() => {
    return new THREE.BufferGeometry().setFromPoints(points);
  }, [points]);

  return (
    <line geometry={lineGeometry}>
      <lineBasicMaterial attach="material" color={color} linewidth={2} transparent opacity={0.6} />
    </line>
  );
};
