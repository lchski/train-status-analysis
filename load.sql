CREATE TEMPORARY TABLE stations_raw AS
	SELECT
		DISTINCT(*)
	FROM read_csv("../data/via-train-status-data/data/out/stations.tsv")
	ORDER BY station_code;

UPDATE stations_raw
	SET
		station_name = 'Aleza Lake'
	WHERE
		station_code = 'ALZL' AND
		station_name = 'Alzea Lake';

UPDATE stations_raw
	SET
		station_name = 'Lac-Aux-Perles'
	WHERE
		station_code = 'PRLL' AND
		station_name = 'Pearl Lake';

CREATE TABLE stations AS
	SELECT
		DISTINCT(*)
	FROM stations_raw
	ORDER BY station_code;



CREATE TABLE times AS
	SELECT
		DISTINCT(*)
	FROM read_csv("../data/via-train-status-data/data/out/times.tsv")
	ORDER BY arrival_scheduled;

ALTER TABLE times
	ALTER train_id SET DATA TYPE INTEGER USING regexp_extract(train_id, '(^\d*)');

ALTER TABLE times ADD COLUMN difference INTERVAL;
ALTER TABLE times ADD COLUMN difference_s INTEGER;

UPDATE times
	SET
		difference = arrival_actual - arrival_scheduled,
		difference_s = date_diff('second', arrival_scheduled, arrival_actual);
