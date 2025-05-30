CREATE OR REPLACE MACRO times_for_service(train_id_oi, station_code_oi) AS TABLE (
	SELECT
		*,
		round(difference_s / 60) AS difference_m
	FROM times
		WHERE
			train_id = train_id_oi::VARCHAR AND
			station_code = station_code_oi
);

CREATE OR REPLACE MACRO summarize_on_time_performance(train_id_oi, station_code_oi) AS TABLE (
	SELECT
		train_id_oi::VARCHAR as train_id,
		station_code_oi as station_code,
		year(arrival_scheduled) as year,
		count(*) as n,
		min(difference) as min,
		max(difference) as max,
		median(difference) as median,
		mean(difference) as mean,
		mode(difference) as mode
	FROM times_for_service(train_id_oi, station_code_oi)
	GROUP BY
		year
	ORDER BY year
);

-- e.g., for an individual train at station:
-- FROM summarize_on_time_performance('24', 'OTTW');

-- e.g., for a combination:
-- FROM summarize_on_time_performance('24', 'OTTW')
-- UNION ALL
-- FROM summarize_on_time_performance('24', 'MTRL');
