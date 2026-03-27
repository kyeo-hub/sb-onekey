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
├── config.json          # 主配置文件
├── node_info.txt        # 节点信息（含分享链接）
└── tls/                 # TLS 证书目录（Hysteria2/TUIC）
    ├── cert.pem
    └── key.pem
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
