import boto3
import json
import logging
import os
import pymysql
import random
import json
from botocore.exceptions import ClientError
from datetime import datetime
from zoneinfo import ZoneInfo
import base64
import traceback

logger = logging.getLogger()
logger.setLevel(logging.INFO)

#Sample request body
#{
#    "prompt" : "Analyze the image and describe its content"
#    "key" : "apple.jpg"
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
            object = ""
            requestbody = ""
            response_body = ""
            result = ""
            model_id = ""
            text = ""        
            input_tokens = ""
            output_tokens = ""
            costReport = ""
        
            s3bucketname = os.environ['S3BUCKETNAME']
            region = os.environ['REGION']
            cloudfrontdistribution = os.environ['CLOUDFRONTDISTRIBUTION']

            requestbody = json.loads(json.loads(event.get('body', '{}'), strict=False))
            prompt = requestbody["prompt"]
            key = requestbody["key"]

            s3 = boto3.client('s3')
            response = s3.get_object(Bucket=s3bucketname, Key=key)
            image_content = response['Body'].read()
            # Encoding images to base64
            base64_encoded_image = base64.b64encode(image_content).decode('utf-8')

             #Sonnet
            #model_id = "anthropic.claude-3-7-sonnet-20250219-v1:0"
            #model_id = "arn:aws:bedrock:us-east-1:099611363243:inference-profile/us.anthropic.claude-3-7-sonnet-20250219-v1:0"

            #Opus 4
            #model_id = "anthropic.claude-opus-4-20250514-v1:0"
            model_id = "arn:aws:bedrock:us-east-1:099611363243:inference-profile/us.anthropic.claude-opus-4-20250514-v1:0"

            # Create payloads for Bedrock Invoke, and can change model parameters to get the results you want.
            modelrequest = {
        "modelId": model_id,
        "contentType": "application/json",
        "accept": "application/json",
        "body": {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 4096,
            "top_k": 250,
            "top_p": 0.999,
            "temperature": 0,
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": "image/png",
                                "data": base64_encoded_image
                            }
                        },
                        {
                            "type": "text",
                            "text": prompt
                        }
                    ]
                }
            ]
        }
    }

            response_body = ""
            result = ""

            # Convert the payload to bytes
            modelrequest_bytes = json.dumps(modelrequest['body']).encode('utf-8')
            accept = 'application/json'
            content_type = 'application/json'
            # Invoke the model
            bedrock_client = get_bedrock_client(region_name=region)
            bedrock_runtime_client = get_bedrock_runtime_client(region_name=region)
            model_response = bedrock_runtime_client.invoke_model(
              body=modelrequest_bytes,
              contentType=content_type,
              accept=accept,
              modelId=model_id
          )

            #logger.info("model Response="+str(model_response))
            # Process the response
            #response_body = json.loads(model_response['body'].read())
            #logger.info("response_body="+str(response_body))
            #result = response_body['content'][0]['text']
            logger.info("bedrock model_response="+str(model_response))


            body = model_response.get("body").read().decode('utf-8')
            bodyjson = json.loads(body)
            content = bodyjson["content"]
            contentobject = content[0]

            text = contentobject["text"]

            usage = bodyjson["usage"]
            input_tokens = usage["input_tokens"]
            output_tokens = usage["output_tokens"]


            #Bedrock pricing
            # https://aws.amazon.com/bedrock/pricing/
            #Claude Opus 4 pricing
            # Price per 1000 tokens
            inputTokenCost = 0.015
            outputTokenCost = 0.075
            numberInputTokens = float(input_tokens)
            numberOutputTokens = float(output_tokens)

            #Separated costs
            totalInputCost = (numberInputTokens / 1000 ) * inputTokenCost
            totalOutputCost = (numberOutputTokens / 1000 ) * outputTokenCost
            totalCost = totalInputCost + totalOutputCost

            inputCostString = " TotalInputCost($)= ("+str(numberInputTokens)+" /1000) * " + str(inputTokenCost)+"="+str(totalInputCost)+"."
            outputCostString = " TotalOutputCost($)= ("+str(numberOutputTokens)+" /1000) * " + str(outputTokenCost)+"="+str(totalOutputCost)+"."

            costReport = "Total Cost($):"+str(totalCost) +". "+inputCostString+outputCostString +" See https://aws.amazon.com/bedrock/pricing/"





        except Exception as e:
            exceptionOccurred = True
            logger.info("An error occurred:"+str(e))
            exceptionMessage = "Exception: "+str(e) +":"+traceback.format_exc()
        finally:
            logger.info("Finally")

         #Put together the response
        items = []
        row_data = {}
        row_data["call"] = "imageanalysis"
        row_data["prompt"] = prompt
        row_data["key"] = key



        row_data["modelId"] = model_id 
        row_data["response"] = text
        
        row_data["inputTokens"] = input_tokens
        row_data["outputTokens"] = output_tokens
        row_data["costReport"] = costReport

        row_data["exceptionOccurred"] = exceptionOccurred
        row_data["exceptionMessage"] = exceptionMessage
        items.append(row_data)

        logger.info("logger.info json_data=%s",items)

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
