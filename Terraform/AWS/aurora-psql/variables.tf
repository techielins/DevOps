variable "region"{
    description = "Name of the region for the resource to be provisioned"
    type        = string
}

variable "tags"{
    description = "A map of tags to add to all resources" 
    type        = map(string)
}

variable "enable_cloudwatch_alarm"{
    description = "Specifies whether to enable cloud watch alarm."
    type        = bool
}

variable "cloudwatch_alarm_evaluation_period"{
    description = "The number of periods over which data is compared to the specified threshold."
    type        = number
}

variable "cloudwatch_alarm_period"{
    description = "The period in seconds over which the specified statistic is applied."
    type        = number
}

variable "endpoint"{
    description = "Endpoint to which cloudwatch alarm notifications are send to."
    type        = string
}

variable "private_subnet_ids_p" {
    description = "A list of private subnet IDs in VPC region"
    type        = list(string)
}

variable "enable_enhanced_monitoring"{
    description = "Determines whether enhanced monitoring should be enabled or not - valid values are 'true' and 'false'."
                  //To enable enhanced monitoring, 'check_enhanced_monitoring' must be set to true and 'monitoring_interval' must be a non-zero value//
                  //To disable enhanced monitoring, 'check_enhanced_monitoring' must be false and 'monitoring_interval' must be set to 0//
    type        = bool
}

variable "replica_scale_enabled" {
    description = "Whether to enable autoscaling for RDS Aurora read replicas"
    type        = string
}
variable "replica_count" {
    description = "If 'replica_scale_enable' is 'true', the value of this variable is used to create read replica, else only writer instance will be created."
    type        = string
}

variable "vpc_id"{
    description = "The VPC id to which the security groups are mapped."
    type        = string
}

variable "create_security_group"{
    description = "Specifies whether a security group should be created or not"
                    //If false, then existing security group is used for creating the DB cluster
    type        = bool
}

variable "security_group_ingress_cidr_block"{
    description = "CIDR block for ingress rule"
    type        = list(string)
}

variable "storage_encrypted"{
    description = "Specifies whether the DB cluster is encrypted"
                   //The default is 'false' for 'provisioned' 'engine_mode' and 'true' for 'serverless' 'engine_mode'.
                   //Aurora RDS instance can be encrypted when we create it, not after the instance is created.
    type        = bool
}

variable "create_cms_key"{
    description = "Specifies whether CMS Key should be created or not"
    type        = bool
}

variable "family"{
    description =  "The family of the DB parameter group"
    type        = string
}


variable "allow_major_version_upgrade"{
    description = "Determines whether to allow major engine version upgrades when changing engine versions"
    type        = bool
}

variable "apply_immediately"{
    description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
    type        = bool
}

variable "cluster_identifier"{
    description = "The name of the DB cluster"
    type        = string
}

variable "database_name"{
    description = "The name of the database to be created"
    type        = string 
}

variable "engine_version"{
    description = "The database engine version"
    type        = string
}

variable "iam_database_authentication_enabled"{
    description = "Determines whether to enable IAM database authentication for the RDS Cluster"
    type        = bool
}

variable "security_group_id" {
    description = "The security group to be connected"
    type        = list(string) 
    default     = null
}

variable "auto_minor_version_upgrade"{
    description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
    type        = bool
}

variable "instance_class"{
    description = "Instance type to use at replica instance"
    type        = string
}

variable "publicly_accessible"{
    description = "Determines whether the DB should have a public IP address"
                    //if set to Yes, the database will have a publicly accessible endpoint and may be exposed to the internet
    type        = bool
}

variable "performance_insights_enabled"{
    description = "Determines whether Performance Insights is enabled or not"
                    //helps to quickly assess the load on database, and determine when and where to take action.
                    //The specified VPC should have DNS resolution and  DNS hostnames enabled.
                    //Instance classes - db.t3.small, db.t3.medium, db.t3.large - do not support performance insight.
    type        = bool
}

variable "serverlessv2_scaling_configuration" {
    description = "Map of nested attributes with serverless v2 scaling properties. Only valid when `engine_mode` is set to `provisioned`"
                   //The minimum capacity must be lesser than or equal to the maximum capacity. 
                   //Valid capacity values are in a range of 0.5 up to 128 in steps of 0.5.
    type        = any
}




