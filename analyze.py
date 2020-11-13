#!/usr/bin/python3
import csv

dropped = 0
waiting = {}

def write_to_csv(url, data):
    with open(url, "w") as fd:
        csvout = csv.writer(fd)
        for row in data:
            csvout.writerow([row[0], row[1]])

def main():
    global dropped
    data = []
    queue_size = []
    x = 0
    with open("trace.tr") as fp:
        for i, e in enumerate(fp):
            tokens = e.split()
            dropped += 1 if tokens[0] == 'd' else 0
            
            if tokens[0] == '+' and tokens[-1] not in waiting:
                waiting[tokens[-1]] = True

            if tokens[0] == '-' and tokens[-1] in waiting:
                waiting.pop(tokens[-1])

            if x == 1000:
                x = 0
                data.append((tokens[1], dropped))
                queue_size.append((tokens[1], len(waiting.keys())))
                dropped = 0
            x+=1
    
    write_to_csv("dropped.dat", data)
    write_to_csv("queue.dat", queue_size)
    print(dropped)

if __name__=="__main__":
    main()
