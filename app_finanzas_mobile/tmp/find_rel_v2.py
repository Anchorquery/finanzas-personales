import json

path = r'c:\Users\Pruebas\.gemini\antigravity\brain\d93918a7-0ac9-421e-8c77-6c5394cabf03\.system_generated\steps\204\output.txt'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()
    data = json.loads(content)

raw = data.get('raw', [])
found = False
for rel in raw:
    if rel.get('collection') == 'transaction_items' or rel.get('related_collection') == 'transaction_items':
        print(json.dumps(rel, indent=2))
        found = True

if not found:
    print("No relations found involving transaction_items")
