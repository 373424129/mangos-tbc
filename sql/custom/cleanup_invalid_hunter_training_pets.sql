-- Remove invalid hunter training pets that were incorrectly persisted as permanent pets.
-- Review the rows with the SELECT first, then run the DELETE when ready.

SELECT id, entry, owner, CreatedBySpell, PetType, slot, name
FROM character_pet
WHERE PetType = 1
  AND CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);

DELETE FROM character_pet
WHERE PetType = 1
  AND CreatedBySpell IN (13481, 19597, 19676, 19678, 19679, 19680, 19681, 19682, 19684, 19685, 19686);
