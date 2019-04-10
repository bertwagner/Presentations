-- SET STATISTICS IO ON;
-- DROP INDEX IF EXISTS IX_Badges__NameDateInclude ON [dbo].[Badges]
-- For each badge, who was the first user to get it (min user id for ties) (are these badges or also tags?)

/* without index:   24%,  100758 reads on Badges */
/* with index       10%,46744 reads on Badges */
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

/* without index:   76%,   49959 reads on Badges, 66533585 reads on Worktable */
/* with index       90%, 47270 reads on Badges, 66533585 reads on Worktable*/
SELECT DISTINCT
    Name,
    FIRST_VALUE(UserId) OVER (PARTITION BY Name ORDER BY Date,UserId) AS UserId
FROM
    dbo.Badges b
ORDER BY
    Name,UserId

/* what if we add the index?

CREATE NONCLUSTERED INDEX IX_Badges__NameDateInclude
ON [dbo].[Badges] ([Name],[Date])
INCLUDE ([UserId])
GO

*/