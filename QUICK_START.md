# KYEOL Infrastructure Quick Start

이 문서는 KYEOL 인프라스트럭처를 처음 배포하는 사용자를 위한 단계별 가이드입니다.
현재 구성은 **오사카(ap-northeast-3)** 리전을 기준으로 작성되었습니다.

## 0. 사전 요구사항 (Prerequisites)
작업을 시작하기 전에 다음 도구들이 설치되어 있어야 합니다.

*   [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (설정: `aws configure`)
*   [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.5 이상)
*   [kubectl](https://kubernetes.io/docs/tasks/tools/)
*   [git](https://git-scm.com/downloads)

## 1. 전체 배포 순서 개요
1.  **Bootstrap**: Terraform 상태 저장소(S3) 생성
2.  **MGMT 환경**: ArgoCD 및 중앙 관리를 위한 클러스터 생성
3.  **ArgoCD 설치**: MGMT 클러스터에 배포 도구 설치
4.  **DEV 환경**: 실제 애플리케이션이 실행될 클러스터 생성
5.  **ArgoCD 연동**: 애플리케이션 배포

---

## 2. 단계별 상세 가이드

### Step 1: Bootstrap (상태 저장소 생성)
가장 먼저 Terraform의 상태를 저장할 금고(S3 Bucket)를 만듭니다.

```bash
# 폴더 이동
cd envs/bootstrap

# 초기화 및 배포
terraform init
terraform apply
# (물어보면 'yes' 입력)
```

### Step 2: MGMT 인프라 배포 (중앙 관리)
ArgoCD가 실행될 관리용 클러스터를 생성합니다.

```bash
# 폴더 이동
cd ../mgmt
# (위치: kyeol-infra-terraform/envs/mgmt)

# 초기화 및 배포
terraform init
terraform apply
# (약 15~20분 소요, 'yes' 입력)

# 배포 완료 후 MGMT 클러스터 접속 설정 (Kubeconfig)
aws eks update-kubeconfig --region ap-northeast-3 --name sol-kyeol-mgmt-eks
```

### Step 3: ArgoCD 설치
MGMT 클러스터에 ArgoCD를 직접 설치합니다. (Terraform이 아닌 kubectl 사용)

```bash
# ArgoCD 설정 파일이 있는 폴더로 이동 (상위 디렉토리의 다른 레포지토리)
cd ../../../kyeol-platform-gitops
# (위치: kyeol-platform-gitops)

# kubectl이 어느 클러스터에 명령을 날릴지 선택
# 'kubectl config get-contexts' 에 등록된 context 중 하나 활성화
kubectl config use-context arn:aws:eks:ap-northeast-3:827913617839:cluster/sol-kyeol-mgmt-eks 

# ArgoCD 설치
kubectl apply -k argocd/bootstrap/

# 설치 확인
kubectl get pods -n argocd
# (모든 파드가 Running 상태가 될 때까지 대기)

# 초기 비밀번호 확인 (로그인용)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
# (나온 비밀번호 복사해두기)
# atKtXxhkNlP8Kj9I
```

### Step 4: DEV 인프라 배포 (애플리케이션용)
실제 서비스가 올라갈 환경을 만듭니다.

```bash
# 다시 인프라 폴더로 이동
cd ../kyeol-infra-terraform/envs/dev
# (위치: kyeol-infra-terraform/envs/dev)

# 초기화 및 배포
terraform init
terraform apply
# ('yes' 입력)

# DEV 클러스터 접속 설정
aws eks update-kubeconfig --region ap-northeast-3 --name sol-kyeol-dev-eks

```

### Step 4-1: IRSA 권한 설정 (필수!)
Addon 설치 전에, Terraform으로 생성된 IAM Role의 ARN을 설정 파일에 입력해야 합니다.

1. **ARN 값 확인**:
   ```bash
   # dev 폴더에서 실행
   terraform output alb_controller_role_arn
   terraform output external_dns_role_arn
   ```
2. **설정 파일 수정**:
   *   `../kyeol-platform-gitops/clusters/dev/values/aws-load-balancer-controller.values.yaml`
   *   `../kyeol-platform-gitops/clusters/dev/values/external-dns.values.yaml`
   
   위 파일들을 열어서 `role-arn` 부분을 방금 확인한 값으로 교체해주세요. (이미 솔(sol) 설정으로 되어있다면 넘어갑니다)

### Step 5: DEV 클러스터에 Addons 설치

```bash

# 어느 클러스터에 명령을 날릴지 선택
kubectl config use-context arn:aws:eks:ap-northeast-3:827913617839:cluster/sol-kyeol-dev-eks

# 1. AWS Load Balancer Controller CRDs 설치 (필수)
# Kustomize 에러 방지를 위해 직접 원본 YAML을 적용합니다.
kubectl apply -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml

# 2. Addons 설치 (옵션 추가됨)
# 모든 Addon이 Helm Chart와 상위 values 파일을 참조하므로 아래 방식을 사용합니다.
kubectl kustomize clusters/dev/addons/aws-load-balancer-controller/ --enable-helm --load-restrictor LoadRestrictionsNone | kubectl apply -f -
kubectl kustomize clusters/dev/addons/external-dns/ --enable-helm --load-restrictor LoadRestrictionsNone | kubectl apply -f -
kubectl kustomize clusters/dev/addons/metrics-server/ --enable-helm --load-restrictor LoadRestrictionsNone | kubectl apply -f -

# 모든 pod가 running 상태인지 확인
kubectl -n kube-system get pods
kubectl get svc -n kube-system


```


---
### Step 6: App GitOps 설정 수정 (도메인/이미지)
이제 `kyeol-app-gitops` 폴더로 이동하여 애플리케이션 배포 설정을 본인의 환경에 맞게 수정합니다.

1.  **도메인 및 ACM 설정 (`ingress-patch.yaml`)**
    *   파일: `../kyeol-app-gitops/apps/saleor/overlays/dev/patches/ingress-patch.yaml`
    *   `alb.ingress.kubernetes.io/certificate-arn`: 본인의 오사카 리전 ACM ARN으로 교체 (`yesol.shop` 인증서)
    *   `external-dns.alpha.kubernetes.io/hostname`: 본인의 도메인으로 교체 (예: `dev.yesol.shop`)
    *   `spec.rules.host`: 위와 동일한 도메인으로 교체

2.  **ExternalDNS 도메인 필터 (`external-dns.values.yaml`)**
    *   파일: `../kyeol-platform-gitops/clusters/dev/values/external-dns.values.yaml` (⚠️ 주의: platform 폴더입니다)
    *   `domainFilters`: `yesol.shop` (본인 도메인)으로 수정
    *   **중요**: 수정 후 반드시 변경사항을 클러스터에 적용해야 합니다.
    *   `kubectl kustomize ../kyeol-platform-gitops/clusters/dev/addons/external-dns/ --enable-helm --load-restrictor LoadRestrictionsNone | kubectl apply -f -`

3.  **이미지 레지스트리 설정 (`kustomization.yaml`)**
    *   파일: `../kyeol-app-gitops/apps/saleor/overlays/dev/kustomization.yaml`
    *   `newName`: 본인 ECR 주소로 변경 (`827913617839.dkr.ecr.ap-northeast-3.amazonaws.com/...`)

### Step 7: ArgoCD에 DEV 클러스터 등록
ArgoCD가 DEV 클러스터에 앱을 배포하려면, DEV 클러스터의 접속 정보를 ArgoCD에 등록해야 합니다.

```bash
# 1. ArgoCD CLI 설치 (Linux)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64


# 2. ArgoCD 로그인 (SKIP)
# CLB(Classic Load Balancer) 문제로 CLI 로그인이 불안정할 수 있습니다.
# 로그인을 건너뛰고 바로 직접 연결(--core) 하는 방식을 사용합니다.
# 2. ArgoCD 로그인 (MGMT LoadBalancer 주소 사용)
# 주소 확인: kubectl get svc -n argocd argocd-server --context arn:aws:eks:ap-northeast-3:827913617839:cluster/sol-kyeol-mgmt-eks
# argocd login <EXTERNAL-IP> --username admin --password <초기비밀번호> --insecure --grpc-web
# 예) argocd login acda1ade2e4d14a9aa3915ce184af50a-109329774.ap-northeast-3.elb.amazonaws.com --username admin --password atKtXxhkNlP8Kj9I --insecure


# 3. DEV 클러스터 등록
# 먼저 MGMT 클러스터에 접속합니다 (ArgoCD가 설치된 곳)
kubectl config use-context arn:aws:eks:ap-northeast-3:827913617839:cluster/sol-kyeol-mgmt-eks
kubectl config set-context --current --namespace=argocd

# DEV 접속 정보 업데이트 (로컬)
aws eks update-kubeconfig --region ap-northeast-3 --name sol-kyeol-dev-eks
aws eks update-kubeconfig --region ap-northeast-3 --name sol-kyeol-mgmt-eks

# 등록 명령 실행 (--core 옵션으로 로그인 없이 수행)
argocd cluster add arn:aws:eks:ap-northeast-3:827913617839:cluster/sol-kyeol-dev-eks --core --name sol-kyeol-dev-eks --yes
```

### Step 8: 애플리케이션 배포
모든 준비가 끝났습니다! 이제 ArgoCD에게 배포 명령을 내립니다.

1.  **Application 매니페스트 수정**
    *   파일: `../kyeol-app-gitops/argocd/applications/saleor-dev.yaml`
    *   `repoURL`: 본인의 GitHub 레포지토리 주소로 변경
    *   `server`: `https://kubernetes.default.svc` 대신 DEV 클러스터의 엔드포인트로 변경
        *   DEV 엔드포인트 확인: `aws eks describe-cluster --name sol-kyeol-dev-eks --region ap-northeast-3 --query "cluster.endpoint" --output text`

2.  **배포 적용**
    ```bash
    kubectl config use-context arn:aws:eks:ap-northeast-3:827913617839:cluster/sol-kyeol-mgmt-eks
    kubectl apply -f ../kyeol-app-gitops/argocd/applications/saleor-dev.yaml
    ```

3.  **확인**
    ArgoCD 웹 UI에 접속해서 `saleor-dev` 애플리케이션이 생성되고 `Synced` 상태가 되는지 확인합니다.

---

## 4. CI/CD 파이프라인 설정 (GitHub Actions)

개발자 코드가 변경될 때 자동으로 빌드 및 배포되도록 설정합니다.

### 1. GitHub Secrets 등록
`kyeol-storefront` 레포지토리의 **Settings > Secrets and variables > Actions** 메뉴에서 아래 값들을 등록합니다.

*   `AWS_ACCESS_KEY_ID`: (IAM 사용자 액세스 키)
*   `AWS_SECRET_ACCESS_KEY`: (IAM 사용자 비밀 키)
*   `ECR_REGISTRY`: `827913617839.dkr.ecr.ap-northeast-3.amazonaws.com`
*   `ECR_REPOSITORY`: `sol-kyeol-storefront`

### 2. 동작 원리
1.  코드를 `main` 브랜치에 푸시합니다.
2.  GitHub Actions (`.github/workflows/build-push-ecr.yml`)가 동작하여 Docker 이미지를 빌드하고 ECR에 푸시합니다 (`dev-latest` 태그).
3.  ArgoCD는 `dev-latest` 태그의 변경을 감지하거나(설정에 따라), 사용자가 ArgoCD UI에서 `Refresh` 버튼을 누르면 새 이미지를 가져와 배포합니다.


## 5. 배포 확인 및 접속

### ArgoCD 접속
*   **URL**: MGMT 환경의 LoadBalancer 주소 (설치 후 확인 필요)
    ```bash
    # 1. MGMT 클러스터로 전환 (ArgoCD가 사는 곳)
    kubectl config use-context arn:aws:eks:ap-northeast-3:827913617839:cluster/sol-kyeol-mgmt-eks
    
    # 2. ArgoCD 서버 주소 확인
    kubectl get svc -n argocd argocd-server
    ```
    (EXTERNAL-IP에 나오는 주소로 접속)
*   **ID**: `admin`
*   **PW**: Step 3에서 확인한 비밀번호

### 문제 해결 (Troubleshooting)
*   **S3 버킷 에러**: `terraform.tfvars`의 `aws_account_id`가 본인의 ID와 일치하는지 확인하세요.
*   **AZ 에러**: 오사카 리전은 `ap-northeast-3a`, `3c`를 사용해야 합니다.
