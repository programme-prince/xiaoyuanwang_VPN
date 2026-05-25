# 校园网 + 手机热点 双网卡分流方案

## 解决什么问题

需要同时满足两个矛盾的需求：

1. **必须连校园网** → 才能访问学校实验室服务器（如 `YOUR_SERVER_IP`）
2. **必须开 VPN** → 但学校规定校园网上开 VPN 会通报批评

**矛盾点**：以前只能用校园网，但校园网不允许开 VPN。现在通过双网卡分流，让两个网络各司其职。

---

## 原理

### 物理层面：两个独立的网

| 网卡 | 连接 | 用途 |
|------|------|------|
| **有线网卡（以太网）** | 插墙上网口 → **校园网** | 访问学校服务器 |
| **无线网卡（WLAN）** | 连你手机开的 **热点** | 浏览器、VPN 等其他所有流量 |

### 软件层面：路由规则

Windows 默认同时连两个网络时会随机或按优先级走，我们需要手动告诉系统：

```
- 访问学校服务器（YOUR_SERVER_IP） → 走校园网有线（网关 YOUR_CAMPUS_GATEWAY）
- 其他所有流量（包括 VPN）        → 走手机热点（网关 YOUR_HOTSPOT_GATEWAY）
```

这是通过两条配置实现的：

**① 跃点数（Interface Metric）**
- 跃点数越小，优先级越高
- 热点设 `10`（高优先级，默认流量走这里）
- 校园网设 `100`（低优先级，除非指定路由否则不走）

**② 静态路由**
- 精确指定 `YOUR_SERVER_IP` 必须走校园网网关
- 这条路由的优先级高于 VPN 添加的路由

### 为什么学校检测不到

- 学校 DPI（深度包检测）检测的是**在校园网链路上出现 VPN 协议的握手特征**
- 我们的 VPN 实际上跑在**手机热点**上，校园网有线网卡只传输普通的 SSH / ICMP 流量
- 学校只能看到你在校园网上访问了 `YOUR_SERVER_IP`，完全看不到 VPN 流量

---

## 文件说明

```
xiaoyuanwang_VPN/
├── settings.bat          ← 【配置文件】所有 IP 地址都在这里改（已被 .gitignore 忽略，不上传）
├── settings.example.bat  ← 【配置模板】复制为 settings.bat 后填入自己的 IP
├── fix_routes.bat        ← 【配置脚本】设置跃点数 + 加路由（以管理员身份运行）
├── monitor.bat           ← 【监控脚本】实时查看网络走向（双击运行，Ctrl+C 退出）
├── check_network.bat     ← 【检测脚本】快速看一眼默认路由（双击运行）
├── restore_routes.bat    ← 【还原脚本】一键还原所有设置（以管理员身份运行）
├── .gitignore            ← Git 忽略规则（防止 settings.bat 被上传）
└── README.md             ← 本文件
```

---

## 使用步骤

### 前提条件

1. 电脑有网线接口（或 USB 转网口）
2. 手机能开热点
3. 知道学校服务器的 IP

### 第一步：修改配置（仅第一次）

复制 `settings.example.bat` 为 `settings.bat`，用记事本打开，填入你自己的 IP：

```bat
set SERVER_IP=YOUR_SERVER_IP           ← 改成你的服务器 IP
set CAMPUS_GATEWAY=YOUR_CAMPUS_GATEWAY ← 改成你校园网的网关
set CAMPUS_SUBNET=YOUR_CAMPUS_SUBNET
```

### 第二步：插网线，连热点

```
有线网卡 → 插墙上校园网口
Wi-Fi    → 连手机热点（不要连校园 Wi-Fi）
```

### 第三步：运行 fix_routes.bat

右键 **`fix_routes.bat`** → **以管理员身份运行**

脚本会自动完成：
1. 设置热点跃点数 = 10（高优先级）
2. 设置校园网跃点数 = 100（低优先级）
3. 添加路由：服务器 IP 走校园网

看到 `Done.` 就完成了。

### 第四步：正常使用

- SSH 连学校服务器 → 走校园网有线
- 开 VPN → 走手机热点，学校看不到
- 浏览器 / 微信 / 查资料 → 走手机热点

---

## 怎么判断 VPN 走的是热点还是校园网

### 方法一：双击 monitor.bat（实时监控，推荐）

每 3 秒刷新一次，看默认网关的最后一列（跃点数）：

```
0.0.0.0 ...  YOUR_CAMPUS_GATEWAY   YOUR_CAMPUS_IP    100  ← 校园网
0.0.0.0 ...  YOUR_HOTSPOT_GATEWAY  YOUR_HOTSPOT_IP    10   ← 热点
```

