# 🌌 Schwarzschild Black Hole Visualizer v1.0

![Schwarzschild Black Hole](docs/assets/black_hole.png)

A high-fidelity, distributed physics simulation and interactive 3D visualizer using GCP Dataproc, BigQuery, FastAPI, and React Three Fiber.

## 🏗️ End-to-End Architecture

```text
    [ DISK OF ACCRETION ]         [ DISTRIBUTED CLUSTER ]        [ DATA WAREHOUSE ]
    Interactive Dashboard  <--->      FastAPI Bridge      <--->     BigQuery
      (React/Three.js)            (High-speed JSON)           (Partitioned/Clustered)
             ^                                                        ^
             |                                                        | Spark-BQ
             +----------------------- [ GCS STORAGE ] <---------------+ Ingestion
                                     (Parquet Output)
```

---

## 🛠️ Project Setup

### 1. Infrastructure (Terraform)
Provision the GCP resources (Dataproc, BigQuery, GCS, IAM).
```bash
cd terraform/environments/dev
terraform init
terraform apply
```

### 2. Application Control (Unified)
You can now manage both the API and the Frontend with a single command:
```bash
./scripts/manage.sh start     # 🚀 Launch everything
./scripts/manage.sh stop      # 🛑 Stop all services
./scripts/manage.sh status    # 📊 Check system health
```

---

## 🚀 Usage Flow (Step-by-Step)

### Step A: Run Physics Simulation
Launches the RK4 integrator on the Dataproc cluster to calculate 10,000 photon geodesics.
```bash
./scripts/data/run_simulation.sh dev
```
**Diagram:**
```text
[ Physics (integrator.py) ] -> [ Spark RDD/DataFrame ] -> [ GCS (Parquet) ]
```

### Step B: Ingest into BigQuery
Transfers simulation results from GCS to the analytical warehouse.
```bash
./scripts/data/run_ingestion.sh dev overwrite
```
**Diagram:**
```text
[ GCS (Parquet) ] -> [ Spark-BQ Connector ] -> [ BigQuery (photon_paths) ]
```

### Step C: Explore in 3D
Run `./scripts/manage.sh start`, open [http://localhost:5173](http://localhost:5173), adjust the "RAY INTENSITY" slider, and click **Load Photons**.
**Diagram:**
```text
[ BigQuery ] -> [ FastAPI (BQ Client) ] -> [ JSON ] -> [ Three.js Line (BufferGeometry) ]
```

---

## 🛑 Project Shutdown & Cleanup

To avoid unnecessary GCP costs, follow these steps in order:

1.  **Stop Local Services:** `Ctrl+C` in API and Frontend terminals.
2.  **Destroy Infrastructure:**
    ```bash
    cd terraform/environments/dev
    terraform destroy
    ```
    *Note: Ensure `deletion_protection=false` is set in the BigQuery module if removing datasets.*
3.  **Clean Local Venv/Node:**
    ```bash
    rm -rf venv/
    rm -rf frontend/node_modules/
    ```

---

## 🛠️ Component Breakdown (ASCII)

### 1. Engine (Simulation)
```text
+-------------------+      +-------------------+      +-------------------+
|   simulation_job  | ---> |   integrator.py   | ---> |   GCS (Parquet)   |
| (PySpark Wrapper) |      | (RK4 Core Math)   |      | (Radial/Angular)  |
+-------------------+      +-------------------+      +-------------------+
```

### 2. API Bridge (Backend)
```text
+-------------------+      +-------------------+      +-------------------+
|      FastAPI      | <--- |  BigQuery Service | <--- |     BigQuery      |
| (main + routes)   |      | (SDK Auto-detect) |      | (Clustered Tables)|
+-------------------+      +-------------------+      +-------------------+
```

### 3. Visualizer (Frontend)
```text
+-------------------+      +-------------------+      +-------------------+
|      App.tsx      | ---> |  ThreeScene/R3F   | ---> |  GPU BufferGeom   |
| (UI + State)      |      | (Event Horizon)   |      | (Photon Traces)   |
+-------------------+      +-------------------+      +-------------------+
```

### 4. Unified App Manager (scripts/manage.sh)
```text
[ manage.sh ]
├── start   --> [ uvicorn (API) ] + [ vite (FE) ] + write *.pid
├── stop    --> read *.pid + kill processes + rm *.pid
├── restart --> stop + sleep + start
└── status  --> check ps for *.pids
```

🕶️✨ **Crafted with mathematical precision and cinematic aesthetics.** Noah. ✨🕶️
