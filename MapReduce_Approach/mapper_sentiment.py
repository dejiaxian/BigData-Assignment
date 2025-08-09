#!/usr/bin/env python3
import sys, csv, re

# A tiny seed lexicon—expand as you like
POS_LEX = {'good','great','love','excellent','awesome','fantastic','best','happy','enjoy'}
NEG_LEX = {'bad','terrible','hate','awful','worst','poor','sad','disappoint','angry'}

# minimal stopword set
STOPWORDS = {
    'a','an','and','are','as','at','be','but','by','for','if','in','into','is',
    'it','no','not','of','on','or','such','that','the','their','then','there',
    'these','they','this','to','was','will','with'
}

def classify(text):
    tokens = re.findall(r"[A-Za-z']+", text.lower())
    pos = sum(1 for t in tokens if t in POS_LEX)
    neg = sum(1 for t in tokens if t in NEG_LEX)
    if pos > neg: return 'positive'
    if neg > pos: return 'negative'
    return 'neutral'

def simple_lemma(tok):
    if tok.endswith('ies') and len(tok)>4: return tok[:-3]+'y'
    if tok.endswith('ing') and len(tok)>5: return tok[:-3]
    if tok.endswith('ed')  and len(tok)>4: return tok[:-2]
    if tok.endswith('s')   and len(tok)>3: return tok[:-1]
    return tok

reader = csv.DictReader(sys.stdin)
for row in reader:
    txt = row.get('review','').strip()
    if not txt:
        continue

    label = classify(txt)
    # 1) emit sentiment count
    print(f"SENT\t{label}\t1")

    # 2) emit token counts under that label
    for tok in re.findall(r"[A-Za-z']+", txt.lower()):
        if tok in STOPWORDS: 
            continue
        lemma = simple_lemma(tok)
        print(f"TOK\t{label}\t{lemma}\t1")
