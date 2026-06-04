# 敌方单位图鉴

本页按当前项目的世界观、元素循环与关卡推进整理第一至第三关的正式版敌方图鉴。文档采用“设定 + 数值混合”写法，每关统一为 `普通怪 10 个`、`精英怪 5 个`、`Boss 1 个`，并与 `蚀 -> 脉 -> 滞` 的主题递进保持一致。本文额外补齐每只怪物的动作设计、攻击方式拆解与 AI 生成提示词，便于后续直接进入像素敌人生产阶段。

---

## 第一关：城市楼栋竖切面

本关对应元素 `蚀`，核心体验是裂解、侵入、坠落、破甲与虫群扩散。场景围绕居民楼断面、电梯井、坍塌平台与废弃通道展开，目标是让玩家在开场就感受到“旧秩序已被撕开”的压迫感。

### 关卡数值基准

- 普通怪血量建议区间：`90 - 180`
- 精英怪血量建议区间：`260 - 420`
- Boss 总血量建议：`780 - 860`
- 本关常见异常：`蚀裂创口`、`结构破甲`、`坠层撕伤`

### 普通怪 10 个

#### 1. 侦察无人机

**类别：** 普通怪 / 侦察型 / 高架巡查单位  
**元素倾向：** 蚀 / 序  
**血量：** 90  
**攻击伤害：** 12  
**组合技能：** `红眼锁定` + `短突光束`  
**攻击特征：** 先短暂停滞锁定玩家，再用极短前摇的直线光束完成试探性打击；常作为其他敌人的先手视野来源。  
**设计说明：** 保留原有巡查定位，但把它纳入第一关“发现你就开始撕裂防线”的开场节奏。

**动作设计：**
- `idle`：悬浮高度轻微起伏，主镜头红眼持续扫描，底部喷口间歇喷气。
- `move`：向前平移时机体前倾，尾部微型推进器喷出短红橙焰。
- `attack`：机头红眼变亮，短暂停顿后机腹炮口闪一下再发射直线光束。
- `hit`：受击时机体抖动、红眼短暂熄灭，恢复后重新锁定。
- `death`：空中失衡旋转，冒出火花和电弧后下坠爆裂。

**攻击方式拆解：**
- `红眼锁定`：前摇是红眼从暗红切到高亮并收窄扫描角；释放时给出一条短暂瞄准线；命中前主要承担心理压迫；收招是机体轻微后仰回正。
- `短突光束`：锁定后前冲半身位，炮口瞬闪发出细直线光束；命中后伴随短火花和击退；收招极快，方便与其他杂兵联动。

**AI生成提示词：**
- 中文说明：小型悬浮巡查无人机，单红眼，高架清剿用途，圆盘与折角混合轮廓，钢铁外壳，少量暴露线缆，红橙危险灯，深色机身，透明背景，不要文字水印，不要写实感，不要 3D 感。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: small hovering scout drone. Human-defined design notes: compact steel shell, one large red sensor eye, underside light cannon, tiny rear thrusters, chipped industrial armor, exposed micro cables, hostile silhouette, red danger accent. Animation state: idle. Style constraints: crisp pixel art, readable silhouette, strong shape language, limited but expressive palette, clean clusters, no soft airbrush. Lighting: high-contrast cyberpunk rim light, subtle cyan bounce, readable on a dark industrial background. Background: transparent background. Do not include text, watermark, UI frame, photorealistic rendering, blurry pixels, extra limbs, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same scout drone, animation state: idle hover scan, body gently bobbing, red sensor eye sweeping forward, tiny thruster flicker, transparent background, crisp pixel art, no text, no watermark.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same scout drone, animation state: attack startup and beam shot, red eye fully focused, body slightly lunging forward, underside cannon flashing, clear forward attack direction, transparent background, no text, no watermark.
Hit EN: Create a 2D side-view pixel art enemy frame, 96x96, same scout drone, animation state: hit reaction, shell shaking, sparks bursting from the side, red eye flickering, readable damaged silhouette, transparent background, no text, no watermark.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same scout drone, animation state: death, spinning downward, broken shell, sparks and a small smoke burst, transparent background, no text, no watermark.
```

#### 2. 轨道啃噬者

**类别：** 普通怪 / 啃噬型 / 贴地切削单位  
**元素倾向：** 蚀  
**血量：** 108  
**攻击伤害：** 15  
**组合技能：** `贴轨潜行` + `锯口啃咬` + `碎屑回喷`  
**攻击特征：** 紧贴地面从平台边缘或裂口处突然扑出，命中后会向前喷出金属碎屑，形成短暂二段伤害。  
**设计说明：** 它是最直接的“裂口生物”，让玩家从第一关开始警惕地图下缘和边角。

**动作设计：**
- `idle`：低伏停靠，前端锯口缓慢空转，尾部支架偶尔轻抽。
- `move`：腹部滚轮或小爪高速滑动，整体近乎贴地爬行。
- `attack`：前段压低，锯口高速蓄转后猛地前蹿咬合。
- `special`：咬完抬头短喷一束碎屑，碎片呈扇形散开。
- `death`：锯口卡死、机壳翻开，内部零件外露后熄火。

**攻击方式拆解：**
- `贴轨潜行`：前摇极短，更多依赖位置差和低轮廓逼近；释放时沿地表直线贴滑；命中反馈弱但压迫感强；收招是贴地刹停。
- `锯口啃咬`：攻击前锯口加速并发出火星；扑咬命中后造成近身伤害；收招阶段嘴部略微抬起，给下一段喷屑留窗口。
- `碎屑回喷`：啃咬之后接小范围扇形喷溅，专门惩罚贴脸贪刀玩家。

**AI生成提示词：**
- 中文说明：贴地小型轨道啃噬机械，低矮，前端是锯齿切削口，背部窄壳，钢铁与磨损陶瓷混合质感，危险点缀偏红，适合 96x96，轮廓要像会从平台裂口里钻出来。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: low-profile rail gnawer crawler. Human-defined design notes: very low body, spinning saw mouth on the front, compact steel shell, tiny rear legs or rollers, scarred industrial wear, hostile red accents, designed to lurk near platform edges. Animation state: idle. Style constraints: crisp pixel art, clean clusters, readable silhouette, no soft shading. Background: transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, extra limbs, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same rail gnawer, animation state: idle low crouch, saw mouth slowly spinning, body tense and close to the ground, transparent background, no text, no watermark.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same rail gnawer, animation state: forward bite attack, body lunging low, saw mouth opened wide and spinning, sparks at the cutting edge, strong attack direction, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same rail gnawer, animation state: death, shell split open, saw jammed, loose parts spilling out, small spark burst, transparent background.
```

#### 3. 信号螨

**类别：** 普通怪 / 干扰型 / 信号寄生单位  
**元素倾向：** 蚀 / 脉  
**血量：** 96  
**攻击伤害：** 8  
**组合技能：** `紊乱电弧` + `蚀频标记`  
**攻击特征：** 单体伤害不高，但会用微弱电弧给玩家叠加标记；带标记时更容易被同场其他单位追踪。  
**设计说明：** 保留它的低威胁高烦躁定位，适合成组铺底，配合第一关其他近战怪压节奏。

**动作设计：**
- `idle`：小型漂浮姿态，核心脉冲忽明忽暗，周围触须微晃。
- `move`：像信号噪点一样快速短距抖动前移，而不是平滑飞行。
- `attack`：核心缩亮，触须向前张开，放出细短电弧。
- `special`：标记时会弹出一圈细窄信号环，然后快速收回。
- `death`：像素化闪断，中心核心炸成碎点并瞬间熄灭。

**攻击方式拆解：**
- `紊乱电弧`：前摇是核心聚光和触须展开；释放时打出短距离电弧；命中反馈偏轻，但会打乱站位节奏；收招时迅速缩回成漂浮姿态。
- `蚀频标记`：通常接在电弧后触发，释放一圈窄信号环；命中后主要提供后续追踪价值；收招短，适合成群覆盖。

**AI生成提示词：**
- 中文说明：小型漂浮寄生信号怪，像机械螨虫和故障信号结节的结合体，中心发光核心，几根细触须，红橙敌对点缀配少量青蓝杂讯，轮廓不能太像普通飞虫，要更像电子寄生物。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: tiny floating signal parasite. Human-defined design notes: glowing core, a few thin wire-like tendrils, noisy mechanical mite silhouette, hostile red-orange accents mixed with glitchy cyan sparks, lightweight floating body, industrial tech parasite vibe. Animation state: idle. Style constraints: crisp pixel art, readable silhouette, limited expressive palette, clean clusters. Background: transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, insect realism, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same signal parasite, animation state: idle hover, core pulsing softly, tendrils drifting, glitchy tiny sparks around the body, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same signal parasite, animation state: arc attack, core bright and condensed, tendrils thrust forward, short electric arc projecting ahead, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same signal parasite, animation state: death, core breaking into pixel fragments, tendrils collapsing inward, tiny glitch burst, transparent background.
```

#### 4. 输送钳爪

**类别：** 普通怪 / 搬运型 / 近距抓取单位  
**元素倾向：** 蚀  
**血量：** 132  
**攻击伤害：** 18  
**组合技能：** `夹臂展开` + `前冲钳锁` + `压碎抛投`  
**攻击特征：** 攻击前会明显展开钳臂，一旦近身抓住玩家，就会执行夹击并向前抛出，适合把人扔进断层边缘。  
**设计说明：** 让第一关的垂直地形真正参与战斗，而不只是视觉背景。

**动作设计：**
- `idle`：双钳合拢垂放，底盘轻晃，抓取液压管规律伸缩。
- `move`：底座滑轮推动前进，双钳略微抬起呈待命姿态。
- `attack`：双钳同时大张，机身前冲半步后猛力夹合。
- `special`：夹住目标后上抬、转体、向前抛掷，动作明显偏重。
- `death`：液压泄压，双钳失力下坠，机体冒出火花倾倒。

**攻击方式拆解：**
- `夹臂展开`：前摇非常明确，双臂展开给足危险提示；释放阶段本身不伤害，但制造心理压力；收招衔接前冲。
- `前冲钳锁`：机身前冲并闭合双钳，命中会造成第一段夹伤；收招不是后退，而是直接进入抬举。
- `压碎抛投`：抓取成功后完成抬举和甩投，主价值是把玩家丢进不利地形。

**AI生成提示词：**
- 中文说明：中小型搬运机械，双大型工业钳臂，滑轮底盘，液压管清楚，暗钢色主体，钳口有红橙警示漆，适合 96x96，轮廓像会把人夹住再扔出去的仓储机。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: industrial transport claw unit. Human-defined design notes: compact wheel base, two large hydraulic clamp arms, exposed hoses, dark steel body, chipped warning paint in red-orange on the claw edges, clear heavy industrial silhouette. Animation state: idle. Style constraints: crisp pixel art, strong shape language, readable clamp direction, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, extra arms, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same transport claw unit, animation state: idle, clamps lowered but tense, hoses compressed, wheels locked, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same transport claw unit, animation state: attack startup, clamps opened wide, body leaning forward, hydraulic pressure visible, clear grab direction, transparent background.
Special EN: Create a 2D side-view pixel art enemy frame, 96x96, same transport claw unit, animation state: grab-and-throw follow-through, clamps raised and body twisting forward, strong industrial force, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same transport claw unit, animation state: death, clamps collapsed, hoses ruptured, sparks and a low smoke puff, transparent background.
```

#### 5. 哨戒刺枪

**类别：** 普通怪 / 警戒型 / 长距刺突单位  
**元素倾向：** 蚀 / 序  
**血量：** 148  
**攻击伤害：** 22  
**组合技能：** `蓄压锁线` + `伸缩刺突` + `破甲回抽`  
**攻击特征：** 直线威胁明确，常守在狭长平台、门禁口和电梯井前沿；最后一段回抽会附带短暂破甲。  
**设计说明：** 它是最标准的卡位怪，教玩家理解“有些位置不是站得住的问题，而是不能站”。

**动作设计：**
- `idle`：长枪臂半收，脚架或滑轨底座稳稳钉住地面。
- `move`：移动极慢，多为短距调整站位，枪臂始终朝向前方。
- `attack`：先蓄压后枪身短抖，随后伸缩刃快速刺出。
- `special`：命中后枪刃回抽带出破甲火花，动作干净利落。
- `death`：枪臂折断，内部伸缩轨弹开，底座侧翻。

**攻击方式拆解：**
- `蓄压锁线`：前摇清楚，枪臂回缩并给出正前方威胁线；收招直接进入刺击。
- `伸缩刺突`：直线高速刺出，攻击方向非常稳定，命中后推进感强；适合守卡口。
- `破甲回抽`：刺击结束后高速回抽，附带第二段细伤害和破甲表现。

