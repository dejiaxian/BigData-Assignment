#!/usr/bin/env python3
import sys

current_key = None
total = 0

def emit(key_parts, count):
    # key_parts is a list like ['SENT','positive'] or ['TOK','negative','sad']
    print('\t'.join(key_parts + [str(count)]))

for line in sys.stdin:
    parts = line.rstrip('\n').split('\t')
    *key_parts, cnt = parts
    cnt = int(cnt)

    key = tuple(key_parts)
    if key == current_key:
        total += cnt
    else:
        if current_key is not None:
            emit(list(current_key), total)
        current_key = key
        total = cnt

# final
if current_key is not None:
    emit(list(current_key), total)
