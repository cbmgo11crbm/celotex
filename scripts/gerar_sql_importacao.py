import csv
import re
import uuid
from pathlib import Path

CSV_PATH = Path('/home/gleusmar/Downloads/militares_13_bbm_dbm_caiaponia.csv')
SQL_PATH = Path('/home/gleusmar/Documentos/dev/11crbm/scripts/import_militares.sql')

QUADRO_MAP = {
    'QOC': 'QOC',
    'QOE/Complementar': 'QOE/Complementar',
    'QP/Especiais': 'QP/Especial',
    'QP/Combatentes': 'QP/Combatente',
}

CNH_DEFAULT = 'A'

RANK_MAP = {
    'ee14ced8-f383-4584-bf15-32d3a4a99af5': 'ee14ced8-f383-4584-bf15-32d3a4a99af5',
    '0a909f3e-2d85-4599-8d60-9ec10f6ca416': '0a909f3e-2d85-4599-8d60-9ec10f6ca416',
    '8511925b-6bc0-41dc-9bad-398b7a0c057a': '8511925b-6bc0-41dc-9bad-398b7a0c057a',
    '31607be0-58a4-463b-aaed-9b191bede08b': '31607be0-58a4-463b-aaed-9b191bede08b',
    'c71382c2-9f67-4b21-8f5f-adbe5201a960': 'c71382c2-9f67-4b21-8f5f-adbe5201a960',
    '4ffffa07-a1d6-47f7-8743-aad276cd83a3': '4ffffa07-a1d6-47f7-8743-aad276cd83a3',
    '4ffffa07-a1d6-47f7-8743-aad276cd83a4': '4ffffa07-a1d6-47f7-8743-aad276cd83a3',
    '4ffffa07-a1d6-47f7-8743-aad276cd83a5': '4ffffa07-a1d6-47f7-8743-aad276cd83a3',
    '4ffffa07-a1d6-47f7-8743-aad276cd83a6': '4ffffa07-a1d6-47f7-8743-aad276cd83a3',
    '334d0773-22e5-4bd9-bec8-2e0fd36bb95f': '334d0773-22e5-4bd9-bec8-2e0fd36bb95f',
    '609bbc24-7f0a-41c0-98d3-c75c028b978e': '609bbc24-7f0a-41c0-98d3-c75c028b978e',
    '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a': '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a',
    'b851e263-f878-41b8-89b0-0c41bc5e86ce': 'b851e263-f878-41b8-89b0-0c41bc5e86ce',
    'c88b285f-ec1d-43c7-8473-23910b8839e2': 'c88b285f-ec1d-43c7-8473-23910b8839e2',
    'ab40a8db-24af-475e-ac2f-db020638332d': 'ab40a8db-24af-475e-ac2f-db020638332d',
    '3649efe3-88ef-468a-ab98-1a6c20b1a17a': '3649efe3-88ef-468a-ab98-1a6c20b1a17a',
}

# Unidade DBM CPN aparece no CSV com variações de dígito no final do UUID.
# Todas devem apontar para o UUID real da unidade.
UNIT_MAP = {
    'ccb57a03-138b-4fad-b81a-e1cecee690f1': 'ccb57a03-138b-4fad-b81a-e1cecee690f1',
    'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc': 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc',
    '51dc74eb-9a4f-496a-8173-f9654362a2b9': '51dc74eb-9a4f-496a-8173-f9654362a2b9',
}
_cpn_base = '51dc74eb-9a4f-496a-8173-f9654362a2b'
for _i in range(10, 21):
    UNIT_MAP[f'{_cpn_base}{_i}'] = '51dc74eb-9a4f-496a-8173-f9654362a2b9'


def only_digits(value):
    return re.sub(r'\D', '', value or '')


def parse_date(value):
    value = (value or '').strip()
    if not value:
        return None
    m = re.match(r'(\d{1,2})/(\d{1,2})/(\d{2,4})', value)
    if not m:
        return None
    d, mo, y = m.groups()
    y = int(y)
    if y < 100:
        y = 2000 + y if y <= 30 else 1900 + y
    return f'{y:04d}-{int(mo):02d}-{int(d):02d}'


def format_cpf(value):
    v = only_digits(value)
    if not v:
        return None
    if len(v) < 11:
        return v.zfill(11)
    if len(v) > 11:
        return v[-11:]
    return v


