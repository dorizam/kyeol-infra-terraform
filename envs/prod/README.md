# PROD Environment (템플릿)
# Phase-1 미적용 - 템플릿만 생성

# 이 환경은 Phase-2에서 활성화됩니다.
# DEV 환경 파일을 참조하여 CIDR 및 설정을 수정하세요.

# PROD CIDR 설정 (spec.md 기준):
# - VPC: 10.30.0.0/16
# - public-a: 10.30.0.0/24
# - public-c: 10.30.1.0/24
# - app-private-a: 10.30.4.0/22
# - app-private-c: 10.30.12.0/22
# - cache-private-a: 10.30.8.0/26
# - cache-private-c: 10.30.8.64/26
# - data-private-a: 10.30.9.0/24
# - data-private-c: 10.30.10.0/24

# RDS: Multi-AZ 활성화, db.t3.medium
# Cache: Valkey 사용
# EKS: desired 3, min 2, max 5
