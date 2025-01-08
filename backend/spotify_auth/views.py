import requests
from django.shortcuts import redirect
from django.conf import settings
from django.utils import timezone
from django.http import JsonResponse
import base64
from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import SpotifyUser, SpotifyTrack, UserProfile, Playlist, PlaylistTrack
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from django.http import JsonResponse
import json
from django.contrib.auth import authenticate
from urllib.parse import unquote


# Spotify 로그인 함수
def login(request):
    scope = 'user-read-private user-read-email user-modify-playback-state'
    auth_url = (
        f"https://accounts.spotify.com/authorize?response_type=code"
        f"&client_id={settings.SPOTIFY_CLIENT_ID}&scope={scope}"
        f"&redirect_uri={settings.SPOTIFY_REDIRECT_URI}"
    )
    return redirect(auth_url)

# Spotify API를 통한 인증 콜백 함수
def callback(request):
    code = request.GET.get('code')
    if not code:
        return JsonResponse({'error': 'No code provided'}, status=400)

    # 토큰 요청
    token_url = 'https://accounts.spotify.com/api/token'
    token_data = {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': settings.SPOTIFY_REDIRECT_URI,
    }
    client_creds = f"{settings.SPOTIFY_CLIENT_ID}:{settings.SPOTIFY_CLIENT_SECRET}"
    client_creds_b64 = base64.b64encode(client_creds.encode())
    token_headers = {
        'Authorization': f'Basic {client_creds_b64.decode()}',
        'Content-Type': 'application/x-www-form-urlencoded'
    }

    response = requests.post(token_url, data=token_data, headers=token_headers)
    if response.status_code != 200:
        return JsonResponse({'error': 'Failed to retrieve token'}, status=response.status_code)

    # 토큰 정보 처리
    token_data = response.json()
    access_token = token_data['access_token']
    refresh_token = token_data.get('refresh_token')
    expires_in = token_data['expires_in']
    token_expiry = timezone.now() + timezone.timedelta(seconds=expires_in)

    # 사용자 프로필 요청
    profile_url = 'https://api.spotify.com/v1/me'
    profile_headers = {'Authorization': f'Bearer {access_token}'}
    profile_response = requests.get(profile_url, headers=profile_headers)
    if profile_response.status_code != 200:
        return JsonResponse({'error': 'Failed to retrieve profile'}, status=profile_response.status_code)

    profile_data = profile_response.json()
    spotify_id = profile_data.get('id')

    # 사용자 정보 저장/업데이트
    SpotifyUser.objects.update_or_create(
        spotify_id=spotify_id,
        defaults={
            'access_token': access_token,
            'refresh_token': refresh_token,
            'token_expiry': token_expiry,
        }
    )

    return JsonResponse({'message': 'Login successful', 'spotify_id': spotify_id})

# Spotify 토큰 조회 및 갱신 함수
def get_token(request, spotify_id):
    try:
        spotify_user = SpotifyUser.objects.get(spotify_id=spotify_id)
        if spotify_user.is_token_expired():
            token_url = 'https://accounts.spotify.com/api/token'
            token_data = {
                'grant_type': 'refresh_token',
                'refresh_token': spotify_user.refresh_token,
                'client_id': settings.SPOTIFY_CLIENT_ID,
                'client_secret': settings.SPOTIFY_CLIENT_SECRET,
            }
            response = requests.post(token_url, data=token_data)
            token_data = response.json()
            spotify_user.access_token = token_data['access_token']
            expires_in = token_data['expires_in']
            spotify_user.token_expiry = timezone.now() + timezone.timedelta(seconds=expires_in)
            spotify_user.save()
        return JsonResponse({'access_token': spotify_user.access_token})
    except SpotifyUser.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)

# 트랙 검색 함수
@api_view(['GET'])
def search_track(request):
    query = request.GET.get('query', '')
    if not query:
        return JsonResponse({'error': 'No query provided'}, status=400)
    
    spotify_user = SpotifyUser.objects.first()
    access_token = spotify_user.access_token
    search_url = 'https://api.spotify.com/v1/search'
    headers = {'Authorization': f'Bearer {access_token}'}
    params = {'q': query, 'type': 'track', 'limit': 10}

    response = requests.get(search_url, headers=headers, params=params)
    if response.status_code != 200:
        return JsonResponse({'error': 'Spotify API request failed'}, status=response.status_code)
        
    search_results = response.json()
    return JsonResponse({'tracks': search_results.get('tracks', {}).get('items', [])})

