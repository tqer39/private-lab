# private-lab

Private で使用している Terraform で構成可能なリソースをまとめる。

## GitHub Actions Status badges

| Name | Environment | Result |
| :--- | :--- | :--- |
| Linterなどによる検証 | pre-commit | ![pre-commit](https://github.com/tqer39/private-lab/actions/workflows/pre-commit.yml/badge.svg) |
| AWS 検証環境 | Sandbox | ![Terraform - sandbox](https://github.com/tqer39/private-lab/actions/workflows/terraform-aws-sandbox.yml/badge.svg) |
| AWS 全体管理 | Management | ![Terraform - management](https://github.com/tqer39/private-lab/actions/workflows/terraform-aws-management.yml/badge.svg) |

## Setup

### Homebrew

```bash
# install brew see: https://brew.sh/index_ja
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install software
brew bundle
```

### anyenv

#### zsh

```bash
anyenv init
anyenv install --init
echo 'eval "$(anyenv init -)"' >> ~/.zshrc
exec $SHELL -l
mkdir -p "$(anyenv root)/plugins"
git clone https://github.com/znz/anyenv-update.git "$(anyenv root)/plugins/anyenv-update"
```

#### fish

```bash
anyenv init - fish | source
anyenv install --init
set -Ux fish_user_paths $HOME/.anyenv/bin $fish_user_paths
echo 'set -x PATH ~/.anyenv/bin $PATH' >> ~/.config/fish/config.fish
echo 'eval (anyenv init - | source)' >> ~/.config/fish/config.fish
exec fish -l
mkdir -p (anyenv root)/plugins
git clone https://github.com/znz/anyenv-update.git (anyenv root)/plugins/anyenv-update
which anyenv
```

### tfenv

```bash
anyenv install tfenv
which tfenv
```

### Terraform

```bash
tfenv install
which terraform
terraform install
terraform -version
```

### Rancher Desktop

#### Linux

see [Rancher Desktop - Linux](https://docs.rancherdesktop.io/getting-started/installation/#linux)

```bash
curl -s https://download.opensuse.org/repositories/isv:/Rancher:/stable/deb/Release.key | gpg --dearmor | sudo dd status=none of=/usr/share/keyrings/isv-rancher-stable-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/isv-rancher-stable-archive-keyring.gpg] https://download.opensuse.org/repositories/isv:/Rancher:/stable/deb/ ./' | sudo dd status=none of=/etc/apt/sources.list.d/isv-rancher-stable.list
sudo apt update
sudo apt install rancher-desktop
```

os reboot.

### Session Manager Plugin

see: [(オプション) AWS CLI 用の Session Manager プラグインをインストールする](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

#### Linux (Debian | amd64)

```bash
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
rm -rf session-manager-plugin.deb
```

### pre-commit

```bash
# setup
pre-commit install --install-hooks
```

### ローカルから Terraform CLI を実行する方法

#### AWS Profile の設定

これは Makefile の aws-vault で使用されます。
下記の内容を `~/.aws/config` に設定します。

```bash
[profile private-lab-management]
sso_start_url = https://tqer39-management.awsapps.com/start/
sso_region = ap-northeast-1
sso_account_id = 577523824419
sso_role_name = <AWS SSO Role Name>
region = ap-northeast-1
output = json
```

#### terraform init（初期化）

- `terraform -chdir=${パス} init` に相当する処理です。
- オプションで `SSH_KEY` が指定可能です。（デフォルトは `${HOME}/.ssh/id_rsa`）
  - 明示的に指定する場合は `SSH_KEY=~/.ssh/id_ed25519` などを指定してください。
  - 環境名は `dev`, `stg`, `prod` のいずれかを指定可能です。

```bash
make build ENV={環境名} TF_PATH={パスを指定}
```

Example:

```bash
make build ENV=management TF_PATH=base_apne1 CMD="-reconfigure"
# 下記に相当します
# aws-vault exec private-lab-management -- docker-compose run --rm \
#  -e AWS_ACCESS_KEY_ID \
#  -e AWS_SECRET_ACCESS_KEY \
#  -e AWS_SESSION_TOKENterraform \
#  -chdir=./terraform/environments/management/base_apne1 init -reconfigure
```

#### terraform validate

Example:

```bash
make terraform ENV=management TF_PATH=base_apne1 CMD="validate"
```

#### terraform plan

Example:

```bash
make terraform ENV=management TF_PATH=base_apne1 CMD="plan"
```

#### terraform apply

**※ローカルからのデプロイは原則禁止です。**

Example:

```bash
make terraform ENV=management TF_PATH=base_apne1 CMD="apply -auto-approve"
```

## 新しい環境の作成方法

手動で s3 バケットを作成。
リソースを作成。

```txt
.github/workflows/terraform-<環境名>.yml
.github/labeler.yml
terraform/environments/<環境名>/base/main.tf
terraform/environments/<環境名>/base/provider.tf
terraform/environments/<環境名>/base/terraform.tf
terraform/environments/<環境名>/base/shared-locals.tf
terraform/environments/<環境名>/shared/locals.tf
```

```zsh
# https://xxxxx.awsapps.com/start#/
export AWS_ACCESS_KEY_ID="XXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="XXXXXXXXXX"
export AWS_SESSION_TOKEN="XXXXXXXXXX"

terraform -chdir=terraform/environments/<環境名>/base init
```

手動で作成した s3 バケットを import。

```zsh
$TF_PATH="terraform/environments/<環境名>/base"
terraform -chdir="$TF_PATH" import module.terraform-backend.module.s3-bucket.aws_s3_bucket.this <バケット名>
terraform -chdir="$TF_PATH" import module.terraform-backend.module.s3-bucket.aws_s3_bucket_acl.this <バケット名>
terraform -chdir="$TF_PATH" import module.terraform-backend.module.s3-bucket.aws_s3_bucket_public_access_block.this <バケット名>
terraform -chdir="$TF_PATH" import module.terraform-backend.module.s3-bucket.aws_s3_bucket_versioning.this <バケット名>
```

OIDC 関連のリソースの新規作成と s3 バケットのパラメータ更新を行います。

```zsh
$TF_PATH="terraform/environments/<環境名>/base"
terraform -chdir="$TF_PATH" fmt
terraform -chdir="$TF_PATH" validate
terraform -chdir="$TF_PATH" plan
terraform -chdir="$TF_PATH" apply -auto-approve
```
