# 本地Git仓库上传至GitHub正式仓库：Windows完整流程指南
无论是首次上传本地仓库，还是已有本地仓库需关联GitHub，均可按以下 **“准备→创建远程→本地操作→推送验证”** 四步流程操作，同时提供两种主流认证方式（SSH/Token）供选择，适配不同使用场景。


## 一、准备工作：基础环境配置（仅需操作1次）
确保本地Git环境正常，且与GitHub账号绑定，这是后续操作的前提。
### 1. 安装并验证Git
- **检查是否已安装**：打开终端（Windows用Git Bash，macOS/Linux用系统终端），输入命令：
  ```bash
  git --version  # 输出类似“git version 2.45.1”即安装成功
  ```
- **未安装则按需安装**：
  - Windows：从[Git官网](https://git-scm.com/)下载安装包，默认下一步即可。
  - macOS：用Homebrew安装：`brew install git`。
  - Linux（Ubuntu）：`sudo apt-get install git`。

### 2. 配置GitHub用户信息（绑定提交身份）
Git需记录提交者身份，命令中的“用户名”和“邮箱”必须与GitHub账号一致：
```bash
# 设置全局用户名（替换为你的GitHub用户名）
git config --global user.name "KomasaQi"
# 设置全局邮箱（替换为你的GitHub绑定邮箱）
git config --global user.email "komasaqi@foxmail.com"

# 验证配置：输出刚才设置的信息即成功
git config --global --list
```


## 二、第一步：在GitHub创建“空远程仓库”
必须先在GitHub创建仓库，才能接收本地代码，**关键是“不初始化任何文件”，避免与本地仓库冲突**。
1. 登录GitHub官网（[github.com](https://github.com)），点击右上角「+」→「New repository」。
2. 填写仓库信息：
   - **Repository name**：建议与本地仓库文件夹同名（如`my-project`），便于识别。
   - **Visibility**：选「Public」（公开）或「Private」（私有，需付费或用免费额度）。
   - **核心注意**：**取消勾选**“Initialize this repository with a README”“Add .gitignore”“Choose a license”（这些文件后续可从本地上传，避免远程与本地历史冲突）。
3. 点击「Create repository」，创建后页面会显示仓库地址（后续关联本地需用），两种格式可选：
   - SSH格式：`git@github.com:YourGitHubUsername/my-project.git`（推荐，后续推送无需重复输密码）。
   - HTTPS格式：`https://github.com/YourGitHubUsername/my-project.git`（需用Token或密码认证）。


## 三、第二步：本地仓库操作（核心步骤）
根据本地仓库状态（是否已初始化Git），操作略有差异，但核心是“关联远程仓库→确保本地提交完整→统一分支名”。

### 场景A：本地项目已初始化Git（有`.git`文件夹）
若本地项目已用`git init`初始化（可在项目目录下查看是否有隐藏的`.git`文件夹），直接执行以下操作：
#### 1. 进入本地仓库目录
终端中用`cd`命令切换到本地项目根目录（替换为你的实际路径）：
```bash
# Windows示例：cd "D:\Projects\my-project"
# macOS/Linux示例：cd /Users/yourname/Projects/my-project
cd /path/to/your-local-project
```

#### 2. 关联GitHub远程仓库
将本地仓库与刚创建的GitHub仓库绑定，`origin`是远程仓库的默认别名（可自定义，但推荐保留）：
```bash
# 方式1：用SSH格式（推荐，后续免密码）
git remote add origin git@github.com:YourGitHubUsername/my-project.git

# 方式2：用HTTPS格式（需Token认证）
git remote add origin https://github.com/YourGitHubUsername/my-project.git

# 验证关联：输出origin及对应地址即成功
git remote -v
```
- 若提示“fatal: remote origin already exists”（远程已存在）：先删除旧关联再重新添加：
  ```bash
  git remote remove origin  # 删除旧远程
  git remote add origin 新地址  # 重新关联
  ```

#### 3. 确保本地代码已提交（避免遗漏文件）
若本地有未提交的修改，需先提交到本地仓库（否则推送时会遗漏）：
```bash
# 1. 查看本地状态：红色文件为未暂存，绿色为已暂存
git status

# 2. 暂存所有文件（.表示当前目录所有文件，也可指定单个文件如README.md）
git add .

# 3. 提交到本地仓库，-m后为提交说明（需简洁描述内容，如“初始化项目：添加核心代码”）
git commit -m "Initial commit: add core files"
```
- 若提示“nothing to commit”：说明本地已无未提交内容，直接跳过此步。

#### 4. 统一分支名（避免GitHub默认分支不匹配）
GitHub当前默认分支为`main`，而部分本地仓库默认是`master`，需将本地分支重命名为`main`，确保与远程一致：
```bash
# 将本地master分支重命名为main（若本地已是main，此命令无影响）
git branch -M main
```


### 场景B：本地项目未初始化Git（无`.git`文件夹）
若本地项目只是普通文件夹（无`.git`），需先初始化Git仓库，再执行上述“场景A”的2-4步：
```bash
# 1. 进入项目目录
cd /path/to/your-local-project

# 2. 初始化Git仓库（生成.git文件夹，开始跟踪文件）
git init

# 3. 后续操作：同场景A的2-4步（关联远程→暂存提交→统一分支名）
```


## 四、第三步：推送本地代码到GitHub（两种认证方式）
推送是最后一步，根据关联远程时选择的格式（SSH/HTTPS），选择对应认证方式。

### 方式1：SSH认证（推荐，一次配置终身免密）
若关联远程时用的是SSH格式（`git@github.com:xxx`），需先配置SSH密钥到GitHub。
#### 1. 生成SSH密钥（本地操作）
终端输入命令（替换为你的GitHub邮箱）：
```bash
ssh-keygen -t rsa -b 4096 -C "your-github-email@example.com"
```
- 执行后按3次回车：第一次确认保存路径（默认`~/.ssh/id_rsa`），后两次跳过密码设置（直接回车）。

#### 2. 复制SSH公钥（本地操作）
- Windows（Git Bash）/macOS/Linux：
  ```bash
  cat ~/.ssh/id_rsa.pub  # 输出以ssh-rsa开头的长字符串，全选复制
  ```
- Windows（cmd）：`type C:\Users\你的用户名\.ssh\id_rsa.pub`。

#### 3. 添加SSH密钥到GitHub（网页操作）
1. 登录GitHub→点击头像→「Settings」→「SSH and GPG keys」→「New SSH key」。
2. 填写信息：
   - 「Title」：自定义名称（如“我的笔记本电脑”）。
   - 「Key」：粘贴刚才复制的SSH公钥（确保无多余空格）。
3. 点击「Add SSH key」，输入GitHub密码验证即可。

#### 4. 测试SSH连接（本地操作）
```bash
ssh -T git@github.com  # 首次连接会提示“Are you sure...”，输入yes
```
- 输出“Hi YourGitHubUsername! You've successfully authenticated...”即SSH配置成功。

#### 5. 推送代码到GitHub
```bash
# 首次推送：-u建立本地main与远程main的跟踪关系，后续推送只需git push
git push -u origin main
```
- 无需输入密码，直接推送，成功后终端会显示“100%”“done”。


### 方式2：Token认证（HTTPS格式专用，无需配置密钥）
若关联远程时用的是HTTPS格式（`https://github.com/xxx`），需用GitHub Personal Access Token（PAT）代替密码（GitHub已废弃账号密码直接认证）。
#### 1. 生成GitHub Token（网页操作）
1. 登录GitHub→头像→「Settings」→「Developer settings」→「Personal access tokens」→「Generate new token」。
2. 配置Token权限：
   - 「Note」：自定义名称（如“本地推送Token”）。
   - 「Expiration」：选择有效期（推荐“No expiration”，避免频繁重新生成）。
   - 「Scopes」：勾选「repo」（全选repo下的子选项，确保有仓库读写权限）。
3. 点击「Generate token」，**立即复制Token并保存**（仅显示一次，丢失需重新生成）。

#### 2. 推送代码到GitHub（本地操作）
执行推送命令，会弹出认证窗口：
```bash
git push -u origin main
```
- **Windows/macOS**：弹出用户名/密码输入框，用户名填GitHub账号，密码粘贴刚才生成的Token。
- **Linux/无图形界面**：终端会提示“Username for 'https://github.com': ”，输入GitHub用户名；接着“Password for 'https://YourUsername@github.com': ”，粘贴Token（输入时无显示，粘贴后回车即可）。


## 五、验证与后续维护
### 1. 验证推送结果
打开GitHub上刚创建的仓库页面，刷新后若能看到本地项目的所有文件，说明上传成功。

### 2. 后续常规推送（修改代码后）
首次推送已用`-u`建立分支跟踪，后续修改本地代码后，只需3步：
```bash
git add .  # 暂存所有修改
git commit -m "更新：修复XX功能/添加XX文件"  # 提交说明
git push  # 直接推送（无需再写origin main）
```


## 六、常见问题解决
1. **推送提示“fatal: refusing to merge unrelated histories”**  
   原因：本地与远程仓库历史不兼容（如GitHub仓库误初始化了README）。  
   解决：强制推送（慎用，仅本地是最新版本时使用）：
   ```bash
   git push -f origin main  # 强制覆盖远程仓库，确保本地是最新内容
   ```

2. **SSH推送提示“Permission denied (publickey)”**  
   原因：SSH密钥未添加到GitHub，或密钥路径错误。  
   解决：重新执行“方式1-2/3步”，确保公钥复制完整，且与GitHub添加的一致。

3. **Token推送提示“invalid credentials”**  
   原因：Token错误或权限不足。  
   解决：重新生成Token，确保勾选「repo」全权限，且输入时无多余空格。


通过以上流程，即可将本地Git仓库完整上传为GitHub的正式仓库，支持后续代码更新、分支管理与协作开发。