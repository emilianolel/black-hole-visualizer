# 🌑 Black Hole Visualizer - Infrastructure

Este sub-proyecto contiene la infraestructura optimizada para la simulación de geodésicas y renderizado de lentes gravitatorias utilizando **Google Cloud Dataproc** y **BigQuery**.

## 🚀 Inicio Rápido

1.  **Instalación**: Ejecuta el script de requerimientos si no lo has hecho.
    ```bash
    bash terraform/scripts/install_requirements.sh
    ```
2.  **Bootstrap**: Inicializa el proyecto con el script dedicado (habilita APIs automáticamente).
    ```bash
    bash terraform/scripts/init.sh PROJECT_ID STATE_BUCKET REGION OPERATOR_EMAIL
    ```
3.  **Sincronización**: Si el proyecto ya existía o cambias de identificadores, usa el script de sincronización:
    ```bash
    bash terraform/scripts/sync-project.sh PROJECT_ID STATE_BUCKET REGION OPERATOR_EMAIL
    ```
4.  **Configuración**:
    *   Copia `terraform/environments/dev/terraform.tfvars.example` a `terraform.tfvars`. (Ya no es necesario si usaste el paso anterior, pero sirve para personalización extra).
5.  **Despliegue**:
    ```bash
    cd terraform/environments/dev
    terraform init -reconfigure
    terraform apply
    ```

## 🛠️ Herramientas de Monitoreo

*   `bash terraform/scripts/audit.sh`: Lista los recursos activos del visualizador.
*   `bash terraform/scripts/costs.sh`: Reporte de costos específico para este proyecto.

---
Métrica de Schwarzschild | RK4 Integration | Distributed PySpark
