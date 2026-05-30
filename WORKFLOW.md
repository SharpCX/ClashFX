# ClashFX 开发工作流

> 创建时间：2026-05-30  
> 原始项目：`yichengchen/clashX`（已归档/删除）  
> 当前 fork：`SharpCX/ClashFX` ← **活跃开发**

---

## Git 配置

```
origin       git@github.com:SharpCX/ClashFX.git      ← 当前开发仓库
upstream-old git@github.com:Clash-FX/ClashFX.git     ← 原团队仓库（备用）
```

### 查看当前 remotes
```bash
git remote -v
```

---

## 日常开发

### 提交修改
```bash
git add -A
git commit -m "feat: xxx"
git push origin main
```

### 拉取最新代码
```bash
git pull origin main
```

---

## 合并原仓库更新（如有）

如果 `Clash-FX/ClashFX` 有更新需要合并：

```bash
# 1. 获取原仓库更新
git fetch upstream-old

# 2. 合并到当前分支
git merge upstream-old/main

# 3. 解决冲突后推送
git push origin main
```

---

## 保留自己的修改（关键原则）

1. **在 `main` 分支上直接开发** — 这是你的 fork，不需要再开 feature 分支
2. **定期 commit** — 避免修改堆积
3. **合并前先看 diff** — `git diff upstream-old/main` 确认合并内容
4. **冲突时优先保留自己的修改** — 除非原仓库的修复确实更好

---

## 提交规范

```
feat:     新功能
fix:      修复 bug
refactor: 重构
docs:     文档更新
chore:    杂项（依赖升级、CI 等）
```

示例：
```bash
git commit -m "feat: add auto update check interval setting"
git commit -m "fix: crash when remote config returns empty"
```

---

## 找回原始项目

原始 `yichengchen/clashX` 已在 2023 年底归档/删除。  
如需参考历史代码，可搜索镜像站或 wayback machine。
