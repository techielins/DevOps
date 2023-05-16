output "master_password"{
    value       =   module.aurora_postgres.master_password
    sensitive   =   true
}

