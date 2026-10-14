import csv
import re
from datetime import datetime

CSV_PATH = '/home/gleusmar/Downloads/militares_chapadao_do_ceu.csv'
OUTPUT_SQL = '/home/gleusmar/Documentos/dev/11crbm/scripts/inserir_chapadao_do_ceu.sql'

UNIT_ID = '4272a75a-d359-4b70-9ef4-f3297c759fec'

RANK_MAP = {
    'Cel': '6b9a6a7c-da8f-4ab5-8e0d-9005a84ef821',
    'TC': 'ee14ced8-f383-4584-bf15-32d3a4a99af5',
    'MAJ': '8511925b-6bc0-41dc-9bad-398b7a0c057a',
    'Cap': '0a909f3e-2d85-4599-8d60-9ec10f6ca416',
    'CAP': '0a909f3e-2d85-4599-8d60-9ec10f6ca416',
    '1º Ten': '31607be0-58a4-463b-aaed-9b191bede08b',
    '1º TEN': '31607be0-58a4-463b-aaed-9b191bede08b',
    '2º Ten': 'c71382c2-9f67-4b21-8f5f-adbe5201a960',
    '2º TEN': 'c71382c2-9f67-4b21-8f5f-adbe5201a960',
    'Asp Of': '4ffffa07-a1d6-47f7-8743-aad276cd83a3',
    'ASPOF': '4ffffa07-a1d6-47f7-8743-aad276cd83a3',
    'ST': '334d0773-22e5-4bd9-bec8-2e0fd36bb95f',
    '1º Sgt': '609bbc24-7f0a-41c0-98d3-c75c028b978e',
    '1º SGT': '609bbc24-7f0a-41c0-98d3-c75c028b978e',
    '2º Sgt': '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a',
    '2º SGT': '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a',
    '3º Sgt': 'b851e263-f878-41b8-89b0-0c41bc5e86ce',
    '3º SGT': 'b851e263-f878-41b8-89b0-0c41bc5e86ce',
    'Cb': 'c88b285f-ec1d-43c7-8473-23910b8839e2',
    'CB': 'c88b285f-ec1d-43c7-8473-23910b8839e2',
    'Sd 1ª Cl': 'ab40a8db-24af-475e-ac2f-db020638332d',
    'SD 1ª CL': 'ab40a8db-24af-475e-ac2f-db020638332d',
    'Sd 2ª Cl': '3649efe3-88ef-468a-ab98-1a6c20b1a17a',
    'SD 2ª CL': '3649efe3-88ef-468a-ab98-1a6c20b1a17a',
    'SD/2ª': '3649efe3-88ef-468a-ab98-1a6c20b1a17a',
    'SD': '3649efe3-88ef-468a-ab98-1a6c20b1a17a',
    'Sd': '3649efe3-88ef-468a-ab98-1a6c20b1a17a',
}

BOARD_MAP = {
    'QOC': 'QOC',
    'QOA/ADM': 'QOE/Complementar',
    'QOE/Complementar': 'QOE/Complementar',
    'QP/ESPEC': 'QP/Especial',
    'QP/COMB': 'QP/Combatente',
    'QP/Combatente': 'QP/Combatente',
    'QP/Especial': 'QP/Especial',
}


def only_digits(value, max_len=None):
    if not value:
        return ''
    digits = re.sub(r'\D', '', str(value))
    if max_len:
        digits = digits[:max_len]
    return digits


def parse_date(value):
    if not value:
        return None
    try:
        return datetime.strptime(value.strip(), '%d/%m/%Y').strftime('%Y-%m-%d')
    except ValueError:
        return None


def escape_sql(value):
    if value is None:
        return 'NULL'
    return "'" + str(value).replace("'", "''").replace('\\', '\\\\') + "'"


