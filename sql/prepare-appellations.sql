-- Renommage de la colonne dont le nom est tronqué
ALTER TABLE Appellation RENAME appellatio TO appellation;

-- Suppression des géométries des segments 3 et 4
UPDATE Appellation SET geom = NULL WHERE segment IN ('3', '4');

-- Correction des géométries incorrectes
UPDATE Appellation SET geom = ST_Buffer(geom, 0) WHERE geom IS NOT NULL AND NOT ST_IsValid(geom);

-- Enrichissement du schéma de la table
CREATE TYPE type_granularite_appellation AS ENUM('commune', 'exacte');

ALTER TABLE Appellation ADD COLUMN instruction_obligatoire boolean;
ALTER TABLE Appellation ADD COLUMN granularite type_granularite_appellation;

-- Enrichissement des données
UPDATE Appellation SET instruction_obligatoire = FALSE;
UPDATE Appellation SET granularite = 'exacte' WHERE segment = '1';
UPDATE Appellation SET granularite = 'commune' WHERE segment IN ('3', '4');

-- Marquage de l'appellation Sable de Camargue
UPDATE Appellation SET instruction_obligatoire = TRUE WHERE IDApp = '1022';

-- Création des indexes
CREATE INDEX appellations_geom_gist ON Appellation USING GIST (geom);
CREATE INDEX appellations_insee ON Appellation USING btree (insee);
