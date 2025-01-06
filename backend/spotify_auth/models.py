from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User

class SpotifyUser(models.Model):
    spotify_id = models.CharField(max_length=100, unique=True)
    access_token = models.CharField(max_length=255)
    refresh_token = models.CharField(max_length=255, null=True, blank=True)
    token_expiry = models.DateTimeField()

    def is_token_expired(self):
        return timezone.now() >= self.token_expiry

class SpotifyTrack(models.Model):
    track_id = models.CharField(max_length=50, unique=True)
    track_name = models.CharField(max_length=255)
    album_cover = models.URLField(max_length=255, null=True)
    artist_name = models.CharField(max_length=255)
    duration_ms = models.IntegerField()  # 노래 길이 (밀리초)
    tempo = models.FloatField(null=True)  # 템포
    danceability = models.FloatField(null=True)  # danceability
    saved_at = models.DateTimeField(auto_now_add=True)  # 저장된 시점 기록

    def __str__(self):
        return self.track_name

class UserProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="profile"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Playlist(models.Model):
    name = models.CharField(max_length=255)  # 플레이리스트 이름
    user = models.ForeignKey(User, on_delete=models.CASCADE)  # 소유자
    exercise_type = models.CharField(max_length=50, null=True, blank=True)  # 운동 유형
    created_at = models.DateTimeField(auto_now_add=True)  # 생성 시점
    #total_duration = models.IntegerField(default=0)  # 총 길이 (밀리초)

    def __str__(self):
        return f"{self.name} - {self.user.username}"

class PlaylistTrack(models.Model):
    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, related_name='tracks')
    track = models.ForeignKey(SpotifyTrack, on_delete=models.CASCADE)
    added_at = models.DateTimeField(auto_now_add=True)  # 트랙이 플레이리스트에 추가된 시점

    def __str__(self):
        return f"{self.playlist.name} - {self.track.track_name}"
