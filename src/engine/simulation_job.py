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
    Worker-side generator. Accessing row by attribute for performance.
    """
    for row in iterator:
        photon_id = row.photon_id
        initial_state = np.array([
            row.t0, row.r0, row.theta0, row.phi0,
            row.pt0, row.pr0, row.ptheta0, row.pphi0
        ])
        
        path = integrator.trace_photon(initial_state, step_size=0.1, max_steps=500)
        
        for i, state in enumerate(path):
            yield (int(photon_id), int(i), float(state[1]), float(state[2]), float(state[3]))

def generate_initial_conditions(photon_id, num_photons):
    """
    Worker-side function to generate initial conditions.
    """
    phi = (2 * np.pi * float(photon_id)) / num_photons
    return (int(photon_id), 0.0, 20.0, float(np.pi/2), float(phi), -1.0, -0.5, 0.0, 4.4)

def main():
    spark = SparkSession.builder \
        .appName("BlackHole-RayTracer-Phase2-Production") \
        .getOrCreate()
    
    # 1. Define Explicit Schemas (Crucial for stability)
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

    result_schema = StructType([
        StructField("photon_id", IntegerType(), False),
        StructField("step", IntegerType(), False),
        StructField("r", DoubleType(), False),
        StructField("theta", DoubleType(), False),
        StructField("phi", DoubleType(), False)
    ])

    # 2. Distributed Generation 
    num_photons = 100000 
    
    rdd_ic = spark.range(num_photons).repartition(200).rdd \
        .map(lambda x: generate_initial_conditions(x.id, num_photons))
    
    df_ic = spark.createDataFrame(rdd_ic, ic_schema)
    
    # 3. Distributed Integration
    print("Launching relativistic ray-tracing across executors...")
    rdd_results = df_ic.rdd.mapPartitionsWithIndex(run_simulation)
    
    # 4. Save to GCS
    output_path = "gs://black-hole-visualizer-project-bh-vis-dataproc-config/sim_results/phase2_pro"
    print(f"Tracking results and writing to {output_path}...")
    
    df_results = spark.createDataFrame(rdd_results, result_schema)
    df_results.write.mode("overwrite").parquet(output_path)
    
    print(f"🏁 Simulation Successful! Results saved to {output_path}")

if __name__ == "__main__":
    main()
