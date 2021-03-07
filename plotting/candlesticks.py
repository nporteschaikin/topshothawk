import numpy as np
import pandas as pd

import matplotlib.pyplot as plt
import plotly.graph_objects as go
from datetime import datetime

def data_prep_candlestick(data, player):
    mask = data['player_name'] == player
    grped = data[mask].sort_values(['player_name', 'moment_id', 'date'], ascending=True)\
                      .groupby(['player_name', 'moment_id', 'date'])\
                      .agg({'price_USD': ['first', 'last', 'min', 'max']})\
                      .reset_index()
    grped.columns = ['_'.join(np.ravel(i)) for i in grped.columns]
    return grped  

def append_moving_avg(candle_data,
                      moment_id,
                      periods=5, 
                      min_periods=1, 
                      moment_id_col='moment_id_', 
                      price_col='price_USD_last'
                      ):
    mask = candle_data[moment_id_col] == moment_id
    MA = candle_data.groupby(moment_id_col)[price_col]\
                    .rolling(periods, min_periods=min_periods)\
                    .mean()\
                    .reset_index()
    MA.columns = ['moment_id_rolling', 'index', 'MA_Price_'+str(periods)]
    return pd.concat((candle_data, MA), axis=1) 

def plot_moment_candle(data, moment_id, MA_col=None, moment_id_col='moment_id_'):
    mask = data[moment_id_col] == moment_id
    to_plot = data[mask]
    if MA_col is None:
        fig = go.Figure(data=[go.Candlestick(x=to_plot['date_'],
                    open=to_plot['price_USD_first'],
                    high=to_plot['price_USD_max'],
                    low=to_plot['price_USD_min'],
                    close=to_plot['price_USD_last'])])
    else:
        fig = go.Figure(data=[go.Candlestick(x=to_plot['date_'],
                                            open=to_plot['price_USD_first'],
                                            high=to_plot['price_USD_max'],
                                            low=to_plot['price_USD_min'],
                                            close=to_plot['price_USD_last']),
                              go.Scatter(x=to_plot['date_'], y=to_plot[MA_col], line=dict(color='orange', width=1))])
    return fig

data = pd.read_csv(obj['Body'], nrows=10000)
keep = ['moment_unique_id',
        'moment_id',
        'player_name',
        'set_asset_path',
        'set_name',
        'serial_number',
        'circulation_count',
        'transaction_timestamp',
        'price_USD',
        'play_category']

df = data[keep]
df['date'] = pd.to_datetime(df['transaction_timestamp']).dt.date.astype(str)
cndl_data = data_prep_candlestick(df, 'Aaron Gordon')
MA_data = append_moving_avg(cndl_data)

fig = plot_moment_candle(MA_data, '5e531f15-d573-4589-9c52-6778448cc105', MA_col='MA_Price_5')
fig.show()