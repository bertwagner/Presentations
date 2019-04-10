--CREATE NONCLUSTERED INDEX IX_Posts__PostTypeIdInclude ON dbo.Posts(PostTypeId) INCLUDE (OwnerUserId)
--https://www.periscopedata.com/blog/use-subqueries-to-count-distinct-50x-faster
--SET STATISTICS IO ON;

-- How many distinct users create each type of post?

-- 3.5 M rows of data have to get joined before we aggregate
SELECT 
    pt.Type, 
    COUNT(DISTINCT p.OwnerUserId) AS DistinctUsers
FROM 
    dbo.Posts p 
    INNER JOIN dbo.PostTypes pt on p.PostTypeId = pt.Id
GROUP BY 
    pt.Type 
ORDER BY    
    pt.Type

-- Data is aggregated first, then 5x5 rows  get joined
SELECT
    pt.Type,
    p.DistinctUsers
FROM 
    dbo.PostTypes pt
    INNER JOIN (
        SELECT
            PostTypeId,
            COUNT(DISTINCT OwnerUserId) AS DistinctUsers
        FROM dbo.Posts 
        GROUP BY PostTypeId
    ) AS p 
    ON pt.Id = p.PostTypeId
ORDER BY 
    pt.Type


-- SAVE THIS FOR ANOTHER POST? Or include it.  More indedpth correlated subquery post in the future
-- This logic is slighty different because it counts the post types because it does an outer join instead of an inner join so post types with no user posts are counted (nonne of those types existed in 2010)
SELECT 
    pt.Type, 
    DistinctUsers = (SELECT COUNT(DISTINCT p.OwnerUserId) FROM  dbo.Posts p WHERE p.PostTypeId = pt.Id)
FROM 
    dbo.PostTypes pt
GROUP BY 
    pt.Type, 
    pt.Id
ORDER BY    
    pt.Type

