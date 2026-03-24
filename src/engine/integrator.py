import numpy as np
from typing import Any

"""Schwarzschild Geodesic Integrator.

Implements 4th-order Runge-Kutta numerical integration for light paths 
around a non-rotating, spherically symmetric black hole.

Equations of motion are derived from the Schwarzschild metric:
ds^2 = -(1 - 2M/r)dt^2 + (1 - 2M/r)^-1 dr^2 + r^2(d_theta^2 + sin^2_theta d_phi^2)
"""

# Universal Constants (Normalized: G = c = 1)
M: float = 1.0  # Mass of the black hole
RS: float = 2.0 * M  # Schwarzschild radius


def derivatives(state: np.ndarray, lambda_prop: float) -> np.ndarray:
    """Computes the derivatives of the state vector for the geodesic equation.

    State vector order: [t, r, theta, phi, p_t, p_r, p_theta, p_phi]
    Note: For null geodesics (light), the mass squared is zero.

    Args:
        state: Current 8-element state vector of the photon.
        lambda_prop: The affine parameter (unused for static metrics but required for signature).

    Returns:
        A np.ndarray containing the 8 derivatives [dt/dl, dr/dl, dth/dl, dph/dl, ...].
    """
    t, r, theta, phi, pt, pr, ptheta, pphi = state
    
    # Pre-calculate common terms to avoid redundant division
    one_minus_rs_r = 1.0 - RS / r
    
    # Equations of motion (Hamiltonian formulation)
    # p_mu = g_mu_nu * dx^nu / d_lambda
    
    dt_dlam = -pt / one_minus_rs_r
    dr_dlam = pr * one_minus_rs_r
    dtheta_dlam = ptheta / (r**2)
    # Adding a small epsilon to sin(theta) to prevent division by zero at the poles
    dphi_dlam = pphi / (r**2 * (np.sin(theta)**2 + 1e-15))
    
    dpt_dlam = 0.0  # t is cyclic
    dpphi_dlam = 0.0  # phi is cyclic
    
    # Radial momentum derivative: derived from Hamiltonian grad:
    # dot(p_r) = - dH/dr = - M*p_t^2/(A^2 * r^2) - M*p_r^2/r^2 + L^2/r^3
    dpr_dlam = (-(M / (r**2 * one_minus_rs_r**2)) * pt**2 - 
                (M / r**2) * pr**2 + 
                (ptheta**2 / r**3) + 
                (pphi**2 / (r**3 * np.sin(theta)**2 + 1e-15)))
    
    # Theta momentum derivative
    dptheta_dlam = (pphi**2 * np.cos(theta)) / (r**2 * np.sin(theta)**3 + 1e-15)
    
    return np.array([dt_dlam, dr_dlam, dtheta_dlam, dphi_dlam, 
                     dpt_dlam, dpr_dlam, dptheta_dlam, dpphi_dlam])


def rk4_step(state: np.ndarray, h: float) -> np.ndarray:
    """Performs one step of 4th-order Runge-Kutta numerical integration.

    Args:
        state: Current photon state vector.
        h: Integration step size (affine parameter increment).

    Returns:
        The updated 8-element state vector after one RK4 step.
    """
    k1 = derivatives(state, 0.0)
    k2 = derivatives(state + h / 2.0 * k1, h / 2.0)
    k3 = derivatives(state + h / 2.0 * k2, h / 2.0)
    k4 = derivatives(state + h * k3, h)
    
    new_state = state + (h / 6.0) * (k1 + 2 * k2 + 2 * k3 + k4)
    return new_state


def trace_photon(
    initial_state: np.ndarray, 
    step_size: float = 0.1, 
    max_steps: int = 1000
) -> np.ndarray:
    """Traces a single photon trajectory until it hits the horizon or escapes.

    Args:
        initial_state: Starting 8-element state vector [t, r, th, ph, pt, pr, pth, pph].
        step_size: The increment of the affine parameter for each integration step.
        max_steps: Maximum number of integration steps to prevent infinite loops.

    Returns:
        A 2D np.ndarray of shape (N, 8) representing the full path of the photon.
    """
    path = [initial_state]
    current_state = initial_state
    
    for _ in range(max_steps):
        current_state = rk4_step(current_state, step_size)
        path.append(current_state)
        
        # Termination conditions (Safety buffer to avoid coordinate singularity at RS)
        if current_state[1] <= RS + 1e-3:  # Captured by Black Hole
            break
        if current_state[1] > 100.0 * M:  # Escaped to 'Infinity' (numerical boundary)
            break
            
    return np.array(path)
