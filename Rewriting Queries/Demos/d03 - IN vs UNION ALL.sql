--33:45
USE StackOverflow2013;
GO
SET STATISTICS IO ON;

/* Blog: https://bertwagner.com/2019/04/23/correlated-subqueries-vs-derived-tables/ */
/* Assume this index is already created*/
DROP INDEX IF EXISTS IX_Badges__Name_Date_UserId ON [dbo].[Badges];
CREATE NONCLUSTERED INDEX [IX_Badges] ON [dbo].[Badges] ([Name]) INCLUDE ([UserId]);


/* Return data for users that received the following badges.  Note this index isn't covering. */

/* Query 1 */
SELECT 
    Name, UserId, Date 
FROM 
    dbo.Badges 
WHERE 
    Name = 'Benefactor'
OPTION(MAXDOP 1)

/* Query 2 */
SELECT 
    Name, UserId, Date 
FROM 
    dbo.Badges 
WHERE 
    Name = 'Research Assistant'
OPTION(MAXDOP 1)

/*
(17935 rows affected)
Table 'Badges'. Scan count 1, logical reads 49649, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(127 rows affected)
Table 'Badges'. Scan count 1, logical reads 401, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/





/* Combine with IN */
SELECT 
    Name, UserId, Date 
FROM 
    dbo.Badges 
WHERE 
    Name IN ('Benefactor','Research Assistant')
OPTION(MAXDOP 1)

/*
(18062 rows affected)
Table 'Badges'. Scan count 2, logical reads 55417, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/








/* UNION ALL */
SELECT 
    Name,UserId,Date 
FROM 
    dbo.Badges 
WHERE 
    Name = 'Benefactor' 
UNION ALL
SELECT 
    Name,UserId,Date 
FROM 
    dbo.Badges 
WHERE 
    Name = 'Research Assistant'
OPTION(MAXDOP 1)

/*
(18062 rows affected)
Table 'Badges'. Scan count 2, logical reads 50050, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/