import sys
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, DoubleType, ArrayType, IntegerType
import numpy as np

# Import our custom integrator (assuming it's on the Python path or sent via --py-files)
try:
    import integrator
except ImportError:
    # If running locally or as a script, we might need a relative import
    import src.engine.integrator as integrator

def run_simulation(partition_id, iterator):
    """
    Worker-side function to process a batch of photons.
    """
    results = []
    for row in iterator:
        photon_id = row['photon_id']
        # Initial state: [t, r, theta, phi, pt, pr, ptheta, pphi]
        initial_state = np.array([
            row['t0'], row['r0'], row['theta0'], row['phi0'],
            row['pt0'], row['pr0'], row['ptheta0'], row['pphi0']
        ])
        
        # Perform the trace
        path = integrator.trace_photon(initial_state, step_size=0.1, max_steps=500)
        
        # Flatten the path for storage [step_index, r, theta, phi]
        # We only store spatial coordinates to save space
        for i, state in enumerate(path):
            results.append((photon_id, i, float(state[1]), float(state[2]), float(state[3])))
            
    return iter(results)

def main():
    spark = SparkSession.builder \
        .appName("BlackHole-RayTracer-Phase2") \
        .getOrCreate()

    sc = spark.sparkContext
    
    # 1. Generate Initial Conditions (Simple dummy grid for testing)
    # In a real run, this would be a complex camera model
    num_photons = 1000
    r_start = 20.0
    initial_conditions = []
    
    for i in range(num_photons):
        phi = (2 * np.pi * i) / num_photons
        ic = {
            "photon_id": i,
            "t0": 0.0, "r0": r_start, "theta0": np.pi/2, "phi0": phi,
            "pt0": -1.0, "pr0": -0.5, "ptheta0": 0.0, "pphi0": 4.4 # Targeted at BH
        }
        initial_conditions.append(ic)

    # 2. Distribute with Spark
    df_ic = spark.createDataFrame(initial_conditions)
    
    # 3. Process partition-wise for efficiency
    rdd_results = df_ic.rdd.mapPartitionsWithIndex(run_simulation)
    
    # 4. Define Output Schema
    schema = StructType([
        StructField("photon_id", IntegerType(), False),
        StructField("step", IntegerType(), False),
        StructField("r", DoubleType(), False),
        StructField("theta", DoubleType(), False),
        StructField("phi", DoubleType(), False)
    ])
    
    # 5. Save results to GCS (Path from project metadata)
    output_path = "gs://black-hole-visualizer-project-bh-vis-dataproc-config/sim_results/phase2_test"
    
    df_results = spark.createDataFrame(rdd_results, schema)
    df_results.write.mode("overwrite").parquet(output_path)
    
    print(f"--- Simulation Complete! Results saved to {output_path} ---")

if __name__ == "__main__":
    main()