**AI生成提示词：**
- 中文说明：守门式长枪机械，细长前刺轮廓，底座稳，伸缩枪刃明显，红橙危险漆和少量蓝色电示灯，不能画成骑士或人形枪兵，要更像门禁用机械岗哨。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: gatekeeping spear sentry. Human-defined design notes: stable industrial base, long telescoping blade arm, narrow aggressive forward silhouette, dark steel body, warning red-orange stripes, small blue diagnostic light, more machine turret than humanoid soldier. Animation state: idle. Style constraints: crisp pixel art, readable attack direction, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, knight armor motifs, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same spear sentry, animation state: idle guard pose, blade half-retracted, body locked forward, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same spear sentry, animation state: thrust attack, telescoping blade fully extended forward, brief recoil in the base, clear line attack silhouette, transparent background.
Hit EN: Create a 2D side-view pixel art enemy frame, 96x96, same spear sentry, animation state: hit reaction, blade shaken aside, sparks on the rail mechanism, transparent background.
```

#### 6. 墙缝掠食蛛

**类别：** 普通怪 / 埋伏型 / 墙体裂缝单位  
**元素倾向：** 蚀  
**血量：** 118  
**攻击伤害：** 16  
**组合技能：** `裂缝潜伏` + `斜跳扑杀` + `倒钩回爬`  
**攻击特征：** 可藏在断墙裂口中，玩家靠近后会沿斜线扑出；落地后若未命中，会迅速回爬至墙面。  
**设计说明：** 让“楼体被侵入”变成可交互的战斗语言，而不是只停留在场景描述里。

**动作设计：**
- `idle`：半身藏在裂缝内，只露出前肢和红色感应器。
- `move`：沿墙面快速横爬，肢体切换清楚，身体重心始终贴墙。
- `attack`：后肢蓄力收拢，沿斜线扑向目标，落地前肢先触地。
- `special`：扑空后用倒钩肢体瞬间挂墙，快速回到高位。
- `death`：肢体松脱下坠，腹部破裂溅出机械液。

**攻击方式拆解：**
- `裂缝潜伏`：本质是埋伏状态，不出手时只提供轮廓和红点提示。
- `斜跳扑杀`：前摇是后肢收紧和感应器聚亮；释放时斜向弹跳；命中后造成扑撞伤害；收招很短。
- `倒钩回爬`：扑空才触发，快速回到墙体高位，避免被轻松反打。

**AI生成提示词：**
- 中文说明：墙缝埋伏机械蛛，轮廓尖锐，贴墙爬行，前肢像钩爪，腹部较小，红眼传感器，工业裂缝寄生感，96x96，不能画成生物写实蜘蛛。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: wall-ambush predator crawler. Human-defined design notes: sharp hooked front legs, compact abdomen, red sensor eye cluster, body designed to cling to cracked walls, mechanical parasite silhouette, steel and cable construction, not a realistic spider. Animation state: idle. Style constraints: crisp pixel art, readable wall-cling silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, organic spider realism, blurry pixels, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same wall ambush crawler, animation state: idle hiding in a wall crack, only front claws and sensor visible, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same wall ambush crawler, animation state: diagonal pounce, legs stretched forward, body springing off the wall, strong forward-down motion, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same wall ambush crawler, animation state: death, limbs splayed, shell cracked, leaking machine fluid, transparent background.
```

#### 7. 坠层搬骨者

**类别：** 普通怪 / 抛投型 / 废料回收单位  
**元素倾向：** 蚀  
**血量：** 142  
**攻击伤害：** 17  
**组合技能：** `残骸投砸` + `蚀屑爆裂`  
**攻击特征：** 抓起断砖、金属片和小型机械残骸砸向玩家，投掷物落地后会炸开细碎蚀屑。  
**设计说明：** 强化城市废墟的“所有碎片都能成为武器”这一感受。

**动作设计：**
- `idle`：低头搜捡周围残骸，机械臂不规则翻找。
- `move`：拖着一只大抓臂缓慢前行，背部废料框轻晃。
- `attack`：抓起废料后明显后摆，再朝前上方投掷。
- `special`：重型残骸落地时追加一圈蚀屑喷散表现。
- `death`：背框翻倒，捡来的碎片先一步散落在地。

**攻击方式拆解：**
- `残骸投砸`：前摇是抓举和后摆，给玩家看见抛物线意图；释放时投出大块废料；命中反馈为钝重砸击。
- `蚀屑爆裂`：废料落地或命中后裂成碎屑，补足落点区域压力；收招阶段本体会短暂低头再抓下一件东西。

**AI生成提示词：**
- 中文说明：废墟回收投掷机械，单大抓臂，背部有废料框或碎片篓，主体偏瘦长，移动拖拽感明显，工业磨损、碎砖金属片挂满身，96x96。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: debris-throwing scavenger unit. Human-defined design notes: one oversized grab arm, a scrap basket on the back, thin industrial body, dragging movement silhouette, covered in broken metal and rubble pieces, dark steel with hazard red chips. Animation state: idle. Style constraints: crisp pixel art, readable throwing silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same scavenger unit, animation state: idle scavenging, head lowered, grab arm searching through debris, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same scavenger unit, animation state: throwing attack, large arm pulled back with a chunk of rubble, body twisting for a forward toss, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same scavenger unit, animation state: death, scrap basket spilled open, broken parts scattering, transparent background.
```

#### 8. 裂脊追咬犬

**类别：** 普通怪 / 追猎型 / 失稳猎杀单位  
**元素倾向：** 蚀  
**血量：** 176  
**攻击伤害：** 21  
**组合技能：** `低伏蓄势` + `双段扑咬` + `撕裂甩尾`  
**攻击特征：** 会先压低身体短暂停顿，再连续扑击两次；贴身后用尾部锯刃补一记横扫。  
**设计说明：** 这是第一关最凶的普通追猎怪，负责把玩家从安全节奏里硬拽出来。

**动作设计：**
- `idle`：四足低伏，背脊裂缝微微亮起，尾刃不耐烦地摆动。
- `move`：奔跑时前低后高，机械犬式重心前压明显。
- `attack`：先压低停顿，再连续两次前扑，第二次张口更大。
- `special`：贴身时尾刃横甩，形成收尾横扫。
- `death`：前冲姿态失控滑倒，背脊裂缝炸开小股能量火花。

**攻击方式拆解：**
- `低伏蓄势`：前摇是全身压低和后肢蓄力，危险感强。
- `双段扑咬`：第一扑逼位，第二扑追实际站位；命中反馈偏咬碎感；收招带一点滑步。
- `撕裂甩尾`：贴身补伤技能，利用尾部锯刃完成半圆扫击，覆盖背后近身死角。

**AI生成提示词：**
- 中文说明：四足机械追猎犬，背脊有裂开的能量缝，头部更像切割口而不是生物犬嘴，尾巴带锯刃，96x96 或 128x128，强调前压冲刺感。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: aggressive quadruped pursuit hound. Human-defined design notes: low forward-heavy body, split glowing spine seam, blade-like tail, mechanical jaw shaped like a cutting maw rather than a natural dog mouth, dark steel, red hazard marks, subtle cyan energy leak in the spine. Animation state: idle. Style constraints: crisp pixel art, readable quadruped silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, realistic fur, blurry pixels, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same pursuit hound, animation state: low crouched idle, spine seam glowing faintly, tail blade twitching, transparent background.
Run EN: Create a 2D side-view pixel art enemy frame, 128x128, same pursuit hound, animation state: sprint, body stretched forward, front paws reaching, clear predatory momentum, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same pursuit hound, animation state: pounce bite attack, mouth wide, forelegs extended, spine seam brighter, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same pursuit hound, animation state: death, body sliding and collapsing, spine seam ruptured with sparks, transparent background.
```

#### 9. 井道垂索者

**类别：** 普通怪 / 垂直型 / 电梯井索降单位  
**元素倾向：** 蚀 / 脉  
**血量：** 156  
**攻击伤害：** 19  
**组合技能：** `索降突刺` + `回摆横切`  
**攻击特征：** 常从电梯井上方垂落，用直刺打先手；若落地时玩家已离开原位，会借绳索回摆补一记横切。  
**设计说明：** 用来把第一关的竖向视野做活，避免战斗始终只发生在平地。

**动作设计：**
- `idle`：悬挂在索具上缓慢摇摆，只露出下半身轮廓。
- `move`：顺着索具快速下滑，上下位移比水平位移更明显。
- `attack`：双臂合拢刀锋向下，执行一段垂降直刺。
- `special`：落地未中时借绳索回摆，横向切过玩家头部高度。
- `death`：绳索断裂，机体自由坠落并在地面摔碎。

**攻击方式拆解：**
- `索降突刺`：前摇是短暂停挂和刀锋对正；释放时直线下扎；命中反馈偏贯穿和落击混合。
- `回摆横切`：只在落空后触发，借绳索把失败攻击改成二次扫切，强化竖井压力。

**AI生成提示词：**
- 中文说明：悬索突击机械，细长人形或半人形，依附钢索，前臂是刀锋或锥刺，电梯井作战感强，轮廓要强调上下落差和回摆攻击。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: cable-drop ambusher. Human-defined design notes: slim hanging body, steel descent cable above the unit, forearms shaped as stabbing blades, elevator-shaft assault silhouette, dark metal body with red warning lights. Animation state: idle. Style constraints: crisp pixel art, clear vertical combat silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same cable-drop ambusher, animation state: hanging idle on a cable, body swaying slightly, blades pointed downward, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same cable-drop ambusher, animation state: descending stab attack, body plunging downward on the cable, blades aligned vertically, transparent background.
Special EN: Create a 2D side-view pixel art enemy frame, 96x96, same cable-drop ambusher, animation state: swing slash follow-up, body arcing sideways on the cable, one blade sweeping across, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same cable-drop ambusher, animation state: death, snapped cable, body falling apart downward, transparent background.
```

#### 10. 侵入清道夫

**类别：** 普通怪 / 支援型 / 裂解回收单位  
**元素倾向：** 蚀  
**血量：** 180  
**攻击伤害：** 20  
**组合技能：** `蚀斑喷雾` + `残体回收`  
**攻击特征：** 会朝地面喷出蚀斑，站在其中的敌人获得轻微增伤；若附近有死亡单位残骸，还会吸收碎片短暂强化自身。  
**设计说明：** 它是第一关怪群的节拍器，告诉玩家“不能慢悠悠一个个清理”。

**动作设计：**
- `idle`：头部喷嘴缓慢转动，腹部回收仓半开半闭。
- `move`：前行时喷嘴始终左右扫，像在检索可分解物。
- `attack`：喷嘴抬起，腹部鼓压后向地面喷蚀雾。
- `special`：遇到尸体时弯腰吸收碎片，背部短暂增亮。
- `death`：腹仓炸开，吸入的残片反向飞散。

**攻击方式拆解：**
- `蚀斑喷雾`：前摇清楚，喷嘴对地；释放时生成地面增伤区；命中反馈以持续性环境压力为主。
- `残体回收`：拾取附近残骸完成自强化，不是主动伤害技能，但会改变战斗优先级。

**AI生成提示词：**
- 中文说明：支援型回收机械，细长喷嘴头部，腹部回收仓，移动时像在清理和喷洒腐蚀剂，红橙警示光，暗色工业机身，96x96。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: corrosive cleanup support unit. Human-defined design notes: narrow spray nozzle head, small recovery chamber in the belly, scavenger-support machine silhouette, dark industrial shell, red-orange warning lights, subtle cyan status lights, designed to spray corrosive patches and absorb remains. Animation state: idle. Style constraints: crisp pixel art, readable nozzle silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same cleanup support unit, animation state: idle scan, spray nozzle moving slowly, belly chamber half open, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same cleanup support unit, animation state: corrosive spray attack, nozzle angled downward, body pressurized and venting forward, transparent background.
Special EN: Create a 2D side-view pixel art enemy frame, 96x96, same cleanup support unit, animation state: corpse recovery, body bent over, chamber glowing brighter while absorbing fragments, transparent background.
```

### 精英怪 5 个

#### 1. 镇暴机架

**类别：** 精英怪 / 镇暴型 / 近距压制单位  
**元素倾向：** 蚀 / 序  
**血量：** 260  
**攻击伤害：** 48  
**组合技能：** `装甲前压` + `高压重击` + `反震顶退`  
**攻击特征：** 以厚重前压维持压制，重击命中后会将玩家顶向身后墙体或平台边缘。  
**设计说明：** 保留原型怪定位，但数值和技能组合提升到正式版开场精英标准。

**动作设计：**
- `idle`：重型站姿极稳，前装甲板微开合，肩部警示灯慢闪。
- `move`：以稳定重步前进，躯干几乎不摇，脚步压地感很重。
- `attack`：先沉肩蓄力，再用整块前装甲或重拳向前砸压。
- `hit`：受击只出现短顿和轻晃，不会夸张后退。
- `death`：关节失压跪倒，前装甲砸地后爆出电弧。

**攻击方式拆解：**
- `装甲前压`：持续推线技能，前摇很短，主要用身体占空间。
- `高压重击`：沉肩蓄力后砸出大伤动作；命中反馈偏冲击波和钝击。
- `反震顶退`：重击之后带一段上抬顶推，专门把玩家往不利位置送。

**AI生成提示词：**
- 中文说明：重型镇暴机体，短粗厚重，前装甲非常大，双臂短但有冲撞力，工业警戒红灯，整体像压人而不是切人的机器，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: heavy riot suppression frame. Human-defined design notes: massive front armor plate, compact heavy legs, short crushing arms, thick industrial body, red warning lights, dark steel and ceramic armor, silhouette built for forward pressure rather than speed. Animation state: idle. Style constraints: crisp pixel art, heavy readable silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same riot suppression frame, animation state: idle heavy guard, front armor raised, warning lights pulsing, transparent background.
Walk EN: Create a 2D side-view pixel art enemy frame, 128x128, same riot suppression frame, animation state: heavy forward march, body leaning in, weighty planted steps, transparent background.
HeavyAttack EN: Create a 2D side-view pixel art enemy frame, 128x128, same riot suppression frame, animation state: heavy slam attack, shoulder dropped, one crushing arm or armor plate swinging down, clear impact direction, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same riot suppression frame, animation state: death, knees buckling, armor cracked, sparks bursting from joints, transparent background.
```

#### 2. 脉冲禁卫

**类别：** 精英怪 / 管制型 / 封锁压杀单位  
**元素倾向：** 蚀 / 序  
**血量：** 308  
**攻击伤害：** 56  
**组合技能：** `定向脉冲` + `前踏封路` + `近距重击`  
**攻击特征：** 先用脉冲打乱节奏，再前踏切断逃生路线，最后以重锤式近击完成处决。  
**设计说明：** 第一关里它更偏“半控制半压杀”，为后续第二关真正的脉系精英留出层级差。

**动作设计：**
- `idle`：立姿端正，背后脉冲线圈低亮循环，像在计算。
- `move`：步幅不快，但每一步都带轻微线圈闪光。
- `attack`：先举起一侧发射臂释放脉冲，再前踏并转为近战重击。
- `special`：封路动作不是跳扑，而是沉稳地向前落步压住空间。
- `death`：线圈过载，胸腔和背部同时炸出蓝白火花。

**攻击方式拆解：**
- `定向脉冲`：前摇是发射臂抬起和线圈蓄亮；释放扇形或窄向脉冲，主打节奏打断。
- `前踏封路`：脉冲后立即落步向前，占住玩家退路，是组合中的站位技。
- `近距重击`：封住路后补重击，完成整套压杀。

**AI生成提示词：**
- 中文说明：秩序感强的封锁型机械禁卫，人形但更像治安装置，背部脉冲线圈，手臂可发射脉冲，深色机身、红橙警告灯、少量蓝白脉冲光，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: pulse-enforced control guard. Human-defined design notes: disciplined humanoid machine, back-mounted pulse coils, one arm configured as a pulse emitter, one heavy striking arm, dark armor, red warning lights, blue-white pulse glow. Animation state: idle. Style constraints: crisp pixel art, strict readable silhouette, strong shape language, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same control guard, animation state: rigid idle stance, back coils softly glowing, arm held ready, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same control guard, animation state: pulse discharge startup, emitter arm raised, coil light intensified, clear forward control attack, transparent background.
HeavyAttack EN: Create a 2D side-view pixel art enemy frame, 128x128, same control guard, animation state: close-range heavy strike, body stepping in with disciplined force, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same control guard, animation state: death, pulse coils overloading and bursting with blue-white sparks, transparent background.
```

