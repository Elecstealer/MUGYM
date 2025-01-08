from django.urls import path
from . import views

urlpatterns = [
    path('login/', views.login, name='login'),
    path('callback/', views.callback, name='callback'),
    path('get_token/<str:spotify_id>/', views.get_token, name='get_token'),
    path('search_track/', views.search_track, name='search_track'),
    path('display_and_save_top_tracks/', views.display_and_save_top_tracks, name='display_and_save_top_tracks'),
    path('get_first_track/', views.get_first_track, name='get_first_track'),
    path('get_multiple_tracks/', views.get_multiple_tracks, name='get_multiple_tracks'),
    path('get_tracks_by_type/', views.get_tracks_by_type, name='get_tracks_by_type'),
    path('save_playlist/', views.save_playlist, name='save_playlist'),
    path('delete_playlist/', views.delete_playlist, name='delete_playlist'),

    path('user/login/', views.login_user, name='user_login'),
    path('user/register/', views.register_user, name='user_register'),
    path('user/get_username/<int:user_id>/', views.get_username, name='get_username'),
    path('user/<int:user_id>/playlists/', views.get_user_playlists, name='get_user_playlists'),

]

