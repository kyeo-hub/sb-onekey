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

### 订阅服务快捷开关

```bash
# 开启订阅服务（显示二维码和订阅链接）
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh) sub-on

# 关闭订阅服务
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh) sub-off
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

| 平台 | 客户端 | 导入方式 |
|------|--------|----------|
| Windows | [sing-box](https://github.com/SagerNet/sing-box) / [v2rayN](https://github.com/2dust/v2rayN) | 配置文件 |
| macOS | [sing-box](https://github.com/SagerNet/sing-box) / [V2RayXS](https://github.com/tzmax/V2RayXS) | 配置文件 |
| iOS | [Shadowrocket](https://apps.apple.com/us/app/shadowrocket/id932747118) / [sing-box](https://apps.apple.com/us/app/sing-box/id6451272673) | 扫码/订阅 |
| **Android** | **[sing-box](https://github.com/SagerNet/sing-box/releases)** ⭐ | **扫码/订阅** |

**安卓推荐**: [SFA (sing-box for Android)](https://github.com/SagerNet/sing-box/releases)
- 支持二维码扫描导入
- 支持订阅链接
- 原生支持 TUN 模式
- 界面简洁，功能完整

## 目录结构

```
/etc/sing-box/
├── config.json          # 服务端配置文件
├── client.json          # 客户端配置文件（可直接使用）
├── node_info.txt        # 节点信息（含分享链接）
├── sub_info.txt         # 订阅链接信息（含二维码）
├── sub_qr.txt           # 二维码（终端显示）
├── sub_qr.png           # 二维码（图片）
├── sub-server.py        # 订阅服务脚本
├── access.log           # 访问日志
└── tls/                 # TLS 证书目录（Hysteria2/TUIC）
    ├── cert.pem
    └── key.pem
```

## 客户端使用

安装完成后，服务器会生成客户端配置文件并提供订阅链接。

### 配置导入方式

#### 方式一：手动复制（最安全，推荐）

```bash
# 在本地电脑执行
scp root@你的服务器IP:/etc/sing-box/client.json ./
```

#### 方式二：订阅服务（临时开启）

为保护配置安全，订阅服务**默认关闭**，需要时手动开启：

```bash
# 1. 运行脚本
bash <(curl -fsSL https://raw.githubusercontent.com/kyeo-hub/sb-onekey/main/sing-box-server.sh)

# 2. 选择菜单选项 11 - 开启订阅服务
# 3. 使用二维码或订阅链接导入配置
# 4. 导入完成后，选择选项 12 - 关闭订阅服务
```

**安卓手机扫码导入：**
1. 开启订阅服务后，终端会显示二维码
2. 打开安卓 sing-box 客户端
3. 点击右上角 "+" → "扫描二维码"
4. 扫描终端显示的二维码导入
5. **导入完成后立即关闭订阅服务**

**订阅链接格式：**
```
http://你的服务器IP:8080/xxxxxxxxxxxxxxxx
```

#### 方式三：查看二维码文本（无需开启服务）

```bash
# 在服务器上查看文本二维码
cat /etc/sing-box/sub_qr.txt
```

**安全建议：**
- ✅ 配置导入完成后立即关闭订阅服务
- ✅ 订阅服务开启期间配置可能被扫描到
- ✅ 使用 scp 手动复制是最安全的方式

### 方式二：手动复制配置

```bash
# 查看客户端配置内容
cat /etc/sing-box/client.json

# 复制到本地（在本地终端执行）
scp root@你的服务器IP:/etc/sing-box/client.json ./sing-box-config.json
```

### 客户端配置说明

生成的客户端配置包含高级功能：

| 功能 | 说明 |
|------|------|
| **TUN 模式** | 透明代理，无需手动设置系统代理，所有流量自动分流 |
| **DNS 分流** | 国内域名用阿里 DNS，国外域名用 Cloudflare DNS |
| **广告屏蔽** | 自动屏蔽常见广告域名（category-ads-all）|
| **应用分流** | 国内 IP/域名直连，国外走代理，QUIC 协议屏蔽 |
| **Clash API** | 提供 `127.0.0.1:9090` 接口，支持 GUI 客户端管理 |
| **混合入口** | 同时支持 TUN 透明代理和 SOCKS5 `127.0.0.1:1080` |

### TUN 模式 vs 代理模式

**TUN 模式（推荐）**
- ✅ 系统级透明代理，无需配置应用代理
- ✅ 支持所有应用（包括不支持代理的应用）
- ✅ 更好的分流精度（基于域名/IP）
- ⚠️ 需要管理员/root权限运行
- ⚠️ 可能与部分 VPN 软件冲突

**代理模式（SOCKS5）**
- ✅ 兼容性好，不修改系统网络
- ✅ 可与 VPN 共存
- ⚠️ 需要应用支持 SOCKS5 代理
- ⚠️ 部分应用可能绕过代理

**建议**：日常使用 TUN 模式，遇到兼容性问题时切换到 SOCKS5

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
