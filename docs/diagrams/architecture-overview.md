# CloudMart Architecture Overview

## 🏗️ **High-Level System Architecture**

```mermaid
graph TB
    subgraph "Users & External Systems"
        U1[Web Users] 
        U2[Mobile Users]
        U3[Admin Users]
        U4[External APIs]
    end

    subgraph "Load Balancing & CDN"
        LB[AWS Application Load Balancer]
        CDN[CloudFront CDN]
    end

    subgraph "AWS - Primary Cloud"
        subgraph "EKS Cluster"
            FE[Frontend Pods<br/>React + Nginx]
            BE[Backend Pods<br/>Node.js + Express]
            AI[AI Service Pods<br/>OpenAI + Bedrock]
        end
        
        subgraph "Data Layer"
            DB1[(DynamoDB<br/>Products)]
            DB2[(DynamoDB<br/>Orders)]
            DB3[(DynamoDB<br/>Tickets)]
            DB4[(DynamoDB<br/>Users)]
        end
        
        subgraph "Serverless"
            L1[Lambda<br/>List Products]
            L2[Lambda<br/>AI Support]
            L3[Lambda<br/>Data Pipeline]
        end
        
        subgraph "Container Registry"
            ECR[Amazon ECR<br/>Container Images]
        end
        
        subgraph "Monitoring"
            CW[CloudWatch<br/>Logs & Metrics]
            S3[S3 Bucket<br/>Observability Data]
        end
    end

    subgraph "Azure - AI Services"
        AZ1[Azure AI Language<br/>Sentiment Analysis]
        AZ2[Azure Cognitive Services<br/>Text Analytics]
    end

    subgraph "GCP - Analytics"
        BQ[BigQuery<br/>Data Warehouse]
        DS[Data Studio<br/>Dashboards]
        GCS[Cloud Storage<br/>Data Lake]
    end

    subgraph "Monitoring Stack"
        PROM[Prometheus<br/>Metrics Collection]
        GRAF[Grafana<br/>Visualization]
        FALCO[Falco<br/>Runtime Security]
        JAEGER[Jaeger<br/>Distributed Tracing]
    end

    %% User Connections
    U1 --> CDN
    U2 --> CDN
    U3 --> LB
    CDN --> LB
    
    %% Load Balancer to Services
    LB --> FE
    FE --> BE
    BE --> AI
    
    %% Database Connections
    BE --> DB1
    BE --> DB2
    BE --> DB3
    BE --> DB4
    L1 --> DB1
    L2 --> DB3
    
    %% Lambda Triggers
    DB2 --> L3
    BE --> L1
    BE --> L2
    
    %% Cross-Cloud Connections
    AI --> AZ1
    AI --> AZ2
    L3 --> BQ
    BQ --> DS
    
    %% Monitoring Connections
    BE --> CW
    FE --> CW
    EKS --> PROM
    PROM --> GRAF
    EKS --> FALCO
    BE --> JAEGER
    
    %% External APIs
    U4 --> BE
    
    %% Container Registry
    ECR --> FE
    ECR --> BE
    ECR --> AI

    %% Styling
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#fff
    classDef azure fill:#0078D4,stroke:#fff,stroke-width:2px,color:#fff
    classDef gcp fill:#4285F4,stroke:#fff,stroke-width:2px,color:#fff
    classDef monitoring fill:#E6522C,stroke:#fff,stroke-width:2px,color:#fff
    classDef users fill:#28a745,stroke:#fff,stroke-width:2px,color:#fff
    
    class FE,BE,AI,DB1,DB2,DB3,DB4,L1,L2,L3,ECR,CW,S3,LB,CDN aws
    class AZ1,AZ2 azure
    class BQ,DS,GCS gcp
    class PROM,GRAF,FALCO,JAEGER monitoring
    class U1,U2,U3,U4 users
```

## 🔄 **Data Flow Architecture**

