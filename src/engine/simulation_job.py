import argparse
import numpy as np
from typing import List, Tuple, Generator, Any
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, IntegerType, DoubleType
from integrator import trace_photon


def run_simulation(photon_params: Tuple[Any, ...]) -> List[Tuple[int, int, float, float, float]]:
    """Spark-compatible wrapper to trace a single photon trajectory.

    Args:
        photon_params: A tuple containing (photon_id, t, r, theta, phi, pt, pr, ptheta, pphi).

    Returns:
        A list of tuples, each representing a step in the photon's path:
        (photon_id, step_index, r, theta, phi).
    """
    photon_id, *initial_state = photon_params
    # convert initial_state list to numpy array for the integrator
    trajectory = trace_photon(np.array(initial_state))
    
    path_data = []
    for step_index, state in enumerate(trajectory):
        # state indices: 1=r, 2=theta, 3=phi
        r, theta, phi = state[1], state[2], state[3]
        path_data.append((int(photon_id), int(step_index), float(r), float(theta), float(phi)))
    
    return path_data


def main() -> None:
    """Main entry point for the distributed simulation job."""
    parser = argparse.ArgumentParser(description="Black Hole Ray-Tracing Distributed Simulation")
    parser.add_argument("--output", required=True, help="GCS destination path for Parquet results")
    parser.add_argument("--photons", type=int, default=10000, help="Total number of photons to simulate")
    args, _ = parser.parse_known_args()

    num_photons: int = args.photons
    output_path: str = args.output

    spark = SparkSession.builder \
        .appName("BlackHole-RayTracer-Phase2") \
        .getOrCreate()

    # Define the output schema for BigQuery compatibility
    schema = StructType([
        StructField("photon_id", IntegerType(), False),
        StructField("step", IntegerType(), False),
        StructField("r", DoubleType(), False),
        StructField("theta", DoubleType(), False),
        StructField("phi", DoubleType(), False)
    ])

    print(f"--- Starting Distributed Ray-Tracing for {num_photons} photons ---")

    # 1. Generate Initial Conditions (Spherical shell at far-field radius)
    initial_radius = 20.0
    
    def initial_conditions_generator() -> Generator[Tuple[Any, ...], None, None]:
        """Generates starting parameters for each photon."""
        for i in range(num_photons):
            # Uniform distribution in phi for an accretion disk perspective
            phi = (2.0 * np.pi * i) / num_photons
            # Yielding: (id, t, r, theta, phi, pt, pr, ptheta, pphi)
            # Initial momentum: combination of capture and orbital velocity
            yield (i, 0.0, initial_radius, np.pi / 2.0, phi, -1.0, -0.5, 0.0, 4.4)

    # 2. Parallelize using Spark RDD
    # Using 100 slices to ensure even distribution across Dataproc workers
    ics_rdd = spark.sparkContext.parallelize(initial_conditions_generator(), numSlices=100)
    
    # 3. FlatMap: map one IC to many path steps
    results_rdd = ics_rdd.flatMap(run_simulation)

    # 4. Convert to DataFrame and write to GCS as Parquet
    results_df = spark.createDataFrame(results_rdd, schema=schema)
    results_df.write.mode("overwrite").parquet(output_path)
    
    print(f"--- Simulation Complete! Results saved to {output_path} ---")


if __name__ == "__main__":
    main()
