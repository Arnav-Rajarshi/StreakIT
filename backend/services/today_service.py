import backend.database.crud as crud
import datetime
import backend.models as models

def getTodaysHabits(uid):
    raw_habit_configs = crud.read_HabitConfigs(uid)
    # business logic ... only the habits which are scheduled for today
    '''
    [
    HabitConfig(...),
    HabitConfig(...),
    HabitConfig(...),
    ]
    '''

    today = datetime.date.today().weekday() # returns an integer from 0 to 6
    filtered_habit_configs=[]
    todays_hids=[]
    for i in raw_habit_configs :
        if today in i.track_on:
            filtered_habit_configs.append(i)
            todays_hids.append(i.hid)
    
    filtered_habit_caches= [crud.read_HabitCache(i) for i in todays_hids]

    result=[]
    for habit,cache in zip(filtered_habit_configs,filtered_habit_caches):
        result.append(
            models.TodaysHabits(
                config=habit,
                cache=cache
            )
        )
    return result 
#user = crud.read_UserDetails(user_name="mock1")
#print(getTodaysHabits(user.uid))
'''
this is what your return looks like
[
TodaysHabits(
    config  =   HabitConfig(
                    hid=UUID('489c1588-f0e0-40c0-b2a3-68a28b7d5ab0'), 
                    user_id=UUID('36ad1bcc-9c87-49bd-912f-f38e96b7f057'), 
                    habit_name='Daily Reading', icon='book-open', 
                    color='#4ECDC4', track_on=[0, 1, 2, 3, 4], 
                    minimum_days=5, 
                    target_duration_per_session=25, 
                    is_active=True, 
                    created_at=datetime.datetime(2026, 7, 3, 18, 11, 55, 741806)
                    ),  
    cache   =   HabitCache(
                    habit_id=UUID('489c1588-f0e0-40c0-b2a3-68a28b7d5ab0'), 
                    current_streak=5, 
                    best_streak=7, 
                    total_sessions=20, 
                    total_duration=500, 
                    last_completed_date=datetime.date(2026, 7, 5), 
                    last_cache_update=datetime.datetime(2026, 7, 5, 10, 8, 8, 389141), 
                    curr_streak_start_date=datetime.date(2026, 6, 29)
                    )
    ),
TodaysHabit( (...),(...)) , 
TodaysHabit( (...),(...))
]
'''


def getTodayPage(uid):
    """
    Purpose:
        Fetch all the data required for the Home page and return it in a
        frontend-friendly format.

    Workflow:
        1. Call CRUD functions to fetch the required data from PostgreSQL.
        2. Store the fetched data in local variables.
        3. Apply any business logic (if required).
        4. Construct a dictionary/Pydantic model containing all the data
           needed by the frontend.
        Then FastAPI will automatically convert it to JSON before sending it to React.
        5. Return the result.

    Design Note:
        Although the same HabitConfig and HabitCache data may be required by
        multiple pages (Dashboard, Calendar, Home, etc.), we intentionally
        fetch it from the database whenever needed instead of storing it in
        global variables.

        Reasons:
        - The database is the single source of truth.
        - Data can change at any time (new logs, edits, deletions).
        - PostgreSQL is optimized for frequent reads.
        - habit_cache already acts as the application's cache.
        - Avoid stale data and synchronization issues caused by maintaining
          another cache inside Python.
    """
    todays_habits = getTodaysHabits(uid)
    return todays_habits

 

        





