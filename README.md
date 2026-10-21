# Amazon EKS Cluster with Self-Managed Workers — Terraform

Terraform configuration that builds a VPC, an Amazon EKS control plane, a self-managed worker Auto Scaling group and a public "kubectl" EC2 server, using three local modules (`network`, `cluster`, `kubernetes-server`).

> **Status:** legacy reference (2020), not actively maintained. Review and update before using. Written for **Terraform 0.11.14** (per the original README; `"${...}"` interpolation, `type = "list"`, `map(...)`), with the pre-3.x AWS provider. Follows the early EKS "getting started" pattern (Launch Configuration + `bootstrap.sh`, `aws-iam-authenticator`), which is now superseded by managed node groups.

## Architecture

- **`network`** — VPC `10.0.0.0/16` with master, worker, public and private subnets across three AZs; IGW + public route table (master and public subnets); one NAT Gateway in the first master subnet + private route table (worker and private subnets). Public/private subnets carry `kubernetes.io/cluster/<name>` and `kubernetes.io/role/(internal-)elb` tags.
- **`cluster`**
  - IAM role for EKS with `AmazonEKSClusterPolicy` and `AmazonEKSServicePolicy`.
  - Cluster SG: 443 from worker nodes and from `0.0.0.0/0`.
  - `aws_eks_cluster` in the master + worker subnets (default Kubernetes version, public endpoint).
  - Worker IAM role with `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`, `AmazonEC2FullAccess` and a custom tagging policy (`tag:*Resources`, `tag:Get*` on `*`).
  - Worker SG (node-to-node, control plane → 1025-65535, kubectl server and ALB SG → all TCP).
  - Latest `amazon-eks-node-<version>` AMI (owner: AWS EKS AMI account), Launch Configuration (`t2.micro`) running `/etc/eks/bootstrap.sh`, ASG min 2 / desired 2 / max 3 in worker subnets.
  - An "ALB" security group for load balancers (no load balancer is created).
  - Outputs: `kubeconfig` (uses `aws-iam-authenticator`), `config_map_aws_auth`, `cluster-name`.
  - `workstation-external-ip.tf` fetches your public IP via `icanhazip.com`, but the result is not used.
- **`kubernetes-server`** — EC2 instance in the first public subnet (50 GiB gp2), SSH SG open to `0.0.0.0/0`, Elastic IP.

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `profile` | AWS CLI profile | — |
| `region` | AWS region | `us-east-1` |
| `key` | Existing EC2 key pair for the kubectl server (`<KEY_PAIR_NAME>`) | — |
| `instance-ami` | AMI for the kubectl server (default is a Mumbai/ap-south-1 AMI — override it) | region-specific AMI |
| `instance_type` | kubectl server instance type | `t3a.medium` |
| `cluster-name` | EKS cluster name | — |
| `server-name` | Name tag of the kubectl server | — |
| `vpc_name` | VPC Name tag | — |
| `sub_ids` | Declared but unused | `[]` |

## Usage

```bash
terraform init
terraform plan  -var profile=<AWS_PROFILE> -var key=<KEY_PAIR_NAME> -var instance-ami=<AMI_ID> \
  -var cluster-name=<CLUSTER_NAME> -var server-name=<SERVER_NAME> -var vpc_name=<VPC_NAME>
terraform apply # same -var flags
terraform output kubeconfig > kubeconfig
terraform output config_map_aws_auth > aws-auth.yaml
kubectl --kubeconfig kubeconfig apply -f aws-auth.yaml   # lets the workers join
```

## Security notes

- EKS API endpoint is public and the cluster SG allows 443 from `0.0.0.0/0`.
- The kubectl server has SSH open to `0.0.0.0/0` and a public Elastic IP; restrict to `<MY_IP>/32` or use SSM.
- Workers get `AmazonEC2FullAccess` plus tag write on `*`; any pod can use these via instance metadata (no IRSA, no IMDSv2 enforcement).
- Master subnets route to the IGW; single NAT Gateway; unencrypted root volumes; local state only.
- `t2.micro` workers, `aws-iam-authenticator` and `client.authentication.k8s.io/v1alpha1` are obsolete; the default EKS version will be far out of support.

## Cleanup

Delete any Kubernetes `LoadBalancer` services first (they create ELBs outside Terraform), then:

```bash
terraform destroy   # same -var flags as apply
```

## License

MIT — see [LICENSE](LICENSE).
