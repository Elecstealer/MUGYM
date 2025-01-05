# back_with_front

## 환경설정

### 1. frontend/pubspec.yaml </br>
설치 패키지 환경에 맞춰 변경

### 2. frontend/app/build.gradle
   ```
       defaultConfig {
        ...
        versionCode = 1
        versionName = "1.0"
   }
   ```
        
### 3. backend\mugym_project\.env  </br>
각자 spotify ID, Secret, DB 설정 변경
   ```
   SPOTIFY_REDIRECT_URI=http://10.0.2.2:8000/auth/callback/
   ```
### 4. SPOTIFY DEVELOPER DASHBOARD URIS
    
        - http://10.0.2.2:8000/auth/callback/
        - http://127.0.0.1:8000/auth/callback/
        - http://localhost:8000/auth/callback/

### 5. backend run server
   ```
   python manage.py runserver 0.0.0.0:8000
   ```
