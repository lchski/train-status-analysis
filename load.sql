CREATE TABLE times AS
	SELECT
		DISTINCT(*)
	FROM read_csv("../data/via-train-status-data/data/out/times.tsv")
	ORDER BY arrival_scheduled;

ALTER TABLE times ADD COLUMN difference INTERVAL;

UPDATE times
	SET difference = arrival_actual - arrival_scheduled;
