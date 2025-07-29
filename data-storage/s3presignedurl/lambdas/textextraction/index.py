import boto3
import json
import logging
import os
import pymysql
import random
import json
from botocore.exceptions import ClientError
from datetime import datetime
from boto3.dynamodb.conditions import Key, Attr
from zoneinfo import ZoneInfo
import base64
import traceback

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):

    logger.info("Starting text extraction")
    try:
        try:
            #initialized output values
            exceptionOccurred = False
            exceptionMessage = ""

            s3bucketname = os.environ['S3BUCKETNAME']
            region = os.environ['REGION']
            cloudfrontdistribution = os.environ['CLOUDFRONTDISTRIBUTION']
            textract_role = os.environ['TEXTRACT_ROLE_ARN']
            topic_arn = os.environ['TEXTRACT_NOTIFICATION_TOPIC']

            s3 = boto3.client('s3')
            textract = boto3.client('textract')

            records = event.get('Records', '{}')
            key = ""
            size = 0
            for i in range(len(records)):
                s3json = records[i].get("s3")
                bucketjson = s3json.get("bucket")
                objectjson = s3json.get("object")
                key = objectjson.get("key")
                size = objectjson.get("size")

                # Start Textract asynchronous processing, use env vars
                response = textract.start_document_text_detection(
                DocumentLocation={
                    'S3Object': {
                        'Bucket': s3bucketname,
                        'Name': key
                    }
                },
                NotificationChannel={
                    'SNSTopicArn': topic_arn,
                    'RoleArn': textract_role
                },
                JobTag='MyCustomDocumentType' # Your custom job tag
              )
                job_id = response['JobId']
                logger.info(f"Textract job started with JobId: {job_id}")

                logger.info(f"File {key} is sent to Textract.")
                textractstatus = boto3.client('textract')
                response = textractstatus.get_document_text_detection(JobId=job_id)
                logger.info(f"Textract response. get_document_analysis: {response}")

        except Exception as e:
            exception = True
            logger.info("An error occurred:"+str(e))
            exceptionMessage = "Exception: "+str(e) +":"+traceback.format_exc()
        finally:
            logger.info("Finally")

         #Put together the response
        items = []
        row_data = {}
        row_data["call"] = "textextraction"
        row_data["event"] = event
        row_data["records"] = records
        row_data["key"] = records
        row_data["size"] = str(size)
        row_data["exceptionOccurred"] = exceptionOccurred
        row_data["exceptionMessage"] = exceptionMessage
        items.append(row_data)

        logger.info("items="+json.dumps(items))
        return {
            'statusCode': 200,
             'headers': {
                "Access-Control-Allow-Origin" : "*", 
                "Access-Control-Allow-Credentials" : "true",
                "Access-Control-Allow-Methods": 'GET, POST, PUT, DELETE, OPTIONS'
                },
            'body': json.dumps(items)
        }
    except Exception as e:
        logger.error('Error during Lambda execution', exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }
