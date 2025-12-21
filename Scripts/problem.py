import numpy as np

w = 40
h = 30
d = 10
flag = np.random.random((w, h, d)) < 0.03
print(flag)