def get_valid_token(spotify_user):
    # 토큰 만료 확인
    if spotify_user.token_expiry <= timezone.now():
        # 토큰 갱신
        token_url = 'https://accounts.spotify.com/api/token'
        token_data = {
            'grant_type': 'refresh_token',
            'refresh_token': spotify_user.refresh_token,
            'client_id': settings.SPOTIFY_CLIENT_ID,
            'client_secret': settings.SPOTIFY_CLIENT_SECRET,
        }
        response = requests.post(token_url, data=token_data)
        
        if response.status_code == 200:
            token_data = response.json()
            spotify_user.access_token = token_data['access_token']
            expires_in = token_data['expires_in']
            spotify_user.token_expiry = timezone.now() + timezone.timedelta(seconds=expires_in)
            spotify_user.save()
        else:
            return None
    return spotify_user.access_token

@api_view(['GET'])
def display_and_save_top_tracks(request):
    spotify_user = SpotifyUser.objects.first()
    access_token = spotify_user.access_token

    top_tracks_url = 'https://api.spotify.com/v1/playlists/4cRo44TavIHN54w46OqRVc/tracks' #나쁜놈들 지원 안해줌

    headers = {'Authorization': f'Bearer {access_token}'}
    response = requests.get(top_tracks_url, headers=headers)

    if response.status_code != 200:
        return JsonResponse({'error': f'Failed to retrieve top tracksBearer {access_token}'}, status=response.status_code)

    # Spotify API에서 Top 50 트랙 데이터를 가져와 필요한 정보만 선택
    tracks_data = response.json().get('items', [])
    track_list = []
    saved_tracks = []
    for item in tracks_data:
        track = item['track']
        track_id = track['id']
        track_info = {
            'track_id': track_id,
            'track_name': track['name'],
            'album_cover': track['album']['images'][0]['url'] if track['album']['images'] else None,
            'artist_name': ', '.join([artist['name'] for artist in track['artists']]),
            'duration_ms': track['duration_ms']
        }
        track_list.append(track_info)

        # 트랙의 오디오 특징 가져오기
        audio_features_url = f'https://api.spotify.com/v1/audio-features/{track_id}'
        audio_features_response = requests.get(audio_features_url, headers=headers)
        if audio_features_response.status_code == 200:
            audio_features = audio_features_response.json()
            track_info['tempo'] = audio_features.get('tempo')
            track_info['danceability'] = audio_features.get('danceability')
        else:
            track_info['tempo'] = None
            track_info['danceability'] = None

        # 데이터베이스에 트랙 저장 (중복 시 업데이트)
        spotify_track, created = SpotifyTrack.objects.update_or_create(
            track_id=track_info['track_id'],
            defaults={
                'track_name': track_info['track_name'],
                'album_cover': track_info['album_cover'],
                'artist_name': track_info['artist_name'],
                'duration_ms': track_info['duration_ms'],
                'tempo': track_info['tempo'],
                'danceability': track_info['danceability']
            }
        )
        saved_tracks.append({
            'track_id': track_info['track_id'],
            'track_name': track_info['track_name'],
            'status': 'created' if created else 'updated'
        })

    # 저장된 트랙 정보와 가져온 데이터를 JSON 형식으로 반환
    return JsonResponse({'top_tracks': track_list, 'saved_tracks': saved_tracks})

@api_view(['GET'])
def get_first_track(request):
    try:
        # 데이터베이스에서 첫 번째 트랙 가져오기
        track = SpotifyTrack.objects.last()
        if not track:
            return JsonResponse({'error': 'No track found in the database'}, status=404)

        # 트랙 정보를 JSON으로 반환
        track_data = {
            'track_id': track.track_id,
            'track_name': track.track_name,
            'album_cover': track.album_cover,
            'artist_name': track.artist_name,
            'duration_ms': track.duration_ms,
            'tempo': track.tempo,
            'danceability': track.danceability,
        }
        return JsonResponse(track_data)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@api_view(['GET'])
