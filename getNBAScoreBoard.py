from nba_api.stats.endpoints import scoreboardv2
from nba_api.stats.endpoints import LeagueGameFinder
import json
import pandas as pd


class GetScoreBoard:
    def __init__(self, year):
        self.year = year
        self.scoreboardv2 = None
        self.loadscoreboard = None

    def initialize_scoreboardv2(self, gameDate):
        self.scoreboardv2 = scoreboardv2.ScoreboardV2(game_date=gameDate)
        scoreboard_json = self.scoreboardv2.get_json()
        self.loadscoreboard = json.loads(scoreboard_json)
        return self.loadscoreboard


    #Get all the dates in the given year of NBA games    
    def getDates(self):
        season_start_year = self.year
        season_end_year = str(int(season_start_year) + 1)
        season = f'{season_start_year}-{season_end_year[-2:]}'
        game_finder = LeagueGameFinder(season_nullable=season)
        games = game_finder.get_data_frames()[0]
        game_dates = games['GAME_DATE'].unique()
        return list(game_dates)

    #Get all the games/scores in that day of the given date   
    def getDayScore(self, gameDate):
      loadscoreboard = self.initialize_scoreboardv2(gameDate)
      df = pd.DataFrame(pd.DataFrame(loadscoreboard['resultSets'])['headers'][1]).T
      for n in range(int(len(pd.DataFrame(loadscoreboard['resultSets'])['rowSet'][1]))) :
        teamStats = pd.DataFrame(loadscoreboard['resultSets'])['rowSet'][1][n]
        df.loc[len(df)] = teamStats  
      return df.drop(index=0), loadscoreboard

    #get all the games/scores in the list of dates given 
    def getScoreBoard(self):
        dates = self.getDates()
        empty_dataframe = pd.DataFrame()
        for n in range(len(dates)):
          df = self.getDayScore(dates[n])[0]
          empty_dataframe = pd.concat([empty_dataframe, df], ignore_index=True)        
        empty_dataframe.columns = (pd.DataFrame(pd.DataFrame((self.getDayScore(dates[1])[1])['resultSets'])['headers'][1]).T).iloc[0].tolist()
        return empty_dataframe

if __name__ == "__main__":
    # Example usage
    year = 2018  # Example year
    scoreboard = GetScoreBoard(year)

    # Call methods as needed
    dates = scoreboard.getDates()
    print("Game dates:", dates)

    gameDate = '2018-11-13'  # Example date
    day_score_df, load_scoreboard = scoreboard.getDayScore(gameDate)
    print("Day score DataFrame:", day_score_df)
    print("Loaded scoreboard:", load_scoreboard)

    scoreboard_df = scoreboard.getScoreBoard()
    print("Scoreboard DataFrame:", scoreboard_df)
