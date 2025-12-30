# STAGE Environment (템플릿)
# Phase-1 미적용 - 템플릿만 생성

# 이 환경은 Phase-2에서 활성화됩니다.
# DEV 환경 파일을 참조하여 CIDR 및 설정을 수정하세요.

# STAGE CIDR 설정 (spec.md 기준):
# - VPC: 10.20.0.0/16
# - public-a: 10.20.0.0/24
# - public-c: 10.20.1.0/24
# - app-private-a: 10.20.4.0/22
# - app-private-c: 10.20.12.0/22
# - cache-private-a: 10.20.8.0/26
# - cache-private-c: 10.20.8.64/26
# - data-private-a: 10.20.9.0/24
# - data-private-c: 10.20.10.0/24

# RDS: Multi-AZ 활성화
# Cache: Valkey 사용