#### 3. 熔炉三头犬

**类别：** 精英怪 / 追猎型 / 工业裂刃单位  
**元素倾向：** 蚀  
**血量：** 346  
**攻击伤害：** 62  
**组合技能：** `灼热扑杀` + `裂刃甩头` + `追尾啃断`  
**攻击特征：** 速度快于其他第一关精英，会连续扑进并衔接短距横扫，极适合在狭窄通道里追压。  
**设计说明：** 它是第一关最典型的“让你没法安心后撤”的精英。

**动作设计：**
- `idle`：三头或三重前端传感器轮流微动，背部热缝持续发红。
- `run`：爆发式四足冲刺，前端头部群像分层前探。
- `attack`：高扑、咬合、甩头三段连成一线，动作极具撕裂感。
- `special`：追尾啃断会在玩家背后小幅转身补咬。
- `death`：头部模块失序，热缝熄灭后整体横倒。

**攻击方式拆解：**
- `灼热扑杀`：前摇不长，但热缝明显增亮；释放时全身向前跃出；命中有强冲撞感。
- `裂刃甩头`：落地后立刻横甩头部切刃，补足正面横向压力。
- `追尾啃断`：玩家从侧后脱离时触发，用来维持连续追压。

**AI生成提示词：**
- 中文说明：工业猎杀三头犬，三头可以是三组头部模块或三向传感器口，背部高温裂缝，四足，危险感强，体型比普通犬更厚更重，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: foundry pursuit hound elite. Human-defined design notes: quadruped body, triple-head or triple-sensor front cluster, hot glowing seams along the spine, industrial blade teeth, heavy but fast silhouette, dark steel with furnace-red heat. Animation state: idle. Style constraints: crisp pixel art, strong predatory silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, realistic fur, blurry pixels, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same foundry pursuit hound, animation state: tense idle, triple front cluster shifting, heat seams glowing dim red, transparent background.
Run EN: Create a 2D side-view pixel art enemy frame, 128x128, same foundry pursuit hound, animation state: full sprint, body stretched forward, aggressive weight transfer, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same foundry pursuit hound, animation state: pounce and bite attack, all front heads or sensors driving forward, heat seams bright, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same foundry pursuit hound, animation state: death collapse, head cluster broken, heat seams cooling and sparking out, transparent background.
```

#### 4. 断层刽子塔

**类别：** 精英怪 / 据点型 / 断层压落单位  
**元素倾向：** 蚀 / 序  
**血量：** 384  
**攻击伤害：** 68  
**组合技能：** `坠块召落` + `扇形切钢` + `井口震波`  
**攻击特征：** 固守在大型断层平台附近，会召落楼体碎块压缩站位；玩家贴近后则用大范围切钢臂横扫。  
**设计说明：** 这只精英把第一关的“建筑在攻击你”具体化了。

**动作设计：**
- `idle`：立柱式主体固定在平台边，顶部感应头缓慢转向。
- `attack`：上半部先仰起召落碎块，近身时再把巨大切钢臂横甩。
- `special`：脚下震波来自底座重踏或插桩动作。
- `hit`：被打时只是局部碎裂，不会整体后退。
- `death`：立柱失稳倾塌，顶部砸落并掀起碎石。

**攻击方式拆解：**
- `坠块召落`：前摇是顶部核心上仰和红光锁定；释放后上方落石压区；命中反馈偏环境重压。
- `扇形切钢`：玩家贴近后横扫切钢臂，攻击范围大，收招相对慢。
- `井口震波`：站桩防贴脸技能，底座重击地面产生低平震波。

**AI生成提示词：**
- 中文说明：半固定据点机械，像断层边缘的处刑塔，立柱底座，顶部感应头，一只巨大切钢臂，可召落建筑碎块，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: fracture execution tower elite. Human-defined design notes: semi-stationary pillar base, one giant steel-cutting arm, top sensor head, built to guard broken platform edges, dark industrial metal, warning red lights, rubble-control machine silhouette. Animation state: idle. Style constraints: crisp pixel art, readable tower silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same execution tower, animation state: rigid idle guard, top sensor scanning, arm folded but threatening, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same execution tower, animation state: wide steel-arm sweep attack, body anchored, giant arm cutting across the front, transparent background.
Special EN: Create a 2D side-view pixel art enemy frame, 128x128, same execution tower, animation state: rubble-drop targeting, top core raised and glowing, arm braced, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same execution tower, animation state: collapse, pillar body tipping over, debris and sparks falling, transparent background.
```

#### 5. 孵巢裂母

**类别：** 精英怪 / 增殖型 / 小型寄生母体  
**元素倾向：** 蚀  
**血量：** 420  
**攻击伤害：** 60  
**组合技能：** `幼体泼洒` + `蚀液喷束` + `受伤狂孵`  
**攻击特征：** 本体并不算快，但会持续孵出低血量幼体；血量降到半数后孵化频率明显提升。  
**设计说明：** 它是第一关 Boss 的前置预演，用来让玩家提前适应虫群扩散压力。

**动作设计：**
- `idle`：腹腔鼓动明显，背部孵囊像呼吸一样收缩。
- `move`：身体缓慢蠕动，侧肢拖动腹部前行。
- `attack`：腹腔裂开向前泼出幼体，随后喷一束蚀液补压制。
- `special`：受伤到半血后动作明显急促，孵囊收缩频率更快。
- `death`：腹腔彻底爆裂，未成熟幼体和残液一并喷散。

**攻击方式拆解：**
- `幼体泼洒`：前摇是腹腔鼓起和背囊收紧；释放时向前中距泼出数只幼体；收招慢，利于玩家反打。
- `蚀液喷束`：通常接在泼洒后，用来封住靠近路线。
- `受伤狂孵`：被动强化，不额外造成瞬时伤害，但大幅提高场面复杂度。

**AI生成提示词：**
- 中文说明：中型寄生母体机械，腹腔很大，背部孵囊和缝合钢板清楚，整体像楼体病灶的移动节点，既恶心又机械，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: brood-spawning parasite elite. Human-defined design notes: swollen belly chamber, multiple incubation sacs on the back, stitched steel plates, mechanical parasite mother silhouette, leaking acidic tubes, red danger lights, dark industrial shell. Animation state: idle. Style constraints: crisp pixel art, readable grotesque machine silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same brood-spawning parasite, animation state: idle breathing pulse, belly swollen, sacs rhythmically contracting, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same brood-spawning parasite, animation state: spawn attack, belly split open and throwing out small larvae, transparent background.
Special EN: Create a 2D side-view pixel art enemy frame, 128x128, same brood-spawning parasite, animation state: frenzy, sacs tightened, body agitated, more dangerous breeding posture, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same brood-spawning parasite, animation state: death, belly ruptured wide, larvae and acidic fluid spilling out, transparent background.
```

### Boss 1 个

#### 机械蜱虫之母

**类别：** Boss / 寄生母体 / 楼体深层增殖单位  
**元素倾向：** 蚀为主，辅以脉  
**总血量：** 820  
**单次重击伤害：** 62 - 108  
**核心机制：** `虫群扩散`、`断层压迫`、`孵化失控`

**阶段设计：**

- **一阶段：深层蠕动**
  Boss 以本体缓慢逼近玩家，使用 `短距扑砸`、`虫巢泼洒` 与 `井口喷酸` 制造平台压迫，重点测试玩家在狭窄地形中的绕位能力。
- **二阶段：巢体裂开**
  背部和腹腔孵化囊大面积炸裂，战场开始持续生成幼体；Boss 会在平台边缘进行 `横向碾冲`，逼迫玩家频繁越过断层与竖井。
- **三阶段：失控增殖**
  场景局部开始塌落，Boss 进入高攻击欲望状态，轮流释放 `双臂扑砸`、`蚀液扫喷`、`虫潮坠井`；血量越低，幼体刷新越快。

**战斗表现：**

- 腹腔孵化区是主要弱点，受击时会短暂暴露内部脉冲核心。
- 每损失 `25%` 血量，Boss 会震落一次场景碎片，改变站位空间。
- 若场上幼体积累过多，Boss 会进入短暂强化，获得更高扑杀频率。

**掉落：** 必定掉落 `机械双臂`、大型经验碎片、蚀系核心素材  

**叙事说明：**  
机械蜱虫之母原本埋设在居民楼深层维护系统之中，是负责回收废弃管线、过滤生物残渣并批量孵化维修虫的寄生中枢。灾变之后，它的底层逻辑彻底失控，不再区分建筑垃圾、机械构件与活体组织，而是将一切靠近电梯井、断层平台与废弃通道的目标统一判定为“可分解资源”。它盘踞在楼体最阴湿的深处，像一处不断自行增殖的建筑病灶。玩家从它身上夺得机械双臂，也意味着第一次把“侵入系统的破坏力”真正装到了自己身上。

**动作设计：**
- `idle`：巨大腹腔和背部孵囊持续鼓动，前肢缓慢拨动地面碎块，整体像在呼吸。
- `core_loop`：身体并不快，但会用前肢拖动庞大腹部缓慢前压，移动时地面碎屑被推开。
- `phase_transition`：孵囊从闭合鼓包进入大面积裂开，内部蓝白脉冲核心与幼体轮廓同时暴露。
- `signature_attack`：大扑砸、横向碾冲、腹喷蚀液和虫潮抛撒都是以整躯干重压为主的攻击。
- `weakpoint_expose`：腹腔撑开、背囊裂出缝隙时，弱点明显发光且伴随高频颤动。
- `hit`：受击后会出现整躯干抽搐、幼体洒落和短暂后仰，而不是灵活闪避。
- `death`：腹腔完全崩裂，孵囊连锁爆开，巨体失压坍塌。

**攻击方式拆解：**
- `短距扑砸`：前摇是前肢抬起和上身后仰，释放时整个前半身砸下；命中反馈重且伴随落地震动；收招慢。
- `虫巢泼洒`：腹腔收缩到极限后向前泼撒幼体，主打场面增殖；命中反馈更多是战场复杂化。
- `井口喷酸`：头部或腹部喷口横扫地面，制造持续危险线；收招后会留短暂喘息。
- `横向碾冲`：身体先扭向一侧再沿平台边缘横压过去，专门逼玩家跨越断层。
- `双臂扑砸`：三阶段高欲望技，双臂抬高后连续落击，中间夹杂弱点暴露。
- `虫潮坠井`：从上方或后背抛洒幼体进井口区域，强化竖向压迫。

**AI生成提示词：**
- 中文说明：超大型寄生母体 Boss，192x192，轮廓像腐坏子宫和工业机械的融合，腹腔巨大，背部多组孵囊，前肢粗大，内部可见蓝白脉冲核心，红橙警示污光混合青蓝脉冲光，不能画成纯生物或纯坦克。
```text
Base EN: Create a 2D side-view pixel art boss concept frame for a cyberpunk machine-crisis action game. Canvas target: 192x192. Boss role: parasite mother hidden in the deep layers of a ruined tower. Human-defined design notes: enormous swollen belly chamber, multiple incubation sacs on the back, two heavy front crushing limbs, visible blue-white pulse core inside the abdomen, decayed industrial shell, stitched cables, hostile red-orange warning glow, grotesque machine-womb silhouette. Readability: large readable silhouette, visible weak point, clear frontal attack parts, strong contrast against a dark ruined-building background. Mood: intimidating industrial parasite, premium demo showcase quality. Output: single pixel art concept frame, transparent background, no text, no watermark.
Idle EN: Create a 2D side-view pixel art boss frame, 192x192, same parasite mother, animation state: idle breathing loop, sacs pulsing, heavy forelimbs planted, weak point faintly visible through the abdomen, transparent background.
PhaseTransition EN: Create a 2D side-view pixel art boss frame, 192x192, same parasite mother, animation state: phase transition, back sacs rupturing open, larvae silhouettes and pulse core exposed, body convulsing, transparent background.
SignatureAttack EN: Create a 2D side-view pixel art boss frame, 192x192, same parasite mother, animation state: crushing pounce attack, upper body lifted and dropping forward, forelimbs spread, belly mass driving the motion, transparent background.
Death EN: Create a 2D side-view pixel art boss frame, 192x192, same parasite mother, animation state: death collapse, belly burst open, sacs exploding, huge body slumping downward with sparks and fluid, transparent background.
```

---

## 第二关：重力实验室

本关对应元素 `脉`，核心体验是高速传导、异常重力、频闪位移与实验设施失控。以下数值按高数值中段版本编写，默认玩家已完成第一关、装配第一件 Boss 部件并进行过一轮残念强化。

### 关卡数值基准

- 普通怪血量建议区间：`110 - 195`
- 精英怪血量建议区间：`320 - 480`
- Boss 总血量建议：`860 - 930`
- 本关常见异常：`脉冲印记`、`失重浮空`、`磁轨感电`

### 普通怪 10 个

#### 1. 相位针蜂

**类别：** 普通怪 / 侦察型 / 高频突刺单位  
**元素倾向：** 脉  
**血量：** 110  
**攻击伤害：** 18  
**组合技能：** `锁定红线` + `三连针突` + `回折电针`  
**攻击特征：** 先在空中画出红色轨线，再进行短距三连冲刺；若冲刺落空，会回身抛出一束折返电针封走位。  
**设计说明：** 借鉴高速前线骚扰怪的“先标记、再突脸”逻辑，用来迫使玩家提前交位移。

**动作设计：**
- `idle`：细长蜂体悬停，尾部针枪微微振颤，红线瞄准器断续闪烁。
- `move`：高速短距离位移，停和冲之间切换很突然。
- `attack`：尾针向前拉直，机体先锁线再打出连续穿刺。
- `special`：掠过目标后回身甩出一串折返电针。
- `death`：飞行失衡、针体弯折、拖着火星坠落。

**攻击方式拆解：**
- `锁定红线`：前摇是机身定住和红线拉出；主要提供读招。
- `三连针突`：锁定完成后连续三次短突，每次之间停顿极短；主打位移压力。
- `回折电针`：突进落空后补远程折返针，防止玩家靠简单后撤应对。

**AI生成提示词：**
- 中文说明：高速悬浮针蜂机械，细长、尖锐、尾部像穿刺针炮，红线锁定组件明显，青蓝边缘补光，96x96，轮廓要快、轻、狠。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: high-speed phase stinger drone. Human-defined design notes: narrow hovering body, long rear stinger cannon, red targeting line projector, sharp aggressive silhouette, dark alloy shell, cyan edge light, built for fast thrust attacks. Animation state: idle. Style constraints: crisp pixel art, readable fast silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels, isometric view.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same phase stinger drone, animation state: idle hover, stinger trembling, targeting light flickering, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same phase stinger drone, animation state: thrust attack, body elongated forward, stinger aligned like a needle, clear burst motion, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same phase stinger drone, animation state: death, body bent and falling with sparks, transparent background.
```

