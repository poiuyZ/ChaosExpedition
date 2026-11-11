# SixHeroes Chaos Expedition：核心系统规则与数据契约

> 状态：设计稿，等待人工审核。本文整理已确定规则、待决规则和运行环境验证项；不代表玩法代码或地图配置已经实现。
>
> 职业规则以最近一次明确变更为准：七种职业，玩家上限仍为六名真实玩家。

## 1. 设计原则与项目适配

- 游戏目标为 Warcraft III 1.27b 多人合作生存 RPG；仓库现有模板文档和工具链主要标注 1.27a，因此 1.27b + KKWE/YDWE 的兼容性必须另行实测。
- 沿用 TypeScript → TSTL → Lua 与现有 `@eiriksgata/wc3ts` 封装。核心规则由 TypeScript 管理，不平行实现为 ECA、JASS 和 Lua 多套业务逻辑。
- [`src/main.ts`](../src/main.ts) 的 `initialize()` 是运行时编排入口。[`maps/`](../maps/) 是 w3x2lni LNI 工程；玩家槽位应以 LNI 地图配置为源，避免只改生成脚本而与编辑器地图设置脱节。
- 不在设计中臆造职业、技能、怪物和物品 rawcode，也不为尚未确定的规则填入数量、价格、间隔或奖励数值。
- 玩法状态变更必须在所有客户端确定性一致。若由本地 UI 发起购买或职业选择，先经同步指令再由共享逻辑验证并应用；不得在仅本地执行的 UI 回调中直接改玩家资源或创建单位。

## 2. 当前六人地图配置检查

### [`maps/table/w3i.ini`](../maps/table/w3i.ini)

| 项目 | 当前配置 | 对六名真实玩家的影响 |
|---|---|---|
| 声明玩家数 | 4 | 需要配置六个可玩的真实玩家槽位。 |
| 玩家 0、1 | 玩家 1、2；类型 `1` | 当前两名用户玩家。 |
| 玩家 2、3 | 玩家 3、4；类型 `2` | 当前是电脑玩家，不可计入六名真实玩家。 |
| 出生点 | 4 个：`(-512, -3328)`、`(-320, 2432)`、`(-1088, -1792)`、`(1088, 1984)` | 当前不足六个；新增两个坐标必须结合地形和可达性由用户/地图设计确定。 |
| 队伍 | 1 队，玩家列表 `{1, 2, 3, 4}` | 需让最终玩家列表只包含配置的真实玩家；是否共享控制、视野和胜负仍是独立规则。 |

### [`maps/map/war3map.j`](../maps/map/war3map.j)

当前生成的 JASS 配置与 [`w3i.ini`](../maps/table/w3i.ini) 的信息需要一起审视：

- `config()` 调用 `SetPlayers(4)`、`SetTeams(4)`，并只定义起点索引 `0..3`。
- `InitCustomPlayerSlots()` 初始化玩家索引 `0..3`，其中 `0、1` 为 `MAP_CONTROL_USER`，`2、3` 为 `MAP_CONTROL_COMPUTER`。
- `config()` 的 `SetPlayerSlotAvailable` 也只覆盖 `0..3`，并把后两个标为电脑。
- 文件中存在 `InitCustomTeams()` 函数定义，但当前 `config()` 未调用它；不能仅凭该函数定义认定运行时队伍已经按预期设置。
- [`w3i.ini`](../maps/table/w3i.ini) 声明 1 队，而 JASS `SetTeams(4)` 与之不一致。应由地图配置保存/生成流程统一并复查结果，不应只改其中一份。

### 六名真实玩家所需的最小地图调整

