# 플레이리스트 저장 구현 필요
### 1. 노래 업데이트 완료
37로 시작하는 스포티파이에서 제공하는 플레이리스트는 api로 추출 불가능 -> 일반 사용자로 변경 완료

### 2. 250108 17:44 기준 
- 이슈
   - mypage에서 플레이리스트 들어가서 다시 저장하기 누르면 다시 저장됨? -> 기존 DB에서 잘 찾지 못하는 것 같음! 수정 필요요
 
- 수정 완료 
   - user name 표시
   - 로그인 에러 메세지
   - 플레이리스트 저장 기능 구현
   - 저장된 플레이리스트 삭제 기능 구현 (페이지 이동 없을 때는 정상 작동동)
   - Mypage에서 저장된 플레이리스트 디자인에 맞게 표시, 운동 달력 표시 (mypage_new.dart)


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

### 6. Migration 오류
   ```
   python manage.py makemigrations
   python manage.py migrate
   ```
   해도 DB에 새로운 테이블 추가 안될 경우, <br/>backend\spotify_auth\migrations 에서 **__init__.py 제외한 파일 모두** 삭제하고 시도 