#### 2. 失重标本臂

**类别：** 普通怪 / 捕获型 / 浮游残肢单位  
**元素倾向：** 脉  
**血量：** 124  
**攻击伤害：** 22  
**组合技能：** `磁握拖拽` + `旋抛重砸`  
**攻击特征：** 从培养槽或天花轨道中漂出，先以磁场抓取玩家，再将其甩向地面或墙体。  
**设计说明：** 让实验残骸本身具备敌意，强化第二关“你可能也是标本之一”的身份裂痕。

**动作设计：**
- `idle`：断臂在空中缓慢漂浮，手指关节偶尔抽动。
- `move`：靠磁场牵引漂移，动作像失控标本而非正常敌兵。
- `attack`：五指张开吸附，抓住目标后绕身旋转再朝地面甩砸。
- `hit`：被击中时手指张力失衡，短暂抽搐。
- `death`：磁场熄灭，断臂像无重量垃圾一样缓慢坠落。

**攻击方式拆解：**
- `磁握拖拽`：前摇是手掌朝向玩家和掌心光环亮起；释放拖拽力，主要改变站位。
- `旋抛重砸`：抓取成功后旋身积蓄角速度，再重重甩向地面或墙面，形成强反馈。

**AI生成提示词：**
- 中文说明：浮游机械断臂标本，手掌巨大，指节清晰，掌心有磁场核心，实验残骸感强，96x96，既像人体义肢又像实验失败物。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: floating specimen arm capture unit. Human-defined design notes: severed mechanical arm silhouette, large grasping hand, visible finger joints, magnetic core in the palm, lab specimen vibe, exposed wiring and broken graft points, cyan magnetic glow, hostile red markers. Animation state: idle. Style constraints: crisp pixel art, readable floating limb silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same floating specimen arm, animation state: eerie idle hover, fingers twitching slightly, palm core dimly glowing, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same floating specimen arm, animation state: grab attack, fingers spread wide, palm magnet core bright, reaching forward aggressively, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same floating specimen arm, animation state: death, magnetic energy gone, fingers limp, arm falling apart, transparent background.
```

#### 3. 脉冲折返球

**类别：** 普通怪 / 炮台型 / 反弹射线单位  
**元素倾向：** 脉  
**血量：** 118  
**攻击伤害：** 19  
**组合技能：** `折返脉冲` + `延时爆闪`  
**攻击特征：** 发射可在墙面反弹两次的脉冲球，命中地形后延迟爆闪，对近身玩家造成二次伤害。  
**设计说明：** 负责把实验室的狭窄廊道变成几何弹幕区，提升空间阅读压力。

**动作设计：**
- `idle`：球形主体轻微旋转，表面导线纹不断换向。
- `move`：本体位移少，更多像浮游炮台缓慢调整角度。
- `attack`：表面裂开一圈发射缝，内部核心短亮后弹出脉冲球。
- `special`：落点延迟爆闪时，机体会再次亮起与弹体共振。
- `death`：外壳向外翻裂，内部晶核崩碎成小片。

**攻击方式拆解：**
- `折返脉冲`：前摇是发射缝展开；释放后弹体可撞墙折返，主打地图几何压力。
- `延时爆闪`：弹体不立刻结束，而是在停顿后爆闪，惩罚靠近观察者。

**AI生成提示词：**
- 中文说明：球形浮游炮台，表面有发射裂缝和导电纹路，内部发光核心，青蓝脉冲光明显，危险提示偏红，96x96。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: rebound pulse orb turret. Human-defined design notes: floating sphere body, opening emitter seams, glowing internal core, electric conduit lines on the shell, blue pulse glow and small red warning markers, compact but threatening artillery silhouette. Animation state: idle. Style constraints: crisp pixel art, readable orb silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same pulse orb turret, animation state: idle hover, shell slowly rotating, core dimly glowing through the seams, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same pulse orb turret, animation state: firing, shell seams opened, core flaring, a pulse orb being launched forward, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same pulse orb turret, animation state: death, shell cracked open, core exploding into fragments, transparent background.
```

#### 4. 轨相步兵

**类别：** 普通怪 / 近战型 / 实验安保单位  
**元素倾向：** 脉 / 序  
**血量：** 152  
**攻击伤害：** 26  
**组合技能：** `滑轨突进` + `双棍连打` + `上挑电击`  
**攻击特征：** 依附地面磁轨快速滑行，贴脸后以双棍连段压制，最后一击会附带短暂浮空。  
**设计说明：** 这是本关最标准的近战节奏怪，用于承接远程单位制造出的空档。

**动作设计：**
- `idle`：双棍收在身侧，脚下磁轨靴偶尔闪一下。
- `run`：脚不完全离地，沿磁轨低姿滑行，肩线稳定。
- `attack`：两棍短促连续连打，最后一击带明显上挑动作。
- `hit`：受击会横移半步，但很快重新站稳。
- `death`：磁轨靴失火花，身形前冲过头后扑倒。

**攻击方式拆解：**
- `滑轨突进`：前摇少，靠路线预判而非大动作预警。
- `双棍连打`：贴脸后快速两到三下击打，主要压制翻滚节奏。
- `上挑电击`：终结一击把目标挑起或打出短浮空，给其他脉系怪接压。

**AI生成提示词：**
- 中文说明：实验室安保步兵，双短棍，脚下磁轨滑行装置明显，体型利落，深色制服甲片配青蓝电线，96x96。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: rail-phase security infantry. Human-defined design notes: lean humanoid machine guard, twin short batons, magnetic rail skates on the feet, dark lab-security armor, cyan electric accents, disciplined forward combat silhouette. Animation state: idle. Style constraints: crisp pixel art, readable melee silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same security infantry, animation state: ready idle, twin batons lowered but active, rail skates glowing faintly, transparent background.
Run EN: Create a 2D side-view pixel art enemy frame, 96x96, same security infantry, animation state: low rail glide run, body leaning forward, feet barely above the track, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same security infantry, animation state: baton combo strike, one baton extended, torso twisted into the hit, transparent background.
```

#### 5. 磁轨切片机

**类别：** 普通怪 / 斩击型 / 墙轨维护单位  
**元素倾向：** 脉  
**血量：** 144  
**攻击伤害：** 28  
**组合技能：** `贴壁移轨` + `十字切线`  
**攻击特征：** 可沿墙面与天花板快速移动，锁定玩家后切出十字型脉冲刃，专门针对跳跃和墙边停留。  
**设计说明：** 用来打击只会横向闪避的玩家，逼迫其处理垂直威胁。

**动作设计：**
- `idle`：吸附在墙轨上，切刃收折在机壳两侧。
- `move`：沿墙和天花高速切换吸附点，像维修机一样滑动。
- `attack`：机体短停，四向切刃同时展开，瞬间切出十字斩线。
- `special`：打完后立即吸回墙面，重新回到上方压迫位。
- `death`：吸附失效，刃片弹开，机体翻滚坠下。

**攻击方式拆解：**
- `贴壁移轨`：本身不伤害，但负责建立空间错位。
- `十字切线`：展开四向刃，在玩家所在高度或墙边给出十字交叉，专门克制跳跃和贴墙。

**AI生成提示词：**
- 中文说明：墙体轨道切割机械，机身扁平，四向折叠刀片，像维护机被武装化，适合 96x96，姿态要能明显吸附在墙或天花。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: wall-rail slicer unit. Human-defined design notes: flat magnetic body, four foldable blade fins, maintenance-machine silhouette weaponized for combat, built to cling to walls and ceilings, cyan power lines, red warning lights. Animation state: idle. Style constraints: crisp pixel art, readable wall-mounted silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same wall-rail slicer, animation state: idle cling on a wall, blade fins folded, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same wall-rail slicer, animation state: cross-line slash attack, blade fins unfolded in a cross pattern, body braced against the wall, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same wall-rail slicer, animation state: death, magnetic grip failed, blades loose, body falling away from the wall, transparent background.
```

#### 6. 引潮采样者

**类别：** 普通怪 / 干扰型 / 重力采样单位  
**元素倾向：** 脉  
**血量：** 122  
**攻击伤害：** 16  
**组合技能：** `引力牵引` + `采样针雨`  
**攻击特征：** 先在玩家脚下生成微型牵引场，拖慢移动后再投射细密采样针。  
**设计说明：** 属于低伤高控制单位，本体不强，但和高速怪搭配时会非常恶心。

**动作设计：**
- `idle`：采样臂围绕主体缓慢转圈，底部引力圈忽隐忽现。
- `move`：浮游侧移，更多是重新校准角度。
- `attack`：先压低主体投下引力场，再抬起采样臂抛撒针雨。
- `hit`：外壳轻晃，采样臂节奏被打断。
- `death`：采样臂散开，底部引力圈闪灭。

**攻击方式拆解：**
- `引力牵引`：前摇是底部圈体亮起；释放拖慢和拉扯效果，主要服务队友。
- `采样针雨`：在目标站位被固定后进行细针覆盖，命中反馈更多是密集感和烦躁感。

**AI生成提示词：**
- 中文说明：重力采样浮游机械，底部有引力环，顶部或侧面有细长采样臂，实验室设备感强，96x96，青蓝引力光为主。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: gravity sampling support unit. Human-defined design notes: floating lab device, circular gravity emitter underneath, thin sampling arms above, cyan-blue gravity glow, clean experimental machinery silhouette, small red hazard markers. Animation state: idle. Style constraints: crisp pixel art, readable support silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same gravity sampling unit, animation state: idle hover, bottom gravity ring pulsing, sampling arms rotating slowly, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same gravity sampling unit, animation state: gravity trap attack, lower ring bright, body lowered as if projecting a pull field, transparent background.
Special EN: Create a 2D side-view pixel art enemy frame, 96x96, same gravity sampling unit, animation state: needle rain follow-up, slim sampling arms opened and firing downward, transparent background.
```

#### 7. 裂相镜奴

**类别：** 普通怪 / 幻像型 / 镜面复制单位  
**元素倾向：** 脉 / 蚀  
**血量：** 136  
**攻击伤害：** 23  
**组合技能：** `短距闪现` + `镜像残击` + `延迟回身斩`  
**攻击特征：** 会先留下一个镜像吸引玩家出招，再从另一侧闪现出刀，形成明显的错位打击。  
**设计说明：** 借用分身误导思路，但叙事上解释为实验室镜面采样系统的畸变产物。

**动作设计：**
- `idle`：本体和淡残影轻微错位重叠，给人不稳定双像感。
- `move`：移动不是跑而是短闪和残影拖尾。
- `attack`：先留下镜像站位，本体再从侧后方切入挥斩。
- `special`：第一刀后短暂停顿，再从相反方向补回身斩。
- `death`：本体与镜像同时碎成镜片和噪点。

**攻击方式拆解：**
- `短距闪现`：前摇非常短，但通常会先给残像提示。
- `镜像残击`：镜像站位是误导，本体从另一侧发起第一刀。
- `延迟回身斩`：第一刀后补一记反向斩，专打条件反射式闪避。

**AI生成提示词：**
- 中文说明：镜面复制型实验怪，接近人形但轮廓像半透明采样体，本体与残影重叠，边缘带镜裂和噪点，96x96，危险色以红为主、辅以冷白反光。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: mirror-copy phase attacker. Human-defined design notes: slim humanoid experiment silhouette, partial transparent mirror duplicate overlapping the body, fractured reflective edges, glitch fragments, one sharp melee arm, red threat accents with cold white reflections. Animation state: idle. Style constraints: crisp pixel art, readable split silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same mirror-copy attacker, animation state: idle with offset afterimage, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same mirror-copy attacker, animation state: side slash attack after a short blink, real body separated from a fake image, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same mirror-copy attacker, animation state: death, body and afterimage shattering into mirror shards and glitch pixels, transparent background.
```

#### 8. 悬井坠锤

