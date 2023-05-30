# Situation (Use case)

If you need to have an automatic mechanism to stop every instances of RDS running in particular AWS region (say us-east-1) at the end of the day at specifc time (say 7PM IST everyday) thus making sure that RDS instance are not running overnight to save running cost. 

_Note: Python script doesn't manage to take care of Aurora instances. It is specifically for RDS instances._

# Task

You can achieve an automated solution to this use case with help of AWS Lambda function and Cloudwatch Events (EventBridge).

# Action

* Create a Lambda function from scratch.
* Login to the AWS Management Console: Go to the AWS Management Console (https://console.aws.amazon.com/) and login to your AWS account.
* Go to AWS Lambda: Once logged in, navigate to the Lambda service by searching for "Lambda" in the search bar or finding it under "Compute" in the services menu.
* Create a new function: Click on the "Create function" button to create a new Lambda function.
* Choose Author from scratch: In the "Create function" page, select the "Author from scratch" option.

Configure function details:

* Function name: Enter a unique name for your Lambda function.
* Runtime: Select "Python" as the runtime for your function.
* Permissions: Create a new execution role that has the necessary permissions to access the AWS resources your function requires.
* Other settings: Please as default settings
* Click on "Create function": Once you have configured the function details, click on the "Create function" button to create the Lambda function.

Code your Lambda function:

* In the function detail page, scroll down to the "Function code" section.
* In the "Code entry type" dropdown, select "Edit code inline"
If you choose "Edit code inline", you can directly write or paste the following Python code in the code editor.

```
import boto3
from datetime import datetime, timedelta

def lambda_handler(event, context):
    print(event)
    # Set the AWS region
    region = 'us-east-1'
    
    # Set the current time in IST
    current_time = datetime.now() + timedelta(hours=5, minutes=30)
    
    # Set the target time for stopping RDS instances (7:00 PM IST)
    target_time = current_time.replace(hour=7, minute=00, second=0, microsecond=0)
    
    # Check if the current time is past the target time
    if current_time >= target_time:
        # Create the RDS client
        rds_client = boto3.client('rds', region_name=region)
        
        # Describe all RDS instances in the region
        response = rds_client.describe_db_instances()
        
        # Check if there are any running instances
        if 'DBInstances' in response:
            for instance in response['DBInstances']:
                if instance['DBInstanceStatus'] == 'available':
                    instance_identifier = instance['DBInstanceIdentifier']
                    print(f"Stopping RDS instance: {instance_identifier}")
                    
                    # Stop the RDS instance
                    rds_client.stop_db_instance(DBInstanceIdentifier=instance_identifier)
                    
                    # Return a success message
                    return {
                        'statusCode': 200,
                        'body': 'RDS instances stopped successfully.'
                    }
    
    # Return a message indicating no RDS instances were stopped
    return {
        'statusCode': 200,
        'body': 'No RDS instances to stop.'
    }

```

Script Explaination is below:

1. The script starts by importing the necessary modules, `boto3` for interacting with AWS services and `datetime` and `timedelta` for working with dates and times.

2. The `lambda_handler` function is the entry point for the AWS Lambda execution. It takes two parameters, `event` and `context`, which are provided by the Lambda service.

3. The AWS region is set to `'us-east-1'`, which can be modified to your desired region.

4. The current time in IST (Indian Standard Time) is calculated by adding 5 hours and 30 minutes to the current system time using `datetime.now()` and `timedelta`.

5. The target time for stopping the RDS instances is set to 7:00 PM IST using `replace()` to set the hour and minute values.

6. The script checks if the current time is past the target time. If it is, the script proceeds with stopping the RDS instances.

7. The RDS client is created using `boto3.client()` with the specified region.

8. The script describes all RDS instances in the region using `describe_db_instances()` and stores the response.

9. It checks if there are any running instances by verifying the presence of the `'DBInstances'` key in the response.

10. For each running instance, it checks if the status is `'available'`. If it is, the instance identifier is retrieved and printed.

11. The script then stops the RDS instance by calling `stop_db_instance()` with the instance identifier.

12. After stopping the first available instance, a success response is immediately returned with a 200 status code and the message `'RDS instances stopped successfully.'`.

13. If there are no running instances or if the current time is not past the target time, the script returns a response with a 200 status code and the message `'No RDS instances to stop.'`.

_Note: The script is designed to run as an AWS Lambda function on a schedule, checking the current time and stopping the RDS instances if it's past the specified target time. 
Remember to configure the Lambda function to have the necessary IAM permissions to interact with RDS and make sure the execution role has the required access to the AWS services._

* Login to IAM console, edit the IAM role created during the creation of Lambda function and create a new inline policy for adding permission to stop the RDS instances so that Lambda function will be able to stop the running RDS instances.

Reference Inline policy is below. 
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "rds:DescribeDBProxyTargetGroups",
                "rds:DescribeDBInstanceAutomatedBackups",
                "rds:DescribeDBEngineVersions",
                "rds:DescribeDBSubnetGroups",
                "rds:DescribeGlobalClusters",
                "rds:DescribeExportTasks",
                "rds:DescribePendingMaintenanceActions",
                "rds:DescribeEngineDefaultParameters",
                "rds:DescribeDBParameterGroups",
                "rds:DescribeDBClusterBacktracks",
                "rds:DescribeRecommendations",
                "rds:DescribeReservedDBInstancesOfferings",
                "rds:DescribeDBProxyTargets",
                "rds:DescribeRecommendationGroups",
                "rds:DownloadDBLogFilePortion",
                "rds:DescribeDBInstances",
                "rds:DescribeSourceRegions",
                "rds:DescribeEngineDefaultClusterParameters",
                "rds:DescribeDBProxies",
                "rds:DescribeDBParameters",
                "rds:DescribeEventCategories",
                "rds:DescribeDBProxyEndpoints",
                "rds:DescribeEvents",
                "rds:DescribeDBClusterSnapshotAttributes",
                "rds:DescribeDBClusterParameters",
                "rds:StopDBCluster",
                "rds:DescribeEventSubscriptions",
                "rds:DescribeDBSnapshots",
                "rds:DescribeDBLogFiles",
                "rds:DescribeDBSecurityGroups",
                "rds:StopDBInstance",
                "rds:DescribeDBSnapshotAttributes",
                "rds:DescribeReservedDBInstances",
                "rds:DescribeBlueGreenDeployments",
                "rds:ListTagsForResource",
                "rds:DescribeValidDBInstanceModifications",
                "rds:DescribeDBClusterSnapshots",
                "rds:DescribeOrderableDBInstanceOptions",
                "rds:DescribeOptionGroupOptions",
                "rds:DownloadCompleteDBLogFile",
                "rds:DescribeDBClusterEndpoints",
                "rds:DescribeCertificates",
                "rds:DescribeDBClusters",
                "rds:DescribeAccountAttributes",
                "rds:DescribeOptionGroups",
                "rds:DescribeDBClusterParameterGroups"
            ],
            "Resource": "*"
        }
    ]
}
```
* Configure Cloudwatch Event rule to trigger Lambda function at 7PM IST.

Configuration details:

The step-by-step instructions to configure EventBridge (CloudWatch Events) to invoke a Lambda function at 7 PM IST:

1. Open the AWS Management Console: Go to the AWS Management Console (https://console.aws.amazon.com/) and log in to your AWS account.

2. Go to AWS EventBridge (CloudWatch Events): Once logged in, navigate to the EventBridge service by searching for "EventBridge" in the search bar or finding it under "Management & Governance" in the services menu.

3. Create a new rule: In the EventBridge dashboard, select "Rules" from the sidebar menu, and then click on the "Create rule" button.

4. Configure the rule:
   - Name: Enter a name for your rule.
   - Description: (Optional) Provide a description for the rule.
   - Define pattern: Under the "Define pattern" section, select "Schedule".
   - Schedule pattern: Enter the cron expression `30 13 * * ? *` to schedule the event at 7 PM IST. This expression translates to "At 1 PM UTC every day" (IST is 5 hours and 30 minutes ahead of UTC).

5. Configure the target:
   - Targets: Click on the "Add target" button and select "Lambda function".
   - Function: Choose your Lambda function from the dropdown list.

6. Configure the rule details:
   - Click on the "Create" button: Once you have configured all the details, click on the "Create" button to create the EventBridge rule.

You have successfully configured EventBridge (CloudWatch Events) to invoke your Lambda function at 7 PM IST. 

# Result

The EventBridge rule will trigger the Lambda function at 7:00 PM IST everyday. Lambda function will execute the python script which will stop any running RDS instances under AWS region us-east-1 at the specified time every day. 
You can monitor the execution and view logs of the Lambda function invocation through the AWS Cloudwatch Log Groups of Lambda function.





