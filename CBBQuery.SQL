-- Assuming you have a table called 'df_box_scores'

-- Separate 'TeamAvTeamB' from 'FixtureKey' by removing the date portion
CREATE TEMP TABLE temp1 AS
SELECT
    FixtureKey,
    SUBSTR(FixtureKey, 1, LENGTH(FixtureKey) - 12) AS TeamAvTeamB
FROM
    df_box_scores;

-- Extract 'TeamName' from 'TeamAvTeamB' based on the lowercase "v" separator
CREATE TEMP TABLE temp2 AS
SELECT
    FixtureKey,
    TeamAvTeamB,
    TRIM(SUBSTR(TeamAvTeamB, 1, INSTR(TeamAvTeamB, 'v') - 1)) AS TeamName
FROM
    temp1;

-- Select the final result
SELECT
    df.Team,
    df.X2PM,
    df.X2PA,
    df.X3PM,
    df.X3PA,
    df.FTM,
    df.FTA,
    df.ORB,
    df.DRB,
    df.AST,
    df.STL,
    df.BLK,
    df.TOV,
    df.PF,
    t2.TeamName
FROM
    df_box_scores AS df
JOIN
    temp2 AS t2
ON
    df.FixtureKey = t2.FixtureKey;
