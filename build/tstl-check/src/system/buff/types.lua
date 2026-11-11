local ____exports = {}
--- Buff 类型标识，用于叠加规则、驱散等
____exports.BuffTypeId = {SHIELD = "shield"}
--- 持续时间语义：负数表示永久（如光环或直到被打破的护盾）
____exports.BUFF_DURATION_PERMANENT = -1
--- Buff 列表变化（增删、过期、护盾耗尽移除），载荷 `{ actor: Actor }`
____exports.BUFF_EVENT_BUFFS_CHANGED = "buff:buffsChanged"
return ____exports
