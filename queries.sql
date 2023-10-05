WITH TeamAvTeamB AS (
    SELECT
        FixtureKey,
        SUBSTR(FixtureKey, 1, LENGTH(FixtureKey) - 12) AS TeamAvTeamB
    FROM
        box_scores
)
SELECT DISTINCT
    TeamAvTeamB.FixtureKey AS FixtureKey, 
    TRIM(CASE
            WHEN Team = 1 THEN SUBSTR(TeamAvTeamB, 1, INSTR(TeamAvTeamB, 'v') - 1)
            WHEN Team = 2 THEN SUBSTR(TeamAvTeamB, INSTR(TeamAvTeamB, 'v') + 1)
            ELSE NULL -- Handle other cases if needed
        END) AS TeamName,
    Team, X2PM, X2PA, X3PM, X3PA, FTM, FTA, ORB, DRB, AST, STL, BLK,TOV,
    PF,
    ROUND((CAST(X2PM AS REAL) + CAST(X3PM AS REAL)) / (CAST(X2PA AS REAL) + CAST(X3PA AS REAL))*100,2) AS 'FG%',
    ROUND((CAST(X2PM AS REAL) / CAST(X3PA AS REAL))*100,2)  AS'3P%',
    ROUND((CAST(FTM AS REAL) / CAST(FTA AS REAL))*100,2)  AS'FT%'
FROM
    TeamAvTeamB
    JOIN box_scores ON TeamAvTeamB.FixtureKey = box_scores.FixtureKey;
