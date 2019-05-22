USE StackOverflow2013;
GO
SET STATISTICS IO, TIME ON;

/* Blog: https://bertwagner.com/2019/04/16/window-functions-vs-group-bys/ */
/* Assume this table started out with the following index */
DROP INDEX IF EXISTS [IX_Badges] ON [dbo].[Badges] ([Name]);
CREATE NONCLUSTERED INDEX IX_Badges__Name_Date_UserId ON [dbo].[Badges] (Name,Date,UserId);
GO

/* Who was the first person to earn each badge? */

SELECT DISTINCT
    Name,
    FIRST_VALUE(UserId) OVER (PARTITION BY Name ORDER BY Date,UserId) AS UserId
FROM
    dbo.Badges b
ORDER BY
    Name,UserId
OPTION (MAXDOP 1)
GO
/*

(2255 rows affected)
Table 'Worktable'. Scan count 8024153, logical reads 66533578, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Badges'. Scan count 1, logical reads 46767, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 47110 ms,  elapsed time = 47518 ms.
*/







/* The old fashioned way */
SELECT
    b.Name,
    MIN(b.UserId) AS UserId
FROM
    dbo.Badges b
    INNER JOIN
    (
    SELECT
        Name,
        MIN(Date) AS Date
    FROM
        dbo.Badges
    GROUP BY
        Name
    ) m
        ON b.Name = m.Name
        AND b.Date = m.Date
GROUP BY
    b.Name
ORDER BY
    Name,UserId
OPTION (MAXDOP 1);
GO

/*
(2255 rows affected)
Table 'Badges'. Scan count 1, logical reads 46767, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 890 ms,  elapsed time = 896 ms.
*/