**类别：** 普通怪 / 重击型 / 井道压杀单位  
**元素倾向：** 脉  
**血量：** 178  
**攻击伤害：** 34  
**组合技能：** `上吸预警` + `垂直坠砸` + `环形脉震`  
**攻击特征：** 会先把玩家微微向上吸起，再从高处砸落；命中地面后释放一圈脉震波。  
**设计说明：** 强化竖井空间的压迫感，是本关最能体现失重和重力报复的普通怪。

**动作设计：**
- `idle`：巨锤主体悬在井道上方，底部推进器维持位置。
- `move`：上下浮动明显，水平漂移少，像在寻找垂直处决角度。
- `attack`：先底部引力口亮起上吸，再把整个锤体抬高后急速下砸。
- `special`：落地瞬间释放一圈扁平脉震。
- `death`：推进器失效，锤体失控斜砸在地。

**攻击方式拆解：**
- `上吸预警`：前摇明确，给玩家看见引力圈和轻微上浮。
- `垂直坠砸`：主杀伤动作，上提后高速下落；命中反馈是重击和落地爆点。
- `环形脉震`：下砸后补地面环波，逼玩家不能只靠贴边躲正下方。

**AI生成提示词：**
- 中文说明：悬浮重锤机械，垂直处决装置，底部引力口，体型笨重，井道执行器风格，128x128，蓝白引力光配红橙警戒灯。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: suspended shaft hammer execution unit. Human-defined design notes: large floating hammer body, downward gravity emitter, heavy industrial silhouette, built for vertical crush attacks in elevator shafts, blue-white gravity glow, red warning lights. Animation state: idle. Style constraints: crisp pixel art, readable heavy silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same suspended hammer unit, animation state: idle hover high above the ground, gravity emitter dim, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same suspended hammer unit, animation state: vertical slam attack, body raised then dropping hard, gravity emitter bright, transparent background.
Special EN: Create a 2D side-view pixel art enemy frame, 128x128, same suspended hammer unit, animation state: impact pulse, body at the ground with a circular energy shock pose, transparent background.
```

#### 9. 涡核幼体

**类别：** 普通怪 / 变体型 / 能量孵化单位  
**元素倾向：** 脉  
**血量：** 114  
**攻击伤害：** 15  
**组合技能：** `贴身自爆` + `分裂残核`  
**攻击特征：** 靠近玩家后会自爆，死亡后裂成两枚小残核继续追击。  
**设计说明：** 吸收了自爆与二段骚扰的设计优点，适合和牵引、封路单位联动。

**动作设计：**
- `idle`：核心像未稳定的能量胚体一样膨胀收缩。
- `move`：滚或浮都不稳定，带一点摇摆和失控感。
- `attack`：靠近后短暂停顿，自身亮度急升再爆开。
- `special`：大体爆后分裂出两枚更小的残核继续冲。
- `death`：残核则是更干脆的瞬闪小爆。

**攻击方式拆解：**
- `贴身自爆`：前摇极短，核心颜色从蓝白切到过曝白；释放即爆。
- `分裂残核`：主爆不是终点，落地后的两枚残核继续追逐，确保战场压力延续。

**AI生成提示词：**
- 中文说明：不稳定能量幼体，像半机械半能量的实验胚球，主体发光，外壳很少，96x96，适合做会爆裂并分裂的小怪。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: unstable energy larva. Human-defined design notes: half-mechanical half-energy embryonic orb, glowing exposed core, minimal shell fragments around it, unstable pulse lines, small aggressive silhouette. Animation state: idle. Style constraints: crisp pixel art, readable glowing shape, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same energy larva, animation state: idle unstable pulse, core swelling and contracting, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same energy larva, animation state: self-destruct startup, body over-bright, shell fragments lifting away, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same energy larva, animation state: split burst, core exploding into two smaller remnants, transparent background.
```

#### 10. 校频观察者

**类别：** 普通怪 / 支援型 / 频率标记单位  
**元素倾向：** 脉 / 序  
**血量：** 195  
**攻击伤害：** 20  
**组合技能：** `频率标记` + `落雷校正`  
**攻击特征：** 本体火力不高，但会给玩家叠加频率标记；标记层数足够时，从上方降下锁定雷束。  
**设计说明：** 它是第二关怪群的指挥官杂兵，优先级极高。

**动作设计：**
- `idle`：主镜面和环形天线轻转，像在不断重新校频。
- `move`：缓慢漂浮换位，本体不急，但观察姿态很稳定。
- `attack`：先抬升天线进行频率锁定，再投下自上而下的校正雷束。
- `special`：层数满时，顶部核心长亮，表示即将判定落雷。
- `death`：环形天线崩裂，本体从中间烧穿。

**攻击方式拆解：**
- `频率标记`：前摇是天线张开和环灯亮起；命中本身伤害低，但重要性高。
- `落雷校正`：标记叠到阈值后触发，从上方向下校正打击，命中反馈更像精确惩罚。

**AI生成提示词：**
- 中文说明：观察者型支援机械，环形天线、镜面感应头、垂直落雷装置，轮廓稳重，偏实验中枢附属机，96x96。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: frequency calibration observer. Human-defined design notes: floating support machine, ring antenna, sensor mirror head, vertical strike calibration device, stable analytical silhouette, dark shell with cyan systems and red threat marks. Animation state: idle. Style constraints: crisp pixel art, readable support silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same calibration observer, animation state: idle scan, antenna ring rotating gently, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same calibration observer, animation state: lock-and-strike setup, ring antenna opened, core bright, calling down a vertical attack, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same calibration observer, animation state: death, antenna ring broken apart, middle core burned out, transparent background.
```

### 精英怪 5 个

#### 1. 逆轨刽子手

**类别：** 精英怪 / 处决型 / 高速斩首单位  
**元素倾向：** 脉  
**血量：** 320  
**攻击伤害：** 76  
**组合技能：** `反向冲轨` + `五段处决斩` + `斩后换位`  
**攻击特征：** 会先假装后撤，再沿反方向高速贴脸，一旦接近就打出极快五连斩。  
**设计说明：** 参考高速扑杀敌人的压迫方式，但加入假退真进的欺骗节奏。

**动作设计：**
- `idle`：单刃或双刃低垂，身体前后重心不断切换，像随时要突进。
- `move`：滑轨后撤和前冲都极快，回拉动作尤其明显。
- `attack`：先假退，随后高速回折切入，连出五段处决斩。
- `special`：斩完会瞬间换位到玩家另一侧，保持威胁。
- `death`：冲势没收住，刃体插地，身体前翻断裂。

**攻击方式拆解：**
- `反向冲轨`：行为欺骗型前摇，先退一步骗闪避，再反向冲回。
- `五段处决斩`：连续高速近战，动作节奏快，前几刀逼停顿，后两刀抢输出窗口。
- `斩后换位`：连段后横切位置，防止玩家背后贪打。

**AI生成提示词：**
- 中文说明：高速处决型实验剑士机械，身形修长，轨道冲刺组件明显，刃体细长锋利，姿态极具爆发感，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: high-speed execution striker. Human-defined design notes: slim lethal humanoid machine, rail acceleration module on legs or back, long execution blade, tense coiled posture, cyan motion systems, red threat lights. Animation state: idle. Style constraints: crisp pixel art, readable fast elite silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same execution striker, animation state: tense idle, body slightly pulled back like a spring, blade low, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same execution striker, animation state: burst slash combo opening, body snapping forward from a fake retreat, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same execution striker, animation state: death, momentum carried forward into a broken collapse, blade embedded in the ground, transparent background.
```

#### 2. 引力禁区编织者

**类别：** 精英怪 / 控场型 / 场域构筑单位  
**元素倾向：** 脉 / 滞  
**血量：** 368  
**攻击伤害：** 64  
**组合技能：** `黑点牵引` + `重力网格` + `爆裂坍针`  
**攻击特征：** 能在战场上生成数个微型引力点，把玩家路线切成危险网格，随后引爆全部节点。  
**设计说明：** 这是第二关最典型的空间设计精英，强度来自“你没地方站”。

**动作设计：**
- `idle`：身体周围环绕数个未成形引力黑点，像织线机一样旋转。
- `move`：漂浮缓慢，但总会在合适的几何中心停下。
- `attack`：先布点，再拉出看不见的重力线，最后远程点爆。
- `special`：引爆前身体会短暂缩成一个紧核，再猛地展开。
- `death`：黑点失控互相吞噬，本体被扯碎成数段。

**攻击方式拆解：**
- `黑点牵引`：先放置多个弱牵引点，改变玩家走线。
- `重力网格`：牵引点之间形成危险网格，是核心控场部分。
- `爆裂坍针`：布网后统一引爆，形成强制结算。

**AI生成提示词：**
- 中文说明：重力织网型实验精英，身体像浮游编织机或神经纺锤，周围有数个黑点节点，青蓝引力线感强，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: gravity zone weaver elite. Human-defined design notes: floating spindle-like control body, several orbiting black-point gravity nodes, cyan-blue force lines, elegant but dangerous lab-machine silhouette, red caution markers. Animation state: idle. Style constraints: crisp pixel art, readable control silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same gravity zone weaver, animation state: idle with orbiting gravity nodes, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same gravity zone weaver, animation state: network creation attack, nodes spread out and linked by subtle energy lines, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same gravity zone weaver, animation state: death, nodes collapsing inward and tearing the body apart, transparent background.
```

#### 3. 双生素体守卫

**类别：** 精英怪 / 双单位 / 培养仓失控守卫  
**元素倾向：** 脉 / 蚀  
**血量：** 402（共享生命池）  
**攻击伤害：** 84  
**组合技能：** `镜步交错` + `双向夹杀` + `残影回收`  
**攻击特征：** 以两具同步素体出现，常从两侧夹击；其中一体被击倒后，另一体会尝试短时间复位回收。  
**设计说明：** 这只精英明确回应“源并非唯一”的世界观线索，战斗上也更高级。

**动作设计：**
- `idle`：两具素体以几乎镜像的姿态站立，但细节故意略有偏差。
- `move`：镜步同步前进，一快一慢制造错觉节奏。
- `attack`：常用一体正面吸引，另一体从斜后切入夹杀。
- `special`：倒下一体后，另一体会俯身拖回残影或回收数据。
- `death`：两具同时断电崩塌，像失败复制品终于停止同步。

**攻击方式拆解：**
- `镜步交错`：不是伤害技，而是战术姿态，通过错位同步压缩可躲路线。
- `双向夹杀`：一前一后或一上一下联动斩击，是主要输出。
- `残影回收`：共享血池核心机制，用来延长战斗并强化叙事冲击。

**AI生成提示词：**
- 中文说明：成对实验素体守卫，两具相似但不完全相同的人形机械体，培养仓残骸感，青蓝实验光，战斗轮廓利落，128x128，适合成对出图。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: twin specimen guards. Human-defined design notes: two nearly identical humanoid lab-grown machine bodies, subtle asymmetry between the pair, lean combat silhouette, exposed graft seams, cyan lab glow, red hostile accents, failed clone security vibe. Animation state: idle. Style constraints: crisp pixel art, readable paired silhouettes, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same twin specimen guards, animation state: mirrored idle stance, both units slightly offset, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same twin specimen guards, animation state: pincer attack, one attacking from the front and one from the rear angle, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same twin specimen guards, animation state: synchronized death collapse, both units failing together, transparent background.
```

#### 4. 相位断路主教

**类别：** 精英怪 / 远程型 / 相位清场单位  
**元素倾向：** 脉 / 序  
**血量：** 352  
**攻击伤害：** 92  
**组合技能：** `扇面光栅` + `定点闪移` + `相位坍枪`  
**攻击特征：** 先发射扇面光栅逼跳跃，再闪到另一侧用贯穿性坍枪补刀。  
**设计说明：** 专门惩罚节奏固定的玩家，是本关优秀的中轴压制者。

**动作设计：**
- `idle`：高位悬浮或长腿站姿，像冷静的处刑官。
- `move`：移动多依赖闪移而非正常跑动。
- `attack`：先张开发射单元打出扇面光栅，再在另一侧闪现补贯穿炮。
- `special`：闪移前机体会先碎成几块相位片，再在新位置重组。
- `death`：相位结构崩塌，身体分层解体。

**攻击方式拆解：**
- `扇面光栅`：前摇是炮臂展开，逼玩家做垂直位移。
- `定点闪移`：利用相位重组换侧，改变炮线角度。
- `相位坍枪`：贯穿性终结炮，主要惩罚机械地躲过第一段的人。

**AI生成提示词：**
- 中文说明：远程清场主教型机械，庄严、冷静、悬浮或高挑，发射单元像光栅器官，带相位碎片感，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: phase-clearing bishop elite. Human-defined design notes: elegant tall machine silhouette, ranged emission arms, ceremonial but lethal presence, phase shard details, cyan-white beam systems, red threat points, calm executioner vibe. Animation state: idle. Style constraints: crisp pixel art, readable elite silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same phase bishop, animation state: poised idle, beam emitters closed, body calm and upright, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same phase bishop, animation state: fan-beam attack, emitters spread wide, body angled forward, transparent background.
Special EN: Create a 2D side-view pixel art enemy frame, 128x128, same phase bishop, animation state: phase teleport, body fragmenting into glowing shards, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same phase bishop, animation state: death, body unraveling into layered phase debris, transparent background.
```

#### 5. 磁暴驯化机

**类别：** 精英怪 / 追猎型 / 四足高压实验兽  
**元素倾向：** 脉  
**血量：** 480  
**攻击伤害：** 108  
**组合技能：** `磁爪飞扑` + `尾轨炮` + `落地电脉圈`  
**攻击特征：** 可连续飞扑两次，落地后释放电脉圈；拉开距离时尾部轨炮会补一记高伤直线炮。  
**设计说明：** 这是第二关最直接的硬压迫精英，不让玩家有舒服输出窗口。

**动作设计：**
- `idle`：四足低伏，尾部轨炮缓慢对焦，爪尖电弧轻跳。
- `run`：冲刺时四肢完全压低，像被放开的实验猛兽。
- `attack`：飞扑时前爪磁光拉满，落地后扩出一圈电脉。
- `special`：拉远距离后尾部轨炮抬起，改用直线炮压制。
- `death`：轨炮过载炸裂，四足抽搐后瘫倒。

**攻击方式拆解：**
- `磁爪飞扑`：高速前扑，命中直接造成强压身位。
- `落地电脉圈`：扑击落点自带范围二次伤害，防止玩家简单靠翻滚穿过去。
- `尾轨炮`：中远程惩罚技，把玩家重新逼回它喜欢的扑杀距离。

**AI生成提示词：**
- 中文说明：四足实验猛兽，尾部有轨炮，前爪带磁暴电弧，身形厚重但速度快，实验缰具和束线还残留在身上，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: magnet-storm tamed beast elite. Human-defined design notes: powerful quadruped experiment beast, tail-mounted rail cannon, charged foreclaws, heavy but agile body, residual restraint gear and cables, cyan electric arcs, red warning lights. Animation state: idle. Style constraints: crisp pixel art, readable beast silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, realistic fur, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same magnet-storm beast, animation state: low tense idle, electric claws crackling, rail tail aiming slowly, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same magnet-storm beast, animation state: leap attack, body airborne, front claws charged and extended, transparent background.
Special EN: Create a 2D side-view pixel art enemy frame, 128x128, same magnet-storm beast, animation state: tail rail cannon shot, rear body braced, cannon raised and firing forward, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same magnet-storm beast, animation state: death, tail cannon ruptured, body collapsing in a shower of sparks, transparent background.
```