```mermaid
flowchart LR
    subgraph "Frontend Layer"
        UI[React UI]
        STATE[State Management]
    end
    
    subgraph "API Gateway"
        ALB[Application Load Balancer]
        INGRESS[Kubernetes Ingress]
    end
    
    subgraph "Application Layer"
        AUTH[Authentication Service]
        PRODUCT[Product Service]
        ORDER[Order Service]
        SUPPORT[Support Service]
        AI_SVC[AI Service]
    end
    
    subgraph "Data Processing"
        STREAM[DynamoDB Streams]
        LAMBDA[Lambda Functions]
        QUEUE[Event Queue]
    end
    
    subgraph "Data Storage"
        DYNAMO[(DynamoDB)]
        CACHE[(Redis Cache)]
        S3_DATA[(S3 Data Lake)]
    end
    
    subgraph "Analytics Pipeline"
        ETL[ETL Process]
        BIGQUERY[(BigQuery)]
        DASHBOARD[Analytics Dashboard]
    end
    
    subgraph "AI/ML Services"
        OPENAI[OpenAI GPT-4]
        BEDROCK[AWS Bedrock]
        AZURE_AI[Azure AI]
    end

    %% User Flow
    UI --> STATE
    STATE --> ALB
    ALB --> INGRESS
    
    %% Service Routing
    INGRESS --> AUTH
    INGRESS --> PRODUCT
    INGRESS --> ORDER
    INGRESS --> SUPPORT
    
    %% Data Flow
    PRODUCT --> DYNAMO
    ORDER --> DYNAMO
    SUPPORT --> AI_SVC
    
    %% AI Integration
    AI_SVC --> OPENAI
    AI_SVC --> BEDROCK
    AI_SVC --> AZURE_AI
    
    %% Event Processing
    DYNAMO --> STREAM
    STREAM --> LAMBDA
    LAMBDA --> QUEUE
    
    %% Analytics Pipeline
    LAMBDA --> ETL
    ETL --> BIGQUERY
    BIGQUERY --> DASHBOARD
    
    %% Caching
    PRODUCT --> CACHE
    ORDER --> CACHE
    
    %% Data Lake
    LAMBDA --> S3_DATA
    S3_DATA --> ETL

    %% Styling
    classDef frontend fill:#61DAFB,stroke:#000,stroke-width:2px,color:#000
    classDef api fill:#FF6B6B,stroke:#fff,stroke-width:2px,color:#fff
    classDef service fill:#4ECDC4,stroke:#fff,stroke-width:2px,color:#fff
    classDef data fill:#45B7D1,stroke:#fff,stroke-width:2px,color:#fff
    classDef ai fill:#96CEB4,stroke:#fff,stroke-width:2px,color:#fff
    
    class UI,STATE frontend
    class ALB,INGRESS api
    class AUTH,PRODUCT,ORDER,SUPPORT,AI_SVC service
    class DYNAMO,CACHE,S3_DATA,BIGQUERY data
    class OPENAI,BEDROCK,AZURE_AI ai
```

## 🌐 **Multi-Cloud Integration**

```mermaid
graph TB
    subgraph "AWS Primary Cloud"
        subgraph "Compute"
            EKS[EKS Cluster]
            LAMBDA_AWS[Lambda Functions]
            FARGATE[Fargate Tasks]
        end
        
        subgraph "Storage & Database"
            DYNAMO[DynamoDB]
            S3_AWS[S3 Buckets]
            RDS[RDS (Future)]
        end
        
        subgraph "Networking"
            VPC[VPC]
            ALB_AWS[Application Load Balancer]
            NAT[NAT Gateway]
        end
        
        subgraph "Security"
            IAM[IAM Roles]
            SECRETS[Secrets Manager]
            KMS[KMS Encryption]
        end
    end

    subgraph "Azure Secondary Cloud"
        subgraph "AI Services"
            COGNITIVE[Cognitive Services]
            LANGUAGE[Language Understanding]
            SENTIMENT[Sentiment Analysis]
        end
        
        subgraph "Security (Future)"
            KEYVAULT[Key Vault]
            AAD[Azure AD]
        end
    end

    subgraph "GCP Analytics Cloud"
        subgraph "Data Analytics"
            BIGQUERY_GCP[BigQuery]
            DATAFLOW[Dataflow]
            DATASTUDIO[Data Studio]
        end
        
        subgraph "Storage"
            GCS_BUCKET[Cloud Storage]
            BIGTABLE[Bigtable (Future)]
        end
    end

    subgraph "Cross-Cloud Networking"
        VPN[VPN Connections]
        PEERING[VPC Peering]
        CDN_GLOBAL[Global CDN]
    end

    %% AWS Internal Connections
    EKS --> DYNAMO
    EKS --> S3_AWS
    LAMBDA_AWS --> DYNAMO
    EKS --> ALB_AWS
    
    %% Cross-Cloud API Connections
    EKS -.->|HTTPS API| COGNITIVE
    EKS -.->|HTTPS API| LANGUAGE
    LAMBDA_AWS -.->|HTTPS API| BIGQUERY_GCP
    
    %% Data Pipeline
    DYNAMO --> LAMBDA_AWS
    LAMBDA_AWS --> GCS_BUCKET
    GCS_BUCKET --> DATAFLOW
    DATAFLOW --> BIGQUERY_GCP
    BIGQUERY_GCP --> DATASTUDIO
    
    %% Security Connections
    EKS --> IAM
    EKS --> SECRETS
    LAMBDA_AWS --> KMS
    
    %% Future Connections (Dotted)
    VPC -.->|Future| VPN
    VPN -.->|Future| KEYVAULT
    
    %% Global CDN
    CDN_GLOBAL --> ALB_AWS
    CDN_GLOBAL --> COGNITIVE

    %% Styling
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#fff
    classDef azure fill:#0078D4,stroke:#fff,stroke-width:2px,color:#fff
    classDef gcp fill:#4285F4,stroke:#fff,stroke-width:2px,color:#fff
    classDef network fill:#6C5CE7,stroke:#fff,stroke-width:2px,color:#fff
    
    class EKS,LAMBDA_AWS,FARGATE,DYNAMO,S3_AWS,RDS,VPC,ALB_AWS,NAT,IAM,SECRETS,KMS aws
    class COGNITIVE,LANGUAGE,SENTIMENT,KEYVAULT,AAD azure
    class BIGQUERY_GCP,DATAFLOW,DATASTUDIO,GCS_BUCKET,BIGTABLE gcp
    class VPN,PEERING,CDN_GLOBAL network
```
