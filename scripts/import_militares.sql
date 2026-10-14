BEGIN;

-- Importação de militares a partir de CSV
-- Obs: driver_license_category vazio foi preenchido com 'A' como padrão.
-- Os triggers de auditoria permanecem ativos.

DO $$
DECLARE
  m_id uuid := 'd1b76c51-327a-4221-8069-aa8908fa0c39';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'ee14ced8-f383-4584-bf15-32d3a4a99af5', '2280', 'Eduardo Monteiro do Amaral', 'EDUARDO MONTEIRO', '1980-10-18', '62993090585', '94159270115', 'capeduardomonteiro@gmail.com', NULL, 'B', '2033-12-06', 'administrativo', NULL, 'QOC'::public.military_board, '2003-03-06', 'Rua Anhanguera', '1275', NULL, NULL, NULL, 'Centro', 'Jataí', NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'R');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'R');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'R');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-12-18', TRUE, FALSE, '2026-12-18');
END $$;

DO $$
DECLARE
  m_id uuid := '771bc077-7694-44f8-a082-b31a2a2ca2e2';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '0a909f3e-2d85-4599-8d60-9ec10f6ca416', '1559', 'Jarbas Bernardes da Silva', 'JARBAS', '1973-01-17', '64992657479', '59757400106', 'jarbasbombeiro@yahoo.com.br', 'A+', 'AD', '2032-10-19', 'administrativo', NULL, 'QOE/Complementar'::public.military_board, '2000-02-04', 'Rua 54', NULL, '4', '32', NULL, 'Residencial Cyllêneo França', NULL, '75804562', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'E');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-01-15', TRUE, FALSE, '2027-01-15');
END $$;

DO $$
DECLARE
  m_id uuid := 'fe5d38fe-bae3-42cd-ae19-a87868030be3';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '31607be0-58a4-463b-aaed-9b191bede08b', '1496', 'Eisenhower Firmino', 'EISENHOWER', '1977-03-07', '64999378919', '69107335172', 'howerbm@gmail.com', 'O+', 'AD', '2031-05-14', 'administrativo', NULL, 'QOE/Complementar'::public.military_board, '2000-02-04', 'Rua A5', NULL, '8', '4', NULL, 'Setor Sul', 'Jataí', '75802451', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-03-19', TRUE, FALSE, '2027-03-19');
END $$;

DO $$
DECLARE
  m_id uuid := '08f27718-a60d-41aa-b8b8-4eb25d658723';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '31607be0-58a4-463b-aaed-9b191bede08b', '1492', 'Eduardo Meneses', 'MENESES', '1976-04-12', '64999738251', '61773506153', 'dudu193193@hotmail.com', 'O+', 'B', '2034-08-05', 'administrativo', NULL, 'QOE/Complementar'::public.military_board, '2000-02-04', 'Av. 7 de setembro', NULL, '9', '18', NULL, 'Setor Sul', 'Jataí', NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'MB');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-04-30', TRUE, FALSE, '2027-04-30');
END $$;

DO $$
DECLARE
  m_id uuid := 'cda70e62-c4d6-4eb9-b527-091b23408db7';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'c71382c2-9f67-4b21-8f5f-adbe5201a960', '1124', 'Carlos Ferreira da Silva', 'DA SILVA', '1968-11-04', '64984329230', '47605260130', 'dasilvabombeiro@yahoo.com.br', 'O+', 'AD', '2030-12-16', 'administrativo', NULL, 'QOE/Complementar'::public.military_board, '1992-06-29', 'Rua Ernesto Martins Vieira', '67', NULL, NULL, NULL, 'Bela Vista', NULL, '75806060', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'E');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-11-27', TRUE, FALSE, '2026-11-27');
END $$;

DO $$
DECLARE
  m_id uuid := 'bd1764c1-7b9f-48d7-8227-cfb157cbd367';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '4ffffa07-a1d6-47f7-8743-aad276cd83a3', '4465', 'Guilherme Bandeira Monteiro', 'BANDEIRA', '1990-04-18', '62999073688', '02418739163', 'guilhermebandeiramonteiro@gmail.com', 'O+', 'AB', '2034-07-23', 'administrativo', NULL, 'QP/Especial'::public.military_board, '2024-07-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, FALSE
  );
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-12-11', TRUE, FALSE, '2026-12-11');
END $$;

DO $$
DECLARE
  m_id uuid := '6735cbe2-e1b1-406f-afb2-40a51bfaac5d';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '4ffffa07-a1d6-47f7-8743-aad276cd83a3', '4499', 'Manuel Eduardo dos Santos Neto', 'MANUEL EDUARDO', '1998-03-18', '79991453406', '07452665503', 'manuel210eduardo@gmail.com', 'O+', 'B', '2032-04-03', 'administrativo', NULL, 'QP/Especial'::public.military_board, '2024-07-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, FALSE
  );
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-12-04', TRUE, FALSE, '2026-12-04');
END $$;

DO $$
DECLARE
  m_id uuid := '6ace014d-af88-413a-ab52-dc805b938ce0';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '4ffffa07-a1d6-47f7-8743-aad276cd83a3', '4497', 'Pyetro Augusto Almeida Andrade', 'AUGUSTO', '1995-05-29', '62982470267', '03869855100', 'pyetroaugustoalmeida@gmail.com', 'O+', 'B', '2034-03-28', 'administrativo', NULL, 'QP/Especial'::public.military_board, '2024-07-29', 'Av. Morse Machado', '97', NULL, NULL, 'Casa 1', 'Residencial Canaa II', 'Rio Verde', '75900320', FALSE
  );
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-12-18', TRUE, FALSE, '2026-12-18');
END $$;

