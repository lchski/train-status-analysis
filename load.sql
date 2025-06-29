-- LOADING: stations

--- Source: https://www.viarail.ca/en/developer-resources
CREATE TABLE stations AS
	SELECT
		DISTINCT(*)
	FROM read_csv("data/source/viarail.ca/via-gtfs/stops.txt")
	ORDER BY stop_code;



-- LOADING: times
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

-- CLEANING

--- To identify errant station codes:
--- SELECT stop_code, COUNT(*) AS n FROM times WHERE char_length(stop_code) > 4 GROUP BY stop_code;
UPDATE times
	SET
		stop_code = 'ALZL'
	WHERE
		stop_code = 'Aleza Lake';
