#!/usr/bin/env bash
# =============================================================
#  sing-box 服务端一键安装/管理脚本
#  支持协议: VLESS-REALITY / Hysteria2 / TUIC / Shadowsocks
#  支持系统: Debian / Ubuntu / CentOS / RHEL / AlmaLinux / Rocky
# =============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PLAIN='\033[0m'

SING_BOX_BIN="/usr/local/bin/sing-box"
SING_BOX_CONFIG="/etc/sing-box/config.json"
SING_BOX_SERVICE="/etc/systemd/system/sing-box.service"
SING_BOX_DIR="/etc/sing-box"

# ──────────────────────────────────────────
#  工具函数
# ──────────────────────────────────────────
info()    { echo -e "${GREEN}[INFO]${PLAIN} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${PLAIN} $*"; }
error()   { echo -e "${RED}[ERROR]${PLAIN} $*"; exit 1; }
confirm() {
    read -rp "$1 [y/N]: " ans
    [[ "$(echo "$ans" | tr '[:upper:]' '[:lower:]')" == "y" ]]
}

check_root() {
    [[ $EUID -ne 0 ]] && error "请使用 root 权限运行此脚本"
}

check_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID="${ID}"
        OS_VERSION_ID="${VERSION_ID%%.*}"
    else
        error "无法识别操作系统"
    fi

    case "${OS_ID}" in
        ubuntu|debian) PKG_MGR="apt-get" ;;
        centos|rhel|almalinux|rocky|fedora) PKG_MGR="yum" ;;
        *) error "暂不支持该系统: ${OS_ID}" ;;
    esac
    info "检测到系统: ${PRETTY_NAME:-$OS_ID}"
}

install_deps() {
    info "安装依赖..."
    if [[ "${PKG_MGR}" == "apt-get" ]]; then
        apt-get update -qq
        apt-get install -y -qq curl wget openssl uuid-runtime jq unzip
    else
        yum install -y -q curl wget openssl util-linux jq unzip
    fi
}

get_ip() {
    SERVER_IP=$(curl -s4m5 https://api.ipify.org 2>/dev/null || \
                curl -s4m5 https://ifconfig.me 2>/dev/null || \
                ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
    [[ -z "${SERVER_IP}" ]] && warn "无法自动获取 IP，部分功能需手动填写"
}

# ──────────────────────────────────────────
#  安装 sing-box 二进制
# ──────────────────────────────────────────
install_singbox_binary() {
    info "获取 sing-box 最新版本..."
    LATEST=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases/latest" \
        | grep '"tag_name"' | sed 's/.*"tag_name": *"v\([^"]*\)".*/\1/')

    [[ -z "${LATEST}" ]] && LATEST="1.10.0"
    info "将安装版本: v${LATEST}"

    ARCH=$(uname -m)
    case "${ARCH}" in
        x86_64)  ARCH_TAG="amd64" ;;
        aarch64) ARCH_TAG="arm64" ;;
        armv7l)  ARCH_TAG="armv7" ;;
        *)       error "不支持的架构: ${ARCH}" ;;
    esac

    PKG_NAME="sing-box-${LATEST}-linux-${ARCH_TAG}"
    DL_URL="https://github.com/SagerNet/sing-box/releases/download/v${LATEST}/${PKG_NAME}.tar.gz"

    TMP_DIR=$(mktemp -d)
    info "下载中: ${DL_URL}"
    curl -fsSL "${DL_URL}" -o "${TMP_DIR}/sing-box.tar.gz" || \
        error "下载失败，请检查网络或手动下载"

    tar -xzf "${TMP_DIR}/sing-box.tar.gz" -C "${TMP_DIR}"
    install -m 755 "${TMP_DIR}/${PKG_NAME}/sing-box" "${SING_BOX_BIN}"
    rm -rf "${TMP_DIR}"

    mkdir -p "${SING_BOX_DIR}"
    info "sing-box v${LATEST} 安装完成 → ${SING_BOX_BIN}"
}

