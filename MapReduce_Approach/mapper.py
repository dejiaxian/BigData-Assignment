#!/usr/bin/env python3
import sys
import csv
import re

# --- Built-in stopwords ---
STOPWORDS = {
    'a','an','and','are','as','at','be','but','by','for','if','in','into','is',
    'it','no','not','of','on','or','such','that','the','their','then','there',
    'these','they','this','to','was','will','with'
}

def simple_lemma(token: str) -> str:
    """
    A minimal, rule-based lemmatizer:
      - ies → y
      - ing, ed → strip
      - final 's' → strip (for plurals)
    """
    if token.endswith('ies') and len(token) > 4:
        return token[:-3] + 'y'
    if token.endswith('ing') and len(token) > 5:
        return token[:-3]
    if token.endswith('ed') and len(token) > 4:
        return token[:-2]
    if token.endswith('s') and len(token) > 3:
        return token[:-1]
    return token

# --- Mapper logic ---
reader = csv.DictReader(sys.stdin)
for row in reader:
    text = row.get('review', '')
    if not text or not text.strip():
        continue

    # tokenize on letters/apostrophes, lowercase
    for token in re.findall(r"[A-Za-z']+", text.lower()):
        if token in STOPWORDS:
            continue
        lemma = simple_lemma(token)
        print(f"{lemma}\t1")
