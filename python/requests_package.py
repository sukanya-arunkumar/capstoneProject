from google.cloud import bigquery
import csv

def query_trips(type, postFix = ""):
    client = bigquery.Client()
    # Set use_legacy_sql to True to use legacy SQL syntax.
    job_config = bigquery.QueryJobConfig()
    job_config.use_legacy_sql = True

    query_job = client.query("""
    SELECT *
    FROM [nyc-tlc:""" + type + """.trips""" + postFix + """]
    WHERE ABS(FARM_FINGERPRINT(CONCAT(STRING(pickup_longitude), STRING(pickup_latitude), STRING(pickup_datetime), STRING( dropoff_datetime)))) % 10 < 8
    LIMIT 50000
    """,
    job_config = job_config)

    results = query_job.result().to_dataframe()  # Waits for job to complete.
    results.to_csv(type + postFix + '.csv', encoding='utf-8')

query_trips('yellow')
query_trips('green', '_2014')
query_trips('green', '_2015')
