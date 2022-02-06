# EKS Cluster.

The AWS engineers have done great job to implement the reconciliation procedure to well secure a K8S cluster running on AWS.

## AWS IAM Roles: let's repeat the conception.
* An access Policy is created.
* A Role is created.
* The Policy is attached to the Role.
* A User is created.
* A Group is created and the User is added to the Group.
* The Role is attached to the Group in the Tab "Permissions", and then the user can obtain the resources allowed by
the Policy via the Role Assuming attached to the Group to which the User belongs to.

So this is short how the "Role-ing" works on AWS.


# K8S has its own permission design - independent from AWS. So here we will reconsile it with that of AWS IAM.

## The components for secure access to K8S cluster.

## apiGroups
```
    "admissionregistration.k8s.io",
    "apiextensions.k8s.io",
    "apiregistration.k8s.io",
    "apiregistration.k8s.io",
    "apps",
    "authentication.k8s.io",
    "authorization.k8s.io",
    "autoscaling",
    "batch",
    "certificates.k8s.io",
    "coordination.k8s.io",
    "crd.k8s.amazonaws.com",
    "events.k8s.io",
    "extensions",
    "networking.k8s.io",
    "node.k8s.io",
    "policy",
    "rbac.authorization.k8s.io",
    "rbac.authorization.k8s.io",
    "scheduling.k8s.io",
    "storage.k8s.io"
```
## resources:
```
    "alertmanagers",
    "apiservices",
    "bindings",
    "certificatesigningrequests",
    "clusterrolebindings",
    "clusterroles",
    "componentstatuses",
    "configmaps",
    "controllerrevisions",
    "cronjobs",
    "customresourcedefinitions",
    "daemonsets",
    "deployments",
    "endpoints",
    "events",
    "horizontalpodautoscalers",
    "ingresses",
    "initializerconfigurations",
    "jobs",
    "leases",
    "limitranges",
    "localsubjectaccessreviews",
    "mutatingwebhookconfigurations",
    "namespaces",
    "networkpolicies",
    "nodes",
    "persistentvolumeclaims",
    "persistentvolumes",
    "poddisruptionbudgets",
    "pods",
    "podsecuritypolicies",
    "podtemplates",
    "priorityclasses",
    "prometheuses",
    "prometheusrules",
    "replicasets",
    "replicationcontrollers",
    "resourcequotas",
    "rolebindings",
    "roles",
    "secrets",
    "selfsubjectaccessreviews",
    "selfsubjectrulesreviews",
    "serviceaccounts",
    "servicemonitors",
    "services",
    "statefulsets",
    "storageclasses",
    "subjectaccessreviews",
    "tokenreviews",
    "validatingwebhookconfigurations",
    "volumeattachments"
```

## verbs:
```
    "get",
    "list",
    "watch",
    "create",
    "update",
    "patch",
    "delete",
    "deletecollection",
    "proxy"
```

Actually **API Groups** can be omited in the K8S Role and all can be allowed:
```
- apiGroups: [
    "*"
    ]
```
and further the access be limited in the **resources:** part: meaning which resources a user is authorized to work with in the K8S cluster after the authentication.
The **verbs:** part lists what the user can do with the resources. They are listed above and they are obvious.

# Practical meaning of all this on the real example of the new PROD account.

We must ensure the secure access for DevOps, Devlopers, Middle Develoepr, Jubior Developers and separate them by the K8S groups.
Technically we can create each user in K8S and describe the access limits for each, but soon we will be overwhelmed with supporting them and terrified with the mess caused by that approach to the security.

So we provide the idea to authenticate the users on AWS IAM Roles. The K8S cluster asks the AWS IAM if the user who is logging in K8S exists or not on AWS IAM.
If exits then the user is authorized by means of the K8S cluster Role.

## Well, practically speaking:

* Prod account
* Create Roles **"prod-devops"**, **"prod-developers"** - delegate them access from the Dev Account (app-dev) so that not to breed up overwhelming mess with user management on two accounts (that would be a terrible headache);
Attach the policies appropriate for these Roles - what DevOps can access, and what Developers can access, and so on. These Roles are for work with the AWS Resources.
* Create Roles **"prod-devops-k8s"** and **"prod-developers-k8s"**.
These Roles actually **DO NOT** need any AWS IAM access Policies attached - attach to it only the users which will be confirmed against K8S internal authentication queries from EKS.
* When the K8S cluster is created by this terraform script it must have two K8S RBAC Roles described in the Terraform code here.
```
    - rolearn: arn:aws:iam::0123456789:role/prod-devops-k8s
      username: prod-devops-k8s
      groups:
        - system:masters
    - rolearn: arn:aws:iam::0123456789:role/prod-developers-k8s
      username: prod-developers-k8s
      groups:
        - prod-developers-k8s
```
* The user **"prod-terraform-runner"** which envoked the Terraform code becomes a built in admin of the K8S Cluster, it's a kind of AWS "root" account: full, unlimited access - and which is presupposed by the K8S design never to be limited.
Say, this is the user **"prod-terraform-runner"**.
So after the cluster has been built, and the RBAC Role on K8S Cluster configured, the Access Key of **"prod-terraform-runner"** can be deleted for security reasons.
* On your local comp the role profile should be configured as usual:
```
[profile prod-devops-k8s]
role_arn = arn:aws:iam::082573909043:role/prod-devops-k8s
mfa_serial = arn:aws:iam::012556223264:mfa/vitali.malicky
source_profile = AKIAQF3DIYMQEFJSRJEK
region = us-east-1
```
* As you see: you login as usual on Dev Account, type an MFA pass code, and Assume Role on to the Prod Account.
K8S Cluster checks you in that Role and if you are there, you are granted access to K8S Cluster on EKS.
Hereafter the K8S Cluster reads its own permission policies provided for your Role.

