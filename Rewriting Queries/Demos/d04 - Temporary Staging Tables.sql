--40
USE StackOverflow2013;
GO
SET STATISTICS IO ON;

/* Blog: https://bertwagner.com/2019/05/07/temporary-staging-tables/ */


/* Imagine this query is used to return offset results for a paginated report */
WITH January2010Badges AS ( 
	SELECT 
		UserId,
		Name,
		Date
	FROM 
		dbo.Badges 
	WHERE 
		Date >= '2010-01-01' 
		AND Date <= '2010-02-01' 
), Next10PopularQuestions AS ( 
	SELECT TOP 10 * FROM (SELECT UserId, Name, Date FROM January2010Badges WHERE Name = 'Popular Question' ORDER BY Date OFFSET 10 ROWS) t
), Next10NotableQuestions AS ( 
	SELECT TOP 10 * FROM (SELECT UserId, Name, Date FROM January2010Badges WHERE Name = 'Notable Question' ORDER BY Date OFFSET 10 ROWS) t
), Next10StellarQuestions AS ( 
	SELECT TOP 10 * FROM (SELECT UserId, Name, Date FROM January2010Badges WHERE Name = 'Stellar Question' ORDER BY Date OFFSET 10 ROWS) t
)
SELECT UserId, Name FROM Next10PopularQuestions 
UNION ALL 
SELECT UserId, Name FROM Next10NotableQuestions
UNION ALL 
SELECT UserId, Name FROM Next10StellarQuestions 
OPTION (MAXDOP 1)

/*

(20 rows affected)
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Badges'. Scan count 3, logical reads 103966, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/





/* Divide an conquer */
DROP TABLE IF EXISTS #January2010Badges;
CREATE TABLE #January2010Badges
(
	UserId int,
	Name nvarchar(40),
	Date datetime
	CONSTRAINT PK_NameDateUserId PRIMARY KEY CLUSTERED (Name,Date,UserId)
);

INSERT INTO #January2010Badges
SELECT
	UserId,
	Name,
	Date
FROM 
	dbo.Badges
WHERE 
	Date >= '2010-01-01' 
	AND Date <= '2010-02-01'; 

/* 
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 204, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Badges'. Scan count 9, logical reads 50379, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(42317 rows affected)
*/

/* Rewrite the rest of the query using the temp table */
WITH Next10PopularQuestions AS ( 
	SELECT TOP 10 * FROM (SELECT UserId, Name, Date FROM #January2010Badges WHERE Name = 'Popular Question' ORDER BY Date OFFSET 10 ROWS) t
), Next10NotableQuestions AS ( 
	SELECT TOP 10 * FROM (SELECT UserId, Name, Date FROM #January2010Badges WHERE Name = 'Notable Question' ORDER BY Date OFFSET 10 ROWS) t
), Next10StellarQuestions AS ( 
	SELECT TOP 10 * FROM (SELECT UserId, Name, Date FROM #January2010Badges WHERE Name = 'Stellar Question' ORDER BY Date OFFSET 10 ROWS) t
)
SELECT UserId, Name FROM Next10PopularQuestions 
UNION ALL 
SELECT UserId, Name FROM Next10NotableQuestions 
UNION ALL 
SELECT UserId, Name FROM Next10StellarQuestions 
OPTION (MAXDOP 1)

/*
(20 rows affected)
Table '#January2010Badges____000000000016'. Scan count 3, logical reads 12, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

/* This helps:
	- Fix inefficient spooling
	- Gives SQL Server more data to work with to help make better plans
*/