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

## 文件说明

安装完成后在服务器上生成：

```
/etc/sing-box/
├── config.json          # 服务端配置
├── node_info.txt        # 节点信息（含分享链接）
└── tls/                 # TLS 证书（Hysteria2/TUIC）
    ├── cert.pem
    └── key.pem
```

## 客户端

安装完成后终端会输出分享链接，复制到客户端导入即可。

| 平台 | 推荐客户端 |
|------|------------|
| Windows | [sing-box](https://github.com/SagerNet/sing-box) / [v2rayN](https://github.com/2dust/v2rayN) |
| macOS | [sing-box](https://github.com/SagerNet/sing-box) |
| iOS | [Shadowrocket](https://apps.apple.com/us/app/shadowrocket/id932747118) / [sing-box](https://apps.apple.com/us/app/sing-box/id6451272673) |
| Android | [sing-box](https://github.com/SagerNet/sing-box/releases) ⭐ |

## 卸载

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh)
# 选择选项 0
```

## 许可证

[MIT](LICENSE)
