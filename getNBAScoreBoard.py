from nba_api.stats.endpoints import LeagueGameFinder
import pandas as pd
pip install nba_api


class GetScoreBoard:

  def __init__(self, year):
     self.year = year

  def getDates(self):
    season_start_year = self.year
    season_end_year = str(int(season_start_year) + 1)
    season = f'{season_start_year}-{season_end_year[-2:]}'
    game_finder = LeagueGameFinder(season_nullable=season)
    games = game_finder.get_data_frames()[0]
    game_dates_2018 = games['GAME_DATE'].unique()
    return list(game_dates_2018)
