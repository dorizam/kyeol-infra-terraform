# RDS PostgreSQL Module: Parameter Group

resource "aws_db_parameter_group" "main" {
  name        = "${var.name_prefix}-rds-pg16"
  family      = "postgres16"
  description = "Custom parameter group for ${var.name_prefix}"

  # Saleor 권장 설정
  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # 1초 이상 쿼리 로깅
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-pg"
  })
}
