# 🌑 Black Hole Visualizer - Infrastructure

This sub-project contains the optimized infrastructure for geodesic simulation and gravitational lensing rendering using **Google Cloud Dataproc** and **BigQuery**.

## 🚀 Quickstart

1.  **Installation**: Run the requirements script if you haven't already.
    ```bash
    bash terraform/scripts/install_requirements.sh
    ```
2.  **Bootstrap**: Initialize the project with the dedicated script (enables APIs automatically).
    ```bash
    bash terraform/scripts/init.sh PROJECT_ID STATE_BUCKET REGION OPERATOR_EMAIL
    ```
3.  **Synchronization**: If the project already existed or you change identifiers, use the sync script:
    ```bash
    bash terraform/scripts/sync-project.sh PROJECT_ID STATE_BUCKET REGION OPERATOR_EMAIL
    ```
4.  **Configuration**:
    *   Copy `terraform/environments/dev/terraform.tfvars.example` to `terraform.tfvars`. (No longer required if you used the previous step, but useful for extra customization).
5.  **Deployment**:
    ```bash
    cd terraform/environments/dev
    terraform init -reconfigure
    terraform apply
    ```

## 🛠️ Monitoring Tools

*   `bash terraform/scripts/audit.sh`: Lists the active resources for the visualizer.
*   `bash terraform/scripts/costs.sh`: Specific cost report for this project.

---
Schwarzschild Metric | RK4 Integration | Distributed PySpark
