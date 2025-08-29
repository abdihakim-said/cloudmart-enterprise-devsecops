# CloudMart AWS Architecture Diagram

## Multi-Cloud E-Commerce Platform Architecture

```mermaid
graph TB
    subgraph "External Services"
        USERS[👥 Users]
        AZURE[🔵 Azure Text Analytics]
        GCP[🟡 Google BigQuery]
    end

    subgraph "AWS Cloud - us-east-1"
        subgraph "VPC: 10.0.0.0/16"
            subgraph "Public Subnets"
                PUB1[Public Subnet 1<br/>10.0.1.0/24<br/>us-east-1a]
                PUB2[Public Subnet 2<br/>10.0.2.0/24<br/>us-east-1b]
                IGW[Internet Gateway]
                NAT1[NAT Gateway 1]
                NAT2[NAT Gateway 2]
            end
            
            subgraph "Private Subnets"
                PRIV1[Private Subnet 1<br/>10.0.10.0/24<br/>us-east-1a]
                PRIV2[Private Subnet 2<br/>10.0.11.0/24<br/>us-east-1b]
            end
            
            subgraph "EKS Cluster"
                EKS[🚢 cloudmart-cluster<br/>Kubernetes 1.28]
                NODES[⚙️ Node Group<br/>t3.medium (1-4 nodes)]
                PODS[📦 Application Pods<br/>Frontend + Backend + AI]
            end
        end
        
        subgraph "DynamoDB Tables"
            PRODUCTS[(🛍️ cloudmart-products<br/>Products Catalog)]
            ORDERS[(📋 cloudmart-orders<br/>Order Management<br/>+ DDB Streams)]
            TICKETS[(🎫 cloudmart-tickets<br/>Support Tickets)]
        end
        
        subgraph "Lambda Functions"
            LAMBDA1[⚡ list-products<br/>Product API]
            LAMBDA2[⚡ data-pipeline<br/>DDB → BigQuery ETL]
        end
        
        subgraph "Security & Secrets"
            KMS[🔐 KMS Key<br/>EKS Encryption]
            SECRET1[🔒 Azure Credentials<br/>Text Analytics Keys]
            SECRET2[🔒 GCP Credentials<br/>BigQuery Service Account]
        end
    end

    %% User Flow
    USERS --> IGW
    IGW --> PUB1
    IGW --> PUB2
    
    %% NAT Gateway connections
    PUB1 --> NAT1
    PUB2 --> NAT2
    NAT1 --> PRIV1
    NAT2 --> PRIV2
    
    %% EKS connections
    EKS --> PRIV1
    EKS --> PRIV2
    NODES --> EKS
    PODS --> NODES
    
    %% Application data flow
    PODS --> LAMBDA1
    PODS --> ORDERS
    LAMBDA1 --> PRODUCTS
    
    %% DynamoDB Streams trigger
    ORDERS -.->|Stream Trigger| LAMBDA2
    
    %% Cross-cloud integration
    LAMBDA2 --> SECRET2
    LAMBDA2 -.->|HTTPS API| GCP
    PODS --> SECRET1
    PODS -.->|HTTPS API| AZURE
    
    %% Security
    KMS --> EKS
    
    %% Styling
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#fff
    classDef azure fill:#0078D4,stroke:#fff,stroke-width:2px,color:#fff
    classDef gcp fill:#4285F4,stroke:#fff,stroke-width:2px,color:#fff
    classDef users fill:#28a745,stroke:#fff,stroke-width:2px,color:#fff
    classDef data fill:#FF6B6B,stroke:#fff,stroke-width:2px,color:#fff
    
    class EKS,NODES,PODS,LAMBDA1,LAMBDA2,KMS,SECRET1,SECRET2,IGW,NAT1,NAT2,PUB1,PUB2,PRIV1,PRIV2 aws
    class AZURE azure
    class GCP gcp
    class USERS users
    class PRODUCTS,ORDERS,TICKETS data
```

## Architecture Components

### 🌐 **Networking Layer**
- **VPC**: `10.0.0.0/16` with DNS support
- **Public Subnets**: `10.0.1.0/24`, `10.0.2.0/24` (Multi-AZ)
- **Private Subnets**: `10.0.10.0/24`, `10.0.11.0/24` (Multi-AZ)
- **Internet Gateway**: Public internet access
- **NAT Gateways**: Outbound internet for private subnets

### 🚢 **Container Platform**
- **EKS Cluster**: `cloudmart-cluster` (Kubernetes 1.28)
- **Node Group**: `t3.medium` instances (1-4 nodes, auto-scaling)
- **Encryption**: KMS-encrypted secrets at rest

### 💾 **Data Layer**
- **Products Table**: Product catalog with encryption
- **Orders Table**: Order management with DynamoDB Streams
- **Tickets Table**: Customer support tickets

### ⚡ **Serverless Functions**
- **List Products**: Product API Lambda function
- **Data Pipeline**: Real-time ETL from DynamoDB to BigQuery

### 🔒 **Security & Secrets**
- **KMS Encryption**: EKS secrets encryption
- **AWS Secrets Manager**: Cross-cloud credentials storage
- **IAM Roles**: Least privilege access policies

### 🌍 **Multi-Cloud Integration**
- **Azure Text Analytics**: Sentiment analysis service
- **Google BigQuery**: Real-time analytics data warehouse
- **Cross-Cloud Auth**: Centralized credential management

## Data Flow

1. **User Requests** → Internet Gateway → Load Balancer → EKS Pods
2. **Product Queries** → Lambda Function → DynamoDB Products Table
3. **Order Processing** → EKS Pods → DynamoDB Orders Table
4. **Real-time Analytics** → DynamoDB Streams → Lambda → BigQuery
5. **AI Processing** → EKS Pods → Azure Text Analytics (via Secrets Manager)

## High Availability Features

- ✅ Multi-AZ deployment across `us-east-1a` and `us-east-1b`
- ✅ Auto-scaling EKS node groups (1-4 nodes)
- ✅ DynamoDB with point-in-time recovery
- ✅ Redundant NAT Gateways for high availability
- ✅ KMS encryption for data at rest
- ✅ Cross-cloud failover capabilities

## Security Features

- 🔐 **Encryption**: KMS keys for EKS secrets
- 🔐 **Network Security**: Private subnets for workloads
- 🔐 **Access Control**: IAM roles with least privilege
- 🔐 **Secrets Management**: Centralized credential storage
- 🔐 **Compliance**: SOC2 and production-ready configurations

---

**Total Resources Deployed**: 28 AWS resources + Multi-cloud integrations
**Estimated Monthly Cost**: ~$250-500 (depending on usage)
**Deployment Time**: ~15 minutes via Terraform
