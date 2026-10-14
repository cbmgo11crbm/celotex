begin;

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Márcio dos Santos Prado', 'PRADO', '01341', '89605160153', '1977-03-28', '64996060672', 'zooprado@hotmail.com', 'D', '2023-08-21', 'Rua 07', '28', '00', '00', 'Casa', 'Setor Oeste', 'Mineiros', '75830218', NULL, '1998-06-30', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, '31607be0-58a4-463b-aaed-9b191bede08b'::uuid, 'QOE/Complementar'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'E'
FROM public.military_personnel
WHERE cpf = '89605160153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'E'
FROM public.military_personnel
WHERE cpf = '89605160153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'E'
FROM public.military_personnel
WHERE cpf = '89605160153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2026, '2026-02-19', '2027-02-19', true, false
FROM public.military_personnel
WHERE cpf = '89605160153'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2026);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Rubson Silva Ribeiro', 'RUBSON', '01711', '84089342104', '1977-12-04', '64999543957', 'rubsonbm@gmail.com', 'AD', '2031-08-24', 'Avenida São João', '304', NULL, NULL, NULL, 'São João', 'Mineiros', '75836046', NULL, '2000-02-04', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'B'
FROM public.military_personnel
WHERE cpf = '84089342104'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'B'
FROM public.military_personnel
WHERE cpf = '84089342104'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2025, '2025-11-13', '2026-11-12', true, false
FROM public.military_personnel
WHERE cpf = '84089342104'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2025);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Jacirlei Silva Batista', 'JACIRLEI', '01557', '87104857168', '1978-02-04', '64996588281', 'jacirleisb@gmail.com', 'D', NULL, 'Rua P-002', '2', '20', '06', NULL, 'Popular', 'Jataí', '75803200', NULL, '2000-02-04', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'B'
FROM public.military_personnel
WHERE cpf = '87104857168'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'B'
FROM public.military_personnel
WHERE cpf = '87104857168'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'R'
FROM public.military_personnel
WHERE cpf = '87104857168'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2026, '2026-04-01', '2027-03-30', true, false
FROM public.military_personnel
WHERE cpf = '87104857168'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2026);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Francisley Patrick Silva', 'PATRICK', '02414', '69586519104', '1980-01-30', '64999423400', 'yelsiknarf@gmail.com', 'AB', '2024-02-15', 'Avenida Corino José de Souza', NULL, '67', '04', NULL, 'Jardim das Perobeiras', 'Mineiros', '75837822', NULL, '2004-04-01', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, '334d0773-22e5-4bd9-bec8-2e0fd36bb95f'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'E'
FROM public.military_personnel
WHERE cpf = '69586519104'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'E'
FROM public.military_personnel
WHERE cpf = '69586519104'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2026, '2026-01-22', '2027-01-20', true, false
FROM public.military_personnel
WHERE cpf = '69586519104'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2026);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Juan Luís Almeida Sierra', 'RUAN', '02457', '82975035187', '1978-07-05', '64999595768', 'sierradrum@hotmail.com', 'AB', '2033-02-10', 'Rua 19', '88', '03', '02', NULL, 'Jardim Goiás II', 'Jataí', '75804695', NULL, '2004-04-01', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'MB'
FROM public.military_personnel
WHERE cpf = '82975035187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'B'
FROM public.military_personnel
WHERE cpf = '82975035187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'R'
FROM public.military_personnel
WHERE cpf = '82975035187'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2026, '2026-07-30', '2027-07-30', true, false
FROM public.military_personnel
WHERE cpf = '82975035187'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2026);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Christiano Silva', 'SILVA', '03832', '99772515172', '1982-06-07', '67981336015', 'christianosilva29@gmail.com', 'AD', '2025-08-13', 'Rua Pedro Pereira de Almeida', '1014', NULL, NULL, 'Bairro: Centro', 'Centro', 'Cassilândia', '79540000', NULL, '2013-07-15', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, 'b851e263-f878-41b8-89b0-0c41bc5e86ce'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'E'
FROM public.military_personnel
WHERE cpf = '99772515172'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'E'
FROM public.military_personnel
WHERE cpf = '99772515172'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'E'
FROM public.military_personnel
WHERE cpf = '99772515172'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2026, '2026-05-14', '2027-05-11', true, false
FROM public.military_personnel
WHERE cpf = '99772515172'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2026);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Deyner Elias de Menezes', 'DEYNER', '03818', '97457248153', '1983-09-17', '64999858803', 'deynerelias@gmail.com', 'AD', '2032-09-14', 'Avenida Alberico de Mamargo', '394', '00', '00', NULL, 'Setor Santa Terezinha', 'Jataí', '75806100', NULL, '2013-07-15', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, 'b851e263-f878-41b8-89b0-0c41bc5e86ce'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'MB'
FROM public.military_personnel
WHERE cpf = '97457248153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'MB'
FROM public.military_personnel
WHERE cpf = '97457248153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'MB'
FROM public.military_personnel
WHERE cpf = '97457248153'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2025, '2025-12-04', '2026-12-01', true, false
FROM public.military_personnel
WHERE cpf = '97457248153'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2025);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Vanderli Feliciano da Silva', 'FELICIANO', '04069', '04662744164', '1994-10-05', '62993779535', 'vanderlifelicianodasilva@hotmail.com', 'AB', '2032-04-01', 'Avenida Desembargador Rivadávia Licínio de 
Miranda', NULL, 'A', '13', 'Apt. 202 Edificio Crc', 'Centro', 'Campos Belos', '73840000', NULL, '2017-08-28', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, 'c88b285f-ec1d-43c7-8473-23910b8839e2'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'MB'
FROM public.military_personnel
WHERE cpf = '04662744164'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'B'
FROM public.military_personnel
WHERE cpf = '04662744164'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'E'
FROM public.military_personnel
WHERE cpf = '04662744164'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2025, '2025-10-23', '2026-10-17', true, false
FROM public.military_personnel
WHERE cpf = '04662744164'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2025);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Alexandre Adorno Santana', 'ADORNO', '04356', '70657856100', '1999-04-17', '64984316413', 'alexandreadornosantana@gmail.com', 'AB', '2024-05-09', 'Rua 20', '41', '0', '0', NULL, 'Mineirinho', 'Mineiros', '75860002', NULL, '2023-09-04', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, '3649efe3-88ef-468a-ab98-1a6c20b1a17a'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'E'
FROM public.military_personnel
WHERE cpf = '70657856100'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'E'
FROM public.military_personnel
WHERE cpf = '70657856100'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'MB'
FROM public.military_personnel
WHERE cpf = '70657856100'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2026, '2026-04-16', '2027-04-15', true, false
FROM public.military_personnel
WHERE cpf = '70657856100'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2026);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Hamohhamed Henrik Santana Carvalho', 'HAMOHHAMED', '04242', '01454177438', '1996-10-13', '6499710275', 'hamohhamedeng@gmail.com', 'AB', '2025-07-22', 'Rua Vidal de Negreiros', '883', NULL, NULL, NULL, 'Setor Central', 'Naviraí', '79950000', NULL, '2023-09-04', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, '3649efe3-88ef-468a-ab98-1a6c20b1a17a'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'MB'
FROM public.military_personnel
WHERE cpf = '01454177438'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'E'
FROM public.military_personnel
WHERE cpf = '01454177438'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'MB'
FROM public.military_personnel
WHERE cpf = '01454177438'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2025, '2025-10-30', '2026-10-30', true, false
FROM public.military_personnel
WHERE cpf = '01454177438'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2025);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Marcos Rodolfo dos Santos Queiroz', 'RODOLFO QUEIROZ', '04323', '06654981103', '1999-12-05', '6184978101', 'marcosrodolfo10@gmail.com', 'B', '2033-04-14', 'Rua 09', NULL, NULL, '11/13', 'Residencial Piazza Di Italia Torre A , Apto 1102', 'Areal (águas Claras)', 'Brasília', '71938360', NULL, '2023-09-04', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, '3649efe3-88ef-468a-ab98-1a6c20b1a17a'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'B'
FROM public.military_personnel
WHERE cpf = '06654981103'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'R'
FROM public.military_personnel
WHERE cpf = '06654981103'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'I'
FROM public.military_personnel
WHERE cpf = '06654981103'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2026, '2026-05-07', '2027-05-06', true, false
FROM public.military_personnel
WHERE cpf = '06654981103'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2026);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Luiz Felipe Rolim Ferreira Gomes', 'ROLIM', '04586', '04624388135', '1993-04-07', '24999920439', 'luiz.fgomes@goias.gov.br', 'AB', '2033-03-13', 'Rua Rui Barbosa', '4950', NULL, NULL, 'Apto 1005. Torre 2', 'São Francisco', 'Campo Grande', '79002366', NULL, '2024-08-05', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, '3649efe3-88ef-468a-ab98-1a6c20b1a17a'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'MB'
FROM public.military_personnel
WHERE cpf = '04624388135'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'B'
FROM public.military_personnel
WHERE cpf = '04624388135'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'MB'
FROM public.military_personnel
WHERE cpf = '04624388135'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2026, '2026-04-30', '2027-04-29', true, false
FROM public.military_personnel
WHERE cpf = '04624388135'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2026);

