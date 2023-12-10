gender = "male"
name = "cit_pain"
count = 13
for i in range(1, count+1):
    num = len(str(i)) == 1 and "0"+str(i) or str(i)
    print('"npc/vo/zbase/npc/'+gender+'01/'+name+num+'.wav",')