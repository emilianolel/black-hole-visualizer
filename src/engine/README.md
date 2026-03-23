# ⚙️ Physics Engine

The core computational heart of the **Black Hole Visualizer**, responsible for high-precision ray-tracing in curved spacetime.

## 🧪 Components

### 1. `integrator.py` (Core Physics)
This script implements the numerical integration of null geodesics using the **Schwarzschild metric**. It calculates the path of light by solving 8 coupled first-order ordinary differential equations (ODEs).

#### Logic Flow:
```text
    +-----------------------+
    |    STATE VECTOR [y]   | (t, r, θ, φ, pt, pr, pθ, pφ)
    +-----------+-----------+
                |
                v
    +-----------+-----------+
    |  derivatives(y, λ)    | (Calculates 8 Hamiltonian ODEs)
    +-----------+-----------+
                |
                v
    +-----------+-----------+
    |      rk4_step(h)      | (4-th Order Runge-Kutta Step)
    |  y_next = y + (k-sum) |
    +-----------+-----------+
                |
                v
    +-----------+-----------+
    |   BOUNDARY CHECKS     | (Checks for r <= 2M or r > 100M)
    +-----------------------+
```

---

### 2. `simulation_job.py` (Distributed Processing)
This is the **PySpark** entry point. it orchestrates the distribution of millions of photon initial conditions across the cluster nodes.

#### Logic Flow:
```text
    [ SPARK DRIVER ]
    +-----------------------+
    | 1. Generate Batch ICs | (Initial Conditions for n photons)
    +-----------+-----------+
                |
                v
    +-----------+-----------+
    | 2. Partition RDD      | (Distribute ICs to Worker Nodes)
    +-----------+-----------+
                |
       [ WORKER NODES ]
       +-----------+-----------+
       | 3. mapPartitions()    | (Parallel Task Execution)
       |   run_simulation()    |
       |     -> trace_photon() |
       +-----------+-----------+
                |
                v
    +-----------+-----------+
    | 4. Write to GCS (Par)  | (Direct save to Cloud Storage)
    +-----------------------+
```

## 📐 Math Details
-   **RK4 Integrator**: 4th-order Runge-Kutta numerical method for solving geodesic equations. 📐
-   **Schwarzschild Metric**: Relativistic mathematical framework for spherical, non-rotating black holes.
-   **PySpark Jobs**: Massively parallel processing across Dataproc clusters. ⚡
-   **GCS Integration**: Scalable data storage for simulation checkpoints and raw results. ☁️
