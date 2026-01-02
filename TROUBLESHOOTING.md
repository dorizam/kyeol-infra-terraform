# KYEOL Infrastructure Troubleshooting Guide

이 문서는 KYEOL 인프라 구축 및 배포 과정에서 발생할 수 있는 일반적인 문제들과 그 해결 방법을 다룹니다.

## 1. ArgoCD 관련

### 1.1 ArgoCD CLI 로그인 실패 (context deadline exceeded)
*   **증상**: `argocd login` 명령어 실행 시 타임아웃 발생
    ```
    FATA[0030] gRPC connection not ready: context deadline exceeded
    ```
*   **원인**: AWS Classic Load Balancer(CLB)가 HTTP/2 기반의 gRPC 통신을 완벽하게 지원하지 않아 패킷이 드랍됨.
*   **해결 방법**:
    1.  **gRPC-Web 사용**: `--grpc-web` 플래그를 추가하여 HTTP/1.1 호환 모드로 통신.
        ```bash
        argocd login <URL> --username admin --password <PW> --insecure --grpc-web
        ```
    2.  **Core 모드 사용 (권장)**: CLI 로그인을 건너뛰고 Kubernetes API를 통해 직접 제어.
        ```bash
        # MGMT 클러스터 컨텍스트에서 실행
        argocd cluster add ... --core
        ```

### 1.2 "Application referencing project kyeol-apps which does not exist"
*   **증상**: ArgoCD 앱 생성 시 Sync 상태가 `Unknown`이며 에러 발생.
*   **원인**: Application 매니페스트(`saleor-dev.yaml`)에서 지정한 `project: kyeol-apps`가 ArgoCD에 생성되지 않음.
*   **해결 방법**: 프로젝트 정의 YAML을 먼저 적용해야 함.
    ```bash
    kubectl apply -f kyeol-platform-gitops/argocd/app-of-apps/projects/kyeol-app-project.yaml
    ```

---

## 2. 도메인 및 접속 관련

### 2.1 사이트 접속 불가 (DNS_PROBE_FINISHED_NXDOMAIN)
*   **증상**: 배포 완료 후 브라우저에서 접속 시 "사이트에 연결할 수 없음" 에러.
*   **원인 및 점검 순서**:
    1.  **Ingress 설정 불일치**: `ingress-patch.yaml`의 호스트네임이 실제 원하는 도메인(`dev.yesol.shop`)과 일치하는지 확인.
    2.  **Git Push 누락**: 로컬 파일을 수정했지만 GitHub에 Push하지 않아 ArgoCD가 옛날 설정(`msp-g1.click`)으로 배포 중일 수 있음.
    3.  **ExternalDNS 설정**: ExternalDNS의 `domainFilters`가 새 도메인(`yesol.shop`)을 포함하고 있는지 확인.
        *   확인: `kubectl logs -n kube-system -l app.kubernetes.io/name=external-dns`

### 2.2 ExternalDNS가 Route53 레코드를 생성하지 않음
*   **증상**: Ingress는 생성되었지만 Route53에 레코드가 없음.
*   **해결 방법**: `values.yaml`에서 `domainFilters`를 수정하고 **반드시 재배포**해야 함.
    ```bash
    # 단순히 파일만 고치면 안 됨! 적용 명령 필수
    kubectl kustomize .../external-dns/ ... | kubectl apply -f -
    ```

---

## 3. GitHub Actions (CI/CD)

### 3.1 워크플로우 실패 또는 배포 안 됨
*   **체크리스트**:
    *   GitHub Secrets(`AWS_ACCESS_KEY_ID`, `ECR_REGISTRY` 등)가 올바르게 등록되었는가?
    *   `build-push-ecr.yml` 파일의 `AWS_REGION`이 `ap-northeast-3` (오사카)로 수정되었는가?
    *   ArgoCD가 Docker 이미지 태그(`dev-latest`)를 사용하고 있는가? (`imagePullPolicy: Always` 필요)
