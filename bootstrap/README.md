# Bootstrap

このディレクトリは、GitHub Actions から Terraform を実行するために先に作成しておく AWS リソースを管理します。

dev と prod は別 AWS account で運用する前提です。Terraform state も各 account 内で管理するため、bootstrap も dev account / prod account それぞれで実行します。

## 構成

```text
bootstrap/
  modules/
    terraform-state-backend/
      main.tf
      variables.tf
      outputs.tf
    github-actions-oidc/
      main.tf
      variables.tf
      outputs.tf
  envs/
    dev/
      main.tf
      locals.tf
      providers.tf
      backend.tf
      outputs.tf
    prod/
      main.tf
      locals.tf
      providers.tf
      backend.tf
      outputs.tf
```

`modules/terraform-state-backend` に Terraform state backend 用の S3 bucket を置き、`modules/github-actions-oidc` に GitHub Actions OIDC provider と IAM role / policy を置いています。`envs/dev` と `envs/prod` は環境ごとの薄い root module として分けています。

`locals.tf` には環境名と AWS account ID だけを置き、派生値や一箇所でしか使わない値は利用箇所に直接書いています。

`backend.tf` の `backend "s3"` block では Terraform の制約により `locals` を参照できません。そのため backend の bucket 名、key、region、許可 account ID は直書きで管理します。

## 作成するリソース

各 account に次のリソースを作成します。

- S3 bucket
  - Terraform state の保存先
  - versioning 有効
  - SSE-S3 (`AES256`) によるサーバーサイド暗号化
  - Object Ownership は `BucketOwnerEnforced` で ACL 無効
  - public access block 有効
  - bucket policy で HTTPS/TLS 必須
  - bucket policy で同一 AWS account の principal に限定
  - 古い state version は 90 日で削除
  - `prevent_destroy` で Terraform からの誤削除を抑止
- GitHub OIDC provider
  - URL は `https://token.actions.githubusercontent.com`
  - GitHub Actions から AWS IAM role を引き受けるために使用
  - thumbprint は GitHub の公開 CA 証明書検証が使われる前提の placeholder として `ffffffffffffffffffffffffffffffffffffffff` を管理
- IAM role
  - bootstrap 用
    - role name: `github-actions-bootstrap`
    - bootstrap 自身の変更に使用
    - bootstrap state backend、GitHub OIDC provider、GitHub Actions 用 IAM role / policy の管理権限だけを付与
  - env 用
    - role name: `github-actions-terraform`
    - `envs/` 配下の通常 Terraform に使用
    - Terraform state backend の利用権限と VPC 操作権限を別 policy として付与

dev と prod は別 AWS account に作成するため、IAM role 名に環境名は含めていません。role ARN は account ID で区別されます。

## GitHub OIDC 条件

GitHub Actions role の trust policy は GitHub Environment を使う前提で絞っています。

- bootstrap dev: `repo:kentaro-kiuchi/aws-infra:environment:bootstrap-dev`
- bootstrap prod: `repo:kentaro-kiuchi/aws-infra:environment:bootstrap-prod`
- env dev: `repo:kentaro-kiuchi/aws-infra:environment:dev`
- env prod: `repo:kentaro-kiuchi/aws-infra:environment:prod`

GitHub Actions workflow 側でも対応する `environment` を指定してください。GitHub Environment を使わない場合は、`bootstrap/envs/*/main.tf` の `github_*_oidc_subjects` を `repo:kentaro-kiuchi/aws-infra:ref:refs/heads/main` など、実際の運用に合わせて変更してください。

## IAM role の使い分け

通常の `envs/dev` / `envs/prod` の plan / apply では env 用 role を使います。env 用 role には次の権限だけを付与しています。

- 対象環境の state object への `GetObject` / `PutObject`
- 対象環境の S3 lockfile (`.tflock`) への `GetObject` / `PutObject` / `DeleteObject`
- 対象環境の state object / lockfile prefix に限定した `ListBucket`
- 現在の Terraform コードで必要な VPC 操作
- `sts:GetCallerIdentity`

state backend 用の権限と、実際に AWS リソースを更新する権限は別々の inline policy に分けています。state 管理権限は `github-actions-terraform-state-backend`、管理対象リソースの権限は `github-actions-terraform-managed-resources` です。

bootstrap 用 role は、bootstrap 自身を GitHub Actions から更新する場合に使います。bootstrap state object / lockfile、state bucket 設定、GitHub OIDC provider、GitHub Actions 用 IAM role / policy の管理権限だけを inline policy として付与しています。bootstrap の変更頻度は低く影響も大きいため、GitHub Environment 側で approval required にすることを推奨します。

## 初回適用手順

backend 用の S3 bucket は、初回適用時点ではまだ存在しません。そのため、各環境の初回 bootstrap は local state で実行し、その後 S3 backend に移行します。

### dev

dev account の認証情報で実行します。

```sh
cd bootstrap/envs/dev
terraform init
terraform plan
terraform apply
```

適用後、`backend.tf` の `backend "s3"` block を有効化して state を S3 に移行します。

```sh
terraform init -migrate-state
```

### prod

prod account の認証情報で実行します。

`bootstrap/envs/prod/locals.tf` と `bootstrap/envs/prod/backend.tf` には、未確定の account ID として `000000000000` を入れています。実行前に prod account ID へ置き換えてください。

次に local state で初回適用します。

```sh
cd bootstrap/envs/prod
terraform init
terraform plan
terraform apply
```

適用後、`backend.tf` の `backend "s3"` block を有効化して state を S3 に移行します。

```sh
terraform init -migrate-state
```

## 通常 Terraform との関係

通常の Terraform コードは `envs/` 配下で管理します。

- `envs/dev` は dev account の S3 backend を使う
- `envs/prod` を追加する場合は prod account の S3 backend を使う

各環境の通常 Terraform を実行する前に、対応する account の bootstrap が完了している必要があります。

## 改善候補

- env 用 role は現在の VPC module に合わせた権限です。subnet、route table、internet gateway、security group など管理対象を増やす場合は、必要な EC2 action を追加してください。
- GitHub OIDC provider の thumbprint は実証明書の固定値ではなく placeholder として管理しています。GitHub 側の TLS 証明書を pinning している値ではないため、変更検知の対象にする場合は AWS IAM の OIDC 検証仕様変更や provider 挙動変更を確認してください。

## 注意事項

- S3 bucket 名はグローバルに一意である必要があります。別 AWS account や別 project で使う場合は bucket 名を変更してください。
- region は `ap-northeast-1` 固定です。変更する場合は provider と backend の両方を合わせて変更してください。
- `prevent_destroy` があるため、state bucket を削除するには Terraform 設定の変更が必要です。
- local state で初回 bootstrap を実行した場合、local の `terraform.tfstate` には作成済みリソース情報が含まれます。S3 backend に移行するか、取り扱いに注意してください。