def get_multiple_tracks(request):
    try:
        # 클라이언트에서 운동 종류와 시간 입력받기
        exercise_type = request.GET.get('exercise', None)  # 예: 'running'
        workout_time = request.GET.get('time', None)  # 단위: 분

        if not exercise_type or not workout_time:
            return JsonResponse({'error': 'Exercise type and time are required'}, status=400)

        # 운동 시간(분)을 밀리초로 변환
        target_duration_ms = int(workout_time) * 60 * 1000

        # 템포 범위를 설정 (운동 종류에 따라)
        tempo_ranges = {
            'running': (100, 120),
            'weight': (90, 110),
            'yoga': (60, 80),
            'pilates': (70, 90),
            'climbing': (80, 100),
            'cycling': (120, 140),
        }

        if exercise_type not in tempo_ranges:
            return JsonResponse({'error': 'Invalid exercise type'}, status=400)

        min_tempo, max_tempo = tempo_ranges[exercise_type]

        # 해당 템포 범위의 노래 필터링
        tracks = SpotifyTrack.objects.filter(tempo__gte=min_tempo, tempo__lte=max_tempo).order_by('?')

        if not tracks.exists():
            return JsonResponse({'error': 'No tracks found for the selected exercise type'}, status=404)

        # 총 길이가 최소 운동 시간을 초과하도록 노래 리스트 선택
        selected_tracks = []
        total_duration = 0

        for track in tracks:
            if total_duration >= target_duration_ms:
                break
            selected_tracks.append(track)
            total_duration += track.duration_ms

        # 만약 선택된 노래들의 길이가 최소 운동 시간에 미치지 못하면 추가로 트랙 선택
        if total_duration < target_duration_ms:
            for track in tracks:
                if track not in selected_tracks:
                    selected_tracks.append(track)
                    total_duration += track.duration_ms
                    if total_duration >= target_duration_ms:
                        break

        if not selected_tracks or total_duration < target_duration_ms:
            return JsonResponse({'error': 'Unable to create a playlist matching the workout time'}, status=400)

        # 선택된 트랙의 정보를 JSON으로 반환
        track_list = [
            {
                'track_id': track.track_id,
                'track_name': track.track_name,
                'album_cover': track.album_cover,
                'artist_name': track.artist_name,
                'duration_ms': track.duration_ms,
                'tempo': track.tempo,
                'danceability': track.danceability,
            }
            for track in selected_tracks
        ]

        return JsonResponse({'tracks': track_list}, safe=False)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
    
@csrf_exempt
def login_user(request):
    if request.method == "POST":
        data = json.loads(request.body)
        email = data.get('email')  # 로그인 이메일
        password = data.get('password')  # 로그인 비밀번호

        # 이메일을 기준으로 사용자 검색
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return JsonResponse({'error': 'Invalid credentials'}, status=400)

        # 비밀번호 확인
        if user.check_password(password):
            print(f'userid: {user.id}, username: {user.username}, email: {user.email}')
            return JsonResponse({
                'message': 'Login successful',
                'user_id': user.id,
                'username': user.username,
                'email': user.email,
            })
        else:
            return JsonResponse({'error': 'Invalid credentials'}, status=400)
    return JsonResponse({'error': 'Invalid request method'}, status=405)


@csrf_exempt
def register_user(request):
    if request.method == "POST":
        data = json.loads(request.body)
        username = data.get('name')  # 사용자 이름
        email = data.get('email')  # 사용자 이메일
        password = data.get('password')  # 비밀번호

        # username이 비어 있는 경우 email을 기본값으로 설정
        if not username:
            username = email

        # 이메일 중복 확인
        if User.objects.filter(email=email).exists():
            return JsonResponse({'error': 'Email already exists'}, status=400)

        # 사용자 생성
        user = User.objects.create_user(username=username, email=email, password=password)
        UserProfile.objects.create(user=user)  # UserProfile 생성
        return JsonResponse({'message': 'Registration successful'})
    return JsonResponse({'error': 'Invalid request method'}, status=405)

@api_view(['GET'])
def get_tracks_by_type(request):
    exercise_type = request.GET.get('exercise', None)
    if exercise_type:
        exercise_type = unquote(exercise_type)  # URL 디코딩

    # 유효성 검사
    if exercise_type not in ['running', 'yoga', 'pilates', 'weight', 'climbing', 'cycling']:
        return JsonResponse({'error': 'Invalid exercise type'}, status=400)

    # 템포 범위 설정
    tempo_ranges = {
        'running': (100, 120),
        'weight': (90, 110),
        'yoga': (60, 80),
        'pilates': (70, 90),
        'climbing': (80, 100),
        'cycling': (120, 140),
    }
    min_tempo, max_tempo = tempo_ranges[exercise_type]

    # 데이터베이스 조회
    tracks = SpotifyTrack.objects.filter(tempo__gte=min_tempo, tempo__lte=max_tempo)
    if not tracks.exists():
        return JsonResponse({'error': f'No tracks found for {exercise_type}'}, status=404)

    track_list = [
        {
            'track_id': track.track_id,
            'track_name': track.track_name,
            'album_cover': track.album_cover,
            'artist_name': track.artist_name,
            'duration_ms': track.duration_ms,
            'tempo': track.tempo,
            'danceability': track.danceability,
        }
        for track in tracks
    ]
    return JsonResponse({'tracks': track_list})