# ──────────────────────────────────────────
#  systemd 服务
# ──────────────────────────────────────────
install_service() {
    cat > "${SING_BOX_SERVICE}" <<'EOF'
[Unit]
Description=sing-box service
Documentation=https://sing-box.sagernet.org
After=network.target nss-lookup.target

[Service]
User=root
WorkingDirectory=/etc/sing-box
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable sing-box
    info "systemd 服务已注册"
}

# ──────────────────────────────────────────
#  生成随机端口 / UUID / 密码
# ──────────────────────────────────────────
rand_port() {
    local lo="${1:-10000}" hi="${2:-65000}"
    shuf -i "${lo}-${hi}" -n 1
}
rand_uuid()     { uuidgen | tr '[:upper:]' '[:lower:]'; }
rand_pass()     { openssl rand -base64 24 | tr -d '/+='; }
rand_hex()      { openssl rand -hex "$1"; }

# ──────────────────────────────────────────
#  TLS Reality 密钥对
# ──────────────────────────────────────────
gen_reality_keys() {
    REALITY_KEYS=$(${SING_BOX_BIN} generate reality-keypair 2>/dev/null)
    REALITY_PRIVATE=$(echo "${REALITY_KEYS}" | awk '/PrivateKey/{print $2}')
    REALITY_PUBLIC=$(echo  "${REALITY_KEYS}" | awk '/PublicKey/{print $2}')
}

# ──────────────────────────────────────────
#  协议配置生成
# ──────────────────────────────────────────

## 1. VLESS-REALITY
config_vless_reality() {
    PORT=$(rand_port 10000 60000)
    UUID=$(rand_uuid)
    SHORTID=$(rand_hex 8)
    gen_reality_keys
    SNI="www.microsoft.com"

    cat > "${SING_BOX_CONFIG}" <<EOF
{
  "log": { "level": "info", "timestamp": true },
  "inbounds": [
    {
      "type": "vless",
      "tag": "vless-in",
      "listen": "::",
      "listen_port": ${PORT},
      "users": [
        { "uuid": "${UUID}", "flow": "xtls-rprx-vision" }
      ],
      "tls": {
        "enabled": true,
        "server_name": "${SNI}",
        "reality": {
          "enabled": true,
          "handshake": { "server": "${SNI}", "server_port": 443 },
          "private_key": "${REALITY_PRIVATE}",
          "short_id": ["${SHORTID}"]
        }
      }
    }
  ],
  "outbounds": [
    { "type": "direct", "tag": "direct" }
  ]
}
EOF

    SHARE_LINK="vless://${UUID}@${SERVER_IP}:${PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${SNI}&fp=chrome&pbk=${REALITY_PUBLIC}&sid=${SHORTID}&type=tcp#SingBox-REALITY"

    echo -e "\n${CYAN}════════════ VLESS-REALITY 节点信息 ════════════${PLAIN}"
    echo -e "  地址    : ${SERVER_IP}"
    echo -e "  端口    : ${PORT}"
    echo -e "  UUID    : ${UUID}"
    echo -e "  Public Key : ${REALITY_PUBLIC}"
    echo -e "  Short ID   : ${SHORTID}"
    echo -e "  SNI     : ${SNI}"
    echo -e "  Flow    : xtls-rprx-vision"
    echo -e "\n  分享链接:"
    echo -e "  ${GREEN}${SHARE_LINK}${PLAIN}"
    echo -e "${CYAN}═══════════════════════════════════════════════${PLAIN}\n"

    save_node_info "VLESS-REALITY" "${SHARE_LINK}"
}

