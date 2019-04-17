-- Can I rewrite this to be more beneficial/make use of the infromation in the outer table?

SET STATISTICS IO, TIME ON;
USE StackOverflow2010;
GO

SELECT DISTINCT
    UserId,
    Name AS BadgeName,
    FirstBadgeDate = (SELECT MIN(Date) FROM dbo.Badges i WHERE o.UserId = i.UserId)
FROM
    dbo.Badges o
OPTION(MAXDOP 1)

-- Filters data first before joining - only have to join 1 million rows
SELECT DISTINCT
    o.UserId,
    o.Name AS BadgeName,
    FirstBadgeDate
FROM
    dbo.Badges o
    INNER JOIN (SELECT UserId, MIN(Date) as FirstBadgeDate FROM dbo.Badges GROUP BY UserId) i
    ON o.UserId = i.UserId
OPTION(MAXDOP 1)

-- But looking at this query, it doesn't offer antyhing special.  Maybe if we needed to retrieve another column in our outer o table (like in [last week's post on window functions](https://bertwagner.com/2019/04/16/window-functions-vs-group-bys/) then this could make sense, but we are getting no value here!

SELECT 
    UserId, 
    MIN(Date) as FirstBadgeDate 
FROM 
    dbo.Badges 
GROUP BY 
    UserId
 
OPTION(MAXDOP 1)

-- While you may think "I would never start off with such a complicated query", I typically see these types of scenarios where requirements change over time.
-- Things started out complicated, but at some point were able to get simplified, but then it wasn't taken a step further to entirely refactor the query to something simpler.
-- Often times queries aren't revisited - if you do have a query that's changed dramatically over time due to changing requirements, it might be worth trying to rewrite it from scratch again instead of making small modifications.














SET STATISTICS IO, TIME ON;
USE StackOverflow2010;
GO

SELECT DISTINCT
    UserId,
    FirstBadgeDate = (SELECT MIN(Date) FROM dbo.Badges i WHERE o.UserId = i.UserId)
FROM
    dbo.Badges o
OPTION(MAXDOP 1)

-- Filters data first before joining - only have to join 1 million rows
SELECT DISTINCT
    o.UserId,
    FirstBadgeDate
FROM
    dbo.Badges o
    INNER JOIN (SELECT UserId, MIN(Date) as FirstBadgeDate FROM dbo.Badges GROUP BY UserId) i
    ON o.UserId = i.UserId
OPTION(MAXDOP 1)

-- But looking at this query, it doesn't offer antyhing special.  Maybe if we needed to retrieve another column in our outer o table (like in [last week's post on window functions](https://bertwagner.com/2019/04/16/window-functions-vs-group-bys/) then this could make sense, but we are getting no value here!

SELECT 
    UserId, 
    MIN(Date) as FirstBadgeDate 
FROM 
    dbo.Badges 
GROUP BY 
    UserId
 
OPTION(MAXDOP 1)

-- While you may think "I would never start off with such a complicated query", I typically see these types of scenarios where requirements change over time.
-- Things started out complicated, but at some point were able to get simplified, but then it wasn't taken a step further to entirely refactor the query to something simpler.
-- Often times queries aren't revisited - if you do have a query that's changed dramatically over time due to changing requirements, it might be worth trying to rewrite it from scratch again instead of making small modifications.