DO $$
DECLARE
  m_id uuid := 'a7b69cb3-0639-4759-b9ec-4bb437d17a4e';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '4ffffa07-a1d6-47f7-8743-aad276cd83a3', '4478', 'Gabriel Santana Mendonça', 'MENDONÇA', '1995-12-13', '79998893238', '05496120500', 'gabriel_sp_va@hotmail.com', 'O+', 'B', '2035-09-18', 'administrativo', NULL, 'QP/Especial'::public.military_board, '2024-07-29', 'Rua Engenheiro Bonfim', '201', NULL, NULL, 'Apt 1001', 'Vila Progresso apt 1001 A', 'Jataí', '75800117', FALSE
  );
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-11-06', TRUE, FALSE, '2026-11-06');
END $$;

DO $$
DECLARE
  m_id uuid := 'a7504ab6-ac43-429a-8f5d-582c96a42566';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1553', 'Hugo Alves Soria', 'HUGO', '1979-10-05', '64999231553', '86521535153', 'qbugobm@gmail.com', 'A+', 'B', '2034-10-09', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2000-02-04', 'Rua Inácio José de Melo', '4005', NULL, NULL, NULL, 'Vila Fátima', 'Jataí', '75803025', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-10-23', TRUE, FALSE, '2026-10-23');
END $$;

DO $$
DECLARE
  m_id uuid := 'd12709b2-a4c6-47fc-8e4b-907c7f947866';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1222', 'Élio Alves da Silva', 'ELIO', '1973-09-17', '64999413882', '61412040159', 'elio.bom@bol.com.br', 'O-', 'D', '2030-12-18', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '1993-12-13', 'Rua N-2', '113', '7', '14', NULL, 'Jardim Goiás', 'Jataí', '75804655', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'R');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'R');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-09-25', TRUE, FALSE, '2026-09-25');
END $$;

DO $$
DECLARE
  m_id uuid := '31f7e093-36e6-4633-bfdb-e123c0e87957';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1225', 'Ailton Lopes de Sousa', 'LOPES', '1973-05-15', '64999074264', '76979679104', 'ailtonlopes193@gmail.com', 'B+', 'AB', '2028-09-12', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '1993-12-13', 'Rua N-3', NULL, '3', '18', NULL, 'Jardim Goiás', 'Jataí', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '57bfd623-a819-4279-b781-c42099d2b4fb';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1495', 'Eisenhonne Firmino', 'FIRMINO', '1981-01-17', '64999555990', '95069011120', 'honnebm@hotmail.com', 'O+', 'AB', '2036-01-21', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2000-02-04', 'Rua Napoleão Laureano', '626', NULL, NULL, NULL, 'Setor Antena', NULL, NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-01-22', TRUE, FALSE, '2027-01-22');
END $$;

DO $$
DECLARE
  m_id uuid := 'd1bbf5e8-cbfb-4044-8756-7052289a9a52';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1336', 'Marcos Weiner Ferreira de Castro', 'MARCOS', '1975-05-07', '64984314693', '83636358120', 'mwfc193@gmail.com', 'O+', 'AD', '2030-11-25', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '1998-06-30', 'Rua 21', NULL, '7', '17', NULL, 'Jardim Goias II', NULL, NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'E');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-05-21', TRUE, FALSE, '2027-05-21');
END $$;

DO $$
DECLARE
  m_id uuid := 'ab12d7a9-d257-445d-846b-e7c64af90010';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1334', 'Wesley Rodrigues Lima', 'LIMA', '1974-08-07', '64984534544', '69151776120', 'wesley1334@hotmail.com', 'O+', 'AB', '2028-09-12', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '1998-06-30', 'Av Dr. Lauro Taveira', '381', NULL, NULL, NULL, NULL, NULL, NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-08-21', TRUE, FALSE, '2026-08-21');
END $$;

DO $$
DECLARE
  m_id uuid := '9f2117e9-42b1-4c09-a5d6-5f44445ac060';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1652', 'Ney Paulino de Souza', 'PAULINO', '1976-05-15', '64999586329', '78612527104', 'neybombeiro@hotmail.com', 'A+', 'AD', '2032-12-21', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2000-02-04', 'Rua 52', NULL, '2', '27', NULL, 'Residencial Cyllêneo França', 'Jataí', '75804556', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'R');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'R');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-05-21', TRUE, FALSE, '2027-05-21');
END $$;

DO $$
DECLARE
  m_id uuid := '0f3e14b5-b323-48df-a482-3c434fadf048';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1514', 'Fabiane Silva Alves', 'FABIANE', '1980-08-11', '64981231403', '87293935153', 'fabianegrph@gmail.com', 'A+', 'AB', '2034-07-03', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2000-02-04', 'Rua 3', '84', NULL, NULL, NULL, 'Samuel Graham', 'Jataí', '75804052', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'E');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-10-09', TRUE, FALSE, '2026-10-09');
END $$;

DO $$
DECLARE
  m_id uuid := 'f2e4a2df-7194-45c0-b734-adede9b1a5b6';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '2141', 'Quintiliano José da Silva Júnior', 'QUINTILIANO', '1978-04-28', '64999331300', '69828512149', 'quintilianojr@yahoo.com.br', 'B-', 'AD', '2032-10-11', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2001-10-01', 'Rua 3', '260', NULL, NULL, NULL, 'Morada do Sol', NULL, '75804589', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-04-24', TRUE, FALSE, '2026-04-24');
END $$;

DO $$
DECLARE
  m_id uuid := 'f4d61ede-fe59-45b3-82b9-410762d7d36d';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '2055', 'Lidiomar Pardim de Souza', 'PARDIM', '1974-08-03', '64999793461', '81447507134', 'lidiomar.pardim@hotmail.com', 'A+', 'AD', '2030-02-10', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2001-10-01', 'Alameda Agro-industrial', '380', '10', '36', NULL, 'Setor Granjeiro', 'Jataí', NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'E');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-07-10', TRUE, FALSE, '2026-07-10');
END $$;

