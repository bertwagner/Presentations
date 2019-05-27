/* 
    Efficient  JSON Querying in SQL Server 2016+
    More information available here: 
        - https://bertwagner.com/2017/03/07/the-ultimate-sql-server-json-cheat-sheet/
        - https://bertwagner.com/2019/02/26/searching-complex-json-data/
*/

/* Create a table and load it with nested data */
DROP TABLE IF EXISTS #ImportedJson;
GO
CREATE TABLE #ImportedJson
(
    Id int IDENTITY,
    JsonValue nvarchar(max) /* need nvarchar for JSON functions to work */
);
GO
INSERT INTO #ImportedJson (JsonValue) VALUES (N'{ 
    "Property1" : "Value1", 
    "Property2" : [1,2,3]
}');
INSERT INTO #ImportedJson (JsonValue) VALUES (N'{ 
    "Property1" : "Value2", 
    "Property3" : [1,2,3], 
    "Property4" : ["A","B","C",null], 
    "Property5" : { 
                    "SubProp1": "A", 
                    "SubProp2": { 
                                    "SubSubProp1":"B", 
                                    "SubSubProp2": 1.2,
                                    "SubSubProp3" : true
                                } 
                    }, 
    "Property6" : [{"ArrayProp":"A"},{"ArrayProp":"B"}], 
    "Property7" : 123, 
    "Property8" : null 
}');
INSERT INTO #ImportedJson (JsonValue) VALUES (N'{ 
    "Property8" : "Not null", 
    "Property9" : [4,5,6]
}');

/* View our table */
SELECT * FROM #ImportedJSON;


/* Scalars */
SELECT JSON_VALUE(JsonValue,'$.Property1') FROM #ImportedJson;

/* Fragments */
SELECT JSON_QUERY(JsonValue,'$.Property2') FROM #ImportedJson;

/* Tables */
SELECT * FROM #ImportedJson CROSS APPLY OPENJSON(JsonValue,'$')

/* But most important task is usually fast parsing.  Use the table function OPENJSONN() */

/* Can search this JSON by using LIKE...but we lose all context and can get false positives */
SELECT * FROM #ImportedJSON WHERE JsonValue LIKE '%Property4"%A%';

/* Or can normalize the data */
WITH JSONRoot AS ( 
	SELECT
		Id as RowId,
		[key],
		[value],
		CAST([type] AS INT) AS [type]
	FROM
		#ImportedJson
		CROSS APPLY OPENJSON(JsonValue,'$')
		UNION ALL 
		SELECT 
			RowId,
			CASE WHEN JSONRoot.[type] = 4 THEN JSONRoot.[key]+'['+t.[key]+']' ELSE t.[key] END,
			t.[value],
			CAST(t.[type] AS INT)
		FROM
			JSONRoot
			CROSS APPLY OPENJSON(JSONRoot.[value],'$') t 
			WHERE 
				JSONRoot.[type] > 3 /* Only parse complex data types */
)
SELECT
	RowId,
	[key],
	[value],
	[type]
FROM 
	JSONRoot
ORDER BY
	RowId;
GO