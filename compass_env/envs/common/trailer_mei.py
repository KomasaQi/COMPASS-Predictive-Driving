import math
import numpy as np
from numba import njit

D_SAFE = 0.0
EPS = 1e-12

# =========================
# 0) Small scalar helpers
# =========================
@njit(cache=True)
def cross2(ax, ay, bx, by):
    return ax * by - ay * bx


# =========================
# 1) Fast single-pair OBB collision (SAT, center-radius form)
# =========================
@njit(cache=True)
def obb_collision_sat(xA, yA, hA, lA, wA,
                      xB, yB, hB, lB, wB):
    cA = math.cos(hA); sA = math.sin(hA)
    cB = math.cos(hB); sB = math.sin(hB)

    # local axes for each box
    uAx, uAy = cA, sA
    vAx, vAy = -sA, cA
    uBx, uBy = cB, sB
    vBx, vBy = -sB, cB

    hxA, hyA = 0.5 * lA, 0.5 * wA
    hxB, hyB = 0.5 * lB, 0.5 * wB

    dx = xB - xA
    dy = yB - yA

    def axis_overlap(ax, ay):
        t = dx * ax + dy * ay
        rA = hxA * abs(uAx * ax + uAy * ay) + hyA * abs(vAx * ax + vAy * ay)
        rB = hxB * abs(uBx * ax + uBy * ay) + hyB * abs(vBx * ax + vBy * ay)
        return abs(t) <= (rA + rB + 1e-15)

    if not axis_overlap(uAx, uAy): return False
    if not axis_overlap(vAx, vAy): return False
    if not axis_overlap(uBx, uBy): return False
    if not axis_overlap(vBx, vBy): return False
    return True


# =========================
# 2) Rectangle corners (standard rotation, consistent for ACT + RTTC bbox)
# =========================
@njit(cache=True)
def rect_corners(x, y, h, l, w):
    c = math.cos(h); s = math.sin(h)
    hx, hy = 0.5 * l, 0.5 * w

    out = np.empty((4, 2), dtype=np.float64)
    # (-hx,+hy), (+hx,+hy), (+hx,-hy), (-hx,-hy) rotated by [c -s; s c]
    out[0, 0] = x + (-hx) * c - ( hy) * s
    out[0, 1] = y + (-hx) * s + ( hy) * c

    out[1, 0] = x + ( hx) * c - ( hy) * s
    out[1, 1] = y + ( hx) * s + ( hy) * c

    out[2, 0] = x + ( hx) * c - (-hy) * s
    out[2, 1] = y + ( hx) * s + (-hy) * c

    out[3, 0] = x + (-hx) * c - (-hy) * s
    out[3, 1] = y + (-hx) * s + (-hy) * c
    return out


# =========================
# 3) Shortest distance (ACT) - same definition as your corner-to-edge search
# =========================
@njit(cache=True)
def point_segment_dist(px, py, x1, y1, x2, y2):
    vx = x2 - x1
    vy = y2 - y1
    wx = px - x1
    wy = py - y1
    c1 = wx * vx + wy * vy
    if c1 <= 0.0:
        dx = px - x1; dy = py - y1
        return math.sqrt(dx*dx + dy*dy), x1, y1
    c2 = vx * vx + vy * vy
    if c2 <= c1:
        dx = px - x2; dy = py - y2
        return math.sqrt(dx*dx + dy*dy), x2, y2
    b = c1 / c2
    bx = x1 + b * vx
    by = y1 + b * vy
    dx = px - bx; dy = py - by
    return math.sqrt(dx*dx + dy*dy), bx, by


@njit(cache=True)
def shortest_distance_and_points(cA, cB):
    min_d = 1e300
    ax = ay = bx = by = 0.0

    # A corners to B edges
    for i in range(4):
        px, py = cA[i, 0], cA[i, 1]
        for k in range(4):
            x1, y1 = cB[k, 0], cB[k, 1]
            x2, y2 = cB[(k + 1) & 3, 0], cB[(k + 1) & 3, 1]
            d, qx, qy = point_segment_dist(px, py, x1, y1, x2, y2)
            if d < min_d:
                min_d = d
                ax, ay = px, py
                bx, by = qx, qy

    # B corners to A edges
    for i in range(4):
        px, py = cB[i, 0], cB[i, 1]
        for k in range(4):
            x1, y1 = cA[k, 0], cA[k, 1]
            x2, y2 = cA[(k + 1) & 3, 0], cA[(k + 1) & 3, 1]
            d, qx, qy = point_segment_dist(px, py, x1, y1, x2, y2)
            if d < min_d:
                min_d = d
                ax, ay = qx, qy
                bx, by = px, py

    return min_d, ax, ay, bx, by


