# 构建说明

## 导出 Windows EXE

### 前置条件

1. 安装 Godot 4.6.x 编辑器（项目使用 4.6.3）
2. 下载导出模板：
   - 打开 Godot 编辑器
   - 菜单：Editor → Manage Export Templates
   - 点击 "Download and Install" 下载 4.6.3.stable 模板

### 导出步骤

#### 方法一：命令行导出

```powershell
cd e:\Project\game\Source
E:\Godot\Godot_v4.6.3-stable_win64_console.exe --headless --export-release "Windows Demo" "builds/windows/NeonMachineDemo.exe"
```

#### 方法二：编辑器导出

1. 打开 Godot 编辑器，加载项目
2. 菜单：Project → Export
3. 选择 "Windows Demo" 预设
4. 点击 "Export Project"
5. 选择输出路径：`builds/windows/NeonMachineDemo.exe`

### 输出位置

```
builds/windows/
├── NeonMachineDemo.exe    # 主程序
└── NeonMachineDemo.pck    # 资源包（如果未嵌入）
```

当前配置已启用 `binary_format/embed_pck=true`，资源会嵌入 exe 中。

## 运行测试

在编辑器中按 F5 或点击运行按钮即可测试游戏。

## 当前状态

- 导出配置：`export_presets.cfg` 已配置 Windows Desktop
- 导出模板：**需要下载**（编辑器中下载）
- 输出目录：`builds/windows/` 已创建
