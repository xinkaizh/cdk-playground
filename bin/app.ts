#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { SampleStack } from '../lib/sample-stack';

const app = new cdk.App();

// TODO: Replace with actual service stack.
new SampleStack(app, 'SampleStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION
  }
});