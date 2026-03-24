import pytest
import numpy as np
from src.engine.integrator import trace_photon, RS, M

def test_photon_sphere_stability():
    """Validates that a photon on the photon sphere (r=3M) remains in a circular orbit.
    
    In Schwarzschild geometry, photons at r = 3.0 (with M=1) have an unstable 
    circular orbit. We test drift over a short integration.
    """
    # State: [t, r, theta, phi, pt, pr, ptheta, pphi]
    # For a circular orbit at r=3M, we need specific momentum components.
    # pt = -(1-2M/r) dt/dl. For null geodesics at r=3M, 
    # the condition is r=3M and p_r = 0.
    
    r0 = 3.0 * M
    theta0 = np.pi / 2.0
    phi0 = 0.0
    
    # Selection of momenta for a circular null geodesic at r=3M
    # E = -pt = 1.0
    # L = pphi = sqrt(27) * M = 3 * sqrt(3)
    pt0 = -1.0
    pr0 = 0.0
    ptheta0 = 0.0
    pphi0 = 3.0 * np.sqrt(3.0) * M
    
    initial_state = np.array([0.0, r0, theta0, phi0, pt0, pr0, ptheta0, pphi0])
    
    # dt=0.01, 100 steps
    path = trace_photon(initial_state, step_size=0.01, max_steps=100)
    
    # Extract last r from the path results (N, 8)
    r_final = path[-1, 1]
    
    # It's an unstable orbit, but over 1 step of path (100 sub-steps in our loop),
    # it shouldn't drift significantly for validation.
    assert abs(r_final - r0) < 0.01

def test_event_horizon_termination():
    """Ensures integration stops when crossing the event horizon (r <= 2M)."""
    r0 = 10.0 * M
    initial_state = np.array([0.0, r0, np.pi/2, 0.0, -1.0, -0.5, 0.0, 0.0])
    
    path = trace_photon(initial_state, step_size=0.2, max_steps=500)
    
    # The last point should be <= RS (2.0)
    assert path[-1, 1] <= RS + 0.01
