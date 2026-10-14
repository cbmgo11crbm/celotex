begin;

UPDATE public.military_personnel
SET full_name = 'Hugo Brito', war_name = 'HUGO', rg = '01554', birth_date = '1980-10-19', phone = '62984162645', email = 'hugo.brito@goias.gov.br', driver_license_category = 'AB', driver_license_expiration = '2025-08-26', address_street = 'Rua John Kennedy', address_number = '337', address_block = '00', address_lot = '00', address_complement = NULL, address_district = 'Setor Social', address_city = 'Itumbiara', address_zipcode = '75510050', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '8511925b-6bc0-41dc-9bad-398b7a0c057a'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QOC'::public.military_board, updated_at = now()
WHERE cpf = '95220216104';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '95220216104' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '95220216104'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '95220216104' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '95220216104'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-11-06', validity_date = '2026-11-04', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '95220216104' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-11-06', '2026-11-04', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '95220216104'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Ricardo Afonso Azevedo do Rosario', war_name = 'AFONSO', rg = '02156', birth_date = '1979-11-12', phone = '64981503120', email = 'afonso.rosario@bol.com.br', driver_license_category = 'AB', driver_license_expiration = '2031-12-01', address_street = 'Rua G', address_number = '241', address_block = '0', address_lot = '0', address_complement = NULL, address_district = 'Alto da Boa Vista II', address_city = 'Catalão', address_zipcode = '75703190', address_state = 'GO', inclusion_date = '2001-10-01', rank_id = '0a909f3e-2d85-4599-8d60-9ec10f6ca416'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QOC'::public.military_board, updated_at = now()
WHERE cpf = '88413357187';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '88413357187' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '88413357187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '88413357187' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '88413357187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '88413357187' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '88413357187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-01-08', validity_date = '2027-01-08', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '88413357187' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-01-08', '2027-01-08', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '88413357187'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Sócrates Cândido Pereira', war_name = 'CÂNDIDO', rg = '01724', birth_date = '1980-08-21', phone = '64999989545', email = 'socrates_candido@hotmail.com', driver_license_category = 'AD', driver_license_expiration = '2031-12-06', address_street = 'Avenida São João', address_number = '305', address_block = NULL, address_lot = NULL, address_complement = 'Ao Lado da Casa Lotérica', address_district = 'São João', address_city = 'Mineiros', address_zipcode = '75836046', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '31607be0-58a4-463b-aaed-9b191bede08b'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QOE/Complementar'::public.military_board, updated_at = now()
WHERE cpf = '91370779100';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '91370779100' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '91370779100'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '91370779100' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '91370779100'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '91370779100' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '91370779100'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-11-06', validity_date = '2026-11-04', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '91370779100' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-11-06', '2026-11-04', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '91370779100'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Marcelo Pereira Carrijo', war_name = 'MARCELO', rg = '02088', birth_date = '1981-02-22', phone = '64996464200', email = 'marcelopcarrijo@gmail.com', driver_license_category = 'AD', driver_license_expiration = '2024-06-27', address_street = 'Avenida 7', address_number = NULL, address_block = '9-A', address_lot = '11', address_complement = 'Próximo ao Supermercado Citro5', address_district = 'Setor Marcelino Teodoro', address_city = 'Mineiros', address_zipcode = '75835045', address_state = 'GO', inclusion_date = '2001-10-01', rank_id = '31607be0-58a4-463b-aaed-9b191bede08b'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QOE/Complementar'::public.military_board, updated_at = now()
WHERE cpf = '90925092134';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '90925092134' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '90925092134'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '90925092134' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '90925092134'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '90925092134' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '90925092134'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-02-12', validity_date = '2027-02-11', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '90925092134' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-02-12', '2027-02-11', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '90925092134'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Cristiano Aparecido de Rezende', war_name = 'REZENDE', rg = '01467', birth_date = '1981-06-13', phone = '64999166368', email = 'cristianoarezende@hotmail.com', driver_license_category = 'AB', driver_license_expiration = '2032-11-07', address_street = 'Avenida Treze - 13', address_number = NULL, address_block = '10', address_lot = '08', address_complement = NULL, address_district = 'Santa Isabel', address_city = 'Mineiros', address_zipcode = '75833103', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = 'c71382c2-9f67-4b21-8f5f-adbe5201a960'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QOE/Complementar'::public.military_board, updated_at = now()
WHERE cpf = '92835830197';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '92835830197' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '92835830197'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '92835830197' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '92835830197'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-07-10', validity_date = '2026-07-10', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '92835830197' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-07-10', '2026-07-10', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '92835830197'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'José Vitor da Silva Gonçalves', war_name = 'JOSÉ VITOR', rg = '04498', birth_date = '1993-04-27', phone = '2797332797', email = 'josevitor_sg@hotmail.com', driver_license_category = 'AB', driver_license_expiration = '2032-06-30', address_street = 'Rua 22 de Abril', address_number = '17', address_block = NULL, address_lot = NULL, address_complement = NULL, address_district = 'Bairro Nao Identificado', address_city = 'Viana', address_zipcode = '29134640', address_state = 'GO', inclusion_date = '2024-07-29', rank_id = '4ffffa07-a1d6-47f7-8743-aad276cd83a3'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Especial'::public.military_board, updated_at = now()
WHERE cpf = '02179612583';