def format_phone(value):
    v = only_digits(value)
    if not v:
        return None
    if len(v) < 10:
        return None
    if len(v) > 11:
        return v[:11]
    return v


def format_cep(value):
    v = only_digits(value)
    if not v:
        return None
    return v.zfill(8) if len(v) < 8 else v


def clean_email(value):
    v = (value or '').strip().lower()
    if not v:
        return None
    v = v.split()[0]
    if not re.match(r'^[^@\s]+@[^@\s]+\.[^@\s]+$', v):
        return None
    return v


def clean_blood(value):
    v = (value or '').strip().upper().replace(' ', '')
    if not v or v in ('NA', 'N/A', '-'):
        return None
    return v if v in {'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'} else None


def clean_cnh(value):
    v = (value or '').strip().upper()
    return v if v in {'A', 'B', 'AB', 'C', 'D', 'E', 'AC', 'AD', 'AE'} else CNH_DEFAULT


def clean_quadro(value):
    v = (value or '').strip()
    return QUADRO_MAP.get(v, v)


def _fix_uuid(value):
    v = (value or '').strip()
    parts = v.split('-')
    if len(parts) == 5 and len(parts[4]) > 12:
        parts[4] = parts[4][:12]
        v = '-'.join(parts)
    try:
        uuid.UUID(v)
        return v
    except ValueError:
        return None


def clean_rank_id(value):
    v = (value or '').strip()
    mapped = RANK_MAP.get(v)
    if mapped:
        return mapped
    return _fix_uuid(value)


def clean_unit_id(value):
    v = (value or '').strip()
    mapped = UNIT_MAP.get(v)
    if mapped:
        return mapped
    return _fix_uuid(value)


def clean_text(value):
    v = (value or '').strip()
    return v if v else None


def parse_taf_mention(value):
    v = (value or '').strip().upper()
    if not v or v in ('NÃO FEZ', 'NAO FEZ', 'N/A', '-'):
        return None
    return v


def parse_health_fit(value):
    v = (value or '').strip().upper()
    if 'RESTR' in v:
        return 'APTO_RESTRICOES'
    if v == 'APTO':
        return 'APTO'
    if v in ('INAPTO', 'INÁPTO'):
        return 'INAPTO'
    return None


def sql_value(value):
    if value is None:
        return 'NULL'
    if isinstance(value, bool):
        return 'TRUE' if value else 'FALSE'
    escaped = str(value).replace("'", "''")
    return f"'{escaped}'"


