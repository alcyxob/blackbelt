variable "region" {}
variable "cluster_name" {}
variable "eks_vpc_id" {}
variable "aws_account_id" {}
/* IAM Roles mapped in RBAC to authenticate the users belonging to those Roles */
variable "eks_aws_managed_policies" {
  type    = list(any)
  default = ["arn:aws:iam::aws:policy/AmazonEKSServicePolicy", "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}
/* -------------------------------------------- */
variable "eks_version" {}
variable "eks_min_capacity" {}
variable "eks_max_capacity" {}
variable "eks_private_subnet_ids" {}
variable "eks_subnet_tag_name" {}
variable "eks_subnet_tag_value" {}
variable "eks_def_cooldown" {}
variable "eks_def_warmup" {}
variable "eks_node_type" {}
variable "eks_ec2_volume_size" {}
variable "eks_node_ami" {}
variable "eks_health_check_type" {}
variable "eks_health_check_grace_period" {}
variable "eks_force_delete" {}
variable "eks_keypair_name" {}
variable "eks_termination_policy" {
  #	OldestInstance, NewestInstance, OldestLaunchConfiguration,
  #	ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy,Default.
}
variable "eks_capacity_timeout" {
  #	Default: ”10m” A maximum duration that Terraform should wait for ASG instances to be healthy before timing out.
  #	Setting this to ”0” causes Terraform to skip all Capacity Waiting behavior.
}
variable "eks_metric_type" {
  /*
	ASGAverageCPUUtilization	-	Average CPU utilization of the Auto Scaling group.
	ASGAverageNetworkIn		-	Average number of bytes received on all network interfaces by the Auto Scaling group.
	ASGAverageNetworkOut		-	Average number of bytes sent out on all network interfaces by the Auto Scaling group.
	ALBRequestCountPerTarget	-	Number of requests completed per target in an Application Load Balancer target group.
    */
}
variable "eks_policy_type" {
  /* "SimpleScaling", "StepScaling" or "TargetTrackingScaling".
	If this value isn't provided, AWS will default to "SimpleScaling."
    */
}
variable "eks_adjustment_type" {
  /* Valid values are "ChangeInCapacity" "ExactCapacity" "PercentChangeInCapacity" */
}
variable "eks_evaluation_periods" {}
variable "eks_high_period_seconds" {
  /*	"The period in seconds over which the specified statistic is applied" */
  default = 60
}
variable "eks_low_period_seconds" {
  type    = number
  default = 300
}
variable "eks_cpu_high_threshold_percent" {
  type    = number
  default = 70
}

variable "eks_cpu_low_threshold_percent" {
  type    = number
  default = 30
}

variable "eks_cpu_statistic" {
  /* Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum`" */
  type    = string
  default = "Average"
}

variable "eks_comparison_up" {
  /*
	The arithmetic operation to use when comparing the specified Statistic and Threshold.
	The specified Statistic value is used as the first operand.
	Either of the following is supported:
	    GreaterThanOrEqualToThreshold
	    GreaterThanThreshold
	    LessThanThreshold
	    LessThanOrEqualToThreshold.
	Additionally, the values
	    LessThanLowerOrGreaterThanUpperThreshold
	    LessThanLowerThreshold
	    GreaterThanUpperThreshold
	are used only for alarms based on anomaly detection models.
    */
}

variable "eks_comparison_down" {}

variable "eks_quantexa_services" {
  description = "Names of the services for quantexa deployment"
  type        = list(string)
  default     = ["etcd", "config-service", "gateway", "app-investigate", "app-resolve", "app-search", "app-security", "app-transaction", "danske-markets-aml-ui"]
}
