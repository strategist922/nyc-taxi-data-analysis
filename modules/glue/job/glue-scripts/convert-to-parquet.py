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

applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("dispatching_base_num", "string", "dispatching_base_num", "string"), ("pickup_date", "string", "pickup_date", "date"), ("locationid", "long", "locationid", "long"), ("partition_0", "string", "partition_0", "string"), ("partition_1", "string", "partition_1", "string")], transformation_ctx = "applymapping1")

resolvechoice2 = ResolveChoice.apply(frame = applymapping1, choice = "make_struct", transformation_ctx = "resolvechoice2")

dropnullfields3 = DropNullFields.apply(frame = resolvechoice2, transformation_ctx = "dropnullfields3")

datasink4 = glueContext.write_dynamic_frame.from_options(
    frame = dropnullfields3, connection_type = "s3", connection_options = {
        "path": "s3://${bucketName}/parquet-data",
        "partitionKeys": ["partition_0", "partition_1"]
    }, format = "parquet", transformation_ctx = "datasink4")
job.commit()