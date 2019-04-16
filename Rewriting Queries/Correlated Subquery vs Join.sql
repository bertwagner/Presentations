SET STATISTICS IO, TIME ON;

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