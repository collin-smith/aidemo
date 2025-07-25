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
#    "prompt" : "Draw an image of a mountain climber."
#}
# 
def get_bedrock_client(region_name='us-east-1'):
    """
    Creates and returns a Bedrock client.

    Args:
        region_name (str, optional): The AWS region. Defaults to 'us-east-1'.

    Returns:
        boto3.client: A Bedrock client.
    """
    bedrock_client = boto3.client(
        service_name='bedrock',
        region_name=region_name
    )
    return bedrock_client

def get_bedrock_runtime_client(region_name='us-east-1'):
    """
    Creates and returns a Bedrock Runtime client.

    Args:
        region_name (str, optional): The AWS region. Defaults to 'us-east-1'.

    Returns:
        boto3.client: A Bedrock Runtime client.
    """
    bedrock_runtime_client = boto3.client(
        service_name='bedrock-runtime',
        region_name=region_name
    )
    return bedrock_runtime_client


def handler(event, context):

    logger.info("Starting lambda execution")
    try:
        try:
            exceptionOccurred = False
            exceptionMessage = ""
            prompt = ""
            requestbody = ""
            response_body = ""
            result = ""
            timestamp = ""
            sanitized_prompt = ""
            image_key = ""
            imageurl = ""
            s3bucketname = os.environ['S3BUCKETNAME']
            region = os.environ['REGION']
            cloudfrontdistribution = os.environ['CLOUDFRONTDISTRIBUTION']

            requestbody = json.loads(json.loads(event.get('body', '{}'), strict=False))
            prompt = requestbody["prompt"]

            #Select the appropriate model
            model_id = "amazon.nova-canvas-v1:0"

            # Create payloads for Bedrock Invoke, and can change model parameters to get the results you want.
            modelrequest = json.dumps({
            "textToImageParams": {"text": prompt},
            "taskType": "TEXT_IMAGE",
            "imageGenerationConfig": {
                "cfgScale": 8,
                "seed": int(datetime.now().timestamp()) % 100000,
                "quality": "standard",
                "width": 1280,
                "height": 720,
                "numberOfImages": 1
            }
        })
    
            accept = 'application/json'
            content_type = 'application/json'
            # Invoke the model
            bedrock_client = get_bedrock_client(region_name=region)
            bedrock_runtime_client = get_bedrock_runtime_client(region_name=region)
            model_response = bedrock_runtime_client.invoke_model(
              body=modelrequest,
              contentType=content_type,
              accept=accept,
              modelId=model_id
          )

            logger.info("bedrock model_response="+str(model_response))

            # Decode the response body.
            bodyjson= json.loads(model_response["body"].read())

            # Extract the image data.
            base64_image_data = bodyjson["images"][0]
            image_bytes = base64.b64decode(base64_image_data)

            #Prepare file name(key)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            sanitized_prompt = prompt.replace(" ", "_").replace(":", "").replace("/", "").replace("\\", "")[:50]
            image_key = f"generatedimages/{sanitized_prompt}_{timestamp}.png"
            imageurl = cloudfrontdistribution+image_key

            #Write the image to the S3 bucket
            s3 = boto3.client('s3')
            response = s3.put_object(
                Bucket=s3bucketname,
                Key=image_key,
                Body=image_bytes,
                ContentType="image/png"
            )

        except Exception as e:
            exception = True
            logger.info("An error occurred:"+str(e))
            exceptionMessage = "Exception: "+str(e) +":"+traceback.format_exc()
        finally:
            logger.info("Finally")
     
        ##Put together the response
        items = []
        row_data = {}
        row_data["call"] = "imagegeneration"
        row_data["prompt"] = prompt
        row_data["requestbody"] = requestbody

        row_data["modelId"] = model_id 
        row_data["modelrequest"] = modelrequest

        row_data["image_key"] = image_key
        row_data["imageurl"] = imageurl
        row_data["exceptionOccurred"] = exceptionOccurred
        row_data["exceptionMessage"] = exceptionMessage
        items.append(row_data)

        #logger.info("logger.info json_data=%s",items)



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
