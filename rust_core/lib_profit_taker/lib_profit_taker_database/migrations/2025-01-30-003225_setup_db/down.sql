-- Drop foreign key-dependent tables first
DROP TABLE IF EXISTS shield_changes;
DROP TABLE IF EXISTS leg_breaks;
DROP TABLE IF EXISTS squad_members;
DROP TABLE IF EXISTS phases;
DROP TABLE IF EXISTS player_pb;

-- Drop tables without foreign key dependencies
DROP TABLE IF EXISTS status_effects;
DROP TABLE IF EXISTS leg_position;
DROP TABLE IF EXISTS runs;
