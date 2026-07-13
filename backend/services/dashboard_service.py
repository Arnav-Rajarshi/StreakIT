import backend.models as M
from backend.database.db import get_connection
import psycopg
import backend.database.crud as C

def getDashboardPage(uid)->M.DashboardPage:

    return M.DashboardPage(
        HeatmapData=getHeatmapData(uid),
        GraphData=getGraphData(uid),
        SummaryData=getSummaryData(uid)
    )


def getSummaryData(uid)->list[M.SummaryData]:
    
    result=[]

    habits = C.read_HabitConfigs(uid) or []
    caches = C.read_HabitCaches(uid)
    caches_by_habit_id = {cache.habit_id: cache for cache in caches}

    with get_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:

            for habit in habits:
                cache = caches_by_habit_id.get(habit.hid)
                if cache is None:
                    continue
                
                hid = habit.hid
                
                cur.execute("Select td_week(%s)", (hid,))
                td_week= cur.fetchone()['td_week'] #{'td_week': 0}
                
                
                cur.execute("Select td_month(%s)", (hid,))
                td_month=cur.fetchone()['td_month']

                cur.execute("Select td_year(%s)", (hid,))
                td_year= cur.fetchone()['td_year']

                cur.execute(
                    """
                    select avg(duration) from habit_logs 
                    where habit_id = %s 
                    and habit_logs.date >= date_trunc('week',CURRENT_DATE)::date
                    """,
                    (hid,)
                    )
                avg_session_length_this_week=cur.fetchone()['avg'] or 0# because the response looks like {'avg': None}
                #print(avg_session_length_this_week)

                HabitName,HabitColor,HabitIcon = habit.habit_name, habit.color, habit.icon
                Currstreak,Beststreak,TotalSessions,TotalDuration = cache.current_streak , cache.best_streak , cache.total_sessions , cache.total_duration

                result.append(M.SummaryData(
                    HabitName=HabitName,
                    HabitColor=HabitColor,
                    HabitIcon=HabitIcon,
                    curr_streak=Currstreak,
                    best_streak=Beststreak,
                    avg_session_duration=avg_session_length_this_week,
                    total_sessions=TotalSessions,
                    total_duration=TotalDuration,
                    td_week=td_week,
                    td_month=td_month,
                    td_year=td_year
                ))

    """
    response would look like
    [
        {
            "date":"2026-07-13",
            "completed":true,
            "duration":60
        },
        {
            "date":"2026-07-13",
            "completed":false,
            "duration":0
        },
        {
            "date":"2026-07-13",
            "completed":true,
            "duration":20
        }
    ]
    """
    return result


def getGraphData(uid)->list[M.GraphData]:

    with get_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute(
                """
                SELECT hl.habit_id, hl.date, hl.consistency_score
                FROM habit_logs hl
                JOIN habit_config hc ON hl.habit_id = hc.hid
                WHERE hc.user_id = %s
                ORDER BY hl.date ASC, hl.habit_id ASC
                """,
                (uid,)
            )
            rows = cur.fetchall()

    return [
        M.GraphData(
            habit_id=row["habit_id"],
            date=row["date"],
            consistency_score=float(row["consistency_score"] or 0),
        )
        for row in rows
    ]


def getHeatmapData(uid)->list[M.HeatmapData]:
    with get_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute(
                """
                SELECT hl.habit_id, hl.date, hl.completed, hl.scheduled, hl.duration
                FROM habit_logs hl
                JOIN habit_config hc ON hl.habit_id = hc.hid
                WHERE hc.user_id = %s
                ORDER BY hl.date ASC, hl.habit_id ASC
                """,
                (uid,)
            )
            rows = cur.fetchall()

    return [
        M.HeatmapData(
            habit_id=row["habit_id"],
            date=row["date"],
            completed=row["completed"],
            scheduled=row["scheduled"],
            duration=row["duration"],
        )
        for row in rows
    ]