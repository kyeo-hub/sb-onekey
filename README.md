# sb-onekey

sing-box 服务端一键安装/管理脚本，支持多种主流代理协议。

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 支持的协议

| 协议 | 特点 | 适用场景 |
|------|------|----------|
| **VLESS-REALITY** | 最隐蔽，抗审查能力强 | 严格网络环境 |
| **Hysteria2** | 基于 QUIC，速度快 | 丢包/高延迟网络 |
| **TUIC v5** | 基于 QUIC，低延迟 | 移动端/不稳定网络 |
| **Shadowsocks 2022** | 轻量，兼容性好 | 简单快速部署 |

## 支持的系统

- Debian 10/11/12
- Ubuntu 20.04/22.04/24.04
- CentOS 7/8/Stream
- RHEL 8/9
- AlmaLinux / Rocky Linux

## 一键安装（推荐）

### 方式一：直接运行（无需克隆仓库）

```bash
# VLESS-REALITY (推荐)
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh) vless

# Hysteria2
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh) hy2

# TUIC
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh) tuic

# Shadowsocks 2022
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh) ss
```

### 方式二：先下载再运行

```bash
# 下载脚本
curl -fsSL -o sing-box-server.sh https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh

# 赋予执行权限
chmod +x sing-box-server.sh

# 一键安装 VLESS-REALITY
./sing-box-server.sh vless
```

### 方式三：交互式菜单

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh)
```

## 安装后管理

```bash
# 查看运行状态
systemctl status sing-box

# 重启服务
systemctl restart sing-box

# 查看实时日志
journalctl -u sing-box -f

# 查看节点信息
cat /etc/sing-box/node_info.txt
```

## 客户端配置

安装完成后，脚本会输出分享链接，直接复制到客户端导入即可。

### 推荐客户端

| 平台 | 客户端 |
|------|--------|
| Windows | [sing-box](https://github.com/SagerNet/sing-box) / [v2rayN](https://github.com/2dust/v2rayN) |
| macOS | [sing-box](https://github.com/SagerNet/sing-box) / [V2RayXS](https://github.com/tzmax/V2RayXS) |
| iOS | [Shadowrocket](https://apps.apple.com/us/app/shadowrocket/id932747118) / [sing-box](https://apps.apple.com/us/app/sing-box/id6451272673) |
| Android | [sing-box](https://github.com/SagerNet/sing-box) / [v2rayNG](https://github.com/2dust/v2rayNG) |

## 目录结构

```
/etc/sing-box/
├── config.json          # 服务端配置文件
├── client.json          # 客户端配置文件（可直接使用）
├── node_info.txt        # 节点信息（含分享链接）
├── sub_info.txt         # 订阅链接信息
├── sub-server.py        # 订阅服务脚本
└── tls/                 # TLS 证书目录（Hysteria2/TUIC）
    ├── cert.pem
    └── key.pem
```

## 客户端使用

安装完成后，服务器会生成客户端配置文件并提供订阅链接。

### 方式一：订阅链接（推荐）

安装完成后会显示订阅链接：

```
http://你的服务器IP:8080/xxxxxxxxxxxxxxxx
```

**使用方法：**
1. **sing-box GUI 客户端**：直接粘贴订阅链接
2. **浏览器访问**：下载 `client.json` 配置文件
3. **curl 下载**：
   ```bash
   curl -o client.json http://你的服务器IP:8080/xxxxxxxxxxxxxxxx
   ```

**安全特性：**
- ✅ 随机 Token（32位十六进制）
- ✅ 访问频率限制（每分钟30次）
- ✅ IP 封禁机制（超过限制封禁5分钟）
- ✅ 访问日志记录

### 方式二：手动复制配置

```bash
# 查看客户端配置内容
cat /etc/sing-box/client.json

# 复制到本地（在本地终端执行）
scp root@你的服务器IP:/etc/sing-box/client.json ./sing-box-config.json
```

### 客户端配置说明

生成的客户端配置包含：
- **本地 SOCKS5 代理**: `127.0.0.1:1080`
- **路由规则**: 国内网站直连，其他走代理
- **协议参数**: 自动填充服务器地址、端口、密码等

### 启动客户端

```bash
# 使用生成的配置文件启动 sing-box
sing-box run -c client.json
```

### 查看订阅信息

```bash
cat /etc/sing-box/sub_info.txt
```

### 查看访问日志

```bash
# 查看最近访问记录
tail -f /etc/sing-box/access.log

# 或通过菜单查看
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh)
# 选择选项 10
```

## 卸载

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh)
# 然后选择选项 0 卸载
```

## 更新 sing-box

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh)
# 然后选择选项 9 更新
```

## 许可证

[MIT](LICENSE)
