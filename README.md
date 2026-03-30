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

## 快速安装

### 方式一：命令行参数（推荐）

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

### 方式二：交互式菜单

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh)
```

### 方式三：下载后运行

```bash
curl -fsSL -o sing-box-server.sh https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh
chmod +x sing-box-server.sh
./sing-box-server.sh vless
```

## 管理菜单

运行脚本（不带参数）进入交互式菜单：

| 选项 | 功能 |
|------|------|
| 1 | 安装 - VLESS-REALITY (推荐) |
| 2 | 安装 - Hysteria2 |
| 3 | 安装 - TUIC v5 |
| 4 | 安装 - Shadowsocks 2022 |
| 5 | 查看节点信息 |
| 6 | 查看运行状态 |
| 7 | 重启 sing-box |
| 8 | 查看实时日志 |
| 9 | 更新 sing-box 到最新版 |
| 0 | 卸载 sing-box |

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

安装完成后，脚本会自动生成客户端配置文件和分享链接。

### 配置文件

安装完成后在服务器上生成：

```
/etc/sing-box/
├── config.json          # 服务端配置
├── client.json          # 客户端配置（可直接使用）
├── node_info.txt        # 节点信息（含分享链接）
└── tls/                 # TLS 证书（Hysteria2/TUIC）
    ├── cert.pem
    └── key.pem
```

### 导入客户端配置

**方式一：scp 复制（推荐）**

```bash
scp root@你的服务器IP:/etc/sing-box/client.json ./
```

**方式二：分享链接**

安装完成后终端会输出分享链接，复制到客户端导入即可。

### 推荐客户端

| 平台 | 客户端 |
|------|--------|
| Windows | [sing-box](https://github.com/SagerNet/sing-box) / [v2rayN](https://github.com/2dust/v2rayN) |
| macOS | [sing-box](https://github.com/SagerNet/sing-box) |
| iOS | [Shadowrocket](https://apps.apple.com/us/app/shadowrocket/id932747118) / [sing-box](https://apps.apple.com/us/app/sing-box/id6451272673) |
| Android | [sing-box](https://github.com/SagerNet/sing-box/releases) ⭐ |

### 客户端配置说明

生成的客户端配置包含以下功能：

| 功能 | 说明 |
|------|------|
| **TUN 模式** | 透明代理，无需手动设置系统代理，所有流量自动分流 |
| **SOCKS5 混合代理** | `127.0.0.1:1080`，兼容不支持 TUN 的场景 |
| **DNS 分流** | 国内域名用阿里 DNS，国外域名用 Cloudflare DNS |
| **纯 IPv4 策略** | `strategy: ipv4_only`，禁用 AAAA 查询，避免 IPv6 不可达 |
| **广告屏蔽** | 自动屏蔽常见广告域名 |
| **智能分流** | 国内 IP/域名直连，私有 IP 直连，其余走代理 |
| **Clash API** | `127.0.0.1:9090`，支持 GUI 客户端管理 |

### 启动客户端

```bash
# 使用生成的配置文件启动
sing-box run -c client.json
```

## 卸载

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh)
# 选择选项 0
```

## 许可证

[MIT](LICENSE)
