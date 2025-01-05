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

class AudioFile(models.Model):
    title = models.CharField(max_length=100)
    file_url = models.URLField()  # Dropbox나 다른 클라우드 스토리지의 URL을 저장
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

class SpotifyTrack(models.Model):
    track_id = models.CharField(max_length=50, unique=True)
    track_name = models.CharField(max_length=255)
    album_cover = models.URLField(max_length=255, null=True)
    artist_name = models.CharField(max_length=255)
    duration_ms = models.IntegerField()  # 노래 길이 (밀리초)
    tempo = models.FloatField(null=True)  # 템포
    danceability = models.FloatField(null=True)  # danceability
    saved_at = models.DateTimeField(auto_now_add=True)  # 저장된 시점 기록

class UserProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="profile"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.track_name

