import argparse
import numpy as np
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, IntegerType, DoubleType
from integrator import trace_photon  # Assumes integrator.py is in the same directory

def run_simulation(photon_params):
    """
    Spark-compatible wrapper to trace a single photon.
    photon_params: (photon_id, t, r, theta, phi, pt, pr, ptheta, pphi)
    """
    photon_id, *initial_state = photon_params
    path = trace_photon(np.array(initial_state))
    
    results = []
    for step, state in enumerate(path):
        # Extract spatial coords: r, theta, phi
        r, theta, phi = state[1], state[2], state[3]
        results.append((int(photon_id), int(step), float(r), float(theta), float(phi)))
    
    return results

def main():
    parser = argparse.ArgumentParser(description="Black Hole Ray-Tracing Simulation")
    parser.add_argument("--output", required=True, help="GCS path for output Parquet files")
    parser.add_argument("--photons", type=int, default=10000, help="Number of photons to simulate")
    args, unknown = parser.parse_known_args()

    num_photons = args.photons
    output_path = args.output

    spark = SparkSession.builder \
        .appName("BlackHole-RayTracer-Phase2") \
        .getOrCreate()

    # Define output schema
    output_schema = StructType([
        StructField("photon_id", IntegerType(), False),
        StructField("step", IntegerType(), False),
        StructField("r", DoubleType(), False),
        StructField("theta", DoubleType(), False),
        StructField("phi", DoubleType(), False)
    ])

    print(f"--- Starting Distributed Ray-Tracing for {num_photons} photons ---")

    # 1. Generate Initial Conditions (Simple spherical shell / disk)
    # Positions are at r=20.0 (far away)
    r_start = 20.0
    
    def generate_ics():
        for i in range(num_photons):
            # Uniform distribution in phi (accretion disk view)
            phi = (2 * np.pi * i) / num_photons
            # Return (id, t, r, theta, phi, pt, pr, ptheta, pphi)
            # Initial momentum: mostly radial inward
            yield (i, 0.0, r_start, np.pi/2, phi, -1.0, -0.5, 0.0, 4.4)

    # 2. Parallelize using Spark RDD
    rdd_ics = spark.sparkContext.parallelize(generate_ics(), numSlices=100)
    
    # 3. FlatMap to run simulation and flatten results [ (id, step, r, th, ph), ... ]
    rdd_results = rdd_ics.flatMap(run_simulation)

    # 4. Convert to DataFrame and save
    df_results = spark.createDataFrame(rdd_results, schema=output_schema)
    df_results.write.mode("overwrite").parquet(output_path)
    
    print(f"--- Simulation Complete! Results saved to {output_path} ---")

if __name__ == "__main__":
    main()
