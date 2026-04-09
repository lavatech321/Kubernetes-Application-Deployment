# Kubernetes Application Deployment (Minikube on AWS EC2)

This project demonstrates a complete **end-to-end deployment of a full-stack application** using:
* **Terraform** → Infrastructure provisioning (AWS EC2)
* **Minikube** → Local Kubernetes cluster inside EC2
* **Kubernetes** → Application orchestration
* **ReactJS** → Frontend
* **Spring Boot** → Backend
* **MySQL** → Database
  
---

# Technologies Used

| Layer                   | Technology                        |
| ----------------------- | --------------------------------- |
| Infrastructure          | Terraform, AWS EC2 (Amazon Linux) |
| Container Orchestration | Kubernetes (Minikube)             |
| Frontend                | ReactJS (Node.js)                 |
| Backend                 | Spring Boot (Java 17)             |
| Database                | MySQL                             |
| Networking              | NodePort + Port Forwarding        |

---

# Architecture Diagram

```
                ┌──────────────────────────────┐
                │        User Browser          │
                │  http://<EC2-IP>:30000      │
                └────────────┬─────────────────┘
                             │
                             ▼
                ┌──────────────────────────────┐
                │        AWS EC2 Instance      │
                │      (Amazon Linux + K8s)    │
                └────────────┬─────────────────┘
                             │
                 ┌───────────┴───────────┐
                 │      Minikube Cluster │
                 │      (Kubernetes)     │
                 └───────────┬───────────┘
                             │
        ┌────────────────────┼────────────────────┐
        ▼                    ▼                    ▼
┌──────────────┐   ┌──────────────────┐   ┌──────────────┐
│  Frontend    │   │    Backend       │   │    MySQL     │
│ ReactJS      │   │ Spring Boot      │   │ Database     │
│ Port: 3000   │   │ Port: 7081       │   │ Port: 3306   │
│ NodePort:    │   │ NodePort:        │   │ ClusterIP    │
│ 30000        │   │ 30081            │   │              │
└──────────────┘   └──────────────────┘   └──────────────┘
```

---

# Application Ports

| Component             | Internal Port | External Access |
| --------------------- | ------------- | --------------- |
| Frontend (ReactJS)    | 3000          | 30000           |
| Backend (Spring Boot) | 7081          | 30081           |
| MySQL                 | 3306          | Internal        |

---

# Project Setup

## Step 1: Clone Repository

```bash
git clone https://github.com/lavatech321/Kubernetes-Application-Deployment.git

# Substitute access key id and secret key id inside terraform.tfvars

cd Kubernetes-Application-Deployment
```

---

## Step 2: Configure AWS Credentials ⚠️

Before running Terraform, update your credentials in:

```bash
terraform.tfvars
```

Add your AWS credentials:

```hcl
access_key_id     = "YOUR_ACCESS_KEY"
secret_key_id     = "YOUR_SECRET_KEY"
```

---

## Step 3: Initialize Terraform

```bash
terraform init
```

---

## Step 4: Apply Infrastructure

```bash
terraform apply --auto-approve
```

---

### Terraform Outputs

After successful deployment, you will get:

```hcl
output "public_ip" {
	value = "Public IP address: ec2-user@${aws_instance.server.public_ip}\n"
}

output "sshkey" {
	value = "SSH Key location: ~/.ssh/id_rsa \n"
}

output "Kubernetes-Application-Deployment" {
	value = "Application pod server: kubectl get pods \n"
}

output "MYsql-Live" {
	value = "MySQL Credentails: mysql -uappuser -papppass appdb \n"
}

output "App-Live" {
	value = "Reactjs and Spring boot Live: http://${aws_instance.server.public_ip}:30000 \n"
}
```

---

## Step 5: Access EC2 Instance

```bash
ssh ec2-user@<PUBLIC_IP>
```

---

## Step 6: Enable Application Access (IMPORTANT)

Since Minikube runs inside Docker, you must enable port forwarding:

```bash
kubectl port-forward service/frontend 30000:3000 --address 0.0.0.0 &
kubectl port-forward service/backend 30081:7081 --address 0.0.0.0 &
```

---

# Access Application

### Frontend:

```
http://<EC2_PUBLIC_IP>:30000
```

---

# MySQL Access

Take access of mysql pod and execute below command:
```bash
mysql -uappuser -papppass appdb
```

---

# Key Highlights

* Automated EC2 provisioning using Terraform
* Automated Minikube setup inside EC2
* Kubernetes deployments for frontend, backend, and database
* Secure port exposure via Security Groups
* Full-stack application accessible via public IP
* No manual infrastructure setup required

---

# Notes

* Port forwarding is required due to Minikube Docker driver networking
* This setup is ideal for **learning, demos, and DevOps practice**
* Not production-ready (no LoadBalancer/Ingress/CI-CD yet)

---