### Boss 1 个

#### 脉冲主机·零域双生

**类别：** Boss / 实验中枢 / 重力实验室统御单位  
**元素倾向：** 脉为主，辅以序与蚀  
**总血量：** 905  
**单次重击伤害：** 86 - 145  
**核心机制：** `双生同步`、`重力改道`、`频率过载`

**阶段设计：**

- **一阶段：观测同步**
  主体悬浮在实验核心上方，以 `折返脉冲雨`、`磁轨冲刺`、`重力抓举` 为主，测试玩家移动习惯。
- **二阶段：双生解缚**
  核心分裂出一具镜像素体，与本体共享部分生命池；战场出现多条可切换方向的重力轨线，玩家稍不注意就会被推入炮线。
- **三阶段：零域过载**
  场景边缘逐步塌缩，Boss 进入持续高速位移状态，轮流释放 `坍缩环`、`万向落雷`、`近身七连斩`，最后以贯穿全屏的 `零域脉冲束` 收尾。

**战斗表现：**

- 头部是可视弱点，但只有在释放大招或回收镜像时才会长时间暴露。
- 每损失 `25%` 血量，场地会发生一次重力翻转，平台的上下概念短暂互换。
- Boss 会读玩家的连续位移习惯；若玩家频繁向同一方向闪避，镜像会提前堵位。

**掉落：** 必定掉落 `机械双腿`、大型经验碎片、脉系核心素材  

**叙事说明：**  
零域双生并不是单一兵器，而是重力实验室用来校验“高速适应体是否能在重压中自我迭代”的最终样本。它体内保存着多轮失败素体的神经节律，因此会在战斗中表现出近似知道你下一步要去哪里的压迫感。玩家击败它后获得机械双腿，也意味着自己正式继承了实验室最核心的高速移动能力。

**动作设计：**
- `idle`：主机核心悬浮旋转，外层环轨与内部素体同步呼吸般开合。
- `core_loop`：主体不靠步行，而靠稳定悬浮、瞬时轨移和姿态翻面完成位移。
- `phase_transition`：分裂镜像素体、重力轨线重编、场地翻转时都要有明显的环轨展开和核心暴露。
- `signature_attack`：折返脉冲雨、重力抓举、坍缩环、零域脉冲束分别对应远程压制、控位、区域清屏和终结型炮线。
- `weakpoint_expose`：大招后核心降速、镜像回收时头部与中枢短暂暴露。
- `hit`：受击会造成环轨短停和镜像同步紊乱，但不会产生传统硬直。
- `death`：双生结构失衡，镜像和主机同时撕裂成互相冲突的重力碎片。

**攻击方式拆解：**
- `折返脉冲雨`：前摇是外环炮口依次亮起；释放多段折返弹；命中反馈偏密集压屏。
- `磁轨冲刺`：本体沿重力轨线高速冲刺，更多承担换位和切场。
- `重力抓举`：掌控技，先抬升玩家再为后续炮线创造窗口。
- `双生解缚`：阶段技，本体分裂镜像素体后形成双点夹压，强调“你正在被两个思路围猎”。
- `坍缩环`：区域压缩技，用大环切站位。
- `万向落雷`：从上方随机但带导向地落击，防止只盯水平线。
- `近身七连斩`：三阶段高压近身惩罚技。
- `零域脉冲束`：终结招，大前摇、大表现、大伤害，需要完整弱点暴露与场景呼应。

**AI生成提示词：**
- 中文说明：实验室终极中枢 Boss，192x192，主机是悬浮核心与环轨结构，内部可分裂出镜像素体，整体高科技、冷静、危险，蓝白重力光与红色锁定光共存，不能画成传统机器人王。
```text
Base EN: Create a 2D side-view pixel art boss concept frame for a cyberpunk machine-crisis action game. Canvas target: 192x192. Boss role: gravity-lab central machine that can split into a mirrored twin. Human-defined design notes: floating core body, rotating ring rails, visible inner humanoid specimen, dual-entity split capability, blue-white gravity light, red targeting indicators, elegant high-tech experimental silhouette, premium showcase boss. Readability: large readable silhouette, visible weak point, clear attack parts, strong contrast. Output: single pixel art concept frame, transparent background, no text, no watermark.
Idle EN: Create a 2D side-view pixel art boss frame, 192x192, same gravity central machine, animation state: idle hover loop, rings rotating, inner specimen suspended, transparent background.
PhaseTransition EN: Create a 2D side-view pixel art boss frame, 192x192, same gravity central machine, animation state: twin split phase transition, inner specimen separating into a mirrored body, ring rails opened wide, transparent background.
SignatureAttack EN: Create a 2D side-view pixel art boss frame, 192x192, same gravity central machine, animation state: zero-domain beam attack, rings aligned into a cannon shape, core overcharged, clear forward line of destruction, transparent background.
Death EN: Create a 2D side-view pixel art boss frame, 192x192, same gravity central machine, animation state: death, rings shattered, twin structures collapsing into gravity fragments, transparent background.
```

---

## 第三关：下水道

本关对应元素 `滞`，核心体验是淤积、封锁、反压、污水回流与残念幻听。以下数值按高数值后中段版本编写，默认玩家已完成第二关，拥有较高移速与闪避能力，因此敌群会更强调拖慢、抓取和持续压迫。

### 关卡数值基准

- 普通怪血量建议区间：`130 - 199`
- 精英怪血量建议区间：`360 - 499`
- Boss 总血量建议：`930 - 990`
- 本关常见异常：`滞流淤层`、`污压窒息`、`残念回响`

### 普通怪 10 个

#### 1. 淤泥滤齿虫

**类别：** 普通怪 / 啃噬型 / 管网底栖单位  
**元素倾向：** 滞  
**血量：** 130  
**攻击伤害：** 24  
**组合技能：** `潜泥突咬` + `拖尾淤层`  
**攻击特征：** 会潜入污泥下接近玩家，突袭后在地面留下一条减速淤层。  
**设计说明：** 最基础的地面压迫怪，主要价值在于改变玩家脚下地形。

**动作设计：**
- `idle`：半身埋在污泥中，只露出滤齿和背壳气孔。
- `move`：潜行时表面只鼓出一条细长泥痕。
- `attack`：突然钻出地表张口咬合，落地后尾部拖出淤泥。
- `hit`：被打中会短暂翻出腹部，再迅速压回泥里。
- `death`：身体僵住后半陷入泥中，滤齿外露。

**攻击方式拆解：**
- `潜泥突咬`：前摇很短，主要靠泥面预兆；释放时从地表下咬出。
- `拖尾淤层`：咬完后沿路径留下减速泥层，是持久控制价值。

**AI生成提示词：**
- 中文说明：下水道底栖机械虫，带滤齿口器，半潜泥，身体粗短，污泥和锈蚀覆盖，96x96，强调拖慢和脏污感。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: sludge-burrowing pipe crawler. Human-defined design notes: short low worm-like machine body, filter-teeth mouth, half-submerged sewer creature silhouette, rust, grime, mud coating, dark metal with dirty green-brown sludge and small red threat lights. Animation state: idle. Style constraints: crisp pixel art, readable low silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same sludge crawler, animation state: half-buried idle, only mouth and back vents visible, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same sludge crawler, animation state: bursting bite attack from the ground, mud spraying backward, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same sludge crawler, animation state: death, body partly sunken into the sludge, filter teeth exposed, transparent background.
```

#### 2. 回压喷胆

**类别：** 普通怪 / 喷吐型 / 废液蓄压单位  
**元素倾向：** 滞  
**血量：** 142  
**攻击伤害：** 28  
**组合技能：** `高压污束` + `炸裂回流`  
**攻击特征：** 先喷出一条直线污束，落点延迟炸开后形成回流漩涡，把玩家往中心拖。  
**设计说明：** 这是本关最典型的先封线、再收口远程杂兵。

**动作设计：**
- `idle`：腹部囊体鼓鼓胀胀，表面压力表忽明忽暗。
- `move`：移动不快，更多是稳稳地架设喷吐角度。
- `attack`：先鼓压后喷出直线污束，几拍后落点反向回吸。
- `special`：爆裂回流时腹囊明显瘪下去，表现出一次性卸压。
- `death`：腹囊炸开，污液从裂口大量溅出。

**攻击方式拆解：**
- `高压污束`：前摇是腹囊胀大，释放直线喷流封路。
- `炸裂回流`：落点不是结束，而是延迟炸开并形成拖拽漩涡，补上二次控场。

**AI生成提示词：**
- 中文说明：喷吐废液机械，腹部大囊，前端喷口明显，污压感重，96x96，颜色以脏绿、锈红、暗钢为主。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: pressurized waste spitter. Human-defined design notes: swollen liquid bladder, heavy front nozzle, sewer corrosion, dark steel mixed with dirty green sludge and rust-red warning details, silhouette built around pressure and vomiting force. Animation state: idle. Style constraints: crisp pixel art, readable nozzle and bladder silhouette, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same waste spitter, animation state: idle with pressurized belly bulging, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same waste spitter, animation state: high-pressure spit attack, nozzle blasting forward, belly compressed, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same waste spitter, animation state: death, bladder ruptured and sludge spilling out, transparent background.
```

#### 3. 管壁伏线者

**类别：** 普通怪 / 埋伏型 / 管壁悬挂单位  
**元素倾向：** 滞 / 蚀  
**血量：** 136  
**攻击伤害：** 26  
**组合技能：** `钢索垂落` + `倒挂割颈` + `拖拽回管`  
**攻击特征：** 藏在头顶管壁内，玩家经过时垂落钢索缠绕，随后以倒挂斩补伤害。  
**设计说明：** 用于打破第三关“只看地面”的习惯，提升通道探索的压迫感。

**动作设计：**
- `idle`：完全缩在管缝里，只露出钢索挂点和一只观察眼。
- `move`：主要靠钢索移动，身体多数时间倒挂。
- `attack`：先垂落钢索缠住，再倒悬摆荡切过玩家喉部高度。
- `special`：攻击后迅速回收钢索，把自己拖回管缝。
- `death`：钢索断裂，身体倒挂失衡掉落。

**攻击方式拆解：**
- `钢索垂落`：前摇是管口金属摩擦和钢索落下；作用先控住。
- `倒挂割颈`：抓到窗口后横摆切喉，伤害集中。
- `拖拽回管`：不命中也会回撤，提高存活率。

**AI生成提示词：**
- 中文说明：管壁埋伏机械，倒挂、钢索、狭长切刃是重点，像下水道天花板陷阱，96x96。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: pipe-wall hanging ambusher. Human-defined design notes: compact hanging machine body, suspension cable, narrow throat-cutting blade, one visible sensor eye, built to hide inside sewer pipe cracks, dirty steel and rust. Animation state: idle. Style constraints: crisp pixel art, readable hanging silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same hanging ambusher, animation state: hidden idle in a pipe crack, cable visible, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same hanging ambusher, animation state: cable drop and hanging slash, body upside down, blade sweeping across, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same hanging ambusher, animation state: death, cable snapped, body falling from above, transparent background.
```

#### 4. 废液肩灯人

**类别：** 普通怪 / 巡逻型 / 旧运维人员改造体  
**元素倾向：** 滞 / 序  
**血量：** 168  
**攻击伤害：** 31  
**组合技能：** `炫盲肩灯` + `短棍三连` + `回身顶膝`  
**攻击特征：** 先用高亮肩灯短暂压低玩家视野，再贴脸打出稳定三连击。  
**设计说明：** 这类敌人让第三关不只是脏和慢，还会在视觉层面令人不适。

**动作设计：**
- `idle`：人形轮廓歪斜，肩灯偶尔闪一下，像坏掉的巡检员。
- `move`：湿滑地面上的小步巡逻，肩灯随着步伐扫动。
- `attack`：先抬肩直照玩家，再贴身用短棍和膝击连续压人。
- `hit`：受击时肩灯失焦乱闪。
- `death`：肩灯最后一次爆亮后熄灭，身体前倾倒下。

**攻击方式拆解：**
- `炫盲肩灯`：前摇是抬肩和聚光，主要制造瞬时视野干扰。
- `短棍三连`：贴脸的稳定输出段。
- `回身顶膝`：收尾近身压迫，惩罚硬吃前两段不躲的人。

**AI生成提示词：**
- 中文说明：旧运维人员改造体，半人形，肩部探照灯很亮，手持短棍，像被下水道系统强行接管的巡检员，96x96。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: retrofitted maintenance patrol body. Human-defined design notes: half-humanoid sewer maintenance worker machine, bright shoulder searchlight, short baton, crooked old industrial frame, damp grime, red hazard details, unsettling worker silhouette. Animation state: idle. Style constraints: crisp pixel art, readable humanoid silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same maintenance body, animation state: uneasy patrol idle, shoulder lamp dim but ready, baton lowered, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same maintenance body, animation state: shoulder-light blind and baton strike, one shoulder turned toward the viewer, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same maintenance body, animation state: death, shoulder lamp bursting bright before going dark, body collapsing, transparent background.
```

