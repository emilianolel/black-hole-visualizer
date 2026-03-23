import numpy as np

"""
Schwarzschild Geodesic Integrator
--------------------------------
Implements 4th-order Runge-Kutta numerical integration for light paths 
around a non-rotating, spherically symmetric black hole.

Equations of motion are derived from the Schwarzschild metric:
ds^2 = -(1 - 2M/r)dt^2 + (1 - 2M/r)^-1 dr^2 + r^2(d_theta^2 + sin^2_theta d_phi^2)
"""

# Universal Constants (Normalized: G = c = 1)
M = 1.0  # Mass of the black hole
RS = 2.0 * M  # Schwarzschild radius

def derivatives(state, lambda_prop):
    """
    Computes the derivatives of the state vector for the geodesic equation.
    State vector: [t, r, theta, phi, p_t, p_r, p_theta, p_phi]
    Note: For null geodesics (light), the mass squared is zero.
    """
    t, r, theta, phi, pt, pr, ptheta, pphi = state
    
    # Pre-calculate common terms
    one_minus_rs_r = 1.0 - RS/r
    
    # Equations of motion (Hamiltonian formulation)
    # p_mu = g_mu_nu * dx^nu / d_lambda
    
    dt_dlam = -pt / one_minus_rs_r
    dr_dlam = pr * one_minus_rs_r
    dtheta_dlam = ptheta / (r**2)
    dphi_dlam = pphi / (r**2 * (np.sin(theta)**2 + 1e-15)) # Small epsilon to avoid div by zero
    
    dpt_dlam = 0 # t is cyclic
    dpphi_dlam = 0 # phi is cyclic
    
    # Radial momentum derivative
    dpr_dlam = (-(RS / (2 * r**2 * one_minus_rs_r)) * pt**2 + 
                (RS / (2 * r**2 * one_minus_rs_r)) * pr**2 + 
                (ptheta**2 / r**3) + 
                (pphi**2 / (r**3 * np.sin(theta)**2)))
    
    # Theta momentum derivative
    dptheta_dlam = (pphi**2 * np.cos(theta)) / (r**2 * np.sin(theta)**3 + 1e-15)
    
    return np.array([dt_dlam, dr_dlam, dtheta_dlam, dphi_dlam, 
                     dpt_dlam, dpr_dlam, dptheta_dlam, dpphi_dlam])

def rk4_step(state, h):
    """
    Performs one step of 4th-order Runge-Kutta integration.
    """
    k1 = derivatives(state, 0)
    k2 = derivatives(state + h/2 * k1, h/2)
    k3 = derivatives(state + h/2 * k2, h/2)
    k4 = derivatives(state + h * k3, h)
    
    new_state = state + (h/6.0) * (k1 + 2*k2 + 2*k3 + k4)
    
    # Event Horizon Boundary Check
    if new_state[1] < RS + 1e-4:
        # Photon is captured
        new_state[1] = RS  # Snap to horizon
        
    return new_state

def trace_photon(initial_state, step_size=0.1, max_steps=1000):
    """
    Traces a single photon path until it hits the horizon or escapes.
    """
    path = [initial_state]
    current_state = initial_state
    
    for _ in range(max_steps):
        current_state = rk4_step(current_state, step_size)
        path.append(current_state)
        
        # Termination conditions
        if current_state[1] <= RS: # Captured by Black Hole
            break
        if current_state[1] > 100 * M: # Escaped to Infinity
            break
            
    return np.array(path)
