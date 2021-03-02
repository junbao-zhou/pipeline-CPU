import random

li = [hex(random.randint(0, 256)) for i in range(128)]

for i in li:
    print(i)
