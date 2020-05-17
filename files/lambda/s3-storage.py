from datetime import datetime
import time
import os
import sys
import traceback
import logging
import uuid
import base64
import botocore
import boto3
import json
import re
import pytz

# Initialize the timezone
oldTimezone = pytz.timezone('UTC')
newTimezone = pytz.timezone('Europe/Paris')

# Initialize Boto3 aws client
s3 = boto3.client('s3')
sqs = boto3.client('sqs')
dynamodb = boto3.resource('dynamodb')
s3Resource = boto3.resource('s3')

dynamodbTable = dynamodb.Table(os.environ['DYNAMODB_TABLE_NAME'])

def handler(event, context):
  # Initialize the logger
  try:
    ipSource = json.loads(event['Records'][0]['body'])['Records'][0]['requestParameters']['sourceIPAddress']
  except:
    ipSource = "0.0.0.0"
  finally:
    logger = setup_logging(context.aws_request_id,ipSource)
    logger.setLevel(logging.INFO)
  
  logger.debug(event)
  logger.info(f"SQS_NAME='{os.environ['SQS_URL']}'")
  results = []
  
  ###Lambda triggered directly by S3### message = sqs.receive_message(QueueUrl=os.environ['SQS_URL'])
  ###Lambda triggered directly by S3### receiptHandle = message['Messages'][0]['ReceiptHandle']

  # Retrieve the ID of the SQS message
  receiptHandle = event['Records'][0]['receiptHandle']
  logger.info(f"RECEIPT_HANDLE='{receiptHandle}'")
  logger.info(f"MESSAGE_ID='{event['Records'][0]['messageId']}'")
  
  ###Lambda triggered directly by S3### for record in json.loads(message['Messages'][0]['Body'])['Records'] :
  for record in json.loads(event['Records'][0]['body'])['Records'] :
    result = {}
    objectPathSource = record['s3']['object']['key']
    objectSize = record['s3']['object']['size']
    logger.info(f"OBJECT_PATH_SOURCE='{objectPathSource}'")
    logger.info(f"OBJECT_SIZE='{objectSize}'")
    fileName = re.search("[^/]*$",objectPathSource).group(0)
    logger.info(f"FILE_NAME='{fileName}'")

    # Retrieve the timestamp of the record and convert it from 'UTC' to 'Europe/Paris'
    recordTime = re.search("[0-9]{10}",fileName).group(0)
    logger.info(f"RECORD_TIME='{recordTime}'")
    recordTimestamp = datetime.fromtimestamp(int(recordTime))
    recordTimestamp = oldTimezone.localize(recordTimestamp).astimezone(newTimezone)

    # Generate the destination path year/month/day/hourminute.mp4
    objectPathDestination = str(recordTimestamp.year)+'/'+("0" if recordTimestamp.month < 10 else "")+str(recordTimestamp.month)+'/'+("0" if recordTimestamp.day < 10 else "")+str(recordTimestamp.day)+'/'+("0" if recordTimestamp.hour < 10 else "")+str(recordTimestamp.hour)+'/'+("0" if recordTimestamp.minute < 10 else "")+str(recordTimestamp.minute)+("0" if recordTimestamp.second < 10 else "")+str(recordTimestamp.second)+".mp4" #fileName
    logger.info(f"OBJECT_PATH_DESTINATION='{objectPathDestination}'")
  
    # Initialize the Lambda response
    result['objectPathSource'] = objectPathSource
    result['fileName'] = fileName
    result['recordTimestamp'] = recordTimestamp.strftime('%Y-%m-%dT%H:%M:%S%z')
    result['objectPathDestination'] = objectPathDestination

    # Save Metadata on DynamoDB
    dynamodbTable.put_item(
      Item={
        'Id': str(time.time_ns()),
        'objectPathSource': objectPathSource,
        'objectSize': str(objectSize),
        'fileName': fileName,
        'recordTimestamp': str(recordTimestamp),
        'objectPathDestination': objectPathDestination,
        'memorySize': os.environ['AWS_LAMBDA_FUNCTION_MEMORY_SIZE']
      }
    )
    
    # Move record object via copy and remove commands & remove the SQS message from the queue
    try:
      s3Resource.Object(os.environ['BUCKET_NAME'], objectPathDestination).copy_from(CopySource=os.environ['BUCKET_NAME']+"/"+objectPathSource, StorageClass='DEEP_ARCHIVE')
      s3Resource.Object(os.environ['BUCKET_NAME'], objectPathSource).delete()
      sqs.delete_message(QueueUrl=os.environ['SQS_URL'],ReceiptHandle=receiptHandle)
    except botocore.exceptions.ClientError as e:
      if e.response['Error']['Code'] == 'NoSuchKey' :
        logger.error(f"File not found OBJECT_PATH_SOURCE='{objectPathSource}'")
      elif e.response['Error']['Code'] == 'NoSuchBucket' :
        logger.error(f"Bucket not found BUCKET_NAME='{os.environ['BUCKET_NAME']}'")
      else:
        logger.error(e)
      result['status'] = 'KO'
    except:
      logger.error(traceback.format_exc())
      result['status'] = 'KO'
    else:
      result['status'] = 'OK'
    results.append(result)

  return json.dumps(results)

def setup_logging(uuid, ipSource):
  logger = logging.getLogger()
  for handler in logger.handlers:
    logger.removeHandler(handler)
  
  handler = logging.StreamHandler(sys.stdout)
  formatter = f"[%(asctime)s] [Xiaomi S3 Storage] [{uuid}] [{ipSource}] [{os.environ['BUCKET_NAME']}] [%(levelname)s] %(message)s"
  handler.setFormatter(logging.Formatter(formatter))
  logger.addHandler(handler)
  logger.setLevel(logging.DEBUG)
  
  return logger
