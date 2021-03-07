import pandas as pd
import numpy as np
import s3fs # reading from s3 bucket
from pulp import * # optimization
import datetime

df = pd.read_csv('s3://topshotdata/nba_topshot_transactions.csv')

keep = ['player_name', 
        'set_name', 
        'serial_number', 
        'transaction_timestamp', 
        'price_USD', 
        'buyer_name',
        'seller_name', 
        'play_category', 
        'set_asset_path',
        'circulation_count',
        'moment_id',
        'moment_unique_id',
        'transaction_id']

df = df[keep]
df['year'] = pd.DatetimeIndex(df['transaction_timestamp']).year
df['month'] = pd.DatetimeIndex(df['transaction_timestamp']).month
df['day'] = pd.DatetimeIndex(df['transaction_timestamp']).day

high_cc = df[df['serial_number'] > df['circulation_count']*0.3]

high_cc_agg = high_cc.groupby(['moment_id', 'year', 'month', 'day', 'player_name', 'set_name', 'set_asset_path'])\
                     .agg({'price_USD': [min, max]})\
                     .reset_index()

high_cc_agg.columns = ["_".join(x) for x in high_cc_agg.columns.ravel()]

high_cc_agg['set_asset_path_'] = high_cc_agg['set_asset_path_']\
                                  .str.split('/', expand=True)\
                                  .iloc[:,5]\
                                  .str.replace('[.]jpg','')\
                                  .str.replace('co_', 'series_')

def build_portfolio(year, month, day, df, spend):
    """Finds the mix of moments that generated the highest return on a given date and spend within a defined budget

    Parameters
    ----------
    year: int
        year of date
    month: int
        month of date
    day: int
        day of date
    df: pandas.DataFrame
        dataframe with very specific columns (for now)
        price_USD_min = lowest price of the day, price_USD_max = highest price of the day
    spend : int
        defined budget

    Returns
    -------
    print statement
        garbage output of what the best moments to buy on that date were, how much it would have cost, and what the return would have been
    """
    
    filtered = df[(df['year_'] == year) & (df['month_'] == month) & (df['day_'] == day)]
    players = np.array(filtered['player_name_'])
    vote = np.array(filtered['price_USD_max'])
    price = np.array(filtered['price_USD_min'])
    sap = np.array(filtered['set_asset_path_'])
    
    P = range(len(players))
    prob = LpProblem("Portfolio", LpMaximize)
    x = LpVariable.matrix("x", list(P), 0, 1, LpInteger)
    prob += sum(vote[p] * x[p] for p in P)
    prob += sum(price[p] * x[p] for p in P) <= spend
    prob.solve()
    
    portfolio = [players[p] for p in P if x[p].varValue]
    prices = [price[p] for p in P if x[p].varValue]
    values = [vote[p] for p in P if x[p].varValue]
    set_path = [sap[p] for p in P if x[p].varValue]
    
    print('buy:', portfolio)
    print('\n')
    print(set_path)
    print('\n')
    print('pay: $', sum(prices))
    print('\n')
    print('revenue: $', sum(values))
    
build_portfolio(year=2021, month=1, day=5, df=high_cc_agg, spend=100)