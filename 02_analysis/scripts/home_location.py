import pandas as pd
import numpy as np

def assign_home_location(data, uid='u_id', tract='OBJECTID', date='date', hour='hour',
                         min_tweets=10, min_days=10, min_hours=8):
    """
    Assign a home location for Twitter users and their tweets based on following methodology:
    
    1. Consider tracts satisfying the following properties:
        - More than `min_tweets` tweets total
        - Sent from more than `min_days` different days
        - Sent from more than `min_hours` different hours of the day
    2. Of the remaining candidates, select the tract with the most tweets
    
    This function does not guarantee that all Twitter users/tweets will be assigned a home location.
    Some users will not have any tweets that meet the criteria defined above; this will result in a
    missing value (np.NaN) being assigned to the home tract for that user's tweets.
    
    
    Parameters
    ----------
    data : pd.DataFrame or gpd.geodataframe.GeoDataFrame
        DataFrame containing the following columns (variables passed into the function):
            - uid : Twitter user ID
            - tract : Tract identifier (e.g. tract ID, FIPS code)
            - date : Datetime object containing just the date 
                     (year, month, and day; not a full timestamp)
            - hour : Integer containing 24-hour-format hour of tweet
    
    uid, tract, date, hour : string (optional, default='u_id', 'OBJECTID', 'date', 'hour')
        Column names to extract from `data`; additional details under `data` parameter
    
    min_tweets : integer (optional, default=10)
        Minimum number of tweets required from a user at a valid tract
        
    min_days : integer (optional, default=10)
        Minimum number of unique days a user must tweet from a valid tract
    
    min_hours : integer (optional, default=8)
        Minimum number of unique hours a user must tweet from a valid tract
    
    
    Returns
    -------
    pd.Series of length data.shape[0], containing a home location for each tweet.
    Note that this function is not an inplace operation. 
    e.g. df['home_tract'] = assign_home_location(df)
    
    """
    # Note: groupby is done multiple times to save computation time
    home_locations = (
        data
        # More than min_tweets
        .groupby([uid, tract])
        .filter(lambda user_tract: len(user_tract) > min_tweets)
        
        # More than min_days
        .groupby([uid, tract])
        .filter(lambda user_tract: user_tract[date].nunique() > min_days)
        
        # More than min_hours
        .groupby([uid, tract])
        .filter(lambda user_tract: user_tract[hour].nunique() > min_hours)
        
        # Extract home location
        .groupby([uid, tract])
        .size()
        .reset_index(name='count')
        .sort_values(by='count', ascending=False)
        .loc[:, [uid, tract]]
        .groupby(uid)
        .first()
        .loc[:, tract]
    )
    
    return data[uid].map(home_locations.to_dict())
    
    
    
    
    
    
    