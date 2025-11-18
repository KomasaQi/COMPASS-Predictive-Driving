# 在Windows的PowerShell中设置Clash的http/https代理

### 第一步：正确设置PowerShell的代理（临时生效，仅当前会话）
PowerShell设置环境变量的语法和CMD不同，且Git可能需要单独配置代理（优先推荐直接给Git配代理，更可靠）。

#### 方式1：直接给Git配置代理（推荐，不影响系统环境）
针对Git单独设置HTTP/HTTPS代理，适配你的7890端口（假设代理工具已启动，如Clash、V2Ray）：
```powershell
# 设置HTTP代理（对应你的7890端口）
git config --global http.proxy http://127.0.0.1:7890
# 设置HTTPS代理（GitHub用HTTPS，必须配置）
git config --global https.proxy http://127.0.0.1:7890

# 验证代理配置（输出刚才设置的地址即成功）
git config --global --get http.proxy
git config --global --get https.proxy
```

#### 方式2：临时设置PowerShell环境变量（备选）
若不想给Git全局配代理，仅在当前PowerShell会话中生效：
```powershell
# PowerShell设置环境变量的正确语法（临时，关闭终端失效）
$env:HTTP_PROXY = "http://127.0.0.1:7890"
$env:HTTPS_PROXY = "http://127.0.0.1:7890"

# 验证环境变量（输出127.0.0.1:7890即成功）
echo $env:HTTP_PROXY
echo $env:HTTPS_PROXY
```


### 第二步：后续清理（可选，推送成功后）
若不需要代理了，取消Git的代理配置（避免影响后续其他仓库操作）：
```powershell
# 取消Git全局代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```

