import boto3
import json
import logging
import os
import pymysql
import random
from boto3 import client
import traceback





logger = logging.getLogger()
logger.setLevel(logging.INFO)

#s3_paginator = boto3.client('s3').get_paginator('list_objects_v2')


def list_s3_objects(bucket_name):
    """
    Lists all objects in an S3 bucket.

    Args:
        bucket_name: The name of the S3 bucket.

    Returns:
        A list of object keys (names).
    """

    s3 = boto3.client('s3')  # Create an S3 client

    objects = []
    next_token = None

    while True:
        if next_token:
            response = s3.list_objects_v2(Bucket=bucket_name, NextContinuationToken=next_token)
        else:
            response = s3.list_objects_v2(Bucket=bucket_name)

        if 'Contents' in response:
            for obj in response['Contents']:
                objects.append(obj['Key'])

        next_token = response.get('NextContinuationToken')
        if not next_token:
            break

    return objects


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
            objects = []

            #Get environmental variables
            s3bucketname = os.environ['S3BUCKETNAME']
            region = os.environ['REGION']
            cloudfrontdistribution = os.environ['CLOUDFRONTDISTRIBUTION']
            http_method = event['httpMethod']


            if http_method == 'GET':
                object_keys = list_s3_objects(s3bucketname)

                #Iterate data set to create formed json
                n = len(object_keys)
                objects = []
                for i in range(n):
                    row_data = {}
                    row_data["key"] = object_keys[i]
                    row_data["url"] = cloudfrontdistribution + object_keys[i]
                    objects.append(row_data)

                logger.info("logger.info json_data=%s",items)

            elif http_method == 'DELETE':

                requestbody = json.loads(json.loads(event.get('body', '{}'), strict=False))
                numberOfKeys = 0

                objects = requestbody["Objects"]
            
                numberOfKeys = len(objects)
                operation = ""
                keysDeleted = ""

                if numberOfKeys == 1:
                    operation = "singleDelete"
                    s3 = boto3.client('s3')  
                    s3Key = objects[0].get('Key')
                    keysDeleted += s3Key + ","
                    s3.delete_object(Bucket=s3bucketname, Key=s3Key)
                elif numberOfKeys > 1:
                    operation = "multipleDelete"
                    s3 = boto3.client('s3') 
                    for i in range(len(objects)):
                        keysDeleted += objects[i].get('Key') + ","
                        s3.delete_objects(
                        Bucket=s3bucketname,
                            Delete={
                            'Objects': objects
                        }
                        )
                else:
                    operation = "none"
            else:
                logger.info("UNKNOWN HTTP Method")

        except Exception as e:
            exception = True
            logger.info("An error occurred:"+str(e))
            exceptionMessage = "Exception: "+str(e) +":"+traceback.format_exc()
        finally:
            logger.info("Finally")



         #Put together the response
        #items = []
        #row_data = {}
        #row_data["call"] = "objects"
        #row_data["objects"] = objects
        #row_data["requestbody"] = requestbody
        #row_data["exceptionOccurred"] = exceptionOccurred
        #row_data["exceptionMessage"] = exceptionMessage
        #items.append(row_data)



        return {
            'statusCode': 200,
             'headers': {
                "Access-Control-Allow-Origin" : "*", 
                "Access-Control-Allow-Credentials" : "true",
                "Access-Control-Allow-Methods": 'GET, POST, PUT, DELETE, OPTIONS'
                },
            'body': json.dumps(objects)
        }
    except Exception as e:
        logger.error('Error during Lambda execution', exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }
