/* Blog: https://bertwagner.com/2019/04/16/window-functions-vs-group-bys/ */
SELECT DISTINCT
    Name,
    FIRST_VALUE(UserId) OVER (PARTITION BY Name ORDER BY Date,UserId) AS UserId
FROM
    dbo.Badges b
ORDER BY
    Name,UserId
OPTION (MAXDOP 1)
GO

CREATE NONCLUSTERED INDEX IX_Badges__Name_Date_UserId ON [dbo].[Badges] (Name,Date,UserId);
GO

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