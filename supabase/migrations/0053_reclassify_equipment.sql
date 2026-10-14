begin;

-- Recategoriza equipamentos importados com base em palavras-chave do item.
-- Equipamentos não categorizados permanecem em Outros.

with mapping as (
  select
    e.id,
    case
      when lower(e.item) like any (array['%nautica%', '%náutica%', '%embarcação%', '%embarcacao%', '%lancha%', '%barco%', '%jet%', '%moto nautica%', '%moto náutica%'])
        then (select id from public.equipment_categories where name = 'Aquático')
      when lower(e.item) like any (array['%moto serra%', '%soprador%', '%incendio florestal%', '%incêndio florestal%', '%fogo%'])
        then (select id from public.equipment_categories where name = 'Incêndio Florestal')
      when lower(e.item) like any (array['%dea%', '%desfibrilador%', '%aspirador%', '%cinto%', '%corda%', '%resgate%', '%salvamento%', '%tripé%', '%desencarcerador%', '%expansora%', '%divisor%'])
        then (select id from public.equipment_categories where name = 'Resgate')
      when lower(e.item) like any (array['%escada%', '%altura%', '%rapel%'])
        then (select id from public.equipment_categories where name = 'Altura')
      when lower(e.item) like any (array['%abafador%', '%extintor%', '%mangueira%', '%incendio urbano%', '%incêndio urbano%'])
        then (select id from public.equipment_categories where name = 'Incêndio Urbano')
      when lower(e.item) like any (array['%radio%', '%rádio%', '%comunicação%', '%comunicacao%'])
        then (select id from public.equipment_categories where name = 'Comunicação')
      when lower(e.item) like any (array['%reboque%', '%carretinha%', '%transporte%'])
        then (select id from public.equipment_categories where name = 'Transporte')
      when lower(e.item) like any (array['%gerador%', '%motobomba%', '%bomba%', '%veículo%', '%veiculo%', '%moto%', '%carro%'])
        then (select id from public.equipment_categories where name = 'Terrestre')
      else (select id from public.equipment_categories where name = 'Outros')
    end as new_category_id
  from public.equipment e
)
update public.equipment e
set category_id = m.new_category_id
from mapping m
where e.id = m.id;

commit;