* So, repeat. Devops are in the Role **"prod-devops-k8s"** (I repeat: the Roles **"*-k8s"** have no permissions at all to do anything with the AWS Resources, their task is only to reply to K8S requests to confirm that the user is in the Role),
next step - the K8S Cluster grants the **"system:masters"** permisions for users who passed the Role authentication on AWS IAM (passed MFA) and now got into K8S.
Here K8S applies its own RBAC Role where the Devops **"system:masters"** which allows everything. The only difference between **"prod-terraform-runner"** and **"prod-devops-k8s"** is that the Service User
**"prod-terraform-runner"** cannot be limited/administered/etc, so its AccessKey is deleted after cluster deploy; the Role **"prod-devops-k8s"** can be managed, the users can be added and removed - so the access to K8S is under strict control.

* When a user who belongs to the Role **"prod-developers-k8s"** has successfully passed the authentication procedure, the K8S looks through the access control group **"prod-developers-k8s"** and controls the access to the K8S Cluster resources.
This K8S groups is as follows (also check **"role.tf"** to see complete configuration with bindings):
```
        api_groups = ["*"]
        resources  = [
            "alertmanagers",
            "apiservices",
            "certificatesigningrequests",
            "componentstatuses",
            "configmaps",
            "controllerrevisions",
            "cronjobs",
            "customresourcedefinitions",
            "daemonsets",
            "deployments",
            "endpoints",
            "events",
            "horizontalpodautoscalers",
            "initializerconfigurations",
            "jobs",
            "leases",
            "limitranges",
            "localsubjectaccessreviews",
            "mutatingwebhookconfigurations",
            "namespaces",
            "networkpolicies",
            "nodes",
            "persistentvolumeclaims",
            "persistentvolumes",
            "poddisruptionbudgets",
            "pods",
            "pods/log",
            "podsecuritypolicies",
            "podtemplates",
            "priorityclasses",
            "prometheuses",
            "prometheusrules",
            "replicasets",
            "replicationcontrollers",
            "resourcequotas",
            "selfsubjectaccessreviews",
            "selfsubjectrulesreviews",
            "serviceaccounts",
            "servicemonitors",
            "services",
            "statefulsets",
            "storageclasses",
            "subjectaccessreviews",
            "tokenreviews",
            "validatingwebhookconfigurations",
            "volumeattachments"
        ]
        verbs = [
            "get",
            "list",
            "watch",
            "create",
            "update",
            "patch",
            "delete",
            "deletecollection",
        ]
```
According to these rules the Developers have all access except seeing the Roles, Rolebindings, Secrets, and cannot manage Ingresses.

This groups is bound to the K8S Cluster
```
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: prod
  name: prod-developers-k8s-binding
subjects:
- kind: User
  name: prod-developers-k8s
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: prod-developers-k8s
  apiGroup: rbac.authorization.k8s.io
```

and thus the group works and controls the users' who had passed AWS IAM MFA and Role authentication.

So just to sum up how the whole configmap in aws-auth looks like:
## kc --kubeconfig us-east-1-dev-prod get -n kube-system configmaps aws-auth -o yaml
```
apiVersion: v1
data:
  mapRoles: |
    - rolearn: arn:aws:iam::082573909043:role/eks-nodes-prod-management
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::082573909043:role/prod-devops-k8s
      username: prod-devops-k8s
      groups:
        - system:masters
    - rolearn: arn:aws:iam::082573909043:role/prod-developers-k8s
      username: prod-developers-k8s
      groups:
        - prod-developers-k8s
kind: ConfigMap
metadata:
  creationTimestamp: "2019-10-25T08:08:27Z"
  name: aws-auth
  namespace: kube-system
  resourceVersion: "499"
  selfLink: /api/v1/namespaces/kube-system/configmaps/aws-auth
  uid: 9fc05100-f6fe-11e9-ba1a-0aac5769a57f
```

## Conclusion
This documents shows the concept how effectively administer permissions, authorization and authentication in K8S without much effort.
You do not have to edit user list in the ConfigMap every time you need to add or remove a user. Just operate the users in IAM Groups.