UPDATE public.military_health_exams h
SET exam_date = '2025-12-04', validity_date = '2026-12-03', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '02179612583' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-12-04', '2026-12-03', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '02179612583'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Jhonata Rafael Mattana', war_name = 'MATTANA', rg = '01564', birth_date = '1980-09-23', phone = '64996464177', email = 'jhonatamattana23@gmail.com', driver_license_category = 'AD', driver_license_expiration = NULL, address_street = 'Rua D', address_number = NULL, address_block = '11', address_lot = '07', address_complement = NULL, address_district = 'Parque dos Jatobás', address_city = 'Mineiros', address_zipcode = '75837601', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '91940800110';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '91940800110' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '91940800110'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '91940800110' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '91940800110'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '91940800110' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '91940800110'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-09-25', validity_date = '2026-09-24', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '91940800110' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-09-25', '2026-09-24', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '91940800110'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Silvio César Resende Carvalho', war_name = 'CÉSAR', rg = '01317', birth_date = '1972-04-07', phone = '64999060396', email = 'silviocesarbm@gmail.com', driver_license_category = 'AD', driver_license_expiration = '2028-08-10', address_street = 'Avenida 15', address_number = NULL, address_block = '03', address_lot = '14', address_complement = NULL, address_district = 'Setor Aeroporto', address_city = 'Mineiros', address_zipcode = '75833112', address_state = 'GO', inclusion_date = '1998-06-30', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '57723974191';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '57723974191' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '57723974191'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '57723974191' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '57723974191'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-05-07', validity_date = '2027-05-06', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '57723974191' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-05-07', '2027-05-06', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '57723974191'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Jair Fialho Batista', war_name = 'FIALHO', rg = '01338', birth_date = '1971-11-18', phone = '64996416362', email = 'jairfbatista@hotmail.com', driver_license_category = 'AB', driver_license_expiration = '2026-01-08', address_street = 'Rua D', address_number = NULL, address_block = '2', address_lot = '10', address_complement = NULL, address_district = 'Residencial Versailles', address_city = 'Mineiros', address_zipcode = '75837599', address_state = 'GO', inclusion_date = '1998-06-30', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '78346657153';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '78346657153' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '78346657153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '78346657153' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '78346657153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '78346657153' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '78346657153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-11-06', validity_date = '2026-11-04', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '78346657153' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-11-06', '2026-11-04', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '78346657153'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'João Pereira de Assis', war_name = 'ASSIS', rg = '01345', birth_date = '1974-02-02', phone = '64999291744', email = 'bombneto@gmail.com', driver_license_category = 'B', driver_license_expiration = '2032-09-01', address_street = 'Rua Presidente Kennedy', address_number = NULL, address_block = '06', address_lot = '05-A', address_complement = NULL, address_district = 'Loteamento Dona Letice', address_city = 'Mineiros', address_zipcode = '75831052', address_state = 'GO', inclusion_date = '1998-06-30', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '69373299115';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '69373299115' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '69373299115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '69373299115' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '69373299115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '69373299115' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '69373299115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-02-12', validity_date = '2027-02-11', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '69373299115' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-02-12', '2027-02-11', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '69373299115'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Elismar Silva', war_name = 'ELISMAR', rg = '01344', birth_date = '1974-05-24', phone = '64999710464', email = 'elismar.silva@goias.gov.br', driver_license_category = NULL, driver_license_expiration = NULL, address_street = 'Rua 02', address_number = '35', address_block = '`S/N`', address_lot = '`S/N`', address_complement = NULL, address_district = 'Setor Oeste', address_city = 'Mineiros', address_zipcode = '75830210', address_state = 'GO', inclusion_date = '1998-06-30', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '77532384187';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '77532384187' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '77532384187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '77532384187' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '77532384187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '77532384187' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '77532384187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-06-04', validity_date = '2027-06-03', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '77532384187' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-06-04', '2027-06-03', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '77532384187'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Fábio Cabral da Silva', war_name = 'CABRAL', rg = '01342', birth_date = '1975-01-08', phone = '64999446815', email = 'fcabrall1@hotmail.com', driver_license_category = 'AD', driver_license_expiration = '2032-02-02', address_street = 'Rua Candida de Carvalho', address_number = NULL, address_block = '31', address_lot = '06', address_complement = NULL, address_district = 'Setor Cruvinel', address_city = 'Mineiros', address_zipcode = '75834137', address_state = 'GO', inclusion_date = '1998-06-30', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '83596690153';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '83596690153' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '83596690153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '83596690153' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '83596690153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '83596690153' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '83596690153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-01-22', validity_date = '2027-01-21', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '83596690153' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-01-22', '2027-01-21', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '83596690153'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Jorge Oliveira da Silva', war_name = 'JORGE', rg = '01337', birth_date = '1972-06-15', phone = '64999437351', email = 'jorgemartelinho193@gmail.com', driver_license_category = 'B', driver_license_expiration = '2022-03-21', address_street = 'Rua W1', address_number = NULL, address_block = '06', address_lot = '05', address_complement = NULL, address_district = 'Jardim Goiás', address_city = 'Mineiros', address_zipcode = '75830000', address_state = 'GO', inclusion_date = '1998-06-30', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '59741139187';

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '59741139187' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '59741139187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'R', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '59741139187' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'R'
FROM public.military_personnel mp
WHERE mp.cpf = '59741139187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'R', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '59741139187' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'R'
FROM public.military_personnel mp
WHERE mp.cpf = '59741139187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-06-23', validity_date = '2026-06-17', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '59741139187' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-06-23', '2026-06-17', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '59741139187'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Rodrigo de Almeida Silva', war_name = 'RODRIGO', rg = '01339', birth_date = '1978-03-05', phone = '64996761087', email = 'aldrigo.ra@gmail.com', driver_license_category = 'AB', driver_license_expiration = '2025-05-28', address_street = 'Avenida Alvina Paniago Vilela', address_number = NULL, address_block = '18', address_lot = '18', address_complement = 'Goias', address_district = 'Jardim Floresta', address_city = 'Mineiros', address_zipcode = '75830000', address_state = 'GO', inclusion_date = '1998-06-30', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '90078535115';

