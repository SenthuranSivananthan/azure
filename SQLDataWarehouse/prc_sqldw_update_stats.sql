CREATE PROCEDURE prc_sqldw_update_stats
AS
	IF OBJECT_ID('tempdb..#stats_ddl_update') IS NOT NULL
	BEGIN;
		DROP TABLE #stats_ddl_update;
	END;

	CREATE TABLE #stats_ddl_update
	WITH    (
				DISTRIBUTION    = HASH([seq_nmbr]),
				LOCATION        = USER_DB
			)
	AS
	(
		select 
			CAST('UPDATE STATISTICS '+QUOTENAME([name]) AS NVARCHAR(4000))	AS update_stat_dml,
			row_number() OVER(ORDER BY (SELECT NULL))   AS [seq_nmbr]
		from sys.[tables]
	);
	
	DECLARE @i INT = 1,
			@t INT = (SELECT COUNT(*) FROM #stats_ddl_update),
			@query NVARCHAR(4000) = N'';

	WHILE @i <= @t
	BEGIN
		SET @query=(SELECT update_stat_dml FROM #stats_ddl_update WHERE seq_nmbr = @i);

		PRINT @query;
		EXEC sp_executesql @query;

		SET @i+=1;
	END

	DROP TABLE #stats_ddl_update;