# 🌑 Black Hole Visualizer - Infrastructure

Este sub-proyecto contiene la infraestructura optimizada para la simulación de geodésicas y renderizado de lentes gravitatorias utilizando **Google Cloud Dataproc** y **BigQuery**.

## 🚀 Inicio Rápido

1.  **Instalación**: Ejecuta el script de requerimientos si no lo has hecho.
    ```bash
    bash terraform/scripts/install_requirements.sh
    ```
2.  **Bootstrap**: Inicializa el proyecto con el script dedicado.
    ```bash
    bash terraform/scripts/init.sh PROJECT_ID STATE_BUCKET REGION OPERATOR_EMAIL
    ```
3.  **Configuración**:
    *   Copia `terraform/environments/dev/terraform.tfvars.example` a `terraform.tfvars`.
    *   Ajusta tu `project_id` y el email de la SA creada en el paso anterior.
4.  **Despliegue**:
    ```bash
    cd terraform/environments/dev
    terraform init
    terraform apply
    ```

## 🛠️ Herramientas de Monitoreo

*   `bash terraform/scripts/audit.sh`: Lista los recursos activos del visualizador.
*   `bash terraform/scripts/costs.sh`: Reporte de costos específico para este proyecto.

---
Métrica de Schwarzschild | RK4 Integration | Distributed PySpark
