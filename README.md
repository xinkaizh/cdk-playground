# Quick Start

## Core Commands

- `npx cdk synth`: Generate the synthesized CloudFormation template from the CDK app.
- `npx cdk deploy [stack_name]`: Deploy the stack to the default AWS account and region.
- `npx cdk destroy [stack_name]`: Destroy all resources created by this stack.
- `npx cdk diff [stack_name]`: Show the difference between the currently deployed stack and your local changes.
- `npm run clean`: Remove generated build artifacts (e.g., `cdk.out`, compiled files).

## Additional Useful Commands

- `npx cdk list`: List all stacks in the CDK app.
- `npm run build`: Compile TypeScript files to JavaScript.
- `npm run watch`: Watch for file changes and automatically recompile TypeScript.
- `npm run clean-all`: Remove node_modules in addition to a build artifacts.

## Typical Workflow

A common CDK development loop looks like this:

1. Edit infrastructure code
2. Generate CloudFormation template: `npx cdk synth`
3. Preview changes (optional): `npx cdk diff`
4. Deploy the stack: `npx cdk deploy`
5. Review deployed infrastructure in AWS console (optional)

Repeat this process as you iterate on the infrastructure. When finished:

1. Clean up deployed resources: `npx cdk destroy`
2. Clean up local environment (optional): `npm run clean`
