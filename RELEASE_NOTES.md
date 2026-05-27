### Bug Fixes

- **Status Bar Menu No Longer Greys Out Unexpectedly** — Action items in the status bar menu (Set as System Proxy, Enhanced Mode, Copy Terminal Command, Quit, etc.) could become disabled when another window briefly stole the responder chain (e.g. during Sparkle update prompts or Settings sheets). All menu items now have explicit targets and a centralized `validateMenuItem:` implementation, so the menu state remains correct regardless of focus changes.
- **Bypass Common Chinese Apps Now Reflects Enhanced Mode** — The "Bypass Common Chinese Apps" toggle relies on `PROCESS-NAME` rules that only resolve under Enhanced Mode (TUN). Under Rule mode mihomo cannot see the originating process, so the toggle was previously a silent no-op. It is now disabled in Rule mode with a tooltip explaining the requirement; toggling Enhanced Mode on automatically re-enables it.
- **External Control Mode No Longer Breaks Other Menu Items** — Selecting an External Control instance used to disable Sparkle's auto-validation for the entire status menu, which could leave unrelated items greyed out. Disable logic now targets only the actions that genuinely don't apply to a remote core (Set as System Proxy, Copy Terminal Command), while everything else stays usable.

---

### 修复

- **菜单栏不再无故灰掉** — 状态栏菜单的动作项（设置为系统代理、增强模式、复制终端代理命令、退出等）在其他窗口短暂抢占响应链时（如 Sparkle 弹窗、设置面板出现时）会被自动禁用。现在所有菜单项都显式绑定 target，并通过统一的 `validateMenuItem:` 校验，焦点切换不会再让菜单状态错乱。
- **「绕过常用国内应用」按增强模式自动启停** — 这个开关依赖 `PROCESS-NAME` 规则，只有增强模式（TUN）下 mihomo 才看得到进程名。规则模式下 mihomo 只是 HTTP/SOCKS 代理，拿不到进程信息，开关此前是静默失效。现在在规则模式下会自动灰掉并显示提示，开启增强模式后自动恢复可用。
- **外部控制模式不再误伤其他菜单项** — 之前选中外部控制实例会关闭整个状态栏菜单的自动校验，可能让无关菜单项一起变灰。现在只有真正不适用远程核心的动作（设置为系统代理、复制终端代理命令）会被禁用，其他菜单项保持可用。