DO $$
DECLARE
  m_id uuid := '6293463e-39a9-45b0-915a-97e6aad33f20';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '609bbc24-7f0a-41c0-98d3-c75c028b978e', '1687', 'Roberto Meneses', 'ROBERTO', '1975-01-20', '64999870445', '91494230100', 'robetome1687@gmail.com', 'O+', 'D', '2030-02-14', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2000-02-04', 'Rua Maria Bahia', '117', NULL, NULL, NULL, 'Setor Dom Abel', NULL, NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'MB');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-01-15', TRUE, FALSE, '2027-01-15');
END $$;

DO $$
DECLARE
  m_id uuid := '16f357dc-007f-4387-a95f-caf1023e1a9c';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '609bbc24-7f0a-41c0-98d3-c75c028b978e', '2452', 'José Ricardo Vieira de Assis', 'ASSIS', '1980-09-11', '64999849593', '98637894100', 'josericardoassis@hotmail.com', 'O+', 'AB', '2033-11-20', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2004-04-01', 'Rua 7 de Setembro', NULL, '13', '33', NULL, 'Setor Cohacol 5', NULL, NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2024, '2024-11-07', TRUE, FALSE, '2025-11-07');
END $$;

DO $$
DECLARE
  m_id uuid := 'dcb3e31b-f23f-42fb-b932-c80fce5548df';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a', '2415', 'Frank Dann da Silva', 'FRANK DANN', '1978-07-19', '62991175744', '88427765134', 'frankdann@bol.com.br', 'O+', 'AD', '2035-09-22', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2004-04-01', 'Rua Profº Samuel Graham', '428', NULL, NULL, NULL, 'Setor Aeroporto', 'Jataí', '75800057', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'E');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-09-25', TRUE, FALSE, '2026-09-25');
END $$;

DO $$
DECLARE
  m_id uuid := '73b20a01-7ee2-4c51-858e-dfe8944b3bbd';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a', '2995', 'David de Mendonça Fábris', 'FABRIS', '1982-02-10', '64999018599', '05137757659', 'davidmfabris@yahoo.com', 'AB+', 'D', '2035-10-24', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2010-11-19', 'Rua 26', '438', '41', '9', NULL, 'Residencial das Brisas', 'Jataí', '75803580', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-03-19', TRUE, FALSE, '2027-03-19');
END $$;

DO $$
DECLARE
  m_id uuid := 'd9f337f6-c3ab-441e-b136-238992a18716';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a', '3202', 'Rogério Arantes Silva', 'ARANTES', '1984-02-27', '64992363319', '00628855109', 'rogerioqindustrial@hotmail.com', 'B+', 'AD', '2035-11-07', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2010-11-19', 'Rua 4', '865', NULL, NULL, NULL, 'Setor Flamboyant', 'Jataí', NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-03-05', TRUE, FALSE, '2027-03-05');
END $$;

DO $$
DECLARE
  m_id uuid := '0521c51a-1d1e-40be-a60a-f1a8bb7b81ea';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'b851e263-f878-41b8-89b0-0c41bc5e86ce', '3821', 'Danillo Vilela de Sousa', 'VILELA', '1982-11-23', '64996067464', '96685662115', 'danillovilelaufg@hotmail.com', 'O+', 'AD', '2033-03-06', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2013-07-15', 'Rua JK', '1387', NULL, NULL, NULL, 'Vila Fátima', 'Jataí', NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'E');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-11-27', TRUE, FALSE, '2026-11-27');
END $$;

DO $$
DECLARE
  m_id uuid := 'ffdd3767-5b43-4382-ab3b-3e498f5fcd3a';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'c88b285f-ec1d-43c7-8473-23910b8839e2', '3987', 'Jonas Carvalho Silva', 'JONAS', '1991-03-30', '64996181077', '03672792152', 'jonasfrol@gmail.com', 'A+', 'AB', '2031-07-22', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2017-08-28', 'Rua Sebastião R. Cintra', '1147', NULL, NULL, NULL, 'St Antena', NULL, NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'MB');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-03-19', TRUE, FALSE, '2027-03-19');
END $$;

DO $$
DECLARE
  m_id uuid := '84a909a3-95b0-443e-badd-dbc3588be130';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'c88b285f-ec1d-43c7-8473-23910b8839e2', '4048', 'Ricardo de Freitas Passos Júnior', 'PASSOS', '1996-12-13', '64999877267', '04488196195', 'passosfreitasricardo@gmail.com', 'B+', 'AD', '2033-08-11', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2017-08-28', 'Rua A-5', NULL, '13', '1', NULL, 'Cohacol 5', 'Jataí', '75802451', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'MB');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-12-18', TRUE, FALSE, '2026-12-18');
END $$;

DO $$
DECLARE
  m_id uuid := '57af0293-9e3f-48e8-9198-6a28d490ae54';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'ab40a8db-24af-475e-ac2f-db020638332d', '4313', 'Cleuton Gomes de Oliveira Júnior', 'CLEUTON', '2000-02-19', '66997230366', '06157552166', 'cleuton.ol1910@gmail.com', 'O+', 'AB', '2033-05-01', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2023-09-04', 'Rua 239', NULL, '704', '14', 'Residencial Atlanta – Apt3', 'Vila Monticelli', 'Goiânia', NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'MB');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-03-19', TRUE, FALSE, '2027-03-19');
END $$;

DO $$
DECLARE
  m_id uuid := '04dcac96-abcb-4eec-bb5f-4643da45ba45';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'ab40a8db-24af-475e-ac2f-db020638332d', '4408', 'Edmário Júnio de Souza Salgueiro', 'EDMÁRIO', '1995-09-15', '62996371591', '02270598164', 'edmariojunio95@gmail.com', 'O+', 'AB', '2031-05-14', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2023-09-27', 'Quadra QC2', NULL, NULL, NULL, 'Conj. B - Bl 3 - Apt 102  - Ed. Salgueiro', NULL, 'Valparaíso', NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-11-27', TRUE, FALSE, '2026-11-27');
END $$;

