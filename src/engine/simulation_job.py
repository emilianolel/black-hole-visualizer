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
    
    # 1. Define IC Schema explicitly
    ic_schema = StructType([
        StructField("photon_id", IntegerType(), False),
        StructField("t0", DoubleType(), False),
        StructField("r0", DoubleType(), False),
        StructField("theta0", DoubleType(), False),
        StructField("phi0", DoubleType(), False),
        StructField("pt0", DoubleType(), False),
        StructField("pr0", DoubleType(), False),
        StructField("ptheta0", DoubleType(), False),
        StructField("pphi0", DoubleType(), False)
    ])

    # 2. Generate Initial Conditions (Pro Mirroring approach)
    num_photons = 10000
    r_start = 20.0
    
    # We use a generator to keep driver memory footprint minimal
    def generate_ics():
        for i in range(num_photons):
            phi = (2 * np.pi * i) / num_photons
            yield (i, 0.0, r_start, np.pi/2, phi, -1.0, -0.5, 0.0, 4.4)

    # 3. Create RDD first (More stable than direct DataFrame from list in some Spark versions)
    ic_rdd = sc.parallelize(list(generate_ics()))
    df_ic = spark.createDataFrame(ic_rdd, schema=ic_schema)
    
    # 4. Process partition-wise for maximum parallelism
    rdd_results = df_ic.rdd.mapPartitionsWithIndex(run_simulation)
    
    # 5. Define Output Schema
    output_schema = StructType([
        StructField("photon_id", IntegerType(), False),
        StructField("step", IntegerType(), False),
        StructField("r", DoubleType(), False),
        StructField("theta", DoubleType(), False),
        StructField("phi", DoubleType(), False)
    ])
    
    # 6. Save results to GCS
    output_path = "gs://black-hole-visualizer-project-bh-vis-dataproc-config/sim_results/phase2_test"
    
    print(f"--- Starting Distributed Ray-Tracing for {num_photons} photons ---")
    df_results = spark.createDataFrame(rdd_results, schema=output_schema)
    df_results.write.mode("overwrite").parquet(output_path)
    
    print(f"--- Simulation Complete! Results saved to {output_path} ---")

if __name__ == "__main__":
    main()
