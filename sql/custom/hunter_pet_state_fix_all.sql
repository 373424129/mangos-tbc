-- Global cleanup for persisted hunter pet state issues.
-- Review the SELECT statements before keeping this in a regular maintenance flow.

SELECT owner, COUNT(*) AS active_rows
FROM tbccharacters.character_pet
WHERE PetType = 1
  AND (slot = 0 OR slot > 2)
GROUP BY owner
HAVING COUNT(*) > 1
ORDER BY active_rows DESC, owner;

-- Remove invalid persisted training tame pets.
DELETE cps
FROM tbccharacters.pet_spell_cooldown AS cps
JOIN tbccharacters.character_pet AS cp ON cp.id = cps.guid
WHERE cp.PetType = 1
  AND cp.CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);

DELETE ps
FROM tbccharacters.pet_spell AS ps
JOIN tbccharacters.character_pet AS cp ON cp.id = ps.guid
WHERE cp.PetType = 1
  AND cp.CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);

DELETE pa
FROM tbccharacters.pet_aura AS pa
JOIN tbccharacters.character_pet AS cp ON cp.id = pa.guid
WHERE cp.PetType = 1
  AND cp.CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);

DELETE cpd
FROM tbccharacters.character_pet_declinedname AS cpd
JOIN tbccharacters.character_pet AS cp ON cp.id = cpd.id
WHERE cp.PetType = 1
  AND cp.CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);

DELETE FROM tbccharacters.character_pet
WHERE PetType = 1
  AND CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);

-- Normalize any remaining duplicate active hunter pet rows.
UPDATE tbccharacters.character_pet AS cp
JOIN (
    SELECT owner, MIN(CASE WHEN slot = 0 THEN id ELSE 4294967295 END) AS current_id, MIN(id) AS fallback_id
    FROM tbccharacters.character_pet
    WHERE PetType = 1
      AND (slot = 0 OR slot > 2)
    GROUP BY owner
) AS keepers ON keepers.owner = cp.owner
SET cp.slot = CASE
    WHEN cp.id = CASE WHEN keepers.current_id <> 4294967295 THEN keepers.current_id ELSE keepers.fallback_id END THEN 0
    WHEN cp.slot = 0 OR cp.slot > 2 THEN 100
    ELSE cp.slot
END
WHERE cp.PetType = 1
  AND (cp.slot = 0 OR cp.slot > 2);

SELECT owner, COUNT(*) AS active_rows
FROM tbccharacters.character_pet
WHERE PetType = 1
  AND (slot = 0 OR slot > 2)
GROUP BY owner
HAVING COUNT(*) > 1
ORDER BY active_rows DESC, owner;
