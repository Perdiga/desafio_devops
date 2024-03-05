# Desafio DEVOPS

1. Criar um cluster EKS de forma segura escalável e eficiente
2. Usar o Helm Charts para instalar e configurar um Grafana no cluster Kubernetes.
3. Criar um AWS Timestream ou Athena e adicionar dados de teste no mesmo.
4. Adicionar o datasource do AWS Timestream ou Athena no Grafana e mostrar os dados do Timestream ou Athena por meio de algum dashboard. Você deverá criar gráficos, tabelas e painéis que apresentem as informações de forma clara e intuitiva.
5. Prover observabilidade dos recursos criados durante o desafio. Você deverá monitorar o desempenho, a disponibilidade e o consumo dos recursos.
6. Adicionar um microserviço a sua escolha no cluster, monitorar os logs e utilização de recursos 
dele no Grafana, implementar uma pipeline de CI/CD para esse serviço.

# Devcontainer

Este repositório utiliza devcontainer para facilitar sua vida :). Instale o plugin do devcontainer no seu VSCode e seja feliz.

O dev container já está configurado com as seguintes features

- Terraform
- AWS-CLI
- kubectl-helm-minikube
- eksctl
- node

Referência: [DevContainer](https://containers.dev/)

# Estrutura de pastas

├── README.md
├── .aws -> Configura credenciais no devcontainer
├── .devcontainer -> Configura um container com todos os recursos necessários para execuçao do projeto
└── terraform -> Configura os recusos necessários para esse projeto
  ├── k8s -> Configura o k8s
  │ ├── dev.tfvars -> Configura as variáveis para o ambiente de desenvolvimento
  │ ├── eks.tf -> Configura o cluster de Kubernetes
  │ ├── main.tf -> Configura os providers, backend e ariáveis locais 
  │ ├── network.tf -> Configura os recursos de network como vpc, subnets, etc
  │ ├── outputs.tf -> Configura outputs gerados pelos recursos criados
  │ └── variables.tf -> Declaração das variáveis do projeto
  └── k8s-observability -> Configura o k8s-observability
    ├── eks_observability.tf -> Configura o Prometheus Stack (Prometheus + Grafana)
    ├── main.tf -> Configura os providers, backend e ariáveis locais 
    └── variables.tf -> Declaração das variáveis do projeto
    

# Setup

Para executar o terraform é necessário ter um bucket previamente criado, onde os statefiles serão salvos. Note que o os caminhos do s3 são globais, então caso você deseje executar esse repositório, você precisara mudar esse path no backend do terraform

Caso você queira criar um bucket você pode utilizar os seguintes comando 

```bash 
aws s3api create-bucket --bucket <BucketName>
aws iam create-policy \
    --policy-name TFStatePolicy \
    --policy-document \
'{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::<BucketName>.tfstate"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::<BucketName>.tfstate/terraform.tfstate"
    }
  ]
}'
```

## Deploy da infraestrutura

### Deploy/Destroy manual
Primeiramente configure o arquivo credentials dentro da pasta .aws com as suas credencias

Dentro do devcontainer, execute os seguintes comandos:

```bash 
cd terraform/k8s

terraform init

terraform plan --var-file=dev.tfvars

terraform apply --var-file=dev.tfvars

cd terraform/k8s-observability

terraform init

terraform plan

terraform apply -target=null_resource.kubectl # TODO: FIX ME

terraform apply
```

A divisão em dois deploy é necessária por para criar alguns recursos de obsevability é necessário ter o k8s já criado. Tem como melhorar só preciso pensar com calma.

Caso queira destruir os recursos, execute os seguintes:
   
```bash 
cd terraform/k8s

terraform init

terraform destroy --var-file=dev.tfvars

cd terraform/k8s-observability

terraform init

terraform destroy
```

### CI/CD

Este projeto conta com algumas actions para criação dos recursos

Lembre-se de configurar as seguintes variáveis no `Actions secrets and variables`

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Também é necessário entrar na configuração de `Workflow permissions` e mudar a permissão para `Read and write permissions`

#### cicd-deploy-k8s-complete
Essa action é disparada em quando um código é mergado na `main` ou quando uma PR é aberta com target a `main`. Essa action pode ser melhorada para fazer deploy em vários ambientes, mas como o objetivo do desse projeto é criar um unico ambiente essa feature não foi implementada.

Quando disparada por um evento de PR, a action faz a validação de estilo, do código, cria o plano de execução e emite o resultado como comentário na PR

Quando disparada por um merge na `main`, a action faz a validação de estilo, do código, cria o plano de execução e aplica o plano de execução.

#### cicd-deploy-k8s-complete
Essa action é disparada manualmente e serve para criar ou destruir a infraestrutura manualmente

# Sample service 

Esse é um pequeno serviço de teste que sobe um AWS Timestream e gera registros

# Grafana

## Setup

1. Certifique-se que o kubeconfig esteja atualizado, caso não esteja rode o seguinte comando `aws eks --region "us-east-1" update-kubeconfig --name challange-eks`

2. Faça o port-foward do grafana para sua maquina executanto o seguinte comando `kubectl port-forward --namespace monitoring service/kube-prometheus-stack-grafana 3000:80`

3. Certifique-se que o devcontainer também está fazendo o port-foward para a sua maquina, caso não esteja faça manualmente

4. Para recuperar o login de acesso execute o seguinte comando `kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-user}" | base64 --decode`

5. Para recuperar a senha de acesso execute o seguinte comando `kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode`

Pronto agora basta acesar `localhost:3000` que você conseguir acesar o grafana