DO $$
DECLARE
  m_id uuid := '0c1f3d38-2908-47c8-9d77-4d16f27fe8b4';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'ab40a8db-24af-475e-ac2f-db020638332d', '4397', 'Abadimarques Queiroz Aquino Alves', 'ABADIMARQUES', '1999-05-01', '62998396994', '05910143190', 'abadimarques@gmail.com', 'A+', 'AB', '2035-03-24', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2023-09-04', 'Av . Cristalina', NULL, '3', '23', NULL, 'Vila João Pedro', 'Guapó', '75350000', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'E');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-05-07', TRUE, FALSE, '2027-05-07');
END $$;

DO $$
DECLARE
  m_id uuid := '6dd8955c-e401-446c-9105-18401eaec9ad';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'ab40a8db-24af-475e-ac2f-db020638332d', '4225', 'Sabatha Adriane dos Santos Passos', 'PASSOS', '2001-04-07', '34984026200', '12492650618', 'sabatha.santos2@gmail.com', 'B-', 'B', '2035-02-22', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2023-09-04', 'Rua 8', '23', NULL, NULL, NULL, 'Residencial Bandeirantes', NULL, '75805873', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'MB');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-03-26', TRUE, FALSE, '2027-03-26');
END $$;

DO $$
DECLARE
  m_id uuid := '00297e22-97ce-4d5c-8a5a-10b33246cfb7';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'ab40a8db-24af-475e-ac2f-db020638332d', '4353', 'Pedro Juntolli Piancó', 'JUNTOLLI', '1999-05-02', '61998819319', '07004554180', 'juntolli.pianco@gmail.com', 'O+', 'B', '2032-05-17', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2023-09-04', 'Av. Norte', '1304', NULL, NULL, NULL, 'Portal do Sol', 'Jataí', NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'R');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-05-14', TRUE, FALSE, '2027-05-14');
END $$;

DO $$
DECLARE
  m_id uuid := '945a9b76-5d7d-460d-bcd1-f6d6a713d781';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'ab40a8db-24af-475e-ac2f-db020638332d', '4363', 'Lucas Dourado de Araujo', 'DOURADO', '1991-12-05', '62981122090', '03541301104', 'nazza_lucas@outlook.com', 'O+', 'AB', '2035-11-13', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2023-09-04', 'Via Professor Jose Gomes de Faria', NULL, '15', '10', NULL, 'Rio Formoso', 'Goiânia', NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'E');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-12-18', TRUE, FALSE, '2026-12-18');
END $$;

DO $$
DECLARE
  m_id uuid := '6964228d-d217-4996-b776-1fddc32f91d9';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'ab40a8db-24af-475e-ac2f-db020638332d', '4278', 'Renan Pignata Nunes', 'PIGNATA', '1996-06-15', '61992748731', '05270836157', 'renan.pignata13@gmail.com', 'A+', 'B', '2034-08-06', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2023-09-04', 'Rua P2', '144', NULL, NULL, NULL, 'Setor Popular Jataí', 'Jataí', '75803200', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'R');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-05-14', TRUE, FALSE, '2027-05-14');
END $$;

DO $$
DECLARE
  m_id uuid := '92c91bb7-1b98-48e9-956d-a056ed8760f0';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'ab40a8db-24af-475e-ac2f-db020638332d', '4171', 'Gustavo Rodrigues Albuquerque', 'ALBUQUERQUE', '1997-05-16', '61991165806', '04132409163', 'gu.albuquerque97@gmail.com', NULL, 'B', '2033-02-17', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2023-09-04', 'Avenida Portal do Sol', '255', NULL, NULL, NULL, NULL, 'Jataí', NULL, FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'MB');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-05-14', TRUE, FALSE, '2027-05-14');
END $$;

DO $$
DECLARE
  m_id uuid := 'dca2f4d1-bfaf-41fe-ab17-b0b85508ecbf';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4579', 'Daniel de Sa Cavalcante', 'DANIEL', '1994-12-26', '89994571180', '05651796320', 'cavalcantedaniel151@gmail.com', 'A+', 'AB', '2033-05-31', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Av. Couto Magalhães', '977', NULL, NULL, NULL, 'Vila Jaraguá', 'Goiânia', '74645971', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'MB');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-01-02', TRUE, FALSE, '2027-01-02');
END $$;

DO $$
DECLARE
  m_id uuid := '0c72555d-5f03-4ed2-83be-31f42394f0f8';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4552', 'Rodrigo Henrique Siqueira de Moura', 'DE MOURA', '1999-01-07', '62998154649', '04819823108', 'rodrigoh123_siqueira@hotmail.com', 'A+', 'B', '2033-05-05', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Rua José Teixeira', NULL, '6', '2', NULL, 'Jardim Dom Fernando I', 'Goiânia', '74765350', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-04-01', TRUE, FALSE, '2027-04-01');
END $$;

DO $$
DECLARE
  m_id uuid := 'f2e84ba2-ae78-4621-9a2a-04e6540759e7';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4600', 'Rafael Neves Wanderley', 'NEVES', '1992-06-30', '84992353931', '07058761442', 'rafael_carango11@hotmail.com', 'O+', 'B', '2032-12-20', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Alameda Ministro Ney Braga', '69', NULL, NULL, NULL, 'Setor Granjeiro', 'Jataí', '75804135', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2026, '2026-06-04', TRUE, FALSE, '2027-06-04');
END $$;

DO $$
DECLARE
  m_id uuid := '3baf17bc-b06b-4427-a97f-5113a76f80f5';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4673', 'Allan Dyckson da Silva', 'DYCKSON', '1992-10-03', '62994577877', '04123890105', 'allan.dyckson1@gmail.com', 'O+', 'AB', '2035-10-18', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Av. D', NULL, '12', '19', NULL, 'Setor Novo Horizonte', 'Goiânia', '74363830', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'E');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-06-26', TRUE, FALSE, '2026-06-26');
END $$;