#### 5. 沉积哨蛭

**类别：** 普通怪 / 附着型 / 异常堆积单位  
**元素倾向：** 滞  
**血量：** 138  
**攻击伤害：** 18  
**组合技能：** `扑附咬合` + `淤层叠加`  
**攻击特征：** 伤害不高，但会扑附到玩家身上叠加滞流层数，层数高时翻滚和闪避距离明显缩短。  
**设计说明：** 本关的状态税怪，不及时清掉会让其他敌人全部升值。

**动作设计：**
- `idle`：像附着在墙面或污面上的扁平吸附体。
- `move`：滑行或短跳靠近，身体拉长后收缩。
- `attack`：扑到目标身上后紧紧咬住，不强调瞬时爆发。
- `special`：附着期间体表会不断分泌淤层。
- `death`：吸附盘翻开，身体缩成一团坠地。

**攻击方式拆解：**
- `扑附咬合`：前摇不长，但扑线清晰；命中后进入附着逻辑。
- `淤层叠加`：附着后持续叠状态，是整只怪的核心价值。

**AI生成提示词：**
- 中文说明：扁平吸附蛭状机械，吸盘和小咬口明显，附着感强，污泥环境用小怪，96x96，避免画成有血肉感的真实水蛭。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: adhesion debuff parasite. Human-defined design notes: flat leech-like machine body, suction plates, small biting mouth, designed to latch onto targets and spread sludge buildup, dirty metal, sewer grime, red warning accents. Animation state: idle. Style constraints: crisp pixel art, readable flat silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, realistic flesh, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same adhesion parasite, animation state: idle clinging pose, body flattened and tense, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same adhesion parasite, animation state: latch attack, body stretched forward, mouth open, suction plate visible, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same adhesion parasite, animation state: death, suction plate peeled open, body curled inward, transparent background.
```

#### 6. 栅门顶颅者

**类别：** 普通怪 / 顶撞型 / 门禁推压单位  
**元素倾向：** 滞 / 序  
**血量：** 182  
**攻击伤害：** 38  
**组合技能：** `盾面顶推` + `墙角碎颅`  
**攻击特征：** 以厚重头盾顶着玩家往墙角或栅门推，若成功撞墙会追加一次高伤碎颅。  
**设计说明：** 它负责把第三关狭窄地形真正变成杀伤资源。

**动作设计：**
- `idle`：前方头盾低垂，像随时准备撞开门禁。
- `move`：低头迈进，重心极低，步子压迫感强。
- `attack`：头盾抬半寸后立刻顶推，推到障碍物再补重压。
- `hit`：正面受击主要是硬扛，侧面受击才有明显晃动。
- `death`：头盾先砸地，身体随后顺着惯性折倒。

**攻击方式拆解：**
- `盾面顶推`：前摇短，重在持续前推。
- `墙角碎颅`：把玩家推出去后若撞实墙角，会接一次压头重击，是狭窄地形专属价值。

**AI生成提示词：**
- 中文说明：头盾冲撞机械，前部像厚重门盾或闸门板，身体低矮结实，下水道压路机气质，96x96 或 128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: gate-shield pusher. Human-defined design notes: low sturdy body, huge front head-shield or gate plate, built to ram and pin targets into walls, heavy sewer-control machine silhouette, rust, dark steel, red warning bars. Animation state: idle. Style constraints: crisp pixel art, readable front-heavy silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same shield pusher, animation state: idle low brace, shield almost scraping the ground, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same shield pusher, animation state: forward ram, shield driving hard into the front, body compressed behind it, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same shield pusher, animation state: death, shield slammed into the floor first, body folding over it, transparent background.
```

#### 7. 腐温搬运虾

**类别：** 普通怪 / 搬运型 / 废件抛投单位  
**元素倾向：** 滞  
**血量：** 154  
**攻击伤害：** 29  
**组合技能：** `废件抛投` + `落地污爆`  
**攻击特征：** 抓起周围垃圾、旧阀门或残骸砸向玩家，投掷物落地后会炸出热污区域。  
**设计说明：** 借搬运机械军用化这一条旧逻辑继续深化下水道生态。

**动作设计：**
- `idle`：前钳或机械臂不断拣起又放下周边垃圾。
- `move`：身体前弓后翘，像背着重物缓慢挪动。
- `attack`：抛投前会明显后撤蓄力，再把废件砸出。
- `special`：热污爆会在落地时额外喷出一层湿热污浆。
- `death`：背负的废件和阀门先从身上滑落。

**攻击方式拆解：**
- `废件抛投`：蓄力长，主要给出抛物线信息。
- `落地污爆`：命中和落空都有压场价值，强化空间持续压力。

**AI生成提示词：**
- 中文说明：搬运虾型机械，前钳强壮，背部背着废阀门和杂件，湿热污浆感明显，96x96，轮廓偏横向。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: waste-hauling thrower. Human-defined design notes: shrimp-like industrial body, strong front claws, back loaded with broken valves and junk, wet heat sludge stains, sideways heavy silhouette, sewer scavenger machine. Animation state: idle. Style constraints: crisp pixel art, readable thrower silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same waste-hauling thrower, animation state: idle with junk load on the back, claw adjusting the cargo, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same waste-hauling thrower, animation state: throwing a heavy valve or scrap piece, body pulled back then released, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same waste-hauling thrower, animation state: death, cargo spilling off the back, body buckling, transparent background.
```

#### 8. 返流唱针

**类别：** 普通怪 / 干扰型 / 声波共振单位  
**元素倾向：** 滞 / 脉  
**血量：** 148  
**攻击伤害：** 25  
**组合技能：** `低频哀鸣` + `节律错拍`  
**攻击特征：** 以低频脉冲干扰玩家节奏，命中后会短暂延后翻滚判定，让玩家产生按了但没完全按出来的迟滞感。  
**设计说明：** 这是很适合残念幻听关的设计，会让玩家心理压力明显上升。

**动作设计：**
- `idle`：细长针状机体轻震，像在持续发出人耳难受的低频。
- `move`：漂移缓慢，但会不自然地突然顿一下。
- `attack`：发声腔体张开，向前打出扭曲音波环。
- `special`：第二段错拍脉冲会在第一波之后半拍补上。
- `death`：唱针折断，音波纹路瞬间静止。

**攻击方式拆解：**
- `低频哀鸣`：前摇明显，发声腔张开；释放波环主要打干扰。
- `节律错拍`：延迟半拍补一段，更像对输入节奏的攻击而不是伤害堆数。

**AI生成提示词：**
- 中文说明：声波针状机械，细长、发声腔突出，低频不适感强，带下水道共鸣器质感，96x96，蓝灰主体配红警示点。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 96x96. Enemy role: low-frequency resonance disruptor. Human-defined design notes: thin needle-like body, visible sound chamber, sewer resonance machine vibe, dark blue-gray shell, red warning nodes, subtle wave pattern details. Animation state: idle. Style constraints: crisp pixel art, readable audio-weapon silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 96x96, same resonance disruptor, animation state: trembling idle, sound chamber closed but vibrating, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 96x96, same resonance disruptor, animation state: sound pulse attack, chamber open wide, visible wave-front silhouette, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 96x96, same resonance disruptor, animation state: death, body snapped and the wave pattern gone silent, transparent background.
```

#### 9. 污洪盘车

**类别：** 普通怪 / 碾压型 / 滚行检修单位  
**元素倾向：** 滞  
**血量：** 199  
**攻击伤害：** 42  
**组合技能：** `蓄污滚压` + `急停喷溅`  
**攻击特征：** 沿通道越滚越快，急停时向前方喷出大片污水碎片。  
**设计说明：** 简单粗暴，但在狭窄地图里很好用，是纯地形杀怪。

**动作设计：**
- `idle`：像一个半休眠的大圆盘或滚桶，内部液体轻晃。
- `move`：滚动速度逐步提升，边缘污水被甩开。
- `attack`：高速滚压撞击，随后急停甩出扇形喷溅。
- `special`：急停时主体会短暂前倾，给视觉上很重的刹车感。
- `death`：轮体裂开，污液和齿轮一起滚出。

**攻击方式拆解：**
- `蓄污滚压`：启动慢但越来越快，靠路线和地形形成威胁。
- `急停喷溅`：滚压之后的二段，专门惩罚从正面侧闪后立刻反打。

**AI生成提示词：**
- 中文说明：滚桶式检修碾压机械，圆盘或轮体巨大，污液蓄在内部，滚动时边缘甩水，96x96 或 128x128，强调重和脏。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: sludge roller crusher. Human-defined design notes: giant rolling wheel or drum body, internal dirty liquid visible through cracks, maintenance-machine roots, sewer grime, red warning strips, heavy crushing silhouette. Animation state: idle. Style constraints: crisp pixel art, readable rolling silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same sludge roller, animation state: idle heavy drum, liquid sloshing inside, transparent background.
Run EN: Create a 2D side-view pixel art enemy frame, 128x128, same sludge roller, animation state: rolling charge, body spinning fast, sludge flinging off the edges, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same sludge roller, animation state: hard stop splash attack, wheel braced and filthy spray bursting forward, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same sludge roller, animation state: death, drum cracked open, gears and sludge spilling out, transparent background.
```

#### 10. 旧泵看守

**类别：** 普通怪 / 固守型 / 泵房喷压单位  
**元素倾向：** 滞 / 序  
**血量：** 196  
**攻击伤害：** 36  
**组合技能：** `扇形喷压` + `排污闸落`  
**攻击特征：** 常守在泵房和阀门点位，喷压覆盖范围大，且会临时落下闸门限制移动路线。  
**设计说明：** 它本身移动慢，但和回压喷胆、栅门顶颅者搭配会非常难受。

**动作设计：**
- `idle`：守在泵房节点，背后阀门和泵管持续有压力脉动。
- `move`：几乎不主动追击，只做小范围转向和站位微调。
- `attack`：双侧喷口展开，朝前方喷出高压扇面污流。
- `special`：脚下或身后闸门短时落下，形成临时封路。
- `death`：泵体回压爆裂，背后管路先喷一次再断。

**攻击方式拆解：**
- `扇形喷压`：中长前摇，喷面覆盖广，主要做区域封锁。
- `排污闸落`：不是伤害，而是改变路线，和队友形成组合拳。

**AI生成提示词：**
- 中文说明：泵房守卫机械，背后有泵和阀门结构，双喷口，站桩压场型，96x96 或 128x128，工业设施感强于生物感。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: pump-room pressure guard. Human-defined design notes: stationary or slow-turning body, twin front pressure nozzles, pump and valve structures mounted behind, sewer utility machine silhouette, dirty metal, red warning details, heavy industrial presence. Animation state: idle. Style constraints: crisp pixel art, readable guard silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same pump-room guard, animation state: idle guard at a valve station, pressure gauges active, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same pump-room guard, animation state: wide pressure spray attack, twin nozzles opened, body braced, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same pump-room guard, animation state: death, rear pump bursting and pipes rupturing, transparent background.
```

### 精英怪 5 个

#### 1. 污泥法官

**类别：** 精英怪 / 审判型 / 沉积区域统管单位  
**元素倾向：** 滞 / 序  
**血量：** 360  
**攻击伤害：** 96  
**组合技能：** `污环宣判` + `地钉锁足` + `缓刑重锤`  
**攻击特征：** 会先铺一圈减速污环，再从地面刺出金属地钉固定玩家，最后重锤收尾。  
**设计说明：** 它像一个会“判你不能动”的第三关精英，节奏非常坏。

**动作设计：**
- `idle`：高位举锤或持杖，背后污环像法庭印章一样悬着。
- `move`：步子不快，但每一步都像宣布裁定。
- `attack`：先落下污环，再伸出地钉，最后重锤执行判决。
- `hit`：受击后污环短暂紊乱，但姿态依旧维持压迫。
- `death`：污环碎裂，重锤拖着它一起倒下。

**攻击方式拆解：**
- `污环宣判`：区域减速开场技，给出“审判开始”的节奏信号。
- `地钉锁足`：趁玩家在污环里迟缓时锁住脚下。
- `缓刑重锤`：控制成立后结算大伤害，是整套组合的高潮。

**AI生成提示词：**
- 中文说明：审判者风格的污泥精英，带大锤或重杖，背后悬浮污环印记，既像法官又像下水道执法机，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: sludge judge elite. Human-defined design notes: imposing humanoid sewer authority machine, large hammer or staff, floating dirty ring seal behind the body, dark corroded armor, red warning lines, oppressive judicial silhouette. Animation state: idle. Style constraints: crisp pixel art, readable elite silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same sludge judge, animation state: solemn idle, heavy hammer grounded, ring seal hovering behind, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same sludge judge, animation state: execution strike setup, hammer raised with the ring flaring, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same sludge judge, animation state: death, ring seal shattered and hammer dragging the body down, transparent background.
```

#### 2. 沉箱收尸官

**类别：** 精英怪 / 拖拽型 / 尸料回收单位  
**元素倾向：** 滞 / 蚀  
**血量：** 418  
**攻击伤害：** 108  
**组合技能：** `链钩回收` + `尸袋投砸` + `压浆喷口`  
**攻击特征：** 用链钩把玩家拉近后，以充满污浆的尸袋进行重砸，地面随后出现持续伤害的压浆口。  
**设计说明：** 它把下水道的废弃处理逻辑武器化了，脏且凶。

**动作设计：**
- `idle`：拖着链钩和沉重尸袋，身体前倾，像永远在回收什么。
- `move`：链条在地上拖行，节奏黏重。
- `attack`：先甩出链钩拖回目标，再把尸袋抡起重砸。
- `special`：砸完地面会压出持续喷浆口。
- `death`：尸袋破裂，链条从手上滑落，身体倒进污浆里。

**攻击方式拆解：**
- `链钩回收`：中距起手技，主价值是把玩家拉到近身处决区。
- `尸袋投砸`：重击主段，强调重量和肮脏感。
- `压浆喷口`：砸地后的持续危险区，扩大惩罚面积。

**AI生成提示词：**
- 中文说明：下水道收尸官机械，链钩、尸袋、压浆喷口是关键特征，轮廓肮脏沉重，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: corpse-retrieval execution unit. Human-defined design notes: heavy sewer recovery machine, chain hook weapon, sludge-filled body bag used as a bludgeon, dirty industrial shell, dragging posture, grim disposal-worker silhouette. Animation state: idle. Style constraints: crisp pixel art, readable elite silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same corpse retrieval unit, animation state: idle dragging a chain and body bag, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same corpse retrieval unit, animation state: hook-and-smash attack, chain extended and body bag swinging, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same corpse retrieval unit, animation state: death, body bag ruptured and chain dropped into the sludge, transparent background.
```

