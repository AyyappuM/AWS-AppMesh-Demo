# AWS-AppMesh-Demo
AWS-AppMesh-Demo

* This set up will work with trusted access disabled for RAM service in AWS Organizations.

cd terraform

```
terraform apply --auto-approve \
-var="mesh_account_number=<a1_account_number>" \
-var="service_a_account_number=<a2_account_number>" \
-var="service_b_account_number=<a3_account_number>" \
-var="region=ap-south-1" \
-var="service_a_account_profile=a2" \
-var="service_b_account_profile=a3" \
-var="service_a_account_vpc_cidr_range=192.168.0.0/25" \
-var="service_a_account_subnet_cidr_range=192.168.0.0/26" \
-var="service_b_account_vpc_cidr_range=192.168.0.128/25" \
-var="service_b_account_subnet_cidr_range=192.168.0.128/26"
```

