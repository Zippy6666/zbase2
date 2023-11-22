import sys

for snd in sys.argv[1::]:
    print('"'+snd[86::].replace("\\", "/")+'",')

input()