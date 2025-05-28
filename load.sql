CREATE TABLE times AS
	SELECT
		DISTINCT(*)
	FROM read_csv("../data/via-train-status-data/data/out/times.tsv")
	ORDER BY arrival_scheduled;

ALTER TABLE times ADD COLUMN difference INTERVAL;
ALTER TABLE times ADD COLUMN difference_s INTEGER;

UPDATE times
	SET
		difference = arrival_actual - arrival_scheduled,
		difference_s = date_diff('second', arrival_scheduled, arrival_actual);
