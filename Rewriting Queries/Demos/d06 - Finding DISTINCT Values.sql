--53:30
USE StackOverflow2013;
GO
SET STATISTICS IO,TIME ON;

/* https://sqlperformance.com/2014/10/t-sql-queries/performance-tuning-whole-plan */

DROP INDEX IF EXISTS IX_Badges ON dbo.Badges;
CREATE NONCLUSTERED INDEX IX_Badges ON dbo.Badges (Name);

/* Sometimes DISTINCT isn't the fastest way to get data when there are a lot of duplicates */

SELECT DISTINCT
	Name
FROM
	dbo.Badges
OPTION (MAXDOP 1);

/*
(2255 rows affected)
Table 'Badges'. Scan count 1, logical reads 34629, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 1016 ms,  elapsed time = 1014 ms.
*/


WITH RecursiveCTE
AS
(
    -- Anchor
    SELECT TOP (1)
        Name
    FROM dbo.Badges AS b
    ORDER BY
        b.Name
 
    UNION ALL
 
    -- Recursive
    SELECT r.Name
    FROM
    (
        -- Number the rows
        SELECT 
            b.Name,
            rn = ROW_NUMBER() OVER (
                ORDER BY b.Name)
        FROM dbo.Badges AS b
        JOIN RecursiveCTE AS r
            ON r.Name < b.Name
    ) AS r
    WHERE
        -- Only the row that sorts lowest
        r.rn = 1
)
SELECT 
    Name
FROM RecursiveCTE
OPTION (MAXRECURSION 0);

/*
(2255 rows affected)
Table 'Badges'. Scan count 2256, logical reads 6783, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 2, logical reads 13531, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 114 ms.
*/