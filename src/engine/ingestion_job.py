import argparse
from pyspark.sql import SparkSession


def main() -> None:
    """Main entry point for the BigQuery data ingestion job.
    
    This script reads Parquet files from GCS and loads them into a BigQuery table
    using the Spark-BigQuery connector.
    """
    parser = argparse.ArgumentParser(description="Ingest simulation data from GCS to BigQuery")
    parser.add_argument("--source", required=True, help="GCS URI to source Parquet files")
    parser.add_argument(
        "--mode", 
        default="append", 
        choices=["append", "overwrite"], 
        help="Write mode (append/overwrite)"
    )
    parser.add_argument(
        "--target", 
        default="black_hole_sims.photon_paths", 
        help="Target BigQuery table (dataset.table)"
    )
    
    args = parser.parse_args()

    spark = SparkSession.builder \
        .appName("BlackHole-DataIngestor") \
        .getOrCreate()

    print("--- Starting Ingestion ---")
    print(f"Source: {args.source}")
    print(f"Target: {args.target}")
    print(f"Mode:   {args.mode}")

    try:
        # 1. Read Parquet from GCS
        # Spark automatically infers the schema from Parquet metadata
        df = spark.read.parquet(args.source)
        
        # 2. Log count for verification before loading
        row_count = df.count()
        print(f"Counted {row_count} rows in source Parquet.")

        # 3. Write to BigQuery
        # The connector handles intermediate GCS staging for optimal performance
        df.write \
            .format("bigquery") \
            .option("table", args.target) \
            .mode(args.mode) \
            .save()

        print("--- Ingestion Complete! ---")
    except Exception as e:
        print(f"❌ Ingestion failed: {str(e)}")
    finally:
        spark.stop()


if __name__ == "__main__":
    main()