def main():
    sql = []
    sql.append('begin;')
    sql.append('')

    with open(CSV_PATH, newline='', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f, delimiter=';')
        for row in reader:
            full_name = row.get('Nome', '').strip()
            war_name = row.get('Nome de Guerra', '').strip().upper()
            rg = only_digits(row.get('RG', ''), 5)
            cpf = only_digits(row.get('CPF', ''), 11)
            birth_date = parse_date(row.get('Data de Nascimento', ''))
            phone = only_digits(row.get('Telefone', ''), 11)
            email = row.get('Email', '').strip() or None
            driver_category = row.get('CNH', '').strip().upper() or None
            driver_expiration = parse_date(row.get('Validade da CNH', ''))

            address_street = row.get('Rua', '').strip() or None
            address_number = row.get('nº', '').strip() or None
            address_block = row.get('Quadra', '').strip() or None
            address_lot = row.get('Lote', '').strip() or None
            address_complement = row.get('Complemento', '').strip() or None
            address_district = row.get('Bairro', '').strip() or None
            address_city = row.get('Cidade', '').strip() or None
            address_zipcode = only_digits(row.get('CEP', ''), 8)
            address_state = 'GO' if address_city and address_city == 'Goiás' else None

            inclusion_date = parse_date(row.get('Data de Inclusão', ''))

            rank_label = row.get('Posto/Graduação', '').strip()
            rank_id = RANK_MAP.get(rank_label)
            if not rank_id:
                print(f'Rank não mapeado: {rank_label} para {full_name}')
                continue

            board_label = row.get('Quadro', '').strip().upper()
            quadro = BOARD_MAP.get(board_label)
            if not quadro:
                print(f'Quadro não mapeado: {board_label} para {full_name}')
                continue

            if not cpf:
                print(f'CPF ausente: {full_name}')
                continue

            if not rg:
                print(f'RG ausente: {full_name}')
                continue

            columns = [
                'id', 'full_name', 'war_name', 'rg', 'cpf', 'birth_date', 'phone', 'email',
                'driver_license_category', 'driver_license_expiration',
                'address_street', 'address_number', 'address_block', 'address_lot', 'address_complement',
                'address_district', 'address_city', 'address_zipcode', 'address_state',
                'inclusion_date', 'unit_id', 'rank_id', 'quadro', 'classification', 'is_inactive'
            ]

            values = [
                'gen_random_uuid()',
                escape_sql(full_name),
                escape_sql(war_name),
                escape_sql(rg),
                escape_sql(cpf),
                escape_sql(birth_date),
                escape_sql(phone),
                escape_sql(email),
                escape_sql(driver_category),
                escape_sql(driver_expiration),
                escape_sql(address_street),
                escape_sql(address_number),
                escape_sql(address_block),
                escape_sql(address_lot),
                escape_sql(address_complement),
                escape_sql(address_district),
                escape_sql(address_city),
                escape_sql(address_zipcode),
                escape_sql(address_state),
                escape_sql(inclusion_date),
                f"'{UNIT_ID}'::uuid",
                f"'{rank_id}'::uuid",
                f"{escape_sql(quadro)}::public.military_board",
                "'operacional'",
                'false',
            ]

            sql.append(f"INSERT INTO public.military_personnel ({', '.join(columns)})")
            sql.append(f"VALUES ({', '.join(values)})")
            sql.append(f"ON CONFLICT (cpf) DO NOTHING;")
            sql.append("")

            taf_values = [
                ('2026/1', row.get('TAF 2026/1', '').strip()),
                ('2025/2', row.get('TAF 2025/2', '').strip()),
                ('2025/1', row.get('TAF 2025/1', '').strip()),
            ]

            for period, mention in taf_values:
                if not mention or mention.lower() in ('não fez', 'nao fez', ''):
                    continue
                mention = mention.strip().upper()
                if mention == 'IN':
                    mention = 'I'
                if mention not in ('E', 'MB', 'B', 'R', 'I', 'NF'):
                    print(f'Menção de TAF inválida: {mention} para {full_name}')
                    continue
                year, semester = period.split('/')
                sql.append(
                    f"INSERT INTO public.military_taf (military_id, year, semester, mention)")
                sql.append(
                    f"SELECT id, {year}, {semester}, {escape_sql(mention)}")
                sql.append(
                    f"FROM public.military_personnel")
                sql.append(
                    f"WHERE cpf = {escape_sql(cpf)}")
                sql.append(
                    f"  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = {year} AND t.semester = {semester});")
                sql.append("")

            health_date = parse_date(row.get('Avaliação Periódica de Saúde - Data', ''))
            health_validity = parse_date(row.get('Avaliação Periódica de Saúde - Validade', ''))
            health_status = row.get('Avaliação Periódica de Saúde - Aptidão', '').strip().upper()

            if health_date and health_status:
                is_fit = 'false' if health_status == 'INAPTO' else 'true'
                has_restrictions = 'true' if health_status == 'APTO_RESTRICOES' else 'false'
                year = datetime.strptime(health_date, '%Y-%m-%d').year
                sql.append(
                    f"INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)")
                sql.append(
                    f"SELECT id, {year}, {escape_sql(health_date)}, {escape_sql(health_validity)}, {is_fit}, {has_restrictions}")
                sql.append(
                    f"FROM public.military_personnel")
                sql.append(
                    f"WHERE cpf = {escape_sql(cpf)}")
                sql.append(
                    f"  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = {year});")
                sql.append("")

    sql.append('commit;')

    with open(OUTPUT_SQL, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql))

    print(f'SQL gerado em {OUTPUT_SQL}')


if __name__ == '__main__':
    main()