UPDATE public.military_taf t
SET mention = 'I', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '90078535115' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'I'
FROM public.military_personnel mp
WHERE mp.cpf = '90078535115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '90078535115' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '90078535115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_health_exams h
SET exam_date = '2026-03-12', validity_date = '2027-03-11', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '90078535115' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-03-12', '2027-03-11', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '90078535115'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Werley Lopes de Souza', war_name = 'WERLEY', rg = '01333', birth_date = '1971-10-30', phone = '64996460240', email = 'werleylsouza@hotmail.com', driver_license_category = 'AD', driver_license_expiration = '2031-06-21', address_street = 'Rua Antonio Candido', address_number = '1056', address_block = '0', address_lot = '0', address_complement = NULL, address_district = 'Jardim Rio Claro', address_city = 'Jataí', address_zipcode = '75802105', address_state = 'GO', inclusion_date = '1998-06-30', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '54641381100';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '54641381100' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '54641381100'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '54641381100' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '54641381100'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_health_exams h
SET exam_date = '2025-10-02', validity_date = '2026-09-26', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '54641381100' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-10-02', '2026-09-26', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '54641381100'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Evando Nunes da Silva', war_name = 'NUNES', rg = '01513', birth_date = '1977-02-18', phone = '64999544572', email = 'evandonunes@hotmail.com', driver_license_category = 'AB', driver_license_expiration = NULL, address_street = 'Rua Dom Mathias Schmidt', address_number = NULL, address_block = '12', address_lot = '26', address_complement = 'Parque São José', address_district = 'São José', address_city = 'Mineiros', address_zipcode = '75831090', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '82381291172';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '82381291172' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '82381291172'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '82381291172' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '82381291172'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-05-14', validity_date = '2027-05-08', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '82381291172' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-05-14', '2027-05-08', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '82381291172'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Patrícia Moreira Silva Resende', war_name = 'PATRÍCIA', rg = '01662', birth_date = '1977-09-09', phone = '64999783625', email = 'patriciabombeira@hotmail.com', driver_license_category = 'AB', driver_license_expiration = NULL, address_street = 'Rua 10', address_number = NULL, address_block = '11', address_lot = '21', address_complement = NULL, address_district = 'Jardim Goiás II', address_city = 'Mineiros', address_zipcode = '75832166', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '91489865187';

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '91489865187' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '91489865187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_health_exams h
SET exam_date = '2025-10-09', validity_date = '2026-10-06', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '91489865187' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-10-09', '2026-10-06', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '91489865187'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Gisele Malveiras Lima', war_name = 'GISELE', rg = '01532', birth_date = '1980-01-03', phone = '64999534379', email = 'giseleml@bombeiros.go.gov.br', driver_license_category = 'B', driver_license_expiration = '2023-10-18', address_street = 'Avenida Alvina Paniago Vilela', address_number = NULL, address_block = '18', address_lot = '18', address_complement = NULL, address_district = 'Jardim Floresta', address_city = 'Mineiros', address_zipcode = '75832252', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '88324265104';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '88324265104' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '88324265104'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'R', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '88324265104' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'R'
FROM public.military_personnel mp
WHERE mp.cpf = '88324265104'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_health_exams h
SET exam_date = '2026-02-26', validity_date = '2027-02-20', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '88324265104' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-02-26', '2027-02-20', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '88324265104'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Juliano Borges Machado', war_name = 'MACHADO', rg = '01579', birth_date = '1978-09-20', phone = '64999398910', email = 'julianobomachado@hotmail.com', driver_license_category = 'B', driver_license_expiration = '2031-07-09', address_street = '7º Avenida', address_number = '54 -A', address_block = 'NÃO', address_lot = 'NÃO', address_complement = NULL, address_district = 'Centro', address_city = 'Mineiros', address_zipcode = '75830000', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '85111201149';

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '85111201149' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '85111201149'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_health_exams h
SET exam_date = '2025-11-06', validity_date = '2026-11-04', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '85111201149' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-11-06', '2026-11-04', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '85111201149'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Wesley Santana Ramos', war_name = 'WESLEY', rg = '01763', birth_date = '1977-08-27', phone = '64984225389', email = 'wesleysantanaramos@gmail.com', driver_license_category = NULL, driver_license_expiration = NULL, address_street = 'Rua 20 Esq. C/ Rua 15', address_number = '41', address_block = NULL, address_lot = NULL, address_complement = NULL, address_district = 'Centro', address_city = 'Mineiros', address_zipcode = '75830002', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '93943032191';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '93943032191' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '93943032191'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '93943032191' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '93943032191'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '93943032191' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '93943032191'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-10-09', validity_date = '2026-10-09', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '93943032191' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-10-09', '2026-10-09', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '93943032191'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Lindomar Santana dos Santos', war_name = 'SANTANA', rg = '01599', birth_date = '1971-07-28', phone = '64999956484', email = 'santanaobom@gmail.com', driver_license_category = 'AC', driver_license_expiration = '2020-03-19', address_street = 'R 18 A', address_number = NULL, address_block = '08', address_lot = '02', address_complement = 'Casa', address_district = 'Loteamento Souza', address_city = 'Mineiros', address_zipcode = '75833074', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '59341912172';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '59341912172' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '59341912172'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '59341912172' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '59341912172'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '59341912172' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '59341912172'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-08-13', validity_date = '2027-08-13', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '59341912172' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-08-13', '2027-08-13', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '59341912172'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Doriedson Santos dos Reis', war_name = 'REIS', rg = '01482', birth_date = '1973-09-07', phone = '64999445877', email = 'central.copi@hotmail.com.br', driver_license_category = 'D', driver_license_expiration = '2032-07-19', address_street = 'Rua Sete', address_number = '68', address_block = '9999', address_lot = '999', address_complement = NULL, address_district = 'Centro', address_city = 'Mineiros', address_zipcode = '73830068', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '42402158115';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '42402158115' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '42402158115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '42402158115' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '42402158115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '42402158115' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '42402158115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-09-25', validity_date = '2026-09-24', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '42402158115' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-09-25', '2026-09-24', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '42402158115'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Cláudio Márcio de Abreu Martins', war_name = 'MÁRCIO', rg = '01456', birth_date = '1974-11-09', phone = '64999184960', email = 'abreubomber@yahoo.com.br', driver_license_category = 'AD', driver_license_expiration = '2025-02-03', address_street = 'Avenida 9', address_number = NULL, address_block = '16', address_lot = '15', address_complement = NULL, address_district = 'Mundinho', address_city = 'Mineiros', address_zipcode = '75832019', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '609bbc24-7f0a-41c0-98d3-c75c028b978e'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '66711789172';

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '66711789172' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '66711789172'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '66711789172' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '66711789172'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '66711789172' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '66711789172'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-11-06', validity_date = '2026-11-04', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '66711789172' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-11-06', '2026-11-04', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '66711789172'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Marcos Jean Lionis Gonzaga', war_name = 'LIONIS', rg = '01636', birth_date = '1972-03-24', phone = '64999839715', email = 'lionisgonzaga@hotmail.com', driver_license_category = 'B', driver_license_expiration = '2028-09-19', address_street = 'Rua W3', address_number = NULL, address_block = '08', address_lot = '08', address_complement = 'Próximo ao Fórum', address_district = 'Jardim Goiás', address_city = 'Mineiros', address_zipcode = '75832144', address_state = 'GO', inclusion_date = '2000-02-04', rank_id = '609bbc24-7f0a-41c0-98d3-c75c028b978e'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '55030246134';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '55030246134' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '55030246134'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '55030246134' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '55030246134'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '55030246134' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '55030246134'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-03-12', validity_date = '2027-03-11', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '55030246134' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-03-12', '2027-03-11', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '55030246134'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Segireib Silva Barbosa', war_name = 'BARBOSA', rg = '02200', birth_date = '1980-12-03', phone = '64996473076', email = 'segireib@gmail.com.com', driver_license_category = 'AD', driver_license_expiration = '2032-05-23', address_street = 'Rua 10', address_number = NULL, address_block = '10', address_lot = '08', address_complement = 'Jardim Goiás 2', address_district = 'Jardim Goiás II', address_city = 'Mineiros', address_zipcode = '75832166', address_state = 'GO', inclusion_date = '2001-10-01', rank_id = '609bbc24-7f0a-41c0-98d3-c75c028b978e'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '95451412120';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '95451412120' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '95451412120'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '95451412120' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '95451412120'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '95451412120' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '95451412120'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-12-18', validity_date = '2026-12-12', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '95451412120' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-12-18', '2026-12-12', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '95451412120'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Rodney de Araújo Minervino', war_name = 'RODNEY', rg = '02167', birth_date = '1977-11-16', phone = '62981215912', email = 'minervinomaosaobra@gmail.com.br', driver_license_category = 'AB', driver_license_expiration = '2031-05-21', address_street = 'Rua Veteranos dos Santos', address_number = '06', address_block = '01', address_lot = '06', address_complement = 'Casa 06', address_district = 'Parque dos Jatobás', address_city = 'Mineiros', address_zipcode = '75837649', address_state = 'GO', inclusion_date = '2001-10-01', rank_id = '609bbc24-7f0a-41c0-98d3-c75c028b978e'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '00754869466';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00754869466' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '00754869466'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00754869466' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '00754869466'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00754869466' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '00754869466'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-04-16', validity_date = '2027-04-16', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '00754869466' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-04-16', '2027-04-16', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '00754869466'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Samuel Santos Silva', war_name = 'SAMUEL', rg = '02195', birth_date = '1972-09-05', phone = '64999692090', email = 'samuel.sasilva@goias.gov.br', driver_license_category = 'AD', driver_license_expiration = '2024-10-22', address_street = 'Rua Ben Ti VI', address_number = NULL, address_block = '21', address_lot = '10', address_complement = NULL, address_district = 'Setor Cidade Nova', address_city = 'Mineiros', address_zipcode = '75830000', address_state = 'GO', inclusion_date = '2001-10-01', rank_id = '609bbc24-7f0a-41c0-98d3-c75c028b978e'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '59773375153';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '59773375153' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '59773375153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '59773375153' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '59773375153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '59773375153' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '59773375153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-08-13', validity_date = '2027-08-13', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '59773375153' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-08-13', '2027-08-13', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '59773375153'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Marcelo Resende Martins', war_name = 'MARTINS', rg = '02089', birth_date = '1981-08-30', phone = '64996474752', email = 'marceloresendemartins@gmail.com', driver_license_category = 'AD', driver_license_expiration = '2025-06-26', address_street = 'Rua José Resende Alvin', address_number = '0', address_block = '18', address_lot = '25', address_complement = NULL, address_district = 'Martins II', address_city = 'Mineiros', address_zipcode = '75830000', address_state = 'GO', inclusion_date = '2001-10-01', rank_id = '609bbc24-7f0a-41c0-98d3-c75c028b978e'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '94522502168';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '94522502168' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '94522502168'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '94522502168' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '94522502168'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '94522502168' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '94522502168'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-05-14', validity_date = '2027-05-08', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '94522502168' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-05-14', '2027-05-08', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '94522502168'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Wilker Oliveira Silva', war_name = 'WILKER', rg = '02252', birth_date = '1978-10-10', phone = '64992252124', email = 'wilkeroliveirasilva@gmail.com', driver_license_category = 'AD', driver_license_expiration = '2024-04-12', address_street = 'Rua 16', address_number = NULL, address_block = '153', address_lot = '16', address_complement = NULL, address_district = 'Setor Costa Nery', address_city = 'Mineiros', address_zipcode = '75833016', address_state = 'GO', inclusion_date = '2001-10-01', rank_id = '609bbc24-7f0a-41c0-98d3-c75c028b978e'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '86720708104';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '86720708104' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '86720708104'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '86720708104' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '86720708104'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '86720708104' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '86720708104'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-11-06', validity_date = '2026-11-04', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '86720708104' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-11-06', '2026-11-04', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '86720708104'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Joaquim Balsanuf de Oliveira Moreira', war_name = 'BALSANUF', rg = '03060', birth_date = '1983-05-11', phone = '64999981525', email = 'jbalsanuf@hotmail.com', driver_license_category = 'AD', driver_license_expiration = '2023-09-17', address_street = 'Rua 04', address_number = NULL, address_block = '02', address_lot = '22', address_complement = NULL, address_district = 'Loteamento Residencial Maria', address_city = 'Mineiros', address_zipcode = '75832581', address_state = 'GO', inclusion_date = '2010-11-19', rank_id = '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '00009683151';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00009683151' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '00009683151'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00009683151' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '00009683151'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00009683151' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '00009683151'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-04-16', validity_date = '2027-04-14', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '00009683151' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-04-16', '2027-04-14', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '00009683151'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Alex Jalowitzki Silva', war_name = 'ALEX', rg = '02969', birth_date = '1986-04-24', phone = '64999622314', email = 'alexjalowitzki@gmail.com', driver_license_category = 'AD', driver_license_expiration = '2025-02-26', address_street = 'Rua Sebastião Ribeiro de Castro', address_number = NULL, address_block = '29', address_lot = '12', address_complement = NULL, address_district = 'Setor Cruvinel', address_city = 'Mineiros', address_zipcode = '75834139', address_state = 'GO', inclusion_date = '2010-11-19', rank_id = '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '01224230116';

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '01224230116' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '01224230116'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '01224230116' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '01224230116'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '01224230116' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '01224230116'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-04-16', validity_date = '2027-04-14', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '01224230116' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-04-16', '2027-04-14', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '01224230116'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Wonder Menezes de Souza', war_name = 'WONDER', rg = '03181', birth_date = '1980-11-26', phone = '64999171428', email = 'stive193@gmail.com', driver_license_category = 'AE', driver_license_expiration = NULL, address_street = 'Avenida José Joaquim de Rezende', address_number = NULL, address_block = '30', address_lot = '08/A', address_complement = NULL, address_district = 'Centro', address_city = 'Mineiros', address_zipcode = '75830032', address_state = 'GO', inclusion_date = '2010-11-19', rank_id = '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '70657025100';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '70657025100' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '70657025100'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '70657025100' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '70657025100'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '70657025100' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '70657025100'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-11-27', validity_date = '2026-11-25', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '70657025100' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-11-27', '2026-11-25', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '70657025100'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Lincoln Eduardo Carrijo Gomes', war_name = 'LINCOLN', rg = '03244', birth_date = '1982-12-29', phone = '64984034123', email = 'lincoln1000@gmail.com', driver_license_category = 'AD', driver_license_expiration = '2025-06-18', address_street = 'Rua José Feliciano de Morais', address_number = '07', address_block = '20', address_lot = '07', address_complement = NULL, address_district = 'Jardim Floresta', address_city = 'Mineiros', address_zipcode = '75830000', address_state = 'GO', inclusion_date = '2011-03-23', rank_id = '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '94518629191';

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '94518629191' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '94518629191'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '94518629191' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '94518629191'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '94518629191' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '94518629191'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-10-16', validity_date = '2026-10-10', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '94518629191' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-10-16', '2026-10-10', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '94518629191'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Neilo Luís Sousa Morais', war_name = 'NEILO', rg = '03490', birth_date = '1980-09-24', phone = '64999115091', email = 'neilomorais@hotmail.com', driver_license_category = 'D', driver_license_expiration = '2033-04-24', address_street = 'Avenida Antônio Carlos Paniago', address_number = '30', address_block = '14', address_lot = '07', address_complement = NULL, address_district = 'Vila 31 de Outubro', address_city = 'Mineiros', address_zipcode = '75835001', address_state = 'GO', inclusion_date = '2012-04-02', rank_id = '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '70938334115';

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '70938334115' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '70938334115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '70938334115' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '70938334115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '70938334115' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '70938334115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-10-09', validity_date = '2026-10-09', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '70938334115' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-10-09', '2026-10-09', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '70938334115'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Ederson Américo Borges', war_name = 'AMÉRICO', rg = '03004', birth_date = '1979-08-02', phone = '64999312876', email = 'edersonaborges@hotmail.com', driver_license_category = 'AD', driver_license_expiration = '2025-08-19', address_street = 'Av Zeca Alfaiate', address_number = '00', address_block = '17', address_lot = '1A', address_complement = 'Ao Lado da Citro 5 Boa Vista', address_district = 'Setor Boa Vista', address_city = 'Mineiros', address_zipcode = '75830000', address_state = 'GO', inclusion_date = '2010-11-19', rank_id = '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '69639060178';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '69639060178' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '69639060178'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '69639060178' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '69639060178'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '69639060178' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '69639060178'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-09-25', validity_date = '2026-09-23', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '69639060178' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-09-25', '2026-09-23', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '69639060178'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Stela Maris Espíndola Duarte Marafon', war_name = 'STELA', rg = '03149', birth_date = '1982-07-30', phone = '64999945481', email = 'stelamedm@yahoo.com.br', driver_license_category = 'AD', driver_license_expiration = '2025-11-26', address_street = 'Travessa Assis', address_number = '05', address_block = '.', address_lot = '.', address_complement = NULL, address_district = 'Centro', address_city = 'Mineiros', address_zipcode = '75830080', address_state = 'GO', inclusion_date = '2010-11-19', rank_id = '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '97505765191';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '97505765191' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '97505765191'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '97505765191' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '97505765191'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '97505765191' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '97505765191'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-10-09', validity_date = '2026-09-24', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '97505765191' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-10-09', '2026-09-24', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '97505765191'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Danilo de Melo e Silva', war_name = 'DE MELO', rg = '02993', birth_date = '1984-02-06', phone = '64996243452', email = 'drdanilomeloadv@hotmail.com', driver_license_category = 'AD', driver_license_expiration = NULL, address_street = 'Avenida Irmã Carmelita', address_number = NULL, address_block = '29', address_lot = '10', address_complement = NULL, address_district = 'Jardim Floresta', address_city = 'Mineiros', address_zipcode = '75831248', address_state = 'GO', inclusion_date = '2010-11-19', rank_id = '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '00293272107';

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00293272107' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '00293272107'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00293272107' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '00293272107'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00293272107' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '00293272107'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-02-26', validity_date = '2027-02-20', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '00293272107' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-02-26', '2027-02-20', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '00293272107'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Lamark Santos Pereira', war_name = 'LAMARK', rg = '03491', birth_date = '1984-07-02', phone = '64996473447', email = 'lamarksp@hotmail.com', driver_license_category = 'AC', driver_license_expiration = '2033-09-18', address_street = 'Rua 04', address_number = NULL, address_block = '24', address_lot = '17', address_complement = NULL, address_district = 'Martins II', address_city = 'Mineiros', address_zipcode = '75832569', address_state = 'GO', inclusion_date = '2012-04-02', rank_id = 'b851e263-f878-41b8-89b0-0c41bc5e86ce'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '00523248180';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00523248180' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '00523248180'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00523248180' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '00523248180'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00523248180' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '00523248180'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-05-07', validity_date = '2027-05-06', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '00523248180' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-05-07', '2027-05-06', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '00523248180'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Cleidiomar Evangelista Campos', war_name = 'CAMPOS', rg = '03633', birth_date = '1981-02-02', phone = '64999418055', email = 'cleidiomarcampos@gmail.com', driver_license_category = 'AD', driver_license_expiration = '2025-02-14', address_street = 'Rua Hildebrando Cruvinel', address_number = 'SN', address_block = '04', address_lot = '11', address_complement = NULL, address_district = 'Cohacol III', address_city = 'Mineiros', address_zipcode = '75835103', address_state = 'GO', inclusion_date = '2012-05-10', rank_id = 'b851e263-f878-41b8-89b0-0c41bc5e86ce'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '96391995168';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '96391995168' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '96391995168'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '96391995168' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '96391995168'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-02-12', validity_date = '2027-02-11', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '96391995168' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-02-12', '2027-02-11', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '96391995168'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Marcelo Silva Teodoro', war_name = 'TEODORO', rg = '03486', birth_date = '1987-08-06', phone = '64999542388', email = 'marcelosteo@gmail.com', driver_license_category = 'AD', driver_license_expiration = '2025-07-30', address_street = 'Rua Rv7', address_number = '0', address_block = '15', address_lot = '28', address_complement = NULL, address_district = 'Residencial Vilhena', address_city = 'Mineiros', address_zipcode = '75833014', address_state = 'GO', inclusion_date = '2012-04-02', rank_id = 'b851e263-f878-41b8-89b0-0c41bc5e86ce'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '02797910117';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '02797910117' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '02797910117'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-01-08', validity_date = '2027-01-07', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '02797910117' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-01-08', '2027-01-07', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '02797910117'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Marcelo Souza Silva', war_name = 'SOUZA', rg = '03632', birth_date = '1982-11-10', phone = '64999873460', email = 'marcelo.souzasilva@gmail.com', driver_license_category = 'AD', driver_license_expiration = '2025-10-23', address_street = 'Rua Pastor Pedro Mascari', address_number = NULL, address_block = '29', address_lot = '08', address_complement = NULL, address_district = 'Loteamento Solar Betel', address_city = 'Mineiros', address_zipcode = '75833444', address_state = 'GO', inclusion_date = '2012-05-10', rank_id = 'b851e263-f878-41b8-89b0-0c41bc5e86ce'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '00247443107';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00247443107' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '00247443107'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00247443107' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '00247443107'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '00247443107' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '00247443107'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-11-27', validity_date = '2026-11-25', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '00247443107' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-11-27', '2026-11-25', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '00247443107'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Marcus Vinícius Ribeiro Dias', war_name = 'MARCUS VINÍCIUS', rg = '03631', birth_date = '1990-02-06', phone = '64996953959', email = 'marcusvinicius_incendio@yahoo.com.br', driver_license_category = 'AD', driver_license_expiration = '2021-04-19', address_street = 'Rua M', address_number = 'SÓ/N', address_block = '18', address_lot = '07', address_complement = NULL, address_district = 'Nossa Senhora Aparecida', address_city = 'Mineiros', address_zipcode = '75830000', address_state = 'GO', inclusion_date = '2012-05-10', rank_id = 'b851e263-f878-41b8-89b0-0c41bc5e86ce'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '02327936110';

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '02327936110' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '02327936110'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '02327936110' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '02327936110'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '02327936110' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '02327936110'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-02-26', validity_date = '2027-02-20', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '02327936110' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-02-26', '2027-02-20', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '02327936110'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Amanda Marsola Pansani Mattana', war_name = 'MARSOLA', rg = '03767', birth_date = '1985-03-30', phone = '64996185082', email = 'mpm.amanda@gmail.com', driver_license_category = 'AD', driver_license_expiration = '2026-01-06', address_street = 'Rua D', address_number = NULL, address_block = '11', address_lot = '07', address_complement = NULL, address_district = 'Parque dos Jatobás', address_city = 'Mineiros', address_zipcode = '75837601', address_state = 'GO', inclusion_date = '2013-07-15', rank_id = 'b851e263-f878-41b8-89b0-0c41bc5e86ce'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '35102762800';

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '35102762800' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '35102762800'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '35102762800' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '35102762800'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'B', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '35102762800' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'B'
FROM public.military_personnel mp
WHERE mp.cpf = '35102762800'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-04-09', validity_date = '2027-04-07', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '35102762800' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-04-09', '2027-04-07', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '35102762800'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

