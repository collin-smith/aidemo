import boto3
import json
import logging
import os
import pymysql
import random
from botocore.exceptions import ClientError
import traceback


logger = logging.getLogger()
logger.setLevel(logging.INFO)



def create_presigned_post(
    bucket_name, object_name, fields=None, conditions=None, expiration=3600
):
    """Generate a presigned URL S3 POST request to upload a file

    :param bucket_name: string
    :param object_name: string
    :param fields: Dictionary of prefilled form fields
    :param conditions: List of conditions to include in the policy
    :param expiration: Time in seconds for the presigned URL to remain valid
    :return: Dictionary with the following keys:
        url: URL to post to
        fields: Dictionary of form fields and values to submit with the POST
    :return: None if error.
    """

    # Generate a presigned S3 POST URL
    s3_client = boto3.client('s3')
    try:
        response = s3_client.generate_presigned_post(
            bucket_name,
            object_name,
            Fields=fields,
            Conditions=conditions,
            ExpiresIn=expiration,
        )
    except ClientError as e:
        logging.error(e)
        return None

    # The response contains the presigned URL and required fields
    return response

#Sample request body
#{
#  "objectname":"myimage.jpg"
#}

def handler(event, context):

    logger.info("Starting lambda execution")
    try:
        try:
            exceptionOccurred = False
            exceptionMessage = ""

            requestbody = json.loads(event.get('body', '{}'))
            objectname = requestbody['objectname']

            s3bucketname = os.environ['S3BUCKETNAME']
            region = os.environ['REGION']
            cloudfrontdistribution = os.environ['CLOUDFRONTDISTRIBUTION']

            #Expiration in seconds (3600/1hour)
            expiration = "3600"
            presignedUrl = "UNDEFINED"
            presignedUrl = create_presigned_post(s3bucketname, objectname)

            success = True

        except Exception as e:
            exception = True
            logger.info("An error occurred:"+str(e))
            exceptionMessage = "Exception: "+str(e) +":"+traceback.format_exc()
        finally:
            logger.info("Finally")



         #Start to formulate the response
        json_data = [{
             "success" : success,
             "objectname" : objectname,
             "expirationInSeconds" : expiration,             
             "presignedUrl" : presignedUrl,
             "exceptionOccurred" : exceptionOccurred,
             "exceptionMessage" : exceptionMessage
             }]
    
        logger.info("logger.info json_data=%s",json_data)

        return {
            'statusCode': 200,
             'headers': {
                "Access-Control-Allow-Origin" : "*", 
                "Access-Control-Allow-Credentials" : "true",
                "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS"
                },
            'body': json.dumps(json_data)
        }
    except Exception as e:
        logger.error('Error during Lambda execution', exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }
