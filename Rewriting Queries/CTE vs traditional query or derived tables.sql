-- What answer triggered a badge to be awarded?

SELECT 
    p.Id as AnswerId,
    p.Score,
    p.CreationDate,
    u.Id as UserId,
    u.DisplayName,
    b.Name as BadgeName
FROM
    dbo.Posts p
    INNER JOIN dbo.Users u
        ON p.OwnerUserId = u.OwnerUserId
    INNER dbo.Badges b
        ON u.Id = b.UserId
        AND p.CreationDate = b.Date
WHERE 
    PostTypeId=2
    