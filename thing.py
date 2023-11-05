def main():
    with open("C://Program Files (x86)//Steam//steamapps//common//GarrysMod//garrysmod//addons//zbase2//lua//zbase//server//tasks.lua", "r") as f:
        lines = f.readlines()

    num = 0
    for line in lines:
        linenew = ""

        for char in line:
            linenew += char

            if char == ",":
                break

        print(linenew)
        # linenew = f'["{linenew}"] = {num},'

        # if linenew.startswith('["TASK_'):
        #     print(linenew)
        #     num += 1


if __name__ == "__main__":
    main()