## 2. Hysteria2
config_hysteria2() {
    PORT=$(rand_port 10000 60000)
    PASS=$(rand_pass)

    # 自签名证书
    mkdir -p "${SING_BOX_DIR}/tls"
    openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 \
        -keyout "${SING_BOX_DIR}/tls/key.pem" \
        -out    "${SING_BOX_DIR}/tls/cert.pem" \
        -days 3650 -nodes \
        -subj "/CN=bing.com" 2>/dev/null

    cat > "${SING_BOX_CONFIG}" <<EOF
{
  "log": { "level": "info", "timestamp": true },
  "inbounds": [
    {
      "type": "hysteria2",
      "tag": "hy2-in",
      "listen": "::",
      "listen_port": ${PORT},
      "users": [
        { "password": "${PASS}" }
      ],
      "tls": {
        "enabled": true,
        "certificate_path": "${SING_BOX_DIR}/tls/cert.pem",
        "key_path": "${SING_BOX_DIR}/tls/key.pem"
      }
    }
  ],
  "outbounds": [
    { "type": "direct", "tag": "direct" }
  ]
}
EOF

    SHARE_LINK="hysteria2://${PASS}@${SERVER_IP}:${PORT}?insecure=1#SingBox-HY2"

    echo -e "\n${CYAN}════════════ Hysteria2 节点信息 ════════════${PLAIN}"
    echo -e "  地址    : ${SERVER_IP}"
    echo -e "  端口    : ${PORT}"
    echo -e "  密码    : ${PASS}"
    echo -e "  跳过证书验证: true (自签证书)"
    echo -e "\n  分享链接:"
    echo -e "  ${GREEN}${SHARE_LINK}${PLAIN}"
    echo -e "${CYAN}════════════════════════════════════════════${PLAIN}\n"

    save_node_info "Hysteria2" "${SHARE_LINK}"
}

## 3. TUIC v5
config_tuic() {
    PORT=$(rand_port 10000 60000)
    UUID=$(rand_uuid)
    PASS=$(rand_pass)

    mkdir -p "${SING_BOX_DIR}/tls"
    openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 \
        -keyout "${SING_BOX_DIR}/tls/key.pem" \
        -out    "${SING_BOX_DIR}/tls/cert.pem" \
        -days 3650 -nodes \
        -subj "/CN=bing.com" 2>/dev/null

    cat > "${SING_BOX_CONFIG}" <<EOF
{
  "log": { "level": "info", "timestamp": true },
  "inbounds": [
    {
      "type": "tuic",
      "tag": "tuic-in",
      "listen": "::",
      "listen_port": ${PORT},
      "users": [
        { "uuid": "${UUID}", "password": "${PASS}" }
      ],
      "congestion_control": "bbr",
      "tls": {
        "enabled": true,
        "alpn": ["h3"],
        "certificate_path": "${SING_BOX_DIR}/tls/cert.pem",
        "key_path": "${SING_BOX_DIR}/tls/key.pem"
      }
    }
  ],
  "outbounds": [
    { "type": "direct", "tag": "direct" }
  ]
}
EOF

    SHARE_LINK="tuic://${UUID}:${PASS}@${SERVER_IP}:${PORT}?congestion_control=bbr&alpn=h3&allow_insecure=1#SingBox-TUIC"

    echo -e "\n${CYAN}════════════ TUIC v5 节点信息 ════════════${PLAIN}"
    echo -e "  地址    : ${SERVER_IP}"
    echo -e "  端口    : ${PORT}"
    echo -e "  UUID    : ${UUID}"
    echo -e "  密码    : ${PASS}"
    echo -e "  拥塞控制: BBR"
    echo -e "\n  分享链接:"
    echo -e "  ${GREEN}${SHARE_LINK}${PLAIN}"
    echo -e "${CYAN}══════════════════════════════════════════${PLAIN}\n"

    save_node_info "TUIC" "${SHARE_LINK}"
}

