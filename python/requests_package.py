from google.cloud import bigquery
import csv

def query_trips(type, postFix, year):
    client = bigquery.Client()
    # Set use_legacy_sql to True to use legacy SQL syntax.
    job_config = bigquery.QueryJobConfig()
    job_config.use_legacy_sql = True

    query_job = client.query("""
    SELECT *
    FROM
    (SELECT * FROM
    [nyc-tlc:""" + type + """.trips""" + postFix + """] WHERE YEAR( pickup_datetime ) = """ + year + """ 
    AND pickup_latitude <> 0 AND pickup_longitude <> 0 
    AND dropoff_latitude <> 0 AND dropoff_longitude <> 0 
    AND trip_distance > 0 AND fare_amount > 0)
    WHERE ABS(FARM_FINGERPRINT(STRING(pickup_datetime))) % 10 < 8
    LIMIT 50000
    """,
    job_config = job_config)

    results = query_job.result().to_dataframe()  # Waits for job to complete.
    results.to_csv(type + '_' + year + '.csv', encoding='utf-8')

query_trips('yellow','', '2014')
query_trips('yellow','', '2015')
query_trips('green','_2014', '2014')
query_trips('green','_2015', '2015')
