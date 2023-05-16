module "aurora_postgres" {
  
    source                                  =   "github.com/techielins/terraform_modules//aws_aurora_postgres?ref=psql-v1.0"
    region                                  =   var.region
    cluster_identifier                      =   var.cluster_identifier     
    engine                                  =   var.engine
    family                                  =   var.family
    engine_mode                             =   var.engine_mode
    engine_version                          =   var.engine_version
    instance_class                          =   var.instance_class
    allow_major_version_upgrade             =   var.allow_major_version_upgrade
    apply_immediately                       =   var.apply_immediately
    auto_minor_version_upgrade              =   var.auto_minor_version_upgrade

    backup_retention_period                 =   var.backup_retention_period
    database_name                           =   var.database_name
    deletion_protection                     =   var.deletion_protection
    iam_database_authentication_enabled     =   var.iam_database_authentication_enabled
    port                                    =   var.port
    master_username                         =   var.master_username
    skip_final_snapshot                     =   var.skip_final_snapshot
    preferred_backup_window                 =   var.preferred_backup_window
    preferred_maintenance_window            =   var.preferred_maintenance_window
    
    performance_insights_enabled            =   var.performance_insights_enabled
    promotion_tier                          =   var.promotion_tier
    publicly_accessible                     =   var.publicly_accessible
    private_subnet_ids                      =   var.private_subnet_ids
    
    tags                                    =   var.tags
  
    create_cms_key                          =   var.create_cms_key
    storage_encrypted                       =   var.storage_encrypted
    kms_key_deletion_window_in_days         =   var.kms_key_deletion_window_in_days
    enable_kms_key_rotation                 =   var.enable_kms_key_rotation
    db_cluster_parameter_group_parameters   =   var.db_cluster_parameter_group_parameters
    
    create_security_group                   =   var.create_security_group
    security_group_id                       =   var.security_group_id
    security_group_ingress_cidr_block       =   var.security_group_ingress_cidr_block

    monitoring_interval                     =   var.monitoring_interval
    enable_enhanced_monitoring              =   var.enable_enhanced_monitoring
  
    random_password_length                  =   var.random_password_length
    special_character                       =   var.special_character
  
  
    //serverlessv2_scaling_configuration configuration is required only if we are using instance_class as db.serverless, else ignore the serverlessv2_scaling_configuration block
    serverlessv2_scaling_configuration      =  var.serverlessv2_scaling_configuration 
   
   
     replica_scale_enabled                   =   var.replica_scale_enabled
     replica_count                           =   var.replica_count
     replica_scale_max                       =   var.replica_scale_max
     replica_scale_min                       =   var.replica_scale_min
     replica_scale_cpu                       =   var.replica_scale_cpu
     replica_scale_connections               =   var.replica_scale_connections
     replica_scale_in_cooldown               =   var.replica_scale_in_cooldown
     replica_scale_out_cooldown              =   var.replica_scale_out_cooldown
     autoscaling_predefined_metric_type      =   var.autoscaling_predefined_metric_type

     enable_cloudwatch_alarm                                   =   var.enable_cloudwatch_alarm
     cloudwatch_alarm_evaluation_period                        =   var.cloudwatch_alarm_evaluation_period
     cloudwatch_alarm_period                                   =   var.cloudwatch_alarm_period
     cloudwatch_alarm_writer_cpu_utilization_threshold         =   var.cloudwatch_alarm_writer_cpu_utilization_threshold
     cloudwatch_alarm_reader_cpu_utilization_threshold         =   var.cloudwatch_alarm_reader_cpu_utilization_threshold
     cloudwatch_alarm_writer_free_local_storage_threshold      =   var.cloudwatch_alarm_writer_free_local_storage_threshold
     cloudwatch_alarm_reader_free_local_storage_threshold      =   var.cloudwatch_alarm_reader_free_local_storage_threshold
     cloudwatch_alarm_writer_disk_queue_depth_threshold        =   var.cloudwatch_alarm_writer_disk_queue_depth_threshold
     cloudwatch_alarm_reader_disk_queue_depth_threshold        =   var.cloudwatch_alarm_reader_disk_queue_depth_threshold
     cloudwatch_alarm_writer_swap_usage_threshold              =   var.cloudwatch_alarm_writer_swap_usage_threshold
     cloudwatch_alarm_reader_swap_usage_threshold              =   var.cloudwatch_alarm_reader_swap_usage_threshold
     cloudwatch_alarm_writer_freeable_memory_threshold         =   var.cloudwatch_alarm_writer_freeable_memory_threshold
     cloudwatch_alarm_reader_freeable_memory_threshold         =   var.cloudwatch_alarm_reader_freeable_memory_threshold
     endpoint                                                  =   var.endpoint
  
}