UPDATE public.military_personnel
SET full_name = 'Daniel Pereira Martins', war_name = 'DANIEL', rg = '03764', birth_date = '1983-09-23', phone = '64999897033', email = 'martins103@hotmail.com', driver_license_category = 'AD', driver_license_expiration = '2024-05-20', address_street = 'Rua 12', address_number = '07', address_block = NULL, address_lot = NULL, address_complement = NULL, address_district = 'Centro', address_city = 'Mineiros', address_zipcode = '75830000', address_state = 'GO', inclusion_date = '2013-07-15', rank_id = 'b851e263-f878-41b8-89b0-0c41bc5e86ce'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '98733990115';

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '98733990115' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '98733990115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '98733990115' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '98733990115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'E', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '98733990115' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'E'
FROM public.military_personnel mp
WHERE mp.cpf = '98733990115'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2025-10-16', validity_date = '2026-10-15', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '98733990115' AND h.year = 2025;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2025, '2025-10-16', '2026-10-15', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '98733990115'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2025);

UPDATE public.military_personnel
SET full_name = 'Luan Ananias de Assis', war_name = 'LUAN', rg = '04006', birth_date = '1991-03-07', phone = '64999950076', email = 'luan_cpa10@hotmail.com', driver_license_category = 'AD', driver_license_expiration = '2032-12-22', address_street = 'Rua Sebastião B de Oliveira', address_number = NULL, address_block = '5', address_lot = '1', address_complement = NULL, address_district = 'Setor Rodrigues', address_city = 'Mineiros', address_zipcode = '75832139', address_state = 'GO', inclusion_date = '2017-08-28', rank_id = 'c88b285f-ec1d-43c7-8473-23910b8839e2'::uuid, unit_id = 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'::uuid, quadro = 'QP/Combatente'::public.military_board, updated_at = now()
WHERE cpf = '04007548196';

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '04007548196' AND t.year = 2026 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2026, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '04007548196'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2026 AND t.semester = 1);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '04007548196' AND t.year = 2025 AND t.semester = 2;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 2, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '04007548196'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 2);

UPDATE public.military_taf t
SET mention = 'MB', updated_at = now()
FROM public.military_personnel mp
WHERE t.military_id = mp.id AND mp.cpf = '04007548196' AND t.year = 2025 AND t.semester = 1;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT mp.id, 2025, 1, 'MB'
FROM public.military_personnel mp
WHERE mp.cpf = '04007548196'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = mp.id AND t.year = 2025 AND t.semester = 1);

UPDATE public.military_health_exams h
SET exam_date = '2026-03-12', validity_date = '2027-03-11', is_fit = true, has_restrictions = false, updated_at = now()
FROM public.military_personnel mp
WHERE h.military_id = mp.id AND mp.cpf = '04007548196' AND h.year = 2026;

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT mp.id, 2026, '2026-03-12', '2027-03-11', true, false
FROM public.military_personnel mp
WHERE mp.cpf = '04007548196'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = mp.id AND h.year = 2026);

commit;