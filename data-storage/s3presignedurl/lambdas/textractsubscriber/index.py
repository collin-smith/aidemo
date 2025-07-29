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

#Sample request body
#{
#    "prompt" : "John, Larry, and Tom are programmers and Tim and Boris are project managers. I have a project that requires 2 programmers and one project manager. Can you give me a set of names that will satisfy my project requirements?"
#}
# 


def handler(event, context):

    logger.info("Textract subscriber")
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

            #requestbody = json.loads(json.loads(event.get('body', '{}'), strict=False))
            s3 = boto3.client('s3')
            textract = boto3.client('textract')
            logger.info("Inside the textract subscriber")

            for record in event['Records']:
                # The SNS message with job information
                sns_message = json.loads(record['Sns']['Message'])
            
                # Accessing the keys for getting Textract results
                job_id = sns_message['JobId']
                status = sns_message['Status']
                # Accessing the keys for destination
                bucket = sns_message['DocumentLocation']['S3Bucket']
                s3_object_key = sns_message['DocumentLocation']['S3ObjectName']
                #file_name = s3_object_key.split('/')[1].split('.')[0]
                file_name = s3_object_key
                if status == 'SUCCEEDED':
                    # Proceed to get the document text detection results
                    response = textract.get_document_text_detection(JobId=job_id)
                    # Collect extracted text
                    detected_text = []
                    for item in response.get('Blocks', []):
                        if item['BlockType'] == 'LINE':
                            detected_text.append(item['Text'])

                    # Save collected text to S3
                    output_key = f"textract/{file_name}.txt"
                    s3.put_object(
                        Bucket=bucket,
                        Key=output_key,
                        Body="\n".join(detected_text)
                    )

                    logger.info(f"Detected text is written to S3/{output_key}")

                elif status == 'FAILED':
                    logger.error(f"Job {job_id} failed.")

        except KeyError as e:
            logger.error(f"KeyError: Missing expected key {str(e)}  in the message: {sns_message}")
            exception = True
            logger.info("An error occurred:"+str(e))
            exceptionMessage = "Exception KeyError: "+str(e) +"in the message: "+str(sns_message)+":"+traceback.format_exc()
        except Exception as e:
            logger.error(f"Error processing job {job_id}: {str(e)}")
            exception = True
            logger.info("An error occurred:"+str(e))
            exceptionMessage = "Exception: "+str(e) +"in the message: "+str(sns_message)+":"+traceback.format_exc()
        finally:
            logger.info("Finally")



         #Put together the response
        items = []
        row_data = {}
        row_data["call"] = "textextractsubscriber"
        row_data["event"] = event
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
