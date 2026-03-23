import argparse
from pyspark.sql import SparkSession

def main():
    parser = argparse.ArgumentParser(description="Ingest simulation data from GCS to BigQuery")
    parser.add_argument("--source", required=True, help="GCS path to source Parquet files")
    parser.add_argument("--mode", default="append", choices=["append", "overwrite"], help="Write mode (append/overwrite)")
    parser.add_argument("--target", default="black_hole_sims.photon_paths", help="Target BigQuery table (dataset.table)")
    
    args = parser.parse_args()

    spark = SparkSession.builder \
        .appName("BlackHole-DataIngestor") \
        .getOrCreate()

    print(f"--- Starting Ingestion ---")
    print(f"Source: {args.source}")
    print(f"Target: {args.target}")
    print(f"Mode:   {args.mode}")

    # 1. Read Parquet from GCS
    df = spark.read.parquet(args.source)
    
    # 2. Log count for verification
    count = df.count()
    print(f"Counted {count} rows in source Parquet.")

    # 3. Write to BigQuery
    # The connector uses a GCS bucket for intermediate storage (BigQuery indirect write)
    df.write \
        .format("bigquery") \
        .option("table", args.target) \
        .mode(args.mode) \
        .save()

    print(f"--- Ingestion Complete! ---")
    spark.stop()

if __name__ == "__main__":
    main()