# =========================
# 4) InDepth (EI core) - analytic equivalent to your max-over-4-corners form
# =========================
@njit(cache=True)
def compute_InDepth_fast(xA, yA, vA, hA, lA, wA,
                         xB, yB, vB, hB, lB, wB):

    vAx = vA * math.cos(hA); vAy = vA * math.sin(hA)
    vBx = vB * math.cos(hB); vBy = vB * math.sin(hB)
    vdx = vBx - vAx
    vdy = vBy - vAy
    vnorm = math.sqrt(vdx*vdx + vdy*vdy)
    if vnorm < EPS:
        return np.nan

    # theta = v_diff / ||v_diff||
    tx = vdx / vnorm
    ty = vdy / vnorm
    # perpendicular unit
    px = -ty
    py = tx

    dx = xB - xA
    dy = yB - yA
    D_t1 = abs(dx * px + dy * py)

    # For a rectangle, max orth distance to theta equals:
    # d_max = hx*|dot(u,perp)| + hy*|dot(v,perp)|
    cA = math.cos(hA); sA = math.sin(hA)
    cB = math.cos(hB); sB = math.sin(hB)

    uAx, uAy = cA, sA
    vAx2, vAy2 = -sA, cA

    uBx, uBy = cB, sB
    vBx2, vBy2 = -sB, cB

    hxA, hyA = 0.5*lA, 0.5*wA
    hxB, hyB = 0.5*lB, 0.5*wB

    dA = hxA * abs(uAx*px + uAy*py) + hyA * abs(vAx2*px + vAy2*py)
    dB = hxB * abs(uBx*px + uBy*py) + hyB * abs(vBx2*px + vBy2*py)

    MFD = D_t1 - (dA + dB)
    InDepth = D_SAFE - MFD
    return InDepth


# =========================
# 5) RTTC - EXACT logic replication of your original is_ray_intersect_segment()
#    but without numpy arrays and without np.cross deprecation warning
# =========================
@njit(cache=True)
def ray_segment_intersect_original_style(ox, oy, dx, dy, ax, ay, bx, by):
    # Equivalent to:
    # v1 = O - A
    # v2 = B - A
    # v3 = perp(D) normalized
    # dot = v2·v3
    # t1 = cross(v2,v1)/dot
    # t2 = v1·v3/dot
    # if 0<=t2<=1 -> return t1 else None
    # parallel/collinear handling replicates your code (including dot projections)

    v1x = ox - ax
    v1y = oy - ay
    v2x = bx - ax
    v2y = by - ay

    # v3 = perp(D) normalized
    dnorm = math.sqrt(dx*dx + dy*dy)
    if dnorm < EPS:
        return np.nan
    v3x = -dy / dnorm
    v3y =  dx / dnorm

    dot = v2x * v3x + v2y * v3y

    if abs(dot) < 1e-10:
        # check collinear using cross(v1, v2)
        if abs(cross2(v1x, v1y, v2x, v2y)) < 1e-10:
            # t0 = dot(A - O, D), t1 = dot(B - O, D)  (exactly your code)
            t0 = (ax - ox) * dx + (ay - oy) * dy
            t1 = (bx - ox) * dx + (by - oy) * dy
            if t0 >= 0.0 and t1 >= 0.0:
                return t0 if t0 < t1 else t1
            if t0 < 0.0 and t1 < 0.0:
                return np.nan
            return 0.0
        return np.nan

    t1 = cross2(v2x, v2y, v1x, v1y) / dot
    t2 = (v1x * v3x + v1y * v3y) / dot

    if 0.0 <= t2 <= 1.0:
        return t1
    return np.nan


@njit(cache=True)
def compute_RTTC_exact(xA, yA, vA, hA, lA, wA,
                       xB, yB, vB, hB, lB, wB,
                       cornersA, cornersB):

    vAx = vA * math.cos(hA); vAy = vA * math.sin(hA)
    vBx = vB * math.cos(hB); vBy = vB * math.sin(hB)
    rvx = vAx - vBx
    rvy = vAy - vBy
    vrel = math.sqrt(rvx*rvx + rvy*rvy)
    if vrel < EPS:
        return np.nan, np.nan, np.nan

    DTC = np.nan

    # First loop: rays from A corners along +v_rel to B edges
    for i in range(4):
        has_neg = False
        ox, oy = cornersA[i, 0], cornersA[i, 1]
        for j in range(4):
            ax, ay = cornersB[j, 0], cornersB[j, 1]
            bx, by = cornersB[(j + 1) & 3, 0], cornersB[(j + 1) & 3, 1]
            dist = ray_segment_intersect_original_style(ox, oy, rvx, rvy, ax, ay, bx, by)
            if not math.isnan(dist):
                if math.isnan(DTC):
                    DTC = dist
                if dist > 0.0:
                    DTC = dist if dist < DTC else DTC
                if dist < 0.0:
                    has_neg = True
                if has_neg and dist > 0.0:
                    return 0.0, 0.0, vrel

    # Second loop: rays from B corners along -v_rel to A edges
    for i in range(4):
        has_neg = False
        ox, oy = cornersB[i, 0], cornersB[i, 1]
        for j in range(4):
            ax, ay = cornersA[j, 0], cornersA[j, 1]
            bx, by = cornersA[(j + 1) & 3, 0], cornersA[(j + 1) & 3, 1]
            dist = ray_segment_intersect_original_style(ox, oy, -rvx, -rvy, ax, ay, bx, by)
            if not math.isnan(dist):
                if math.isnan(DTC):
                    DTC = dist
                if dist >= 0.0:
                    DTC = dist if dist < DTC else DTC
                if dist < 0.0 and not math.isnan(DTC) and DTC < 0.0:
                    # replicate your "if DTC < 0: DTC = max(DTC, dist)" logic
                    DTC = dist if dist > DTC else DTC
                    has_neg = True
                if dist < 0.0:
                    has_neg = True
                if has_neg and dist > 0.0:
                    return 0.0, 0.0, vrel

    if not math.isnan(DTC):
        RTTC = DTC / vrel
        return RTTC, DTC, vrel

    return np.nan, np.nan, np.nan


