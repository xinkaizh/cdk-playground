import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as sqs from 'aws-cdk-lib/aws-sqs';
import * as s3 from 'aws-cdk-lib/aws-s3';

export class SampleStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // SQS queue
    const queue = new sqs.Queue(this, 'CdkPlaygroundQueue', {
      queueName: 'cdk-playground-queue',
      visibilityTimeout: cdk.Duration.seconds(300)
    });

    // S3 bucket
    const bucket = new s3.Bucket(this, 'CdkPlaygroundBucket', {
      bucketName: 'cdk-playground-bucket-demo',
      versioned: true,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      autoDeleteObjects: true
    });

    // CloudFormation outputs (for debugging)
    new cdk.CfnOutput(this, 'QueueUrl', {
      value: queue.queueUrl
    });

    new cdk.CfnOutput(this, 'BucketName', {
      value: bucket.bucketName
    });
  }
}