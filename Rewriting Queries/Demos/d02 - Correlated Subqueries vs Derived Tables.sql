USE StackOverflow2013;
GO
SET STATISTICS IO, TIME ON;

/* Blog: https://bertwagner.com/2019/04/23/correlated-subqueries-vs-derived-tables/ */

/* When was each user's first badge awarded? */
SELECT DISTINCT
    UserId,
    FirstBadgeDate = (SELECT MIN(Date) FROM dbo.Badges i WHERE o.UserId = i.UserId)
FROM
    dbo.Badges o
OPTION (MAXDOP 1)

/*
(1318413 rows affected)
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Badges'. Scan count 2, logical reads 93534, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 7828 ms,  elapsed time = 12075 ms.
*/








/* Moving to a derived table */
SELECT DISTINCT
    o.UserId,
    FirstBadgeDate
FROM
    dbo.Badges o
    INNER JOIN 
        (SELECT 
            UserId, 
            MIN(Date) as FirstBadgeDate 
        FROM 
            dbo.Badges GROUP BY UserId
        ) i
    ON o.UserId = i.UserId
OPTION (MAXDOP 1)

/* CPU 33% faster
(1318413 rows affected)
Table 'Workfile'. Scan count 10, logical reads 10296, physical reads 930, read-ahead reads 9366, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Badges'. Scan count 2, logical reads 93534, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 5313 ms,  elapsed time = 9567 ms.
*/


/* Reduce more redundancy - maybe we needed multiple calls to dbo.Badges originally but not anymore */
SELECT 
    UserId, 
    MIN(Date) as FirstBadgeDate 
FROM 
    dbo.Badges 
GROUP BY 
    UserId
OPTION (MAXDOP 1)

/*
(1318413 rows affected)
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 4, logical reads 8024, physical reads 875, read-ahead reads 7149, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Badges'. Scan count 1, logical reads 46767, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 2828 ms,  elapsed time = 7163 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
*/