def main():
    sql_lines = [
        "BEGIN;",
        "",
        "-- Importação de militares a partir de CSV",
        "-- Obs: driver_license_category vazio foi preenchido com 'A' como padrão.",
        "-- Os triggers de auditoria permanecem ativos.",
        "",
    ]

    erros = []
    inseridos = 0
    taf_inseridos = 0
    saude_inseridos = 0

    with open(CSV_PATH, newline='', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader, start=2):
            m_id = str(uuid.uuid4())
            unit_id = clean_unit_id(row.get('Unidade'))
            rank_id = clean_rank_id(row.get('Posto/Graduação'))
            full_name = clean_text(row.get('Nome'))
            war_name = clean_text(row.get('Nome de Guerra'))
            rg = clean_text(row.get('RG'))
            cpf = format_cpf(row.get('CPF'))
            birth_date = parse_date(row.get('Data de Nascimento'))
            phone = format_phone(row.get('Telefone'))
            email = clean_email(row.get('Email'))
            blood_type = clean_blood(row.get('Tipagem Sanguínea'))
            driver_license_category = clean_cnh(row.get('CNH'))
            driver_license_expiration = parse_date(row.get('Validade da CNH'))
            inclusion_date = parse_date(row.get('Data de Inclusão'))
            quadro = clean_quadro(row.get('Quadro'))

            address_street = clean_text(row.get('Rua'))
            address_number = clean_text(row.get('nº'))
            address_block = clean_text(row.get('Quadra'))
            address_lot = clean_text(row.get('Lote'))
            address_complement = clean_text(row.get('Complemento'))
            address_district = clean_text(row.get('Bairro'))
            address_city = clean_text(row.get('Cidade'))
            address_zipcode = format_cep(row.get('CEP'))

            if not all([unit_id, rank_id, full_name, war_name, rg, cpf, birth_date, phone, quadro]):
                erros.append(f'Linha {i}: dados obrigatórios ausentes')
                continue

            sql_lines.append("DO $$")
            sql_lines.append("DECLARE")
            sql_lines.append(f"  m_id uuid := {sql_value(m_id)};")
            sql_lines.append("BEGIN")
            sql_lines.append("  INSERT INTO public.military_personnel (")
            sql_lines.append("    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,")
            sql_lines.append("    cpf, email, blood_type, driver_license_category, driver_license_expiration,")
            sql_lines.append("    classification, platoon, quadro, inclusion_date,")
            sql_lines.append("    address_street, address_number, address_block, address_lot,")
            sql_lines.append("    address_complement, address_district, address_city, address_zipcode,")
            sql_lines.append("    is_inactive")
            sql_lines.append("  ) VALUES (")
            sql_lines.append(
                f"    m_id, {sql_value(unit_id)}, {sql_value(rank_id)}, {sql_value(rg)}, "
                f"{sql_value(full_name)}, {sql_value(war_name)}, {sql_value(birth_date)}, "
                f"{sql_value(phone)}, {sql_value(cpf)}, {sql_value(email)}, "
                f"{sql_value(blood_type)}, {sql_value(driver_license_category)}, "
                f"{sql_value(driver_license_expiration)}, 'administrativo', NULL, "
                f"{sql_value(quadro)}::public.military_board, {sql_value(inclusion_date)}, "
                f"{sql_value(address_street)}, {sql_value(address_number)}, {sql_value(address_block)}, "
                f"{sql_value(address_lot)}, {sql_value(address_complement)}, {sql_value(address_district)}, "
                f"{sql_value(address_city)}, {sql_value(address_zipcode)}, FALSE"
            )
            sql_lines.append("  );")
            inseridos += 1

            for col_name, year, semester in [
                ('TAF 2026/1', 2026, 1),
                ('TAF 2025/2', 2025, 2),
                ('TAF 2025/1', 2025, 1),
            ]:
                mention = parse_taf_mention(row.get(col_name))
                if mention:
                    sql_lines.append("  INSERT INTO public.military_taf (")
                    sql_lines.append("    military_id, year, semester, mention")
                    sql_lines.append("  ) VALUES (m_id, {}, {}, {});".format(year, semester, sql_value(mention)))
                    taf_inseridos += 1

            health_date = parse_date(row.get('Avaliação Periódica de Saúde - Data'))
            health_fit = parse_health_fit(row.get('Avaliação Periódica de Saúde - Aptidão'))
            health_validity = parse_date(row.get('Avaliação Periódica de Saúde - Validade'))

            if health_date and health_fit and health_validity:
                is_fit = health_fit != 'INAPTO'
                has_restrictions = health_fit == 'APTO_RESTRICOES'
                year = int(health_date.split('-')[0])
                sql_lines.append("  INSERT INTO public.military_health_exams (")
                sql_lines.append("    military_id, year, exam_date, is_fit, has_restrictions, validity_date")
                sql_lines.append("  ) VALUES (m_id, {}, {}, {}, {}, {});".format(
                    year,
                    sql_value(health_date),
                    'TRUE' if is_fit else 'FALSE',
                    'TRUE' if has_restrictions else 'FALSE',
                    sql_value(health_validity),
                ))
                saude_inseridos += 1

            sql_lines.append("END $$;")
            sql_lines.append("")

    sql_lines.append("")
    sql_lines.append("COMMIT;")
    sql_lines.append("")
    sql_lines.append("-- Resumo:")
    sql_lines.append(f"-- Militares: {inseridos}")
    sql_lines.append(f"-- Registros de TAF: {taf_inseridos}")
    sql_lines.append(f"-- Avaliações de saúde: {saude_inseridos}")
    sql_lines.append(f"-- Erros: {len(erros)}")
    for e in erros[:20]:
        sql_lines.append(f"-- {e}")

    SQL_PATH.write_text('\n'.join(sql_lines), encoding='utf-8')
    print(f'SQL gerado: {SQL_PATH}')
    print(f'Militares: {inseridos}')
    print(f'TAFs: {taf_inseridos}')
    print(f'Saúde: {saude_inseridos}')
    print(f'Erros: {len(erros)}')
    for e in erros[:20]:
        print(e)


if __name__ == '__main__':
    main()
