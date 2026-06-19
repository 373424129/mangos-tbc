-- Hunter pet state investigation and repair for a single character.
-- Replace @player_name if needed before running.

SET @player_name := 'Test';

SELECT guid, name, class
FROM tbccharacters.characters
WHERE name = @player_name;

SET @owner_guid := (
    SELECT guid
    FROM tbccharacters.characters
    WHERE name = @player_name
    LIMIT 1
);

SELECT owner, id, entry, slot, name, CreatedBySpell, PetType, curhealth
FROM tbccharacters.character_pet
WHERE owner = @owner_guid
ORDER BY slot, id;

-- Remove training tame pets that should never persist as hunter pets.
DELETE cps
FROM tbccharacters.pet_spell_cooldown AS cps
JOIN tbccharacters.character_pet AS cp ON cp.id = cps.guid
WHERE cp.owner = @owner_guid
  AND cp.PetType = 1
  AND cp.CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);

DELETE ps
FROM tbccharacters.pet_spell AS ps
JOIN tbccharacters.character_pet AS cp ON cp.id = ps.guid
WHERE cp.owner = @owner_guid
  AND cp.PetType = 1
  AND cp.CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);

DELETE pa
FROM tbccharacters.pet_aura AS pa
JOIN tbccharacters.character_pet AS cp ON cp.id = pa.guid
WHERE cp.owner = @owner_guid
  AND cp.PetType = 1
  AND cp.CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);

DELETE cpd
FROM tbccharacters.character_pet_declinedname AS cpd
JOIN tbccharacters.character_pet AS cp ON cp.id = cpd.id
WHERE cp.owner = @owner_guid
  AND cp.PetType = 1
  AND cp.CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);

DELETE FROM tbccharacters.character_pet
WHERE owner = @owner_guid
  AND PetType = 1
  AND CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);

-- Pick one active hunter pet record to keep as current and push all other active records to slot 100.
SET @preferred_pet_id := (
    SELECT id
    FROM tbccharacters.character_pet
    WHERE owner = @owner_guid
      AND PetType = 1
      AND (slot = 0 OR slot > 2)
    ORDER BY CASE WHEN slot = 0 THEN 0 ELSE 1 END, id
    LIMIT 1
);

UPDATE tbccharacters.character_pet
SET slot = 0
WHERE owner = @owner_guid
  AND id = @preferred_pet_id;

UPDATE tbccharacters.character_pet
SET slot = 100
WHERE owner = @owner_guid
  AND PetType = 1
  AND id <> @preferred_pet_id
  AND (slot = 0 OR slot > 2);

SELECT owner, id, entry, slot, name, CreatedBySpell, PetType, curhealth
FROM tbccharacters.character_pet
WHERE owner = @owner_guid
ORDER BY slot, id;
