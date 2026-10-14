import csv
import re
from collections import Counter
from pathlib import Path

CSV_PATH = Path('/home/gleusmar/Downloads/militares_13_bbm_dbm_caiaponia.csv')

BLOOD_TYPES = {'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', ''}
CNH_CATS = {'A', 'B', 'AB', 'C', 'D', 'E', 'AC', 'AD', 'AE'}
QUADRO_MAP = {
    'QOC': 'QOC',
    'QOE/Complementar': 'QOE/Complementar',
    'QP/Especiais': 'QP/Especial',
    'QP/Combatentes': 'QP/Combatente',
}

def parse_date(value):
    value = (value or '').strip()
    if not value:
        return None
    m = re.match(r'(\d{1,2})/(\d{1,2})/(\d{2,4})', value)
    if not m:
        return f'INVALID:{value}'
    d, mo, y = m.groups()
    y = int(y)
    if y < 100:
        y = 2000 + y if y <= 30 else 1900 + y
    return f'{y:04d}-{int(mo):02d}-{int(d):02d}'

def only_digits(value, length=None):
    v = re.sub(r'\D', '', value or '')
    if length and len(v) < length:
        v = v.zfill(length)
    return v

def first_email(value):
    v = (value or '').strip().lower()
    if not v:
        return None
    return v.split()[0]

problemas = []
contagens = Counter()

with open(CSV_PATH, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for i, row in enumerate(reader, start=2):
        cpf = only_digits(row.get('CPF', ''), 11)
        if len(cpf) != 11:
            problemas.append(f'Linha {i}: CPF inválido [{row.get("CPF")}] -> {cpf}')
        telefone = only_digits(row.get('Telefone', ''))
        if not (10 <= len(telefone) <= 11):
            problemas.append(f'Linha {i}: Telefone inválido [{row.get("Telefone")}] -> {telefone}')
        if row.get('Data de Nascimento') and parse_date(row.get('Data de Nascimento')).startswith('INVALID'):
            problemas.append(f'Linha {i}: Data de Nascimento inválida [{row.get("Data de Nascimento")}]')
        email = first_email(row.get('Email', ''))
        if email and not re.match(r'^[^@\s]+@[^@\s]+\.[^@\s]+$', email):
            problemas.append(f'Linha {i}: Email inválido [{row.get("Email")}] -> {email}')
        blood = (row.get('Tipagem Sanguínea') or '').strip()
        if blood and blood not in BLOOD_TYPES:
            problemas.append(f'Linha {i}: Tipagem sanguínea inválida [{blood}]')
        cnh = (row.get('CNH') or '').strip().upper()
        if cnh not in CNH_CATS:
            problemas.append(f'Linha {i}: CNH inválida [{cnh}]')
        quadro = (row.get('Quadro') or '').strip()
        if quadro not in QUADRO_MAP:
            problemas.append(f'Linha {i}: Quadro não mapeado [{quadro}]')
        else:
            contagens['quadro_' + quadro] += 1

print('Problemas encontrados:')
for p in problemas[:30]:
    print(p)

print('\nTotal de problemas:', len(problemas))
print('\nContagens:', dict(contagens))
