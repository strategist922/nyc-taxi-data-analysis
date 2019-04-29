import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, when
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.types import DoubleType

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Step 0 ----------------------------------------
# Initialization of Glue Dynamic Frame
step0 = glueContext.create_dynamic_frame.from_catalog(
    database = "${bucketName}-data-database",
    table_name = "yellow",
    transformation_ctx = "step0"
)

# Convert to Spark Data Frame
spark_df = step0.toDF()

# Step 1 ----------------------------------------
if "vendor_id" and "vendorid" in spark_df.columns:
    step1 = spark_df.withColumn("vendor", when((col("vendor_id").cast('string').isNull()), col("vendorid").cast('string'))
                                .when((col("vendorid").cast('string').isNull()), col("vendor_id").cast('string'))
                                )
else:
    if "vendor_id" in spark_df.columns:
        step1 = spark_df.withColumn("vendor", col("vendor_id").cast('string'))
    if "vendorid" in spark_df.columns:
        step1 = spark_df.withColumn("vendor", col("vendorid").cast('string'))

# Step 2 ----------------------------------------
if "pickup_datetime" and "tpep_pickup_datetime" in step1.columns:
    step2 = step1.withColumn("pickup_timestamp", when((col("pickup_datetime").isNull()), col("tpep_pickup_datetime"))
                             .when((col("tpep_pickup_datetime").isNull()), col("pickup_datetime"))
                             )
else:
    if "pickup_datetime" in step1.columns:
        step2 = step1.withColumn("pickup_timestamp", col("pickup_datetime"))
    if "tpep_pickup_datetime" in step1.columns:
        step2 = step1.withColumn("pickup_timestamp", col("tpep_pickup_datetime"))

# Step 3 ----------------------------------------
if "dropoff_datetime" and "tpep_dropoff_datetime" in step2.columns:
    step3 = step2.withColumn("dropoff_timestamp", when((col("dropoff_datetime").isNull()), col("tpep_dropoff_datetime"))
                             .when((col("tpep_dropoff_datetime").isNull()), col("dropoff_datetime"))
                             )
else:
    if "dropoff_datetime" in step2.columns:
        step3 = step2.withColumn("dropoff_timestamp", col("dropoff_datetime"))
    if "tpep_dropoff_datetime" in step2.columns:
        step3 = step2.withColumn("dropoff_timestamp", col("tpep_dropoff_datetime"))

# Convert back to Glue DynamicFrame
glue_df = DynamicFrame.fromDF(step3, glueContext, "glue_df")

# Step 4 ----------------------------------------
step4 = ApplyMapping.apply(
    frame = glue_df,
    mappings = [
        ("vendor", "string", "vendor", "string"),
        ("pickup_timestamp", "string", "pickup_timestamp", "timestamp"),
        ("dropoff_timestamp", "string", "dropoff_timestamp", "timestamp"),
        ("pickup_longitude", "string", "pickup_longitude", "string"),
        ("pickup_latitude", "string", "pickup_latitude", "string"),
        ("dropoff_longitude", "string", "dropoff_longitude", "string"),
        ("dropoff_latitude", "string", "dropoff_latitude", "string"),
        ("passenger_count", "long", "passenger_count", "long"),
        ("trip_distance", "string", "trip_distance", "double"),
        ("rate_code", "long", "rate_code", "long"),
        ("store_and_fwd_flag", "string", "store_and_fwd_flag", "string"),
        ("payment_type", "string", "payment_type", "string"),
        ("fare_amount", "double", "fare_amount", "double"),
        ("surcharge", "double", "surcharge", "double"),
        ("mta_tax", "double", "mta_tax", "double"),
        ("tip_amount", "string", "tip_amount", "string"),
        ("tolls_amount", "double", "tolls_amount", "double"),
        ("total_amount", "double", "total_amount", "double"),
        ("tpep_pickup_datetime", "string", "tpep_pickup_datetime", "string"),
        ("tpep_dropoff_datetime", "string", "tpep_dropoff_datetime", "string"),
        ("ratecodeid", "long", "ratecodeid", "long"),
        ("extra", "double", "extra", "double"),
        ("improvement_surcharge", "double", "improvement_surcharge", "double"),
        ("pulocationid", "long", "pulocationid", "long"),
        ("dolocationid", "long", "dolocationid", "long"),
        ("partition_0", "string", "year", "string"),
        ("partition_1", "string", "month", "string")
    ],
    transformation_ctx = "step4"
)

# Step 5 ----------------------------------------
step5 = ResolveChoice.apply(frame = step4, choice = "make_struct", transformation_ctx = "step5")


# Step 6 ----------------------------------------
step6 = DropNullFields.apply(frame = step5, transformation_ctx = "step6")


# Step 7 ----------------------------------------
step7 = glueContext.write_dynamic_frame.from_options(
    frame = step6,
    connection_type = "s3",
    connection_options = {
        "path": "s3://${bucketName}/parquet-data/yellow",
        "partitionKeys":
            [
                "year",
                "month"
            ]
    },
    format = "parquet",
    transformation_ctx = "step7")

job.commit()