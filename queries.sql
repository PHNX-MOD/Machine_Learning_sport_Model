WITH TeamAvTeamB AS (
    SELECT
        FixtureKey,
        SUBSTR(FixtureKey, 1, LENGTH(FixtureKey) - 12) AS TeamAvTeamB
    FROM
        box_scores
)
SELECT
    TeamAvTeamB.FixtureKey AS FixtureKey, 
    CASE
        WHEN Team = 1 THEN SUBSTR(TeamAvTeamB, 1, INSTR(TeamAvTeamB, 'v') - 1)
        WHEN Team = 2 THEN SUBSTR(TeamAvTeamB, INSTR(TeamAvTeamB, 'v') + 1)
        ELSE NULL -- Handle other cases if needed
    END AS TeamName,
    Team,
    X2PM,
    X2PA,
    X3PM,
    X3PA,
    FTM,
    FTA,
    ORB,
    DRB,
    AST,
    STL,
    BLK,
    TOV,
    PF
FROM
    TeamAvTeamB
    JOIN box_scores ON TeamAvTeamB.FixtureKey = box_scores.FixtureKey;

