# Unity 프로젝트 초기화 가이드 (에이전트용)

이 문서는 **다른 AI 에이전트가** 이 템플릿 구조로 Unity 프로젝트의 `Assets/` 폴더를
초기화할 때 따라야 할 절차다. 사람이 읽어도 무방하다.

## 목표
이 리포의 `_Project/`, `_Sandbox/`, `Plugins/`, `ThirdParty/` 골격을
대상 Unity 프로젝트의 `Assets/` 안에 재현한다.

## 사전 확인
1. 대상이 실제 Unity 프로젝트인지 확인한다 — 루트에 `Assets/`, `ProjectSettings/`, `Packages/`가 있어야 한다. 없으면 Unity 프로젝트가 아니므로 사용자에게 경로를 다시 확인한다.
2. 대상 `Assets/`에 이미 같은 이름의 폴더가 있으면 **덮어쓰지 말고** 사용자에게 보고한 뒤 진행 여부를 묻는다.

## 🚨 가장 중요한 규칙: `.meta`
- 이 템플릿 리포의 `.gitignore`는 `*.meta`를 무시한다. **이 설정을 절대 대상 프로젝트로 복사하지 마라.**
- 실제 Unity 프로젝트에서는 **모든 `.meta` 파일을 반드시 커밋**해야 한다. 무시하면 GUID·import 설정이 공유되지 않아 참조가 끊기고 협업이 깨진다.
- 대상 프로젝트에 `.gitignore`가 없거나 부실하면 [GitHub 공식 Unity.gitignore](https://github.com/github/gitignore/blob/main/Unity.gitignore)를 적용한다.
- 대상 프로젝트의 `.gitignore`에 `*.meta` 또는 `*.meta` 무시 패턴이 있으면 **제거**한다.

## 절차

### 1. 폴더 골격 복사
이 리포의 `_Project/`, `_Sandbox/`, `Plugins/`, `ThirdParty/`를 대상 `Assets/` 안으로 복사한다.
`.gitkeep` 파일도 함께 복사해 빈 폴더가 유지되도록 한다. (Unity는 빈 폴더를 무시한다)

PowerShell 예시:
```powershell
$src = "<이 repo 경로>"        # 예: C:\Git\FolderStructure
$dst = "<대상프로젝트>\Assets"
foreach ($d in '_Project','_Sandbox','Plugins','ThirdParty') {
    Copy-Item -Path (Join-Path $src $d) -Destination $dst -Recurse -Force
}
```

bash 예시:
```bash
src="<이 repo 경로>"; dst="<대상프로젝트>/Assets"   # 예: ~/Git/FolderStructure
cp -r "$src/_Project" "$src/_Sandbox" "$src/Plugins" "$src/ThirdParty" "$dst/"
```

> 참고: 위는 **수동 복사** 절차이며, 폴더와 함께 템플릿 asmdef 5종도 따라온다.
> 스킬 스크립트(`create_structure.sh/.ps1`)로 초기화하면 동일한 asmdef 5종이 idempotent하게 생성되어 결과가 같다.

### 2. 템플릿 메타파일 흔적 제거
- 대상으로 README.md, INIT_GUIDE.md, 이 리포의 `.gitignore`는 **복사하지 않는다.**
- 복사된 트리에 혹시 `.DS_Store`, `Thumbs.db`가 섞여 들어갔으면 삭제한다.

### 3. Unity에서 import 시키기
1. Unity 에디터로 대상 프로젝트를 연다(또는 포커스를 준다).
2. 에디터가 폴더를 스캔하면서 각 폴더에 대한 `.meta` 파일을 자동 생성한다.
3. 이때 생성된 `.meta`들은 **반드시 버전관리에 추가**한다.

### 4. _Sandbox 개인 폴더 안내
`_Sandbox/<디자이너이름>` 폴더를 각자 직접 만들어 자유롭게 쓰도록 안내한다(고정 구조 없음). 사용법은 `_Sandbox/README.md` 참고.
프로젝트 `.gitignore`에 `/Assets/_Sandbox/**` + `!/Assets/_Sandbox/README.md`(및 `.meta`) 규칙을 추가해 **개인 실험물은 커밋되지 않고 폴더·README만 공유**되게 한다. (create_structure 스크립트는 이 규칙을 자동 주입한다.)

### 5. 커밋
```
git add Assets/_Project Assets/_Sandbox Assets/Plugins Assets/ThirdParty
git add -A   # 새로 생성된 .meta 포함
git commit -m "Initialize Assets folder structure from template"
```

## 검증 체크리스트
- [ ] `Assets/_Project/Art/Themes/_Template`이 존재하고 `Prop`,`Environment` 하위에 `Texture/Material/Mesh/Prefab`가 있다.
- [ ] 각 테마 폴더(`_Template`/`ThemeA` 등)에 `Prop/Environment`(+`Texture/Material/Mesh/Prefab`)와 테마 레벨 `Animation/VFX/Audio`가 있다.
- [ ] `Assets/_Project/Art/Characters/_Template`에 `Mesh/Texture/Material/Animation/Prefab`가 있다.
- [ ] `Assets/_Project/Prefab`에 `System/Gameplay`가 있다(아트가 아닌 시스템/게임플레이 프리팹용).
- [ ] `Assets/_Project/UI/Font`가 존재한다.
- [ ] `Assets/_Project/Scene`에 `Dev/Production/UI/Test`가 있다.
- [ ] `Assets/_Project/Test`에 `EditMode/PlayMode`와 각 `.asmdef`가 있다.
- [ ] `Assets/_Project/Script/Features/_Template`에 `Runtime/Editor/Tests`와 `.asmdef` 3종이 있다.
- [ ] `Assets/_Project/ScriptableObject`에 `Config/Data/Events`가 있다.
- [ ] `Assets/_Project/Settings`에 `RenderPipeline/Input`, `Assets/_Project/Localization`에 `StringTables/AssetTables/Locales`가 있다.
- [ ] `Assets/ThirdParty`에 `Libraries/Art/Audio/Tools`가 있다.
- [ ] 대상 프로젝트 `.gitignore`에 `*.meta` 무시 패턴이 **없다.**
- [ ] Unity가 생성한 `.meta` 파일들이 git에 스테이징되어 있다.

## 생성 후 추가 작업
- **asmdef 이름 변경:** 복사한 feature의 `_Template` asmdef는 `name`이 `Game.FeatureTemplate*`로 되어 있다. 새 feature를 만들 땐 `_Template`을 복사한 뒤 asmdef의 `name`·`rootNamespace`를 `Game.<FeatureName>` 형태로 바꾼다. (asmdef는 이름 기반 참조이므로 GUID 수정은 불필요)
- **_Sandbox 빌드 배제 + git 제외:** `_Sandbox`는 실험용이므로 빌드 스크립트/씬 목록/Addressables 그룹에서 제외하고, 릴리스 전에 정리한다. 또한 프로젝트 `.gitignore`에 `/Assets/_Sandbox/**`(README·`.meta`는 예외)를 두어 개인 실험물이 커밋되지 않게 한다.
- **Editor 코드 정책:** feature 전용 에디터 코드는 feature의 `Editor` asmdef에, 프로젝트 전역 도구만 `Script/Editor`에 둔다.
- **예약 폴더 주의:** `Resources/`, `StreamingAssets/`, `Gizmos/`, `Editor Default Resources/`는 Unity 특수 폴더다. 이 구조의 일반 폴더 대신 임의로 만들지 말고, 정말 필요할 때만 의도적으로 생성한다. 런타임 로딩은 Addressables를 사용한다.
- **Plugins / ThirdParty 배치:** `Plugins`에는 네이티브/플랫폼 바이너리(.jslib/.dll/.so/.bundle)만 둔다. 외부 에셋스토어/라이브러리는 `ThirdParty/<카테고리>/<패키지>`(`Libraries`/`Art`/`Audio`/`Tools`)에 **패키지 단위로 통째로** 둔다(타입별로 쪼개지 않음). 순수 C# 라이브러리는 `Plugins`가 아니라 `ThirdParty/Libraries`로.

## 새 테마/캐릭터/Feature 생성 규칙
- `_Template` 폴더를 복사하고 이름만 바꾼다. 하위 타입 폴더 구조는 변경하지 않는다.
- 테마 전용 VFX/Audio/Animation은 테마 폴더 안에, 범용 자원은 글로벌 `Art/VFX`·`Art/Audio`에 둔다.
- 자세한 폴더 용도와 네이밍 컨벤션은 `README.md`를 참조한다.
