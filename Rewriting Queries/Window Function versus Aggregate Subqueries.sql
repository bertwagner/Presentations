USE [StackOverflow2013];
GO

SET STATISTICS IO ON;
DROP INDEX IF EXISTS IX_Badges__Name_Date_UserId ON [dbo].[Badges]


-- For each badge, who was the first user to get it (min user id for ties) (are these badges or also tags?)

/* without index:   76%,   49959 reads on Badges, 66533585 reads on Worktable */
/* with index       90%, 47270 reads on Badges, 66533585 reads on Worktable*/
SELECT DISTINCT
    Name,
    FIRST_VALUE(UserId) OVER (PARTITION BY Name ORDER BY Date,UserId) AS UserId
FROM
    dbo.Badges b
ORDER BY
    Name,UserId
OPTION (MAXDOP 1) /* remove parallelism effects between queries */
/* before 49649 reads, 66533578 reads */
CREATE NONCLUSTERED INDEX IX_Badges__Name_Date_UserId ON [dbo].[Badges] (Name,Date,UserId);
/* after 46767 reads, 66533578 reads */
/* minor improvement, but not significant.  Query takes 46 seconds to run on my machine. */
/* segments are groupings for window.  First groups Name, second Name, Date,UserId. */
/* Window spool then "Expands each row into the set of rows that represent the window associated with it." */
/* Then in each of those windows, stream agg sees if first value is null and gets first non-null value (stream aggregate more efficient than window aggregate, but data was sorted from our window Spool)*/
/* then for each window group, we return the first value  in the compute scalar */
/* hash match used to dedupe the values for our DISTINCT */
/* then sort and return results */
/* => not great because window spool is writing a bunch to temp db, and then hashmatch has to go throug hand dedpue the records */

/* so while query syntax is easy to understand, performance is meh because operations happen on full 8 million rows the whole (and then need temp db to expand to 16 million rows) time. */

/* what if we rewrite using old fashion nested group bys? */



/* 46767 reads.  no temp db */
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
--OPTION (QUERYTRACEON 3604, QUERYTRACEON 8607, QUERYTRACEON 8612);


/* same exact results, finish in 1 second */
/* query is uglier - have to use a derived table to get first date for each name, then join that with the original data to get all users who have that same date before then choosing the user with the lowest userid*/
/* the reason this is so fast is that we never have to go to temp db.  The data is already sorted and flows through */
/* additionally, SQL Server is able to simplify the query - while the queyr is ugly and is the first way I thoguht of writing, SQL Server is able to do some cool optimizations. */
/* for example, you might see that our query references the badges table twice, but the execution plan only shows us reading from ti once.  */
/* this is because the SQL Server optimizer determined that since the data is sorted, it can use the Top operator to only return the Name and UserId rows for the top name and date within a group - which matches the MIN logic in this case.  This reduces from 8 million to 30k rows. */




/* so window functions are always slower? */
/* not necessarily.  There is the temp db hit as in this exapmle, but sometime sthat hit is neglibale on small amoutns of data.  In those cases a more concise query sytnax would be preferable.*/
