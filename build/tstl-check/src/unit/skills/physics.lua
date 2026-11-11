local ____exports = {}
--- 单位移动/击飞所需的轻量物理/数学工具。
function ____exports.clamp01(t)
    if t <= 0 then
        return 0
    end
    if t >= 1 then
        return 1
    end
    return t
end
function ____exports.lerp(a, b, t)
    return a + (b - a) * t
end
--- 抛物线归一化高度（0..1..0）：
-- p(t) = 4t(1-t), t in [0,1]
function ____exports.parabolaArc(t)
    local s = ____exports.clamp01(t)
    return 4 * s * (1 - s)
end
--- 更平滑的水平插值（用于横向移动），比直线 t 更接近“加速/减速”观感。
function ____exports.easeInOutQuad(t)
    local s = ____exports.clamp01(t)
    return s < 0.5 and 2 * s * s or 1 - (-2 * s + 2) ^ 2 / 2
end
function ____exports.unitVector2(dx, dy)
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < 0.000001 then
        return {nx = 0, ny = 0, dist = dist}
    end
    return {nx = dx / dist, ny = dy / dist, dist = dist}
end
return ____exports
