/* 
    What is a SQL Injection Homoglyph Attack?
    More information available here: 
        - https://bertwagner.com/2017/09/12/how-unicode-homoglyphs-can-thwart-your-database-security/ */
        - https://bertwagner.com/category/sql-injection/
*/

USE StackOverflow2010;
GO

/* Create a procedure that builds and executes a dynamic query */
DROP PROCEDURE IF EXISTS dbo.GetProfile_Injectable
GO
CREATE PROCEDURE dbo.GetProfile_Injectable
	@DisplayName nvarchar(40)
AS
BEGIN
	DECLARE @Query varchar(max);

	SET @Query = 'SELECT 
					Id, 
                    DisplayName,
                    CreationDate
				FROM
					dbo.Users
				WHERE
					DisplayName = ''' + @DisplayName + '''
					';

	EXEC(@Query);
END;
GO

EXEC dbo.GetProfile_Injectable @DisplayName = N'BertWagner';
EXEC dbo.GetProfile_Injectable @DisplayName = N' '' OR 1=1--';


/* Oh no! Let's write our own security function from preventing this from happening */
DROP PROCEDURE IF EXISTS dbo.GetProfile_PartiallySecure
GO
CREATE PROCEDURE dbo.GetProfile_PartiallySecure
	@DisplayName nvarchar(40)
AS
BEGIN
	-- Add quotes to escape injection...or not?
	SET @DisplayName = REPLACE(@DisplayName, '''','''''');

	DECLARE @Query varchar(max);

	SET @Query = 'SELECT 
					Id, 
                    DisplayName,
                    CreationDate
				FROM
					dbo.Users
				WHERE
					DisplayName = ''' + @DisplayName + '''
					';

	EXEC(@Query);
END;
GO

EXEC dbo.GetProfile_PartiallySecure @DisplayName = N'BertWagner';
EXEC dbo.GetProfile_PartiallySecure @DisplayName = N' '' OR 1=1--';
EXEC dbo.GetProfile_PartiallySecure @DisplayName = N' ʼ OR 1=1--';

/* Kind of worked.  But the implicit conversion allowed a homoglyph? */
SELECT 
	CAST(N'ʼ' AS nchar) AS UnicodeChar, 
	CAST(N'ʼ' AS char) AS NonUnicodeChar;
       
/* use parameterized queries.  Use sp_execute sql. don't write your own "security" functions. */        

DROP PROCEDURE IF EXISTS dbo.GetProfile_Secure
GO
CREATE PROCEDURE dbo.GetProfile_Secure
	@DisplayName nvarchar(40)
AS
BEGIN
	DECLARE @Query nvarchar(max)

	SET @Query = 'SELECT 
					Id, 
                    DisplayName,
                    CreationDate
				FROM
					dbo.Users
				WHERE
					DisplayName = @DisplayName 
					';

	DECLARE @ParmDefinition nvarchar(100) = N'@DisplayName nvarchar(40)';  

	EXEC sp_executesql @Query, @ParmDefinition,  
					  @DisplayName = @DisplayName;

END
GO                    

EXEC dbo.GetProfile_Secure @DisplayName = N'BertWagner';
EXEC dbo.GetProfile_Secure @DisplayName = N' '' OR 1=1--';
EXEC dbo.GetProfile_Secure @DisplayName = N' ʼ OR 1=1--'; 