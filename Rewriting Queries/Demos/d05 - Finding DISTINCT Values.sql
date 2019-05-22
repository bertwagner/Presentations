USE StackOverflow2013;
GO
SET STATISTICS IO ON;

/* https://sqlperformance.com/2014/10/t-sql-queries/performance-tuning-whole-plan */


/* Sometimes DISTINCT or TOP 1 isn't the fastest way to get  data */