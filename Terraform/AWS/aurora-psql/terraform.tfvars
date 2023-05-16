region                                  =   "us-east-1"
cluster_identifier                      =   "mypsqlcluster"
family                                  =   "aurora-postgresql15"
engine_version                          =   "15.2"                  # To provision serverless DB, supported engine_versions are between 13.6-13.8, 14.3-14.7 and 15.2
instance_class                          =   "db.r5.large"           # To provision serverless DB, instance_class should be changed to db.serverless
                                                                    # Aurora PostgreSQL engine versions earlier than 11.9 don't support the newest r6g generation instance classes.
allow_major_version_upgrade             =   true
auto_minor_version_upgrade              =   true
apply_immediately                       =   false

database_name                           =   "psqldb"
iam_database_authentication_enabled     =   true
performance_insights_enabled            =   true
publicly_accessible                     =   false

private_subnet_ids_p                    =   ["subnet-xxx","subnet-xxx","subnet-xxx"]   # Replace these subnet ids with your private subnet ids
tags                                    =   { "Created By" = "Terraform using Techielins Aurora-PSQL Module" }
create_cms_key                          =   false
storage_encrypted                       =   true
create_security_group                   =   true                 # If false, security_group_id must be provided. If true, vpc_id and security_group_ingress_cidr_block must be mentioned.
security_group_id                       =   ["sg-xxx"]           # Replace this with your security group id, if create_security_group is set to false.
vpc_id                                  =   "vpc-xxx"            # Replace this with your vpc id, if create_security_group is set to true.
security_group_ingress_cidr_block       =   ["0.0.0.0/0"]        # For ingress rule. security_group_ingress_cidr_block is needed when create_security_group is set to true.
enable_enhanced_monitoring              =   true
serverlessv2_scaling_configuration      =   {
                                             min_capacity = 3
                                             max_capacity = 10
                                            }                    # Serverlessv2_scaling_configuration configuration is required only if we are using instance_class as db.serverless, else ignore the serverlessv2_scaling_configuration block
replica_scale_enabled                   =   true
replica_count                           =   1

enable_cloudwatch_alarm                                   =   false
cloudwatch_alarm_evaluation_period                        =   2
cloudwatch_alarm_period                                   =   60
endpoint                                                  =   "xxx@xxx.com"