@api_view(['GET'])
def get_username(request, user_id):
    try:
        # user_id로 사용자 검색
        user = User.objects.get(id=user_id)
        return JsonResponse({'username': user.username}, status=200)
    except User.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)

@api_view(['POST'])
def save_playlist(request):
    try:
        data = request.data
        user_id = data.get('userId')
        playlist_name = ''  # 플레이리스트 이름은 필요에 따라 수정
        exercise_type = data.get('exercise_type')
        tracks = data.get('tracks', [])

        if not user_id or not exercise_type or not tracks:
            return JsonResponse({'error': f'Required fields are missing. {user_id}, {exercise_type}, {tracks}'}, status=400)

        user = User.objects.get(id=user_id)

        # 중복 확인: 동일한 유저, 운동 유형, 그리고 같은 트랙 ID 리스트가 이미 존재하는지 확인
        existing_playlists = Playlist.objects.filter(user=user, exercise_type=exercise_type)
        for playlist in existing_playlists:
            playlist_tracks = PlaylistTrack.objects.filter(playlist=playlist).values_list('track__track_id', flat=True)
            existing_track_ids = set(playlist_tracks)
            incoming_track_ids = set(track['track_id'] for track in tracks)

            if existing_track_ids == incoming_track_ids:  # 중복된 플레이리스트
                return JsonResponse({'message': 'Playlist already exists.', 'playlist_id': playlist.id}, status=200)

        # 플레이리스트 생성
        playlist = Playlist.objects.create(
            name=playlist_name,
            user=user,
            exercise_type=exercise_type
        )

        missing_tracks = []  # 존재하지 않는 트랙 저장용
        # 트랙 추가
        for track_data in tracks:
            track_id = track_data.get('track_id')
            try:
                track = SpotifyTrack.objects.get(track_id=track_id)
                PlaylistTrack.objects.create(playlist=playlist, track=track)
            except SpotifyTrack.DoesNotExist:
                print(f"Track not found: {track_id}")
                missing_tracks.append(track_id)

        if missing_tracks:
            return JsonResponse({'error': 'Some tracks were not found in the database.', 'missing_tracks': missing_tracks}, status=404)

        return JsonResponse({'message': 'Playlist saved successfully.', 'playlist_id': playlist.id}, status=201)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@api_view(['GET'])
def get_user_playlists(request, user_id):
    try:
        user = User.objects.get(id=user_id)
        playlists = Playlist.objects.filter(user=user)

        # 각 플레이리스트의 트랙 데이터 포함
        playlist_data = []
        for playlist in playlists:
            tracks = PlaylistTrack.objects.filter(playlist=playlist).select_related('track')
            track_list = [
                {
                    'track_id': track.track.track_id,
                    'track_name': track.track.track_name,
                    'artist_name': track.track.artist_name,
                    'album_cover': track.track.album_cover,
                    'duration_ms': track.track.duration_ms,
                }
                for track in tracks
            ]
            playlist_data.append({
                'playlist_id': playlist.id,
                'playlist_name': playlist.name,
                'exercise_type': playlist.exercise_type,
                'tracks': track_list,
            })

        return JsonResponse({'playlists': playlist_data}, status=200)

    except User.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)

@api_view(['DELETE'])
def delete_playlist(request):
    try:
        data = request.data
        user_id = data.get('userId')
        exercise_type = data.get('exercise_type')
        tracks = data.get('tracks', [])

        # 필수 데이터 확인
        if not user_id or not exercise_type or not tracks:
            return JsonResponse({'error': 'Required fields are missing.'}, status=400)

        # 사용자 확인
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return JsonResponse({'error': 'User not found.'}, status=404)

        # 플레이리스트 검색
        playlists = Playlist.objects.filter(user=user, exercise_type=exercise_type)
        for playlist in playlists:
            playlist_tracks = PlaylistTrack.objects.filter(playlist=playlist).values_list('track__track_id', flat=True)
            existing_track_ids = set(playlist_tracks)
            incoming_track_ids = set(track['track_id'] for track in tracks)

            if existing_track_ids == incoming_track_ids:
                playlist.delete()
                return JsonResponse({'message': 'Playlist deleted successfully.'}, status=200)

        # 일치하는 플레이리스트가 없을 경우
        return JsonResponse({'error': 'No matching playlist found.'}, status=404)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
