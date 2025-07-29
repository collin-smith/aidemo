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
#    "prompt" : "Summarize the following text in 3 sentences"
#    "key" : "PDP.pdf"
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
            model_id =""
            key = ""
            output_key = ""
            prompt = ""
            results = ""
            text = "Using the base64 version direct"
            
            region = os.environ['REGION']
            cloudfrontdistribution = os.environ['CLOUDFRONTDISTRIBUTION']
            s3bucketname = os.environ['S3BUCKETNAME']

            requestbody = json.loads(json.loads(event.get('body', '{}'), strict=False))
            key = requestbody["key"]
            prompt = requestbody["prompt"]
            file_name = key



            #Let's get the Base64 version of the file in the S3 bucket (Not the textract version)
            output_key = f'{file_name}'
            logger.info("output_key="+output_key)
            #Let's look up the S3 object and get the 
            #textract = boto3.client('textract')
            s3 = boto3.client('s3')
            response = s3.get_object(Bucket=s3bucketname, Key=output_key)
            file_content = response['Body'].read()
            base64_encoded_string = base64.b64encode(file_content).decode('utf-8')
            #Sonnet
            #model_id = "anthropic.claude-3-7-sonnet-20250219-v1:0"
            #model_id = "arn:aws:bedrock:us-east-1:099611363243:inference-profile/us.anthropic.claude-3-7-sonnet-20250219-v1:0"

            #Opus 4
            #model_id = "anthropic.claude-opus-4-20250514-v1:0"
            model_id = "arn:aws:bedrock:us-east-1:099611363243:inference-profile/us.anthropic.claude-opus-4-20250514-v1:0"

            accept = 'application/json'
            content_type = 'application/json'
            modelrequest = json.dumps(
{
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 1000,
    "temperature": 0.3,
    "messages": [
      {
        "role": "user",
        "content": [
        {
          "type": "document",
          "source": {
            "type": "base64",
            "media_type": "application/pdf",
            "data": base64_encoded_string
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
        )
            
            bedrock_client = get_bedrock_client(region_name=region)
            bedrock_runtime_client = get_bedrock_runtime_client(region_name=region)
            response = bedrock_runtime_client.invoke_model(
            body=modelrequest,
            modelId=model_id,
            accept=accept,
            contentType=content_type
            )

            body = response.get("body").read().decode('utf-8')
            bodytobject = json.loads(body)
            content = bodytobject["content"]
            contentobject = content[0]
            results = contentobject["text"]
            usage = bodytobject["usage"]
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
            exception = True
            logger.info("An error occurred:"+str(e))
            exceptionMessage = "Exception: "+str(e) +":"+traceback.format_exc()
        finally:
            logger.info("Finally")

         #Put together the response
        items = []
        row_data = {}
        row_data["call"] = "documentanalysisllm"
        row_data["key"] = key
        row_data["output_key"] = output_key
        row_data["prompt"] = prompt
        row_data["results"] = results
        row_data["text"] = text

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