1. 在 [`w3i.ini`](../maps/table/w3i.ini) 中配置六个用户槽位（玩家索引 `0..5`），电脑玩家数量为零；将声明玩家数与六个玩家项、队伍成员和起点数量对齐。
2. 现有四个起点可以保留；补充两个经地形确认的坐标。坐标不可从当前配置或代码推断。
3. 让生成后的 `war3map.j` 与 LNI 配置一致：玩家数六、起点索引 `0..5`、六个用户玩家的 controller 和 slot availability、符合最终合作规则的队伍数与队伍成员。
4. 目前没有依据改变 `共享视野`、`共享单位控制` 或 `共享高级单位设置`；这些不能因为“合作”而默认为开启。
5. 实施时优先通过 KKWE 打开并保存 [`maps/`](../maps/) LNI 工程，检查写回结果。不要将电脑槽位计入六名真实玩家，也不要仅编辑打包产物。

## 3. 四个核心管理器

建议的新代码边界为 `src/system/gameplay/`，玩法配置放在 `src/config/gameplay/`。这些是提议路径，尚未创建。

| 模块 | 唯一职责 | 依赖/协作 |
|---|---|---|
| `PlayerManager` | 从已配置槽位中识别实际进行中的用户玩家；维护玩家索引、玩家 handle 和本局状态；检查真实玩家人数是否在 1..6。电脑玩家和空槽不计入玩家人数。 | 向 `HeroManager`、`EconomyManager` 提供有效玩家集合。 |
| `HeroManager` | 每位玩家的初始农民、职业选择状态、职业单位/属性/技能配置及归属关系。初始农民基准攻击 10、防御 1、生命 100。 | 消费 `PlayerManager` 的玩家列表；使用 [`Actor`](../src/system/actor.ts)/[`Unit`](../wc3ts/src/handles/unit.ts) 创建与 wrapper 属性接口。 |
| `WaveManager` | 波次状态机、准备/战斗/结算状态、普通怪和精英生成、Boss 波次、当前波单位追踪与清理。 | 只追踪自己创建的战斗单位；死亡事件去重后委托 `EconomyManager` 发奖。 |
| `EconomyManager` | 金币、木材的读取/扣除/发放及商店交易校验。每位有效玩家初始 10 金币。它是资源写入的唯一业务入口。 | 玩家验证依赖 `PlayerManager`；接收 `WaveManager` 的奖励请求；为药品/技能商店执行交易。 |

### 调用与状态流

```text
main.initialize()
  ├─ ydlua.initialize()
  ├─ 现有事件、伤害、Buff、UI 系统初始化
  └─ GameplayBootstrap
       ├─ PlayerManager.init()         -> 有效用户玩家 1..6
       ├─ EconomyManager.init(players) -> 为每位玩家设初始金币
       ├─ WaveManager.init()           -> 先挂死亡监听，准备波次状态
       └─ HeroManager.init(players)    -> 创建/配置初始农民，进入职业选择

职业选择/商店 UI -> 同步玩家意图 -> 共享逻辑校验 -> Hero/Economy 状态变更
WaveManager 创建单位 -> 记录 spawnId/所属波次/单位类型/奖励类别
单位死亡事件 -> WaveManager 确认归属并去重 -> EconomyManager 发放奖励
```

初始化细节：

1. 在玩法对象生成前初始化所需的事件/伤害基础设施。
2. 先识别玩家并初始化经济，再创建农民；WaveManager 的死亡监听应在第一波刷怪前安装。
3. 首波开始条件必须等用户确认职业选择与准备阶段规则后再编码。
4. `HeroManager` 与 `WaveManager` 不直接修改玩家金币/木材；只能调用 `EconomyManager`。
5. 购买与选择事件只携带请求意图；所有客户端使用同一逻辑检查玩家身份、价格、资源、商品/职业有效性和重复请求。

## 4. 规则状态分类

分类定义：

- **A — 已确定**：可纳入正式规则配置，但实施前仍需映射到尚未提供的 rawcode 或地图数据。
- **B — 尚未确定**：必须由用户决定，不应由 Agent 补值或猜测。
- **C — 环境验证项**：有源码/声明依据，但必须在目标 1.27b + KKWE/YDWE 实际运行环境验证。

### A. 已确定，可直接采用

