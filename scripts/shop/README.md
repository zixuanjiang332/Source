# Shop Module

## 概述

商店模块提供赛博朋克风格的购买界面，玩家可以使用货币购买物品升级。

## 文件结构

```
scripts/shop/
├── ShopController.gd    # 商店主控制器

scenes/shop/
├── Shop.tscn            # 商店场景

resources/shop/
├── main_shop_catalog.tres  # 主商店商品目录
```

## 对接接口

### 1. 触发商店打开

在任意 DemoInteractable 节点上勾选 `opens_shop` 属性即可将其变为商店入口：

```
DemoInteractable 节点:
  - opens_shop = true
  - shop_id = &"main"
```

或通过代码触发：
```gdscript
GameEvents.request_shop(&"main")
```

### 2. GameEvents 信号

| 信号 | 参数 | 说明 |
| --- | --- | --- |
| `shop_requested` | `shop_id: StringName` | 请求打开商店 |
| `shop_closed` | - | 商店关闭 |
| `currency_changed` | `current_amount: int` | 货币变动 |
| `item_purchased` | `shop_item_id, item_data` | 物品购买成功 |

### 3. CurrencyManager (Autoload)

```gdscript
# 获取余额
CurrencyManager.get_balance() -> int

# 检查是否买得起
CurrencyManager.can_afford(amount: int) -> bool

# 扣款（返回是否成功）
CurrencyManager.spend(amount: int) -> bool

# 增加货币
CurrencyManager.add(amount: int) -> void
```

### 4. 添加新商品

1. 创建 ItemData 资源（如 `resources/items/new_item.tres`）
2. 在 `resources/shop/main_shop_catalog.tres` 中添加 ShopData 条目：

```
[sub_resource type="Resource" id="ShopData_new"]
script = ExtResource("2_shopdata")
shop_item_id = &"shop_new_item"
item_data = ExtResource("path_to_item_data")
price = 100
stock = -1  # -1 = 无限, >0 = 有限库存
```

### 5. 玩家物品效果

玩家 `PlayerController.gd` 的 `apply_item()` 方法处理物品效果：

```gdscript
match item_data.effect_id:
    &"damage_multiplier":  # 伤害加成
    &"heal":               # 回血
    &"dash_cooldown":      # 冲刺冷却减少
    &"max_health":         # 最大生命增加
```

添加新效果类型需在 PlayerController.gd 的 `apply_item()` 中添加 match 分支。

## 配置

- 初始货币：`CurrencyManager.gd` 中的 `_credits = 500`
- 商店目录：在 Shop.tscn 的 `catalog` 属性中指定 ShopCatalog 资源

## 输入操作

- W/S 或 上/下：导航商品
- E 或 Space：选择/确认
- ESC：关闭商店/取消