## 4. Shadowsocks (2022)
config_shadowsocks() {
    PORT=$(rand_port 10000 60000)
    METHOD="2022-blake3-aes-128-gcm"
    SS_KEY=$(openssl rand -base64 16)

    cat > "${SING_BOX_CONFIG}" <<EOF
{
  "log": { "level": "info", "timestamp": true },
  "inbounds": [
    {
      "type": "shadowsocks",
      "tag": "ss-in",
      "listen": "::",
      "listen_port": ${PORT},
      "method": "${METHOD}",
      "password": "${SS_KEY}"
    }
  ],
  "outbounds": [
    { "type": "direct", "tag": "direct" }
  ]
}
EOF

    B64=$(echo -n "${METHOD}:${SS_KEY}" | base64 -w 0)
    SHARE_LINK="ss://${B64}@${SERVER_IP}:${PORT}#SingBox-SS2022"

    echo -e "\n${CYAN}════════════ Shadowsocks 2022 节点信息 ════════════${PLAIN}"
    echo -e "  地址    : ${SERVER_IP}"
    echo -e "  端口    : ${PORT}"
    echo -e "  加密    : ${METHOD}"
    echo -e "  密码    : ${SS_KEY}"
    echo -e "\n  分享链接:"
    echo -e "  ${GREEN}${SHARE_LINK}${PLAIN}"
    echo -e "${CYAN}═══════════════════════════════════════════════════${PLAIN}\n"

    save_node_info "Shadowsocks-2022" "${SHARE_LINK}"
}

# ──────────────────────────────────────────
#  保存节点信息
# ──────────────────────────────────────────
save_node_info() {
    local proto="$1" link="$2"
    cat > "${SING_BOX_DIR}/node_info.txt" <<EOF
协议: ${proto}
生成时间: $(date '+%Y-%m-%d %H:%M:%S')
服务器IP: ${SERVER_IP}

分享链接:
${link}
EOF
    info "节点信息已保存至 ${SING_BOX_DIR}/node_info.txt"
}

# ──────────────────────────────────────────
#  防火墙放行端口
# ──────────────────────────────────────────
open_firewall() {
    local port="$1" proto="${2:-tcp}"

    if command -v ufw &>/dev/null && ufw status | grep -q "active"; then
        ufw allow "${port}/${proto}" >/dev/null 2>&1
        info "ufw 已放行端口 ${port}/${proto}"
    fi

    if command -v firewall-cmd &>/dev/null; then
        firewall-cmd --permanent --add-port="${port}/${proto}" >/dev/null 2>&1
        firewall-cmd --reload >/dev/null 2>&1
        info "firewalld 已放行端口 ${port}/${proto}"
    fi

    if command -v iptables &>/dev/null; then
        iptables -I INPUT -p "${proto}" --dport "${port}" -j ACCEPT 2>/dev/null
    fi
}

# ──────────────────────────────────────────
#  开启 BBR
# ──────────────────────────────────────────
enable_bbr() {
    KVER=$(uname -r | cut -d. -f1-2 | tr -d '.')
    if [[ "${KVER}" -ge "412" ]]; then
        if ! sysctl net.ipv4.tcp_congestion_control 2>/dev/null | grep -q bbr; then
            echo "net.core.default_qdisc=fq"           >> /etc/sysctl.conf
            echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
            sysctl -p >/dev/null 2>&1
            info "BBR 加速已开启"
        fi
    fi
}

# ──────────────────────────────────────────
#  主菜单
# ──────────────────────────────────────────
show_menu() {
    echo -e "\n${BLUE}╔══════════════════════════════════════════╗${PLAIN}"
    echo -e "${BLUE}║     sing-box 服务端一键管理脚本          ║${PLAIN}"
    echo -e "${BLUE}╠══════════════════════════════════════════╣${PLAIN}"
    echo -e "${BLUE}║  ${GREEN}1.${PLAIN} 安装 - VLESS-REALITY (推荐)         ${BLUE}║${PLAIN}"
    echo -e "${BLUE}║  ${GREEN}2.${PLAIN} 安装 - Hysteria2                    ${BLUE}║${PLAIN}"
    echo -e "${BLUE}║  ${GREEN}3.${PLAIN} 安装 - TUIC v5                      ${BLUE}║${PLAIN}"
    echo -e "${BLUE}║  ${GREEN}4.${PLAIN} 安装 - Shadowsocks 2022              ${BLUE}║${PLAIN}"
    echo -e "${BLUE}╠══════════════════════════════════════════╣${PLAIN}"
    echo -e "${BLUE}║  ${YELLOW}5.${PLAIN} 查看节点信息                        ${BLUE}║${PLAIN}"
    echo -e "${BLUE}║  ${YELLOW}6.${PLAIN} 查看运行状态                        ${BLUE}║${PLAIN}"
    echo -e "${BLUE}║  ${YELLOW}7.${PLAIN} 重启 sing-box                       ${BLUE}║${PLAIN}"
    echo -e "${BLUE}║  ${YELLOW}8.${PLAIN} 查看实时日志                        ${BLUE}║${PLAIN}"
    echo -e "${BLUE}║  ${YELLOW}9.${PLAIN} 更新 sing-box 到最新版              ${BLUE}║${PLAIN}"
    echo -e "${BLUE}╠══════════════════════════════════════════╣${PLAIN}"
    echo -e "${BLUE}║  ${RED}0.${PLAIN} 卸载 sing-box                       ${BLUE}║${PLAIN}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${PLAIN}"
    echo -ne "  请输入选项 [0-9]: "
}