| 规则 ID | 已确定规则 | 不隐含的内容 |
|---|---|---|
| `players.maxRealPlayers` | 实际用户玩家数为 1..6，最多六名；电脑玩家不计入。 | 玩家掉线后是否仍占用名额/如何处理待定。 |
| `economy.initialGold` | 每位有效玩家初始 10 金币。 | 初始木材未定义，不能默认为 0 或其他值。 |
| `hero.initialPeasant` | 每位玩家的初始农民基准攻击 10、防御 1、生命 100。 | 生命值是否等于生命上限，以及职业选择后是否替换/升级农民，待定。 |
| `hero.classes` | 职业共七种：战士 Warrior、弓箭手 Archer、法师 Mage、术士 Warlock、牧师 Priest、猎人 Hunter、恶魔 Demon。 | 7 种职业不改变 1..6 名玩家人数上限；Demon 的数据与机制未定义。 |
| `wave.firstWaveElite` | 第一波不生成精英怪。 | 普通怪数量、是否有特殊事件未定义。 |
| `wave.bossInterval` | 每五波出现一次 Boss。 | Boss 具体单位、生命、技能和奖励金额未定义。 |
| `wave.bossElite` | Boss 波伴随精英怪。 | 精英数量/类型及精英公式未定义。 |
| `elite.rewardRelation` | 精英怪金币和木材奖励都高于普通怪。 | 具体金额及是否按等级/波次变化未定义。 |
| `shops.types` | 提供药品商店和技能商店。 | 商品清单、价格、库存和购买效果未定义。 |
| `hunter.feature` | 猎人具有每波狩猎怪物的职业专属机制。 | 目标选择、狩猎次数、奖励、失败/无人可猎条件未定义。 |

Boss 波次可在配置契约中表达为 `waveNumber % 5 === 0`，并保证该波同时配置 Boss 与至少一类精英；此表达只编码已确定的周期规则，不代表已决定该波的具体数量或种类。

### B. 尚未确定，必须由用户决定

| 领域 | 需要决定的数据/规则 |
|---|---|
| 玩家与地图 | 新增的两个出生点坐标；玩家退出后是否允许中途加入；退出玩家的单位/资源处理；队伍共享视野、控制权和胜负统计。 |
| 农民与职业转换 | 是否每人恰好一名初始农民；农民是否直接作为选择载体、变身、替换成英雄或保留为支援单位；初始农民生命 100 是当前生命还是最大生命与当前生命都为 100。 |
| 七种职业数据 | 每种职业的单位 rawcode、名称/图标资源、基础生命/攻击/防御/属性、技能 rawcode、技能等级/解锁方式和职业限制。Demon 另需决定职业定位及是否有独特机制；不得自动复用其他职业设计。 |
| 选择/准备阶段 | 选择 UI 或其他交互方式；是否允许重复选择/更换；全员选择后开始还是有倒计时；未选择玩家如何处理；准备阶段长度；首波触发条件。 |
| 波次普通怪 | 每波普通怪种类和数量、生成间隔、同时存活上限、生成点/路径、失败重试与清场规则。 |
| 难度成长 | 按波次增加生命/攻击/数量的公式、上限、玩家人数缩放、最低/最高波处理。 |
| 非 Boss 波精英规则 | 第一波以后哪些波可出精英、概率或确定性公式、每波数量、随波次/玩家人数变化的规则；Boss 波已确定必须有精英，但不能据此推导其他波规则。 |
| Boss 与奖励 | Boss rawcode、每个 Boss 的技能/波次变体、Boss 波是否额外增加普通怪、Boss 金币/木材/物品奖励、Boss 奖励与精英奖励叠加规则。 |
| 战斗奖励 | 普通怪金币/木材金额、精英金额、Boss 金额；奖励按击杀者、最后一击者、全队平分还是全队各得；助攻与召唤物击杀归属；物编原生赏金是否关闭以避免重复奖励。 |
| 商店 | 药品与技能商品 ID、效果、价格、库存/刷新、每玩家限购、购买范围和失败提示。商店采用原生单位商店还是自定义 UI；技能书是立即学会、消耗品还是其他形式。 |
| 失败/胜利 | 是否存在核心建筑/目标；全队失败条件（全员死亡、目标被毁、超时等）；是否允许复活；胜利是生存到指定波次、击败最终 Boss、无尽模式记录或由玩家配置。 |
| 经济规则 | 木材初始值、木材是否可交易/共享、负数保护、是否存在其他支出或波间维护费用。 |