DO $$
DECLARE
  m_id uuid := '3b7de122-802e-4719-bb34-c531437a6ee2';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'ccb57a03-138b-4fad-b81a-e1cecee690f1', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4713', 'Fernando de Jesus Lopes', 'JESUS LOPES', '1998-11-30', '61992599023', '70736688145', 'fernandolopes.fl52@gmail.com', 'A+', 'AB', '2032-05-18', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Rua do Hipódromo', '308', NULL, NULL, NULL, 'Setor Hermosa', 'Jataí', '75803330', FALSE
  );
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2026, 1, 'B');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 2, 'MB');
  INSERT INTO public.military_taf (
    military_id, year, semester, mention
  ) VALUES (m_id, 2025, 1, 'B');
  INSERT INTO public.military_health_exams (
    military_id, year, exam_date, is_fit, has_restrictions, validity_date
  ) VALUES (m_id, 2025, '2025-06-26', TRUE, FALSE, '2026-06-26');
END $$;

DO $$
DECLARE
  m_id uuid := '9551ef0d-e2a3-4639-b58b-4283c4849207';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', 'b851e263-f878-41b8-89b0-0c41bc5e86ce', '3489', 'Genesio Soares da Mata', 'GENESIO', '1980-06-27', '64996171577', '91183960115', 'genesiodamata@gmail.com', 'AB+', 'AD', '2031-11-10', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2012-04-02', 'Rua Tapajós', NULL, '4A', '6', NULL, 'Setor Vila Nova', 'Caiapônia', '75850000', FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '6a7f02c7-d1c6-4acd-8e6b-d47d8b65315c';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', 'c88b285f-ec1d-43c7-8473-23910b8839e2', '4111', 'Wesley Rangel Lins Fernandes', 'LINS', '1986-06-12', '62991278506', '02220815382', 'wesleyrlf@gmail.com', 'O+', 'AD', '2033-05-10', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2017-09-19', 'Avenida Adalto Assis Cabral', NULL, NULL, NULL, NULL, 'Setor Nova Caiapônia', 'Caiapônia', '75850000', FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '6be48463-3962-49cf-82a6-16b3be0b35e7';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', 'c88b285f-ec1d-43c7-8473-23910b8839e2', '3925', 'Edmundo Dias Moraes Neto', 'MORAES', '1990-03-25', '64984207576', '02742785108', 'edmundobop@gmail.com', 'O+', 'D', '2034-04-17', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2017-08-28', 'Rua 5', '710', NULL, NULL, NULL, 'Bairro Primavera II', 'Jataí', '75804527', FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '9a3c267a-935c-495e-acef-64d252250362';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', 'c88b285f-ec1d-43c7-8473-23910b8839e2', '3972', 'Israel Palmas Ayres da Silva Reis', 'ISRAEL', '1993-03-24', '61993551108', '04577295113', 'israel.palmas@gmail.com', 'O+', 'D', '2035-09-03', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2017-08-28', 'Rua 22', '59', NULL, NULL, NULL, 'Setor Brisas I', 'Jataí', '75803590', FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '6d2b62a4-bfa9-46e9-ad3f-fdf7b0841fbd';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4762', 'Amanda Cristina de Paula Oliveira', 'AMANDA', '1997-12-17', '64992966273', '06055395100', 'amandacriss839@gmail.com', 'A+', 'AB', '2031-09-13', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Rua C', NULL, '5', '19', NULL, 'Setor Alto da Boa Vista', 'São Luís de Montes Belos', '76056018', FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '7517a898-27ef-4c63-b994-d3a961c11804';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4675', 'Israel Pinheiro Araujo dos Santos', 'ISRAEL PINHEIRO', '1999-03-27', '62982299478', '70459229141', 'israelpinheiro.as@gmail.com', 'A+', 'AB', '2031-09-13', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Rua da Vitória', NULL, '1', '33', NULL, 'Residencial Grajaú', 'Goiânia', '74354301', FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'a50a2bb1-2913-4b5e-a865-020f79031209';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4772', 'Paulo Ibsen Cavalcante Martins Vieira', 'IBSEN', '1992-05-20', '62984673248', '03774534128', 'pauloibsen@gmail.com', 'A-', 'AB', '2035-04-03', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-09-05', 'Rua C-81', NULL, '166', '8', NULL, 'Setor Sudoeste', 'Goiânia', '74303090', FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'e2f3c81e-09c7-43ac-928f-e53381fddf58';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4670', 'Abner Pereira Duarte da Silva', 'ABNER', '1992-01-23', '61984686280', '02937302106', 'abner.pereira23@gmail.com', 'A+', 'B', '2035-03-22', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Rua 21', '342', NULL, NULL, 'Torre Dream - Apto 1702', 'Vila Jaraguá', 'Goiânia', '74655090', FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '18979387-750a-4aa2-be51-0a47a5048272';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4612', 'Luis Renato Neves Felipe', 'RENATO NEVES', '1995-11-02', '62984489257', '70390289132', 'luisrenatonevesfelipe@gmail.com', 'A+', 'AB', '2032-10-11', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Rua C-160', NULL, '332', '5', NULL, 'Setor Jardim América', 'Goiânia', '07425513', FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '6e5a504f-294b-408b-89cf-1a71917c4cb9';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4616', 'Felipe Souza Mendes Menezes', 'SOUZA MENDES', '2000-02-01', '11958794144', '50770822860', 'fmenezes171717@gmail.com', 'A+', 'B', '2033-07-12', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Avenida Afonso Pena', '2260', NULL, NULL, NULL, 'Setor Goiânia 2', 'Goiânia', '74665555', FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'afdf91d4-780a-4abf-8a70-fbbf16f2257b';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4710', 'Eric Alison Cardoso Godoy', 'GODOY', '1995-05-30', '62992358030', '02321894121', 'ericcoxa@outlook.com', 'A+', 'AB', '2036-01-12', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Rua São Pedro', NULL, NULL, '12', NULL, 'Residencial Bela Vista', 'Anápolis', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'cadc9c6a-723b-4f3e-b78a-b7a2e8f70259';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, '51dc74eb-9a4f-496a-8173-f9654362a2b9', '3649efe3-88ef-468a-ab98-1a6c20b1a17a', '4514', 'Pablo Henrique Martins Neves', 'PABLO', '1995-05-01', '62982119305', '05379614108', 'martinsnevesp@gmail.com', 'A+', 'AD', '2033-01-30', 'administrativo', NULL, 'QP/Combatente'::public.military_board, '2024-08-05', 'Rua Alameda das Gardênias', NULL, NULL, NULL, NULL, 'Setor Ponta Caiana', 'Trindade', '75384502', FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'fe203391-5336-48a5-ae76-dc77b2f6e233';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '8511925b-6bc0-41dc-9bad-398b7a0c057a', '1554', 'Hugo Brito', 'HUGO', '1980-10-19', '62984162645', '95220216104', 'hugo.brito@goias.gov.br', 'A+', 'A', NULL, 'administrativo', NULL, 'QOC'::public.military_board, NULL, 'Av 07', NULL, '151', NULL, NULL, 'Costa Nery', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'f75c5a8b-fc33-48b2-a785-5dc149d8b0d4';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '0a909f3e-2d85-4599-8d60-9ec10f6ca416', '2156', 'Ricardo Afonso Azevedo do Rosario', 'AFONSO', '1979-12-11', '64981503120', '88413357187', 'afonso.rosario@bol.com.br', 'O+', 'A', NULL, 'administrativo', NULL, 'QOC'::public.military_board, NULL, 'Rua Anchieta', NULL, '9', '4A', NULL, 'Cohacol 1', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '1dc02e13-7ef6-4c79-b5eb-59f5fe36f510';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '31607be0-58a4-463b-aaed-9b191bede08b', '1724', 'Sócrates Cândido Pereira', 'CÂNDIDO', '1980-08-21', '64999989545', '91370779100', 'socrates_candido@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QOE/Complementar'::public.military_board, NULL, 'Av. São João', '305', NULL, NULL, NULL, 'São João', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '5d4e9514-c274-4544-87dc-1d238334a05d';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '31607be0-58a4-463b-aaed-9b191bede08b', '2088', 'Marcelo Pereira Carrijo', 'MARCELO', '1981-02-22', '64996464200', '90925092134', 'marcelopcarrijo@gmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QOE/Complementar'::public.military_board, NULL, 'Av 07', NULL, '9A', '11', NULL, 'Marcelino Teodoro Gomes', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '433aaab3-d6f9-4a21-8da7-eb177101e3f5';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', 'c71382c2-9f67-4b21-8f5f-adbe5201a960', '1467', 'Cristiano Aparecido de Rezende', 'REZENDE', '1981-06-13', '64999916636', '92835830197', 'sgt.cristiano.rezende@gmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QOE/Complementar'::public.military_board, NULL, 'Avenida 13', NULL, '10', '8', NULL, 'Santa Isabel', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '5b866cc9-de08-450b-bc3e-3a9dd0e4368a';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '4ffffa07-a1d6-47f7-8743-aad276cd83a3', '4498', 'José Vitor da Silva Gonçalves', 'JOSÉ VITOR', '1993-04-27', '27997332797', '02179612583', 'josevitor_sg@hotmail.com', 'A-', 'A', NULL, 'administrativo', NULL, 'QP/Especial'::public.military_board, NULL, 'Provisoriamente sem residência', NULL, NULL, NULL, NULL, NULL, 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'dd2d8ac6-461d-4255-bc1f-c6cba8344a25';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1564', 'Jhonata  Rafael Mattana', 'MATTANA', '1980-09-23', '64996464177', '91940800110', 'jhonatamattana@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua D', NULL, '11', '7', NULL, 'Parque dos Jatobás', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '018b916d-1af6-4e37-81de-95b705280c69';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1317', 'Sílvio César Resende Carvalho', 'CÉSAR', '1972-07-04', '64999060396', '57723974191', 'silviocesarbm@gmail.com', 'B+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Avenida 15', NULL, '3', '14', NULL, 'Setor Aeroporto', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '41e8dc9a-c6fb-43b8-9a79-bfcbb355517e';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1338', 'Jair Fialho Batista', 'FIALHO', '1971-11-18', '64996416362', '78346657153', 'jairfbatista@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua D', NULL, '2', '10', NULL, 'Versalles', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'ed353ce5-3e9a-4efc-96b0-0c4b0d2656d1';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1345', 'João Pereira de Assis', 'ASSIS', '1974-02-02', '64999291744', '69373299115', 'bombneto@gmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua Anchieta', NULL, '20', '20', NULL, 'Jardim Floresta', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '48b0e431-c5cb-4721-91fa-382ee7069db0';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1344', 'Elismar Silva', 'ELISMAR', '1974-05-24', '64999276883', '77532384187', 'mazinbombeiro@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua 02', '35', NULL, NULL, NULL, 'Oeste', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'de07ad4e-f7d8-4ccc-a4bc-816768a40759';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1342', 'Fábio Cabral da Silva', 'CABRAL', '1975-08-01', '64999446815', '83596690153', 'fcabral1@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua Cândida de Carvalho', NULL, '31', '6', NULL, 'Cruvinel', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '4b1e3c90-f10d-4d28-adb8-f31dc27b09e7';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1337', 'Jorge Oliveira da Silva', 'JORGE', '1972-06-15', '64999437351', '59741139187', 'jorgemartelinho@bol.com.br', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua W1', NULL, '6', '5', NULL, 'Jardim Goiás', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '6946fa03-62fc-4822-ad14-c756123138da';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1339', 'Rodrigo de Almeida Silva', 'RODRIGO', '1978-05-03', '64996761087', '90078535115', 'aldrigo@bol.com.br', 'B+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Avenida Alvina Paniago Vilela', NULL, '18', '8', NULL, 'Jardim Floresta', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '20f190d3-29a6-4841-9b91-6235def3228f';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1333', 'Werley Lopes de Souza', 'WERLEY', '1971-10-30', '64996460240', '54641381100', 'werleylsouza@hotmail.com', 'B+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua Anhanguera', NULL, '2', '2', NULL, 'Manoel Abrão', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'aca91b5c-6a64-461c-a692-bfd80e40f0f0';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1513', 'Evando Nunes da Silva', 'NUNES', '1977-02-18', '64999544572', '82381291172', 'evandonunes@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua Dom Mathias Schmidt', NULL, '12', '26', NULL, 'Parque São José', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'cd1f3402-9351-4b88-bf30-067e2c1a2a8c';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1662', 'Patrícia Moreira Silva Resende', 'PATRÍCIA', '1977-09-09', '64999783625', '91489865187', 'patriciabombeira@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua 10', NULL, '11', '21', NULL, 'Jardim Goiás II', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '4884ed53-4908-4a89-9024-8c69c9c8b23f';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1532', 'Gisele Malveiras Lima', 'GISELE', '1980-01-03', '64999534379', '88324265104', 'gimalveiras@hotmail.com', 'A+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Avenida Alvina Paniago Vilela', NULL, '18', '18', NULL, 'Jardim Floresta', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '85eb0c32-5872-4139-adf9-02b1f32e6dae';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1579', 'Juliano Borges Machado', 'MACHADO', '1978-09-20', '64999398910', '85111201149', 'julianobomachado@hotmail.com', 'A+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, '7ª Av', '54', NULL, NULL, NULL, 'Centro', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '7328f0af-98af-4e2f-a5f1-a240d07169c7';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1763', 'Wesley Santana Ramos', 'WESLEY', '1977-08-27', '64984225389', '93943032191', 'wesleysantanaramos@gmail.com', 'B+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua 20', '41', NULL, NULL, 'Esq c/ Rua 15', 'Mineirinho', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '496a4935-c591-434a-be97-68dfad65d5b6';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1599', 'Lindomar Santana dos Santos', 'SANTANA', '1971-07-28', '64999956484', '59341912172', 'santanaobom@gmail.com', 'AB+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Av 13', NULL, '18', '2', NULL, 'Santa Isabel', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '94254549-9883-4187-b3be-87eb0618a07a';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '334d0773-22e5-4bd9-bec8-2e0fd36bb95f', '1482', 'Doriedson Santos dos Reis', 'REIS', '1973-09-07', '64999445877', '42402158115', 'doriedsonssr@bombeiros.go.gov.br', 'B+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua 07', '86', NULL, NULL, NULL, 'Centro', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '13346097-b5e5-451a-a23a-3232edf59246';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '609bbc24-7f0a-41c0-98d3-c75c028b978e', '1456', 'Cláudio Márcio de Abreu Martins', 'MÁRCIO', '1974-11-09', '64999184960', '66711789172', 'abreubomber@hotmail.com', 'AB+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Av. 09', NULL, '16', '15', NULL, 'Mundinho', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'b60084f3-24a7-4f57-82ac-61b2fb2ab1e0';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '609bbc24-7f0a-41c0-98d3-c75c028b978e', '1636', 'Marcos Jean Lionis Gonzaga', 'LIONIS', '1972-03-24', '64999899715', '55030246134', 'lionisgonzaga@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua W3', NULL, '8', '8', NULL, 'Jardim Goiás', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'ae78e239-c5bb-46f7-b47b-e5d8f95cc604';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '609bbc24-7f0a-41c0-98d3-c75c028b978e', '2200', 'Segireib Silva Barbosa', 'BARBOSA', '1980-03-12', '64996473076', '95451412120', 'segireib@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua W8', NULL, '11', '5', NULL, 'Jardim Goiás II', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '1c0f1ce8-1fc6-4b7d-8407-c65d334bdf32';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '609bbc24-7f0a-41c0-98d3-c75c028b978e', '2167', 'Rodney de Araújo Minervino', 'RODNEY', '1977-11-16', '62981215912', '00754869466', 'minervinomaosaobra@gmail.com', 'A+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua Veteranos dos Santos', NULL, '1', '3', 'Casa 6', 'Parque dos Jatobás', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'cebbd3f4-d351-4d64-babf-426e2087f85e';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '609bbc24-7f0a-41c0-98d3-c75c028b978e', '2195', 'Samuel Santos Silva', 'SAMUEL', '1972-09-05', '64984068124', '59773375153', 'samuelagente@gmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua Cabeceira Alta', NULL, '12', '7', NULL, 'Setor Iores', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '18839020-f61b-4861-95dc-25eb4edd6e55';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '609bbc24-7f0a-41c0-98d3-c75c028b978e', '2089', 'Marcelo Resende Martins', 'MARTINS', '1981-08-30', '64996444752', '94522502168', 'marceloresendemartins@gmail.com', 'A+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Av D5', NULL, '9A', '6', NULL, 'Marcelino Teodoro Gomes', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'b3cb60c1-90d7-4691-a3ad-6ae62f8651a8';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '609bbc24-7f0a-41c0-98d3-c75c028b978e', '2252', 'Wilker Oliveira Silva', 'WILKER', '1978-10-10', '64992072882', '86720708104', 'wilkeroliveirasilva@gmail.com', 'A+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua RV 13', NULL, '21', '17', NULL, 'Vilhena', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '3a2b8728-f30e-46a3-827c-6afad2b40ca5';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a', '3060', 'Joaquim Balsanuf de Oliveira Moreira', 'BALSANUF', '1983-11-05', '64999981525', '00009683151', 'jbalsanuf@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Av. 07', NULL, '14', '24', NULL, 'Jardim Goiás II', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '90bd37d1-568d-4b15-bd5f-3d2fb8f2d435';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a', '2969', 'Alex Jalowitzki Silva', 'ALEX', '1986-04-24', '64999622314', '01224230116', 'alexjalowitzki@gmail.com', 'B+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua 07', '71', NULL, NULL, NULL, 'Oeste', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '94488685-908a-4805-a2bb-7e8cdf5360c7';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a', '3181', 'Wonder Menezes de Souza', 'WONDER', '1980-11-26', '64999770233', '70657025100', 'stive193@gmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Avenida Jardim', NULL, '28', '8A', NULL, 'Centro', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'be9af4f8-2949-46ec-804d-b134e9a586c9';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a', '3244', 'Lincoln Eduardo Carrijo Gomes', 'LINCOLN', '1982-12-29', '64984034123', '94518629191', 'lincol1000@gmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Avenida José Feliciano de Morais', NULL, '20', '7', NULL, 'Jardim Floresta', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'e39f1900-c381-4f3b-a714-20cdf3368f72';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a', '3490', 'Neilo Luis Sousa Morais', 'NEILO', '1980-09-24', '64999115091', '70938334115', 'neilomorais@hotmail.com', 'A-', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Avenida Antônio Carlos Paniago', '30', NULL, NULL, NULL, '31 de Outubro', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '51f5b320-f8f2-4664-be34-b554171a9a3c';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a', '3004', 'Ederson Américo Borges', 'AMÉRICO', '1979-02-08', '64999312876', '69639060178', 'edersonaborges@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua 04', '82', NULL, NULL, NULL, 'Setor Oeste', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'b6fc1216-7920-4494-bc2f-4f6340af4aa3';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a', '3149', 'Stela Maris Espíndola Duarte Marafon', 'STELA', '1982-07-30', '64999945481', '97505765191', 'stelamedm@yahoo.com.br', 'O-', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Avenida 25', NULL, '26', '65', NULL, 'Aeroporto', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '6eb6827b-5dfd-4ead-b22e-0cc795494372';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a', '2993', 'Danilo de Melo e Silva', 'DE MELO', '1984-06-02', '64996243452', '00293272107', 'drdanilomeloadv@hotmail.com', 'AB+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua Irmã Carmelita', NULL, '29', '10', NULL, 'Jardim Floresta', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '3b785b22-5963-4a64-b8b6-b5545d3c0c19';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', 'b851e263-f878-41b8-89b0-0c41bc5e86ce', '3491', 'Lamark Santos Pereira', 'LAMARK', '1984-02-07', '64996473447', '00523248180', 'lamarksp@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua 16', NULL, '139', '15', NULL, 'Costa Nery', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'd06980fb-f882-4df5-9546-c009665d682c';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', 'b851e263-f878-41b8-89b0-0c41bc5e86ce', '3633', 'Cleidiomar Evangelista Campos', 'CAMPOS', '1981-02-02', '64999418055', '96391995168', 'cleidiomarcampos@gmail.com', 'O-', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua Hidelbrando Cruvinel', NULL, '4', '11', NULL, 'Cohacol 3', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'ca5b8dd9-5522-4094-b8b5-b78196026c91';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', 'b851e263-f878-41b8-89b0-0c41bc5e86ce', '3486', 'Marcelo Silva Teodoro', 'TEODORO', '1987-06-08', '64999542388', '02797910117', 'marcelo_5056@hotmail.com', 'A+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua 03', NULL, '15', '6', NULL, '31 de Outubro', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'f5e7772f-6824-4b33-8ee8-82fed884c27f';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', 'b851e263-f878-41b8-89b0-0c41bc5e86ce', '3632', 'Marcelo Souza Silva', 'SOUZA', '1982-10-11', '64999873460', '00247443107', 'marcello23edf@hotmail.com', 'O+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Avenida Q', NULL, '11', '12-B', NULL, 'Marcelino Teodoro Gomes', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '8a46fe2b-31d2-4686-ba4d-a4ba796d8eab';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', 'b851e263-f878-41b8-89b0-0c41bc5e86ce', '3631', 'Marcus Vinicius Ribeiro Dias', 'MARCUS VINICIUS', '1990-06-02', '64996953959', '02327936110', 'marcusvinicius_incendio@yahoo.com.br', 'O-', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua M', NULL, '18', '7', NULL, 'Nossa Sra Aparecida', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'cb7e8ce1-849d-463f-8868-816ed5129099';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', 'b851e263-f878-41b8-89b0-0c41bc5e86ce', '3767', 'Amanda Marsola Pansani Mattana', 'MARSOLA', '1985-03-30', '64996185082', '35102762800', 'mpm.amanda@gmail.com', 'A+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua D', NULL, '11', '7', NULL, 'Parque dos Jatobás', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := 'ab041e52-ce92-4be3-a874-14490f1b2f56';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', 'b851e263-f878-41b8-89b0-0c41bc5e86ce', '3764', 'Daniel Pereira Martins', 'DANIEL', '1983-09-23', '64999897033', '98733990115', 'martins103@hotmail.com', 'A-', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua BV-33', NULL, '36', '1', 'Esq c/ Rua BV-38', 'Buena Vista', 'Mineiros', NULL, FALSE
  );
END $$;

DO $$
DECLARE
  m_id uuid := '1089ca3a-e034-4f74-be95-342b76f1021b';
BEGIN
  INSERT INTO public.military_personnel (
    id, unit_id, rank_id, rg, full_name, war_name, birth_date, phone,
    cpf, email, blood_type, driver_license_category, driver_license_expiration,
    classification, platoon, quadro, inclusion_date,
    address_street, address_number, address_block, address_lot,
    address_complement, address_district, address_city, address_zipcode,
    is_inactive
  ) VALUES (
    m_id, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', 'c88b285f-ec1d-43c7-8473-23910b8839e2', '4006', 'Luan Ananias de Assis', 'LUAN', '1991-07-03', '64999950076', '04007548196', 'luan_cpa10@hotmail.com', 'A+', 'A', NULL, 'administrativo', NULL, 'QP/Combatente'::public.military_board, NULL, 'Rua Sebastião Barbosa de Oliveira', NULL, '5', '1', 'Apto 102', 'Rodrigues', 'Mineiros', NULL, FALSE
  );
END $$;


COMMIT;

-- Resumo:
-- Militares: 97
-- Registros de TAF: 93
-- Avaliações de saúde: 39
-- Erros: 0