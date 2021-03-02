import random


def generate_protect_reg():
    num = 32

    text = ''

    register_indexs = [i for i in range(1, 18)]
    register_indexs.append(31)

    for i in range(register_indexs.__len__()):
        # text += "li $t0 " + str(random.randint(0, 128)) + '\n'
        text += f"sw ${register_indexs[i]} {i * 4}($sp)\n"

    text += f"addi $sp $sp {4 * (i + 1)}\n"

    print(text)


def generate_random_array():
    array_len = 128
    destination = [4 * i for i in range(array_len)]
    array_text = []
    array_text = [
        f"li $t0 {random.randint(0,256)}\n" + f"sw $t0 {i}($sp)\n" for i in destination]
    array_text.insert(0, f"sub $sp $sp {4 * array_len}\n")
    for i in array_text:
        print(i, end='')


generate_random_array()