### C. 依赖 1.27b + KKWE/YDWE 实际环境验证

| 项目 | 代码/类型现状 | 需要验证的内容 |
|---|---|---|
| 版本兼容 | 仓库模板与 TSTL 配置以 1.27a、Lua 5.3、YDWE/KKWE JAPI 为主。 | 用户目标 1.27b 客户端、当前 KKWE/YDWE 的加载、Lua 和 JAPI 组合是否兼容。 |
| 玩家枚举 | wc3ts [`MapPlayer`](../wc3ts/src/handles/player.ts) 暴露 `controller`、`slotState`，且 [`define.ts`](../wc3ts/src/globals/define.ts) 定义用户控制/进行中常量。 | 运行时是否能可靠筛出真实进行中的用户玩家，涵盖空槽、电脑、观察者、退出和中途加入。 |
| 资源接口 | [`MapPlayer`](../wc3ts/src/handles/player.ts) 的 `getState/setState` 与 [`define.ts`](../wc3ts/src/globals/define.ts) 中金币/木材 player state 常量有类型声明。 | 金币/木材初始化、发放/扣除与 UI 显示是否一致，边界和联机同步是否可靠。 |
| 农民属性 | [`Unit`](../wc3ts/src/handles/unit.ts) wrapper 有 `armor`、`maxLife` 和 `setBaseDamageJAPI`；[`Widget`](../wc3ts/src/handles/widget.ts) 有 `life`。 | 攻击 10、防御 1、生命 100 是否按 1.27b 运行时实际生效；设置 max life 后当前 life 的行为。 |
| 创建与死亡事件 | [`Actor.create`](../src/system/actor.ts)、[`Unit.create`](../wc3ts/src/handles/unit.ts)、Timer 和 [`GameEvent`](../src/system/event/GameEvent.ts) 的死亡事件订阅均存在。 | 多波单位创建、死亡事件覆盖率、handle 生命周期、重复死亡/召唤物归属及奖励只发一次。 |
| 多人选择和购买同步 | wc3ts [`japi.d.ts`](../wc3ts/src/types/japi.d.ts) 声明 `DzSyncData`、`DzTriggerRegisterSyncData` 等。 | 目标 JAPI 行为、玩家身份获取、重复/伪造/过时操作校验、客户端确定性与断线表现。 |
| 商店与技能 | wc3ts 含原生物品/技能调用封装，1.27a 类型存在不等于 1.27b 验证。 | 选定的原生/自定义商店方案、购买事件、商品库存、添加技能/物品效果和资源扣款是否正确。 |
| 地图配置 | 目前只从现有 LNI/JASS 读取，不依赖新 API。 | 六个真实槽位在大厅、单人至六人开局、队伍配置、出生点、Start Location 路径和视野共享的实机行为。 |
| 性能 | 项目有 Timer、Group、Trigger、Actor 等封装。 | 高波次单位数量、频繁 Timer/事件订阅的性能、触发器回收与资源清理。 |

## 5. 规则配置契约草案

建议全部使用 TSTL 可编译的 TypeScript 配置，避免把 Node JSON 运行时读文件假设带入地图运行时。以下是字段契约，不是最终代码，也不填未确认值。

