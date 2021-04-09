def random3():
    is0 = 0
    is1 = 0
    is2 = 0

    # 0 or 1
    res = random2()
    if res == 0:
        is0 += 1
    else:
        is1 += 1

    # 0 or 2
    res = random2()
    if res == 0:
        is0 += 1
    else:
        is2 += 1

    # 1 or 2
    res = random2()
    if res == 0:
        is1 += 1
    else:
        is2 += 1

    if is0 == 2: return 0
    if is1 == 2: return 1
    if is2 == 2: return 2
    return random3()
