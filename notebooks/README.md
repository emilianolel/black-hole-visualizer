# 📓 Research & Validation Notebooks

This directory contains research and validation notebooks that run locally but execute on the **GCP Dataproc Cluster**.

## 🏗️ Connection & Execution Architecture

```text
    [ LOCAL WORKSTATION ]                   [ GOOGLE CLOUD PLATFORM (GCP) ]
   +-----------------------+               +-------------------------------------+
   |  VS Code / Jupyter    |               |       Dataproc Compute Cluster      |
   |  (Frontend Interface) |               |                                     |
   +-----------+-----------+               |   +-----------------------------+   |
               |                           |   |      MASTER NODE (VM)       |   |
               v                           |   |                             |   |
   +-----------+-----------+               |   |  +-----------------------+  |   |
   | Local Port 8888       | <==[ SSH ]====|==>|  | Jupyter Gateway (8123)|  |   |
   +-----------+-----------+      Tunnel   |   |  +-----------+-----------+  |   |
               ^             (via IAP)     |   |              |              |   |
               |                           |   |              v              |   |
               |                           |   |  +-----------------------+  |   |
      (Kernel Requests)                    |   |  |  Spark Driver Kernel  |  |   |
               |                           |   |  +-----------+-----------+  |   |
               |                           |   +--------------|--------------+   |
               |                           |                  |                  |
               |                           |        (Distributed Tasks)          |
               |                           |                  v                  |
               |                           |   +--------------+--------------+   |
               |                           |   |      WORKER NODES (n)       |   |
               |                           |   +--------------+--------------+   |
               |                           |                  |                  |
               +---------------------------|------------------+                  |
                                           |                  v                  |
                                           |   +--------------+--------------+   |
                                           |   |   GCS/BigQuery Data Lake    |   |
                                           |   +-----------------------------+   |
                                           +-------------------------------------+
```

## 🧪 Validation Process Flowchart (RK4)

This diagram describes the internal logic of `physics_validation.ipynb` and `integrator.py`:

```text
    +-----------------------+
    | 1. INITIAL CONDITIONS | (t0, r0, θ0, φ0, pt0, pr0, pθ0, pφ0)
    +-----------+-----------+
                |
                v
    +-----------+-----------+ <-----------+
    | 2. RK4 STEP FUNCTION  |             |
    | (Runge-Kutta 4th Ord) |             |
    +-----------+-----------+             |
                |                         |
                v                         |
    +-----------+-----------+             |
    | 3. BOUNDARY CHECK     |             | (Loop for
    +-----------+-----------+             |  max_steps)
       /                 \                |
      v                   v               |
 [ Captured? ]      [ Escaped? ]          |
 ( r <= 2M )         ( r > 100M )         |
      |                   |               |
      +---------+---------+               |
                |                         |
          [ NO (Default) ] ---------------+
                |
                v (YES / Max Steps)
    +-----------------------+
    | 4. COORDINATE TRANSF. | (Boyer-Lindquist -> Quasi-Cartesian)
    | x = r * cos(φ)        |
    | y = r * sin(φ)        |
    +-----------+-----------+
                |
                v
    +-----------------------+
    | 5. VISUALIZATION      | (Matplotlib Plot)
    | - Event Horizon (2M)  |
    | - Photon Sphere (3M)  |
    | - Traced Light Path   |
    +-----------------------+
```

## 🚀 How to Connect

1.  **Authorize GCP**: Ensure you have logged in with `gcloud auth login`.
2.  **Start the Tunnel**: Run the automation script from the project root:
    ```bash
    chmod +x scripts/dev/connect-jupyter.sh
    ./scripts/dev/connect-jupyter.sh dev
    ```
3.  **Copy the URL**: The script will print a URL containing a `token` 🎫, for example:
    `http://localhost:8888/gateway/default/jupyter/?token=abcdef123...`

## 💻 Integration with VS Code

1.  Open any `.ipynb` file in this directory.
2.  Click on **"Select Kernel"** in the top right corner.
3.  Choose **"Existing Jupyter Server"**. 🔌
4.  Paste the **full URL** provided by the script (ensure it includes the `/gateway/default/jupyter/` path).
5.  Select the **PySpark** kernel from the list.

## 🛑 Stop the Session

To close the tunnel and free up your local port, run:
```bash
./scripts/dev/connect-jupyter.sh --stop
```