```ts
type HeroClassId =
  | "warrior"
  | "archer"
  | "mage"
  | "warlock"
  | "priest"
  | "hunter"
  | "demon";

interface PlayerRules {
  minRealPlayers: 1;
  maxRealPlayers: 6;
  initialGold: 10;
  initialLumber: number; // 待决定
}

interface UnitStats {
  attack: number;
  defense: number;
  maxLife: number;
  currentLife: number;
}

interface HeroClassDefinition {
  id: HeroClassId;
  unitRawcode: string; // 未确认，不得猜测
  stats: UnitStats; // 各职业属性待决定
  abilityRawcodes: string[]; // 未确认
  mechanic?: string; // 仅在规则确定后描述，例如 Hunter 的狩猎机制
}

interface WaveDefinition {
  waveNumber: number;
  normalGroups: Array<{
    unitRawcode: string; // 未确认
    count: number; // 未确认
    intervalSeconds: number; // 未确认
    spawnPointId: string; // 未确认
  }>;
  eliteRule: "none" | "configured"; // 第一波必须 none；其他波规则待决定
  bossRawcode?: string; // waveNumber 为 5 的倍数时必须配置，具体值待决定
  rewards: RewardDefinition; // 金币/木材金额与分配方式待决定
}

interface RewardDefinition {
  gold: number; // 待决定
  lumber: number; // 待决定
  distribution: string; // 待决定
}

interface ShopProduct {
  id: string;
  kind: "potion" | "skill";
  rawcode: string; // 待决定
  goldCost: number; // 待决定
  lumberCost: number; // 待决定
  stock: number; // 待决定
  effect: string; // 待决定
}
```

额外校验约束：

- 波次索引从 1 开始；波次 1 不允许配置精英。
- 波次为 5 的正整数倍时必须有 Boss 与精英配置。
- 精英的金币奖励必须大于对应普通怪金币奖励，木材奖励也必须大于对应普通怪木材奖励。
- 类别列表必须恰有七种且 ID 唯一；职业 rawcode、技能 rawcode 必须在实际物编核对后才能落配置。
- 真实玩家数筛选与经济初始化使用同一份 PlayerManager 玩家集合，禁止一处算空槽、一处把电脑算玩家。

## 6. 下一阶段 Copilot Agent 开发顺序

1. **规则签字/冻结**：先逐项处理 B 类问题，至少冻结玩家槽位、出生点、初始农民/职业转换、选择阶段、普通波次与精英公式、奖励分配和结束条件。七职业 rawcode/技能/属性先由物编来源确认。
2. **六人地图配置变更（单独审阅）**：通过 `maps/` LNI 对六个用户槽位、两处新出生点、队伍成员和 map/player metadata 进行最小变更；确认保存后的 `w3i.ini` 与生成的 `war3map.j` 一致。不要改正式地图文件，除非该阶段明确授权。
3. **配置与 PlayerManager/EconomyManager**：实现强类型规则数据、真实用户玩家筛选、人数校验和金币/木材的单一资源服务；先做可独立验证的规则测试。
4. **HeroManager**：实现初始农民及七职业定义、职业选择/准备状态机；先加入已确认数据，未知字段保持未配置，不提供假 rawcode。
5. **同步交互层**：实现并审阅选择/购买同步协议，确定幂等请求、玩家身份、重复点击与失败反馈；本地 UI 只提交意图。
6. **WaveManager 与奖励结算**：实现普通怪、非 Boss 精英规则、每五波 Boss+精英、Wave 单位追踪、死亡去重和 EconomyManager 发奖。
7. **商店**：接入药品与技能商品并复用同一交易校验；防止原生赏金与脚本奖励重复。
8. **目标版本验证**：先 TypeScript/TSTL 静态编译，再经人工批准执行 1.27b + KKWE/YDWE 的单机与多人联机验证。构建/测试脚本可能写入地图工程或启动游戏，需在相应阶段另行明确批准。

## 7. 本轮检查范围

- 阅读了 [`maps/table/w3i.ini`](../maps/table/w3i.ini)、[`maps/map/war3map.j`](../maps/map/war3map.j)、[`src/main.ts`](../src/main.ts)、管理器/事件系统、wc3ts 的玩家/单位封装与 [`tsconfig.json`](../tsconfig.json) 配置。
- 本轮只新增本设计文档；没有修改 TypeScript、Lua、JASS、INI、地图文件，也没有运行构建、测试或游戏。
