# 使用GitHub Actions构建Batocera 6.14.5内核

本仓库包含两个GitHub Actions工作流，用于为AM40 RK3399设备构建Batocera Linux 6.14.5内核及其设备树文件。

## 工作流说明

### 1. 完整编译工作流 (build-batocera-rk3399.yml)

此工作流执行完整的Batocera Linux系统编译，包括内核6.14.5和我们自定义的设备树文件。

#### 触发条件
- 推送到主分支
- 拉取请求到主分支
- 手动触发（带参数选项）

#### 工作流参数
- `kernel_version`: Linux内核版本（默认: 6.14.5）
- `debug_enabled`: 是否启用调试模式（默认: false）

#### 构建产物
- 完整的Batocera镜像文件 (batocera-rockchip-rk3399-am40-*.img)
- 引导分区文件 (boot-rk3399-am40-*.tar.xz)
- 设备树二进制文件包 (am40-dtb-*.tar.gz)

### 2. 仅编译DTB工作流 (build-dtb-only.yml)

此工作流仅编译设备树二进制文件，不编译完整的Batocera系统。当您只需要更新设备树而不需要完整重新编译时，这个工作流非常有用。

#### 触发条件
- 推送修改了.dts或.dtsi文件时
- 拉取请求修改了.dts或.dtsi文件时
- 手动触发（带参数选项）

#### 工作流参数
- `kernel_version`: Linux内核版本（默认: 6.14.5）

#### 构建产物
- 设备树二进制文件 (am40-user.dtb)
- 包含安装脚本的设备树包 (am40-dtb-*.tar.gz)

## 手动触发工作流

### 在GitHub上触发

1. 访问仓库的Actions标签页
2. 选择您想运行的工作流
3. 点击"Run workflow"按钮
4. 根据需要调整参数
5. 点击"Run workflow"确认启动

### 使用GitHub CLI触发

完整构建工作流:
```bash
gh workflow run build-batocera-rk3399.yml --ref main -f kernel_version=6.14.5 -f debug_enabled=false
```

仅DTB构建工作流:
```bash
gh workflow run build-dtb-only.yml --ref main -f kernel_version=6.14.5
```

## 使用构建产物

### 完整镜像

完整镜像可以使用dd命令写入SD卡:

```bash
sudo dd if=batocera-rockchip-rk3399-am40-6.14.5.img of=/dev/sdX bs=4M status=progress
```

### DTB文件包

DTB文件包可以用于更新现有Batocera系统的设备树而不需要重新刷写整个系统:

1. 下载并解压DTB文件包
2. 运行包含的安装脚本:
   ```bash
   chmod +x install.sh
   sudo ./install.sh
   ```
3. 重启系统

## 自定义工作流

如果需要自定义工作流，可以编辑`.github/workflows/`目录下的yml文件。主要可以自定义的部分包括:

- 内核版本
- 额外的内核补丁
- 额外的Batocera软件包
- 编译选项和优化

## 故障排除

如果工作流失败:

1. 检查Action日志以获取详细错误信息
2. 常见问题:
   - 空间不足: GitHub Actions运行器有有限的磁盘空间
   - 依赖问题: 确保工作流安装了所有必要的依赖
   - 网络问题: 下载大文件可能会超时 