do_install() {
    local proto_fn="$1"
    local fw_proto="${2:-tcp}"

    check_os
    install_deps
    get_ip

    # 若已安装则询问是否覆盖
    if [[ -f "${SING_BOX_BIN}" ]]; then
        if ! confirm "sing-box 已安装，是否重新安装配置？"; then
            info "已取消"
            return
        fi
        systemctl stop sing-box 2>/dev/null || true
    fi

    install_singbox_binary
    install_service
    enable_bbr

    ${proto_fn}

    # 从配置中读取实际端口
    ACTUAL_PORT=$(grep '"listen_port"' "${SING_BOX_CONFIG}" | grep -oE '[0-9]+' | head -1)
    open_firewall "${ACTUAL_PORT}" "${fw_proto}"

    systemctl restart sing-box
    sleep 1

    if systemctl is-active --quiet sing-box; then
        info "sing-box 服务启动成功 ✓"
    else
        warn "服务启动异常，请运行: journalctl -u sing-box -n 50"
    fi
}

do_uninstall() {
    if ! confirm "确认卸载 sing-box？配置将全部删除"; then
        return
    fi
    systemctl stop sing-box 2>/dev/null || true
    systemctl disable sing-box 2>/dev/null || true
    rm -f "${SING_BOX_BIN}" "${SING_BOX_SERVICE}"
    rm -rf "${SING_BOX_DIR}"
    systemctl daemon-reload
    info "sing-box 已卸载完毕"
}

# ──────────────────────────────────────────
#  入口
# ──────────────────────────────────────────
main() {
    echo "[DEBUG] Script started, args: $*"
    check_root
    echo "[DEBUG] Root check passed"

    # 支持命令行参数直接安装
    case "${1:-}" in
        vless|reality) do_install config_vless_reality tcp; exit 0 ;;
        hy2|hysteria2) do_install config_hysteria2 udp; exit 0 ;;
        tuic)          do_install config_tuic udp; exit 0 ;;
        ss|shadowsocks) do_install config_shadowsocks tcp; exit 0 ;;
    esac

    while true; do
        show_menu
        read -r opt
        case "${opt}" in
            1) do_install config_vless_reality tcp ;;
            2) do_install config_hysteria2 udp ;;
            3) do_install config_tuic udp ;;
            4) do_install config_shadowsocks tcp ;;
            5) [[ -f "${SING_BOX_DIR}/node_info.txt" ]] && cat "${SING_BOX_DIR}/node_info.txt" || warn "尚未安装任何节点" ;;
            6) systemctl status sing-box --no-pager ;;
            7) systemctl restart sing-box && info "已重启" ;;
            8) journalctl -u sing-box -f --no-pager ;;
            9)
                check_os; install_deps
                systemctl stop sing-box 2>/dev/null || true
                install_singbox_binary
                systemctl start sing-box
                info "更新完成"
                ;;
            0) do_uninstall ;;
            *) warn "无效选项" ;;
        esac
    done
}

main "$@"
