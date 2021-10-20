import time

from redis import Redis


def write_key():
    for i in range(cnt):
        key = "hget:key:" + str(i)
        ri = i % 4
        v = ""
        if ri == 1:
            v = "-"
        elif ri == 2:
            v = "err"
        elif ri == 3:
            v = time.strftime("%Y-%m-%d", time.localtime())
        else:
            pass
        client.hset(key, "gdt", v)


if __name__ == '__main__':
    host = "127.0.0.1"
    port = 6379
    db = 0
    cnt = 10000
    client = Redis(host=host, port=port, db=db)
    write_key()