# =========================
# 6) Optimized compute_real_time_metrics (math-consistent)
# =========================
@njit(cache=True)
def compute_real_time_metrics_fast(xA, yA, vA, hA, lA, wA,
                                   xB, yB, vB, hB, lB, wB):

    # 1) collision (fast, exact)
    if obb_collision_sat(xA, yA, hA, lA, wA, xB, yB, hB, lB, wB):
        nan = np.nan
        return nan, nan, nan, nan, nan, nan, nan, nan

    # 2) corners (once)
    cornersA = rect_corners(xA, yA, hA, lA, wA)
    cornersB = rect_corners(xB, yB, hB, lB, wB)

    # 3) shortest distance + closest points
    shortest_d, ax, ay, bx, by = shortest_distance_and_points(cornersA, cornersB)

    # 4) v_closest (same as your definition)
    dx = bx - ax
    dy = by - ay
    dist = math.sqrt(dx*dx + dy*dy)
    if dist > EPS:
        ux = dx / dist
        uy = dy / dist
        vAx = vA * math.cos(hA); vAy = vA * math.sin(hA)
        vBx = vB * math.cos(hB); vBy = vB * math.sin(hB)
        vdx = vBx - vAx
        vdy = vBy - vAy
        v_closest = -(ux * vdx + uy * vdy)
    else:
        v_closest = 0.0

    # Not approaching -> keep same output policy: ACT/MEI/RTTC as NaN
    if v_closest <= 0.0:
        nan = np.nan
        return nan, v_closest, shortest_d, nan, nan, nan, nan, nan

    # 5) InDepth (equivalent math)
    InDepth = compute_InDepth_fast(xA, yA, vA, hA, lA, wA, xB, yB, vB, hB, lB, wB)
    if math.isnan(InDepth) or InDepth < 0.0:
        nan = np.nan
        return nan, v_closest, shortest_d, InDepth, nan, nan, nan, nan

    # 6) ACT
    ACT = shortest_d / v_closest

    # 7) RTTC (EXACT replication of your RTTC math)
    RTTC, DTC, v_norm = compute_RTTC_exact(
        xA, yA, vA, hA, lA, wA,
        xB, yB, vB, hB, lB, wB,
        cornersA, cornersB
    )

    # 8) MEI
    if (not math.isnan(RTTC)) and RTTC != 0.0:
        MEI = InDepth / RTTC
    else:
        MEI = np.nan

    return ACT, v_closest, shortest_d, InDepth, MEI, RTTC, DTC, v_norm


# # =========================
# # 7) Example main (same as your test)
# # =========================
# def main(verbose=False):
#     x_A = 0.0
#     y_A = 0.0
#     v_A = 0.1
#     h_A = 0.0
#     l_A = 10.0
#     w_A = 2.5

#     x_B = -2.0
#     y_B = 8.0
#     v_B = 5.0
#     h_B = -1.0
#     l_B = 4.8
#     w_B = 1.8

#     ACT, v_closest, Shortest_D, InDepth, MEI, RTTC, DTC, v_norm = compute_real_time_metrics_fast(
#         x_A, y_A, v_A, h_A, l_A, w_A,
#         x_B, y_B, v_B, h_B, l_B, w_B
#     )

#     if verbose:
#         print(f"ACT: {ACT:.4f} s")
#         print(f"v_closest: {v_closest:.4f} m/s")
#         print(f"Shortest_D: {Shortest_D:.4f} m")

#         print(f"RTTC: {RTTC:.4f} s")
#         print(f"DTC: {DTC:.4f} m")
#         print(f"v_norm: {v_norm:.4f} m/s")

#         print(f"InDepth: {InDepth:.4f} m")
#         print(f"MEI: {MEI:.4f} m/s")


# if __name__ == "__main__":
#     import time

#     # warm-up (Numba compile)
#     main(verbose=False)

#     test_time = 10000
#     tic = time.time()
#     for _ in range(test_time):
#         main(verbose=False)
#     toc = time.time()

#     main(verbose=True)
#     print("average time cost: ", (toc - tic) / test_time * 1000, "ms")
