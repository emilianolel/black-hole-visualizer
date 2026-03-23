import React, { useState, useEffect, Suspense } from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls, Stars } from '@react-three/drei';
import { EventHorizon } from './components/EventHorizon';
import { PhotonPath } from './components/PhotonPath';
import { RefreshCw, Zap } from 'lucide-react';

// API Configuration
const API_BASE = "http://localhost:8000";

function App() {
  const [photons, setPhotons] = useState<any>({});
  const [loading, setLoading] = useState(false);
  const [stats, setStats] = useState({ count: 0 });
  const [limit, setLimit] = useState(40);

  const fetchSample = async () => {
    setLoading(true);
    try {
      const resp = await fetch(`${API_BASE}/v1/photons/sample/batch?limit=${limit}`);
      const data = await resp.json();
      setPhotons(data.photons);
      setStats({ count: data.count });
    } catch (err) {
      console.error("Failed to fetch photons:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSample();
  }, []);

  return (
    <div style={{ width: '100vw', height: '100vh', position: 'relative' }}>
      {/* UI Overlay */}
      <div className="overlay">
        <h1 className="title">Schwarzschild</h1>
        <p className="subtitle">Visualizer v1.0</p>
        
        <div style={{ marginBottom: '1rem' }}>
          <label style={{ fontSize: '0.7rem', color: '#888', display: 'block', marginBottom: '0.4rem' }}>
            RAY INTENSITY (LIMIT)
          </label>
          <input 
            type="range" 
            min="10" 
            max="1000" 
            step="10"
            value={limit}
            onChange={(e) => setLimit(parseInt(e.target.value))}
            style={{ width: '100%', marginBottom: '0.5rem' }}
          />
          <div style={{ fontSize: '0.8rem', textAlign: 'right', color: '#aaa' }}>{limit} Photons</div>
        </div>

        <button onClick={fetchSample} disabled={loading}>
          {loading ? (
            <RefreshCw className="animate-spin" size={16} />
          ) : (
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}>
              <Zap size={16} /> Load Photons
            </div>
          )}
        </button>

        <div className="stats-grid">
          <div className="stat-item">
            <span className="stat-label">Active Rays</span>
            <span className="stat-value">{stats.count}</span>
          </div>
          <div className="stat-item">
            <span className="stat-label">Metric</span>
            <span className="stat-value">Gμν = 8πTμν</span>
          </div>
        </div>
      </div>

      {/* 3D Scene */}
      <Canvas
        shadows
        camera={{ position: [30, 20, 30], fov: 45 }}
        style={{ background: '#050505' }}
      >
        <color attach="background" args={['#050505']} />
        
        <Suspense fallback={null}>
          <ambientLight intensity={0.2} />
          <pointLight position={[10, 10, 10]} intensity={1} />
          
          <EventHorizon />
          
          {Object.entries(photons).map(([id, path]: [string, any]) => (
            <PhotonPath key={id} id={parseInt(id)} data={path} />
          ))}

          <Stars radius={100} depth={50} count={5000} factor={4} saturation={0} fade speed={1} />
          
          <OrbitControls 
            enablePan={true} 
            enableZoom={true} 
            maxDistance={100} 
            minDistance={5} 
          />
          
        </Suspense>
      </Canvas>
    </div>
  );
}

export default App;