#### 3. 逆流处刑机

**类别：** 精英怪 / 处刑型 / 旧式闸刀兵器  
**元素倾向：** 滞 / 序  
**血量：** 472  
**攻击伤害：** 126  
**组合技能：** `逆流推进` + `双闸铡切` + `窒水灌顶`  
**攻击特征：** 先用背后泵机强行顶进，随后打出双闸刀铡击；若命中浮空目标，会追加一次灌顶处刑。  
**设计说明：** 第三关最硬核的近战精英之一，强度来自连段结束技。

**动作设计：**
- `idle`：背后泵机低频运作，两侧闸刀半开半闭。
- `move`：推进时像被反压水流持续顶着向前挤。
- `attack`：先顶进，再双刀铡切，最后对失衡目标灌顶。
- `special`：处刑段会把上半身抬高再重重灌下。
- `death`：泵机爆裂，两片闸刀失控交错后卡死。

**攻击方式拆解：**
- `逆流推进`：靠背泵给出的硬顶位移，不靠灵活。
- `双闸铡切`：近身核心输出，左右闸刀形成夹铡视觉。
- `窒水灌顶`：命中浮空后追加，强化处刑感。

**AI生成提示词：**
- 中文说明：旧式闸刀处刑机械，背后泵机巨大，双侧铡刀，极强压迫感，像下水道旧时代的执法装置，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: reverse-flow execution machine. Human-defined design notes: huge pump engine on the back, twin guillotine blades on both sides, brutal old-mechanism execution silhouette, dark wet metal, red warning slashes, heavy sewer authority presence. Animation state: idle. Style constraints: crisp pixel art, readable elite silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same execution machine, animation state: idle with pump engine pulsing and twin blades half open, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same execution machine, animation state: guillotine combo attack, body driving forward with twin blades crossing, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same execution machine, animation state: death, back pump exploded and blades jammed together, transparent background.
```

#### 4. 腐坝巨蟹

**类别：** 精英怪 / 据点型 / 重壳水闸守卫  
**元素倾向：** 滞  
**血量：** 499  
**攻击伤害：** 118  
**组合技能：** `正面封壳` + `侧钳爆压` + `淤波拍岸`  
**攻击特征：** 正面几乎打不动，只能绕到腹部或关节弱点；一旦贴太近会被侧钳重压并推出去。  
**设计说明：** 借用了硬壳弱点这一经典思路，但整体气质更像下水道阀坝怪物。

**动作设计：**
- `idle`：像闸坝一样蹲伏，正壳厚重封住大半正面。
- `move`：横向侧移为主，守点意味强于追击。
- `attack`：近身时侧钳猛压，远一点则拍出一层淤波。
- `special`：受威胁时会把前壳彻底合拢形成强防。
- `death`：壳体开裂，内部阀门与软管喷出污压。

**攻击方式拆解：**
- `正面封壳`：防御态，不是输出，但决定打法。
- `侧钳爆压`：惩罚绕位失败和贴太近。
- `淤波拍岸`：区域压迫技，延缓玩家绕背节奏。

**AI生成提示词：**
- 中文说明：阀坝巨蟹式重壳精英，正面外壳像水闸门板，侧钳厚重，身体宽大，下水道Boss前置感，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: corrosion-dam crab guardian. Human-defined design notes: massive front shell like a floodgate plate, heavy side claws, broad sewer guardian body, valve details under the armor, dirty dark metal and sludge stains, fortress-like silhouette. Animation state: idle. Style constraints: crisp pixel art, readable heavy defensive silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same dam crab guardian, animation state: defensive idle with front shell closed, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same dam crab guardian, animation state: side claw crush attack, shell partially opened and a huge claw slamming sideways, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same dam crab guardian, animation state: death, shell cracked open, internal valves bursting, transparent background.
```

#### 5. 盲井牧主

**类别：** 精英怪 / 幻听型 / 深井神经束聚合体  
**元素倾向：** 滞 / 脉  
**血量：** 446  
**攻击伤害：** 112  
**组合技能：** `井壁回声` + `残念投影` + `神经拖缆`  
**攻击特征：** 先制造声音假目标，再从黑暗中伸出拖缆抓人；玩家若被命中，会短暂看见错误的敌方影子。  
**设计说明：** 这只精英专门服务第三关的残念幻觉系统，属于心理战怪。

**动作设计：**
- `idle`：身体像多束神经线和井壁设备缠成的怪异牧者轮廓。
- `move`：很少整身位移，更多是从井壁黑暗里局部伸出。
- `attack`：先放出假回声和投影，再用真拖缆把玩家拽向黑处。
- `special`：受击后会短暂散成几束影子，难以确认本体。
- `death`：神经束一根根断开，回声逐步消失。

**攻击方式拆解：**
- `井壁回声`：心理前摇，先让玩家以为别处有敌人。
- `残念投影`：制造假敌方影子，干扰判断。
- `神经拖缆`：真正的结算抓取，从错误视角里伸出来。

**AI生成提示词：**
- 中文说明：深井神经聚合体，像井壁设备、线缆、神经束和模糊人形混成的存在，诡异、抽象、压迫，128x128。
```text
Base EN: Create a 2D side-view pixel art enemy for a cyberpunk machine-crisis action game. Purpose: final enemy frame. Canvas target: 128x128. Enemy role: blind-well shepherd psychic elite. Human-defined design notes: eerie humanoid silhouette made from bundled nerve cables, wall-mounted machinery and hanging lines, partially hidden body, false shadow projections, unsettling sewer psychic-machine presence. Animation state: idle. Style constraints: crisp pixel art, readable eerie silhouette, clean clusters, transparent background. Do not include text, watermark, UI, photorealism, blurry pixels.
Idle EN: Create a 2D side-view pixel art enemy frame, 128x128, same blind-well shepherd, animation state: hidden idle emerging from darkness and cables, transparent background.
Attack EN: Create a 2D side-view pixel art enemy frame, 128x128, same blind-well shepherd, animation state: cable-grab attack from the shadows, false afterimages around it, transparent background.
Death EN: Create a 2D side-view pixel art enemy frame, 128x128, same blind-well shepherd, animation state: death, nerve bundles snapping and false images fading out, transparent background.
```

### Boss 1 个

#### 滞流总阀·黑潮

**类别：** Boss / 沉积母体 / 下水总阀统御单位  
**元素倾向：** 滞为主，辅以蚀与序  
**总血量：** 980  
**单次重击伤害：** 102 - 168  
**核心机制：** `黑潮蓄积`、`阀门改压`、`残念幻听`

**阶段设计：**

- **一阶段：总阀苏醒**
  Boss 以庞大阀门躯体盘踞在下水主干道深处，使用 `扇形污压`、`缓流波`、`吊管拖拽` 持续拖慢玩家，逼其在低速状态下找空档输出。
- **二阶段：黑潮翻仓**
  场地两侧水位升高，Boss 开始周期性开启副阀，释放 `淤泥洪峰`、`腐温雨` 与 `闸门拍击`；同时会召出沉积哨蛭和回压喷胆扰乱站位。
- **三阶段：残念回响**
  Boss 的胸腔阀室张开，露出密集神经脊束，开始播放历代源死亡时的断裂语音。此阶段会出现 `幻影诱导区`，玩家若误入会把闪避方向反转半秒；Boss 则趁机释放 `黑潮吞口` 与 `总阀坠闭`。

**战斗表现：**

- 主体前方护甲极厚，但腹部阀门、背部压力脊和张口时的内部滤芯都是可击穿弱点。
- 每损失 `20%` 血量，场地中的污水层级会上升一级，部分安全平台会被永久淹没。
- 当玩家身上 `滞流淤层` 叠到高层时，Boss 会触发强化技 `静滞凝视`，短暂锁住玩家动作后再进行追击。

**掉落：** 必定掉落 `机械背脊`、大型经验碎片、滞系核心素材  

**叙事说明：**  
黑潮原本是下水系统最深处的总阀管理母机，负责过滤旧时代残渣、回收报废机械与稳定地下流量。随着机械文明不断迭代，它逐渐吸纳了太多被遗弃的记录、残骸和失败实验品，于是开始把沉积本身理解为一种保存文明的方式。它不急着杀死入侵者，它更愿意把一切拖慢、淹没、压入底部，让你成为它庞大记忆污泥中的又一层沉积物。玩家从它身上取得机械背脊，也等于拿到了真正意义上的抗压骨架。

**动作设计：**
- `idle`：庞大阀门躯体缓慢搏动，外壳像堆积多年的淤层和旧闸门活了过来。
- `core_loop`：主体移动极慢，但会通过开启副阀、升降水位、抽动吊管来支配整个场地。
- `phase_transition`：每次翻仓或张开胸腔阀室时，所有副阀、压力脊和内部神经束都会同步亮起。
- `signature_attack`：扇形污压、淤泥洪峰、闸门拍击、黑潮吞口、总阀坠闭分别代表喷压、涨潮、地形拍杀、吞口吸引和终极阀门闭合。
- `weakpoint_expose`：腹部阀门张开、胸腔滤芯暴露、背脊压力脉冲外露时都是核心输出窗口。
- `hit`：受击时会有整具阀体迟滞震荡、污水回涌和神经束抽动。
- `death`：总阀彻底失压，整个母体像一座倒塌的下水设施一样层层坠闭。

**攻击方式拆解：**
- `扇形污压`：一阶段主要远程喷压，前摇是喷口打开和压力表拉满。
- `缓流波`：低平横向减速波，用来让玩家越来越难保持节奏。
- `吊管拖拽`：从上方或侧面甩出吊管，把玩家拉离安全点。
- `淤泥洪峰`：二阶段涨潮压场技，主价值在于改变安全区。
- `腐温雨`：高处滴落腐热污液，补垂直压力。
- `闸门拍击`：地形型重压技能，像整个水闸往下拍。
- `黑潮吞口`：三阶段胸腔张口吸入，兼具吸引和惊吓表现。
- `总阀坠闭`：终结大招，利用阀门整体下坠压出极强存在感。
- `静滞凝视`：条件强化技，用来惩罚高层淤积状态。

**AI生成提示词：**
- 中文说明：下水总阀母体 Boss，192x192，主体由巨大闸门、泵房、压力脊、滤芯和沉积污层组成，像一座活着的下水设施，胸腔能张开露出内部神经束和滤芯，颜色偏脏绿、锈红、黑钢，带少量病态蓝白光。
```text
Base EN: Create a 2D side-view pixel art boss concept frame for a cyberpunk machine-crisis action game. Canvas target: 192x192. Boss role: living sewer main-valve mother body. Human-defined design notes: enormous floodgate torso, pump-room structures fused into the body, pressure spines, exposed filter core, layered sludge and corrosion, chest chamber that can open to reveal nerve bundles, dirty green-brown and rust-red palette with sickly blue-white inner light. Readability: huge readable silhouette, visible weak point, industrial machine-monster hybrid, premium showcase quality. Output: single pixel art concept frame, transparent background, no text, no watermark.
Idle EN: Create a 2D side-view pixel art boss frame, 192x192, same living sewer valve boss, animation state: idle pressure-breathing loop, valves pulsing slowly, heavy body planted like infrastructure, transparent background.
PhaseTransition EN: Create a 2D side-view pixel art boss frame, 192x192, same living sewer valve boss, animation state: phase transition, side valves opening, water pressure rising, chest chamber beginning to unlock, transparent background.
SignatureAttack EN: Create a 2D side-view pixel art boss frame, 192x192, same living sewer valve boss, animation state: black tide maw attack, chest chamber fully opened like a devouring valve mouth, sludge and cables drawn inward, transparent background.
Death EN: Create a 2D side-view pixel art boss frame, 192x192, same living sewer valve boss, animation state: death, giant valve body collapsing shut in layers, pipes bursting, sludge spilling, transparent background.
```

---

## 灵感借鉴方向（非直接照搬）

- `Returnal` 提供了很强的“敌人按战斗角色分工，再按组合关系测试”的思路，所以第二关大量使用了牵引、弹幕、近战扑杀和弱点暴露的混编结构。
- `DOOM` 系列的前线高速怪、冲锋怪和远程压制怪很适合拿来拆角色职能，因此第二关很多单位都采用了远近混合出招和假动作后高速贴脸的压迫逻辑。
- `Dead Cells` 的高压肉鸽杂兵设计很适合参考节奏感，所以我把自爆、扑脸连段、拖慢后补刀、护场支援这些高效率敌群关系吸收进了三关设计里。
- `NieR:Automata` 的大型机械体思路适合借来做 Boss 体量感，因此第一关 Boss 强调楼体寄生感，第二关 Boss 强调实验设施一体化，第三关 Boss 强调阀门、泵房、污水系统和身体结构融为一体。
- 第一关整体目标不是单纯教操作，而是让玩家从开局就明白这个世界的敌意来自结构裂开后的失控扩散。
- 第二关整体目标不是炫技弹幕，而是让玩家感觉整座实验室都在高速计算和修正自己。
- 第三关整体目标不是恶心玩家就完了，而是让拖慢、幻听、封路和沉积成为统一的文明表达。
