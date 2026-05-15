#!/usr/bin/env python3
#!/usr/bin/env python3
import numpy as np
import sympy as sp

def to_hex(val, bits):
    return format(val & ((1 << bits) - 1), f'0{bits//4}x')

def gen_vectors(fname="vectors.dat", N=4, DATA_W=16, TESTS=10):
    np.random.seed(42)
    lo, hi = -(1 << (DATA_W-1)), (1 << (DATA_W-1)) - 1
    DET_W = N * DATA_W

    # Диапазон, гарантирующий отсутствие переполнения при сложении/вычитании
    SAFE_LO, SAFE_HI = -10000, 10000

    with open(fname, 'w') as f:
        for t in range(TESTS):
            # Первые 5 тестов: полный диапазон (возможно переполнение)
            # Следующие 5 тестов: безопасный диапазон (гарантированно без переполнения)
            if t < 5:
                A = np.random.randint(lo, hi + 1, (N, N), dtype=np.int64)
                B = np.random.randint(lo, hi + 1, (N, N), dtype=np.int64)
            else:
                A = np.random.randint(SAFE_LO, SAFE_HI + 1, (N, N), dtype=np.int64)
                B = np.random.randint(SAFE_LO, SAFE_HI + 1, (N, N), dtype=np.int64)

            add_raw = A + B
            sub_raw = A - B
            trans = A.T
            det = int(sp.Matrix(A.tolist()).det())

            # Флаги переполнения вычисляем по "сырым" математическим результатам
            ovf_add = int(not all(lo <= v <= hi for v in add_raw.flatten()))
            ovf_sub = int(not all(lo <= v <= hi for v in sub_raw.flatten()))

            # Если значение вышло за границы -> заменяем на -1 (0xFFFF, "все единицы")
            add_sat = np.where((add_raw < lo) | (add_raw > hi), -1, add_raw)
            sub_sat = np.where((sub_raw < lo) | (sub_raw > hi), -1, sub_raw)

            # Формат строки: ID A... B... ADD... SUB... TRANS... DET OVF_ADD OVF_SUB
            line = f"{t} "
            for m in [A, B, add_sat, sub_sat, trans]:
                line += " ".join(to_hex(v, DATA_W) for v in m.flatten()) + " "
            line += to_hex(det, DET_W)
            line += f" {ovf_add} {ovf_sub}\n"

            f.write(line)

        print(f"Сгенерировано {TESTS} тестов → {fname}")

if __name__ == "__main__":
    gen_vectors()


    