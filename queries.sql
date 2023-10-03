SELECT
    SUBSTR(FixtureKey, 1, LENGTH(FixtureKey) - 12) AS TeamAvTeamB,
    SUBSTR(SUBSTR(FixtureKey, 1, LENGTH(FixtureKey) - 12), 1, INSTR(SUBSTR(FixtureKey, 1, LENGTH(FixtureKey) - 12), 'v') - 1) AS TeamName,
    Team, X2PM,  X2PA, X3PM, X3PA, FTM, FTA, ORB,  DRB, AST, STL, BLK,TOV, PF
FROM
    box_scores;