INSERT INTO public.military_personnel (id, full_name, war_name, rg, cpf, birth_date, phone, email, driver_license_category, driver_license_expiration, address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_zipcode, address_state, inclusion_date, unit_id, rank_id, quadro, classification, is_inactive)
VALUES (gen_random_uuid(), 'Rafael dos Santos Queiroz', 'QUEIROZ', '04585', '06654996127', '2003-06-02', '61984179583', 'rafael.squeiroz@goias.gov.br', 'B', '2031-07-14', 'Rua 9', NULL, NULL, '11/13', 'Apto 102 A', 'Bairro Nao Identificado', 'Brasília', '71938360', NULL, '2024-08-05', '4272a75a-d359-4b70-9ef4-f3297c759fec'::uuid, '3649efe3-88ef-468a-ab98-1a6c20b1a17a'::uuid, 'QP/Combatente'::public.military_board, 'operacional', false)
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2026, 1, 'MB'
FROM public.military_personnel
WHERE cpf = '06654996127'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2026 AND t.semester = 1);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 2, 'MB'
FROM public.military_personnel
WHERE cpf = '06654996127'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 2);

INSERT INTO public.military_taf (military_id, year, semester, mention)
SELECT id, 2025, 1, 'MB'
FROM public.military_personnel
WHERE cpf = '06654996127'
  AND NOT EXISTS (SELECT 1 FROM public.military_taf t WHERE t.military_id = public.military_personnel.id AND t.year = 2025 AND t.semester = 1);

INSERT INTO public.military_health_exams (military_id, year, exam_date, validity_date, is_fit, has_restrictions)
SELECT id, 2025, '2025-06-26', '2026-06-24', true, false
FROM public.military_personnel
WHERE cpf = '06654996127'
  AND NOT EXISTS (SELECT 1 FROM public.military_health_exams h WHERE h.military_id = public.military_personnel.id AND h.year = 2025);

commit;