判断标准：
- **热点跃点数小（10）** → ✅ VPN 走热点，安全
- **校园网跃点数小** → ⚠️ 有风险，跑 `fix_routes.bat` 修复

按 **Ctrl + C** 退出监控。

### 方法二：双击 check_network.bat

快速看一眼就走，原理同上。

---

## 热点断了会泄漏 VPN 流量吗？

**会，有一个短暂的风险窗口。**

当手机热点突然断开时：
1. 热点的默认路由消失
2. VPN 可能还开着没反应过来
3. 校园网的默认路由还在，VPN 流量会短暂漏到校园网上

这个风险很小（热点断后 VPN 很快也断了），但有下面两种处理方式：

### 方式一：不处理（简单省事）

默认配置已经够安全了，热点断开后 VPN 几秒内也会断，泄漏窗口极短。

### 方式二：开启防泄漏模式（手动挡）

> 开启后，热点断了 VPN 就直接发不出去，0 泄漏。

以管理员身份打开 **PowerShell**（Win 键 → 输入 powershell → 右键以管理员身份运行），粘贴以下命令（替换 YOUR_ 为你的实际 IP）：

```powershell
# 1. 添加校园网子网路由
route add YOUR_CAMPUS_SUBNET mask 255.255.255.0 YOUR_CAMPUS_GATEWAY -p

# 2. 删除校园网的默认路由（防泄漏的关键）
Get-NetRoute -DestinationPrefix "0.0.0.0/0" -AddressFamily IPv4 | Where-Object { $_.NextHop -eq "YOUR_CAMPUS_GATEWAY" } | Remove-NetRoute -Confirm:$false -ErrorAction SilentlyContinue

# 3. 禁止 DHCP 自动恢复校园网默认路由
Set-NetIPInterface -InterfaceAlias "以太网" -IgnoreDefaultRoutes "Enabled" -ErrorAction SilentlyContinue
```

**还原方法**：右键以管理员身份运行 `restore_routes.bat`，或者粘贴以下命令：

```powershell
# 1. 重新允许 DHCP 加路由
Set-NetIPInterface -InterfaceAlias "以太网" -IgnoreDefaultRoutes "Disabled" -ErrorAction SilentlyContinue

# 2. 删掉我们加的路由
route delete YOUR_SERVER_IP
route delete YOUR_CAMPUS_SUBNET

# 3. 恢复校园网默认路由
route add 0.0.0.0 mask 0.0.0.0 YOUR_CAMPUS_GATEWAY -p

# 4. 恢复自动跃点数
Set-NetIPInterface -InterfaceAlias "WLAN" -InterfaceMetric "Automatic" -ErrorAction SilentlyContinue
Set-NetIPInterface -InterfaceAlias "以太网" -InterfaceMetric "Automatic" -ErrorAction SilentlyContinue
```

---

## 还原所有设置

右键 **`restore_routes.bat`** → **以管理员身份运行**

会执行：
1. 删除服务器的路由规则
2. 恢复所有网卡为自动跃点数
3. 恢复校园网默认路由

---

## 换电脑或换 IP 怎么用

复制整个文件夹到新电脑，编辑 `settings.bat` 填上新环境的 IP，然后跑 `fix_routes.bat` 即可。

---

## 注意事项

| 情况 | 说明 |
|------|------|
| **重启电脑** | 配置持久化保存，重启后还在 |
| **拔掉网线** | 学校服务器会连不上。插回网线自动恢复 |
| **热点断开** | VPN/浏览器会断网。重新连上热点自动恢复 |
| **换个热点** | 只要手机热点网段不变，配置不受影响 |
| **跃点数被改乱** | 跑 **`fix_routes.bat`** 重新修复 |
| **VPN 开 TUN 模式** | 不影响，VPN 加密后的流量仍然走热点物理出口 |
| **IPv6** | 不影响，IPv4 和 IPv6 路由独立 |

## 常见问题

**Q：开 VPN 后 SSH 断了怎么办？**
A：说明 VPN 抢了路由。跑 `restore_routes.bat` 还原后，关掉 VPN，重新跑 `fix_routes.bat`，再开 VPN。

**Q：monitor.bat 里显示 8.8.8.8 timeout 但浏览器能上网？**
A：这是正常的，有些 VPN 或热点会屏蔽 ping（ICMP 协议），不影响实际使用。

**Q：SSH 连不上服务器但 ping 通了？**
A：检查服务器 SSH 服务是否在运行（`systemctl status ssh`），或者校园网有线是否需要网页认证。

**Q：手机热点流量够用吗？**
A：VPN、浏览器、微信等走热点流量。学校服务器访问走校园网有线，不消耗热点流量。只开 VPN 查资料的话流量消耗不大。
