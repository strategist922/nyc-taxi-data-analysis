import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "${bucketName}-data-database", table_name = "yellow", transformation_ctx = "datasource0")

applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [
    ("vendor_id", "string", "vendor_id", "string"),
    ("pickup_datetime", "string", "pickup_datetime", "date"),
    ("dropoff_datetime", "string", "dropoff_datetime", "date"),
    ("passenger_count", "long", "passenger_count", "long"),
    ("trip_distance", "string", "trip_distance", "string"),
    ("pickup_longitude", "string", "pickup_longitude", "string"),
    ("pickup_latitude", "string", "pickup_latitude", "string"),
    ("rate_code", "long", "rate_code", "long"),
    ("store_and_fwd_flag", "string", "store_and_fwd_flag", "string"),
    ("dropoff_longitude", "string", "dropoff_longitude", "string"),
    ("dropoff_latitude", "string", "dropoff_latitude", "string"),
    ("payment_type", "string", "payment_type", "string"),
    ("fare_amount", "double", "fare_amount", "double"),
    ("surcharge", "double", "surcharge", "double"),
    ("mta_tax", "double", "mta_tax", "double"),
    ("tip_amount", "string", "tip_amount", "string"),
    ("tolls_amount", "double", "tolls_amount", "double"),
    ("total_amount", "double", "total_amount", "double"),
    ("vendorid", "long", "vendorid", "long"),
    ("tpep_pickup_datetime", "string", "tpep_pickup_datetime", "string"),
    ("tpep_dropoff_datetime", "string", "tpep_dropoff_datetime", "string"),
    ("ratecodeid", "long", "ratecodeid", "long"),
    ("extra", "double", "extra", "double"),
    ("improvement_surcharge", "double", "improvement_surcharge", "double"),
    ("pulocationid", "long", "pulocationid", "long"),
    ("dolocationid", "long", "dolocationid", "long"),
    ("partition_0", "string", "partition_0", "string"),
    ("partition_1", "string", "partition_1", "string")
], transformation_ctx = "applymapping1")

resolvechoice2 = ResolveChoice.apply(frame = applymapping1, choice = "make_struct", transformation_ctx = "resolvechoice2")

dropnullfields3 = DropNullFields.apply(frame = resolvechoice2, transformation_ctx = "dropnullfields3")

datasink4 = glueContext.write_dynamic_frame.from_options(
    frame = dropnullfields3, connection_type = "s3", connection_options = {
        "path": "s3://${bucketName}/parquet-data/yellow",
        "partitionKeys": ["partition_0", "partition_1"]
    }, format = "parquet", transformation_ctx = "datasink4")
job.commit()

