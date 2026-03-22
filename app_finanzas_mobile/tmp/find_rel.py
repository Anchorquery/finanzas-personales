import json
import os

path = r'c:\Users\Pruebas\.gemini\antigravity\brain\d93918a7-0ac9-421e-8c77-6c5394cabf03\.system_generated\steps\192\output.txt'

with open(path, 'r') as f:
    data = json.load(f)

raw = data.get('raw', [])
for rel in raw:
    if rel.get('collection') == 'transaction_items' or rel.get('related_collection') == 'transaction_items':
        print(json.dumps(rel, indent=2))
