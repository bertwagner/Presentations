--47:30
USE StackOverflow2013;
GO
SET STATISTICS IO, TIME ON;

/* Blog: https://bertwagner.com/2017/11/21/does-the-join-order-of-my-tables-matter/ */
/* Adam Machanic's SQL Bits Presentation: https://sqlbits.com/Sessions/Event14/Query_Tuning_Mastery_Clash_of_the_Row_Goals */

DROP INDEX IF EXISTS IX_Badges ON dbo.Badges;
CREATE NONCLUSTERED INDEX IX_Badges ON dbo.Badges (Date) INCLUDE (Name,UserId);

/* This query joins Badges and Users first. */
SELECT
	p.Id,
	p.Title,
	u.DisplayName,
	b.Name AS BadgeName,
	b.Date
FROM
	dbo.Users u
	INNER JOIN dbo.Badges b
		ON u.Id = b.UserId
	INNER JOIN dbo.Posts p
		ON u.Id = p.OwnerUserId
WHERE
	b.Date >= '2010-01-01'
	AND b.Date < '2010-01-07'
OPTION (MAXDOP 1)

/*
(2077705 rows affected)
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Posts'. Scan count 1, logical reads 4184557, physical reads 0, read-ahead reads 4169202, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Users'. Scan count 0, logical reads 28932, physical reads 19, read-ahead reads 3013, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Badges'. Scan count 1, logical reads 41, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 11437 ms,  elapsed time = 27258 ms.
*/






/* Even if we change the join order and add parenthesis, SQL Server still executes in the same order. */
SELECT
	p.Id,
	p.Title,
	u.DisplayName,
	b.Name AS BadgeName,
	b.Date
FROM
	(dbo.Users u
	INNER JOIN dbo.Posts p
		ON u.Id = p.OwnerUserId)
	INNER JOIN dbo.Badges b
		ON u.Id = b.UserId
WHERE
	b.Date >= '2010-01-01'
	AND b.Date < '2010-01-07'
OPTION (MAXDOP 1)




/* Adding a blocking operator, we can force the join order. */
SELECT
	pu.Id,
	pu.Title,
	pu.DisplayName,
	b.Name AS BadgeName,
	b.Date
FROM
	(SELECT TOP (2147483647) /* This TOP forces the join order.  This large number of results should never be returned from this derived table query */ 
		p.Id, p.Title, u.Id AS UserId, u.DisplayName 
	FROM 
		dbo.Posts p
	INNER JOIN dbo.Users u
		ON p.OwnerUserId = u.Id
	) pu
	INNER JOIN dbo.Badges b
		ON pu.UserId = b.UserId
WHERE
	b.Date >= '2010-01-01'
	AND b.Date < '2010-01-07'
OPTION (MAXDOP 1)

/*
(2077705 rows affected)
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Posts'. Scan count 1, logical reads 4184557, physical reads 0, read-ahead reads 4169056, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Users'. Scan count 1, logical reads 44530, physical reads 0, read-ahead reads 41225, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Badges'. Scan count 1, logical reads 41, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 18672 ms,  elapsed time = 33580 ms.
*/