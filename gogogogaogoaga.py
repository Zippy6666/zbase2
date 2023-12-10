count = 18
for i in range(1, count+1):
    num = len(str(i)) == 1 and "0"+str(i) or str(i)
    print(f'"vo/npc/vortigaunt/vanswer{num}.wav",')