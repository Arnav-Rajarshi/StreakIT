import backend.services.dashboard_service as ds
import backend.database.crud as C

user = C.read_UserDetails("mock1")

print(ds.getDashboardPage(user.uid))