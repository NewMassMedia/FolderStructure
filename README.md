# Unity 폴더 구조 템플릿

여러 디자이너가 함께 에셋을 넣고 관리하기 좋도록 설계한 **콘텐츠/타입 하이브리드** 폴더 골격입니다.
이 리포의 폴더들을 Unity 프로젝트의 `Assets/` 안으로 복사해서 사용합니다.

> ⚠️ **`.meta` 주의**
> 이 리포는 빈 폴더 템플릿이라 `.gitignore`가 `*.meta`를 무시합니다.
> **실제 Unity 프로젝트에서는 `*.meta`를 절대 무시하면 안 됩니다(반드시 커밋).**
> 무시하면 에셋 GUID·import 설정이 공유되지 않아 참조가 통째로 끊기고 팀 협업이 깨집니다.
> 실제 프로젝트는 [GitHub 공식 Unity.gitignore](https://github.com/github/gitignore/blob/main/Unity.gitignore)를 사용하세요.

---

## 스킬 설치 (다른 PC에서 폴더 구조 자동 생성)

이 repo에는 Unity Assets 폴더 구조를 한 번에 생성·검증하는 Claude Code 스킬(`unity-folder-init`)이
`skill/` 폴더에 들어 있습니다. 다른 PC에서 이 repo를 받은 뒤 설치하면 **어느 Unity 프로젝트에서나** 쓸 수 있습니다.

다른 PC에서 이 repo를 clone한 뒤, **Claude에게 "이 repo의 스킬 설치해줘"** 라고 요청하면 됩니다.
Claude가 `skill/INSTALL.md` 가이드를 따라 `skill/unity-folder-init` 를 `~/.claude/skills/` 로 복사합니다
(OS에 맞는 복사 명령은 Claude가 알아서 처리). Claude Code를 재시작하면 활성화됩니다.

수동 설치도 가능합니다 — `skill/unity-folder-init` 폴더를 `~/.claude/skills/` 아래로 통째로 복사하면 끝.

설치 후에는 대상 Unity 프로젝트에서 **"유니티 폴더 구조 초기화해줘"** 라고 하면 됩니다.

---

## 핵심 결정 규칙 (애매할 때 이 축으로 판단)

이 구조는 두 가지 분류 축을 **의도적으로 섞어** 씁니다. 어디에 둘지 헷갈리면 이 규칙으로 판단하세요.

> **양산되고 통째로 교체·삭제·스트리밍되는 것(테마·캐릭터)은 콘텐츠 단위로 묶는다.
> 여러 콘텐츠가 공유하는 인프라(셰이더·범용 VFX·범용 오디오·코드)는 타입 단위로 둔다.**

그리고 콘텐츠 단위 안에서는 다시 타입별(`Texture/Material/Mesh/Prefab…`)로 정리합니다.

### 부가 원칙
1. **한 디자이너 = 한 콘텐츠 폴더.** 작업 충돌과 실수를 최소화합니다.
2. **모든 동급 폴더는 동일한 하위 구조를 따른다.** (`_Template` 참고)
3. **공용 에셋은 `_Shared`로.** 콘텐츠 간 복붙을 막아 용량 폭증과 수정 누락을 방지합니다.
4. **개인 실험은 `_Sandbox`에서.** 검수 후 정식 폴더로 이동합니다.
5. **테마 전용 vs 범용:** 특정 테마에서만 쓰는 VFX/Audio/Animation은 그 테마 폴더 안에, 여러 곳에서 쓰는 범용 자원은 글로벌 `Art/VFX`·`Art/Audio`에 둡니다.

---

## 폴더 구조

```
_Project/
├─ Art/
│  ├─ Themes/                    # 맵/월드 테마 단위 (콘텐츠 기반)
│  │  ├─ _Shared/                # 여러 테마 공용
│  │  ├─ _Template/              # 새 테마 만들 때 복사할 원본
│  │  └─ ThemeA/
│  │     ├─ Prop/                # 소품: Texture/Material/Mesh/Prefab
│  │     ├─ Environment/         # 배경: Texture/Material/Mesh/Prefab
│  │     ├─ Animation/           # 이 테마 전용 클립 (문, 깃발 등)
│  │     ├─ VFX/                 # 이 테마 전용 이펙트
│  │     └─ Audio/               # 이 테마 전용 환경음/BGM
│  ├─ Characters/                # 캐릭터 단위 (콘텐츠 기반)
│  │  ├─ _Shared/
│  │  ├─ _Template/
│  │  └─ CharacterA/             # Mesh/Texture/Material/Animation/Prefab
│  ├─ Audio/      { Mixer, Music, Sound }   # 범용 오디오 (타입 기반)
│  ├─ Shader/     { ShaderGraph, Script }   # 공유 인프라
│  ├─ VFX/        { Particle, VFXGraph }    # 범용 이펙트
│  └─ Timeline/                  # 컷신/Timeline(.playable)·Signal 등 횡단 자원
├─ UI/
│  ├─ Font/                      # 폰트는 UI 하위
│  ├─ Sprite/
│  ├─ Prefab/
│  ├─ Animation/                 # UI 전용 애니메이션
│  └─ UIToolkit/  { USS, UXML, Theme, Setting, Extension }
├─ Prefab/                       # ★ 아트가 아닌 시스템/게임플레이 프리팹
│  ├─ System/                    # GameManager, AudioManager, Spawner 등
│  └─ Gameplay/                  # 픽업, 트리거, 풀링 오브젝트 등
├─ Scene/         { Dev, Production, UI, Test }
├─ Script/
│  ├─ Core/                      # 공용 기반 코드 (asmdef 권장)
│  ├─ Features/                  # Feature 단위, 각자 .asmdef
│  │  └─ _Template/  { Runtime, Editor, Tests }   # 새 feature 복사 원본
│  └─ Editor/                    # 프로젝트 전역 에디터 도구만 (feature 전용은 feature 안 Editor로)
├─ ScriptableObject/  { Config, Data, Events }     # 평면 금지, 카테고리로
├─ Settings/      { RenderPipeline, Input }         # URP/HDRP 에셋, Input Action 등
├─ Localization/  { StringTables, AssetTables, Locales }   # Unity Localization 패키지
└─ Test/          { EditMode, PlayMode }           # 코드 테스트 (asmdef 포함)
_Sandbox/                        # 개인 실험 공간(자유 구조). README만 git 추적(내부는 .gitignore 제외). ★ 빌드 전 반드시 정리
└─ <DesignerName>/               # 각 디자이너가 직접 만들어 사용
Plugins/                         # ⚠️ Unity 특수 폴더 — 네이티브/플랫폼 바이너리 전용(.jslib/.dll/.so/.bundle)
ThirdParty/                      # 외부 에셋·패키지 — 카테고리 → 패키지(폴더 통째로 유지)
├─ Libraries/                    # 순수 코드 라이브러리 (예: BreakInfinity)
├─ Art/                          # 모델·텍스처·머티리얼 팩
├─ Audio/                        # 사운드 팩
└─ Tools/                        # 에디터·디버그 툴 (예: Graphy)
```

### Prefab이 세 종류로 나뉘는 이유
- **아트 결과물 프리팹** → `Art/Themes/*/Prefab`, `Art/Characters/*/Prefab` (콘텐츠와 함께)
- **UI 프리팹** → `UI/Prefab`
- **시스템/게임플레이 프리팹** → `_Project/Prefab/{System, Gameplay}` (매니저·스포너·픽업 등 아트가 아닌 것)

### Plugins vs ThirdParty (합치지 않고 역할 분리)
- **`Plugins/`** — Unity가 예약한 **특수 폴더**입니다. 네이티브 플러그인(`.dll`/`.so`/`.aar`/`.jslib`/`.bundle`)과 플랫폼별 바이너리(`Plugins/Android`, `Plugins/iOS`)만 둡니다. **순수 C#·매니지드 라이브러리는 여기 두지 말고** `ThirdParty`(외부) 또는 `_Project/Script`(우리가 편집/소유하는 프레임워크)로 보냅니다.
- **`ThirdParty/`** — 에셋스토어 패키지, 외부 라이브러리 등 **외부 에셋**. **카테고리 → 패키지** 구조로 둡니다:
  - `Libraries/` 순수 코드 라이브러리 · `Art/` 모델·텍스처·머티리얼 팩 · `Audio/` 사운드 팩 · `Tools/` 에디터·디버그 툴
  - **한 패키지는 파일 타입별로 쪼개지 말고 자기 폴더에 통째로** 둡니다(스크립트+모델+텍스처 등 한 묶음). 그래야 업데이트·삭제를 한 단위로 안전하게 할 수 있습니다.

### 새 테마/캐릭터/Feature 추가하는 법
1. 해당 `_Template` 폴더를 복사한다.
2. 폴더명을 `ThemeB`, `CharacterB`, `Inventory` 등으로 바꾼다.
3. **하위 구조는 그대로 둔다.** Feature의 경우 `.asmdef` 파일의 `name`을 `Game.<FeatureName>` 형태로 바꾼다.

### 어디에 넣어야 할지 빠른 판단
- 특정 테마/캐릭터 **전용** 에셋? → 해당 콘텐츠 폴더 안 타입 폴더로
- 여러 콘텐츠 **공용**? → `_Shared` 또는 글로벌 타입 폴더(`Art/VFX` 등)로
- **UI** 관련? → `UI/` 아래로
- 아트가 아닌 **시스템/게임플레이 프리팹**? → `_Project/Prefab/`로
- **외부 에셋스토어/라이브러리**? → `ThirdParty/<카테고리>/<패키지>/` (Libraries·Art·Audio·Tools 중 성격에 맞게, 패키지는 통째로)
- **네이티브 플러그인**(.jslib/.dll/.so/.bundle)? → `Plugins/`
- 아직 실험 중? → `_Sandbox/<내이름>/`

---

## 네이밍 컨벤션

파일명은 `Prefix_이름_변형` (PascalCase, 공백/한글 금지).

| 종류 | Prefix | 예시 |
|------|--------|------|
| Texture | `T_` | `T_Wall_BaseColor` |
| Material | `M_` | `M_Wall` |
| Mesh | `SM_` | `SM_Chair` |
| Skinned Mesh | `SKM_` | `SKM_CharacterA` |
| Prefab | `PF_` | `PF_CharacterA` |
| Animation Clip | `A_` | `A_CharacterA_Idle` |
| Animator Controller | `AC_` | `AC_CharacterA` |
| ScriptableObject | `SO_` | `SO_EnemyStats_Goblin` |
| Audio (SFX) | `SFX_` | `SFX_Door_Open` |
| Audio (Music) | `BGM_` | `BGM_ThemeA` |
| Sprite | `SPR_` | `SPR_Button_Confirm` |
| Font | `F_` | `F_NotoSans` |
| VFX (Particle) | `PS_` | `PS_Explosion` |
| VFX (VFX Graph) | `VFX_` | `VFX_Smoke` |
| Shader | `SH_` | `SH_Water` |
| Scene | `SC_` | `SC_ThemeA_Main` |

**텍스처 맵 접미사:** `_BaseColor`, `_Normal`, `_MRA`(Metallic/Roughness/AO), `_Emission`, `_Height`

> **경로 vs 파일명 중복에 대해:** 파일이 `Themes/ThemeA/...`에 있으면 파일명에 `ThemeA`를 또 넣을지는 선택입니다.
> 위 예시는 경로에 컨텍스트가 있다고 보고 생략했습니다. 단, 로그·검색·에셋 이동 시 **전역 고유성**이 중요하면
> `T_ThemeA_Wall_BaseColor`처럼 접두에 콘텐츠명을 넣는 방식도 합리적입니다. 팀에서 한 방식으로 통일하세요.

---

## 협업 규칙 (요약)

- `.meta`는 실제 프로젝트에서 **항상 커밋**한다.
- 빈 폴더는 Unity가 인식하지 않으므로 `.gitkeep`을 둔다 (에셋이 들어가면 삭제 가능).
- **`_Sandbox`는 릴리스 빌드 전에 반드시 정리**한다. 실험물이 빌드에 섞이지 않도록, 빌드 스크립트에서 제외하거나 씬/Addressables 그룹에 포함하지 않는다. 또한 프로젝트 `.gitignore`에 `/Assets/_Sandbox/**`(README·`.meta` 예외)를 두어 **개인 실험물은 커밋하지 않고 폴더·README만 공유**한다 (create_structure 스크립트가 자동 주입).
- **에디터 코드**는 가능하면 feature 폴더 안의 `Editor` asmdef에 둔다. `Script/Editor`는 프로젝트 전역 도구(빌드 파이프라인, 공용 인스펙터 등)만.
- **ScriptableObject는 평면으로 쌓지 말 것.** `Config`(설정), `Data`(아이템·스탯 등 데이터), `Events`(이벤트 채널)로 분류하고 필요시 더 쪼갠다.
- 원본 작업 파일(`.psd`, `.blend`, 원본 `.wav` 등)은 `Assets` 밖(예: `~RawAssets/`)에 두고 버전관리에서 제외한다.
- 런타임 로딩은 `Resources/` 대신 **Addressables**를 사용한다. 테마/캐릭터 폴더가 Addressables 그룹과 매핑되도록 설계되어 있다.
- `Script/Features`는 feature마다 `.asmdef`(Runtime/Editor/Tests)를 두어 컴파일 속도와 의존성 관리를 확보한다.

### ⚠️ Unity 예약(특수) 폴더 — 일반 에셋용으로 쓰지 말 것
다음 이름의 폴더는 Unity가 특별 취급하므로, 위 구조의 일반 폴더 대신 함부로 만들지 않는다. 필요할 때만 의도적으로 생성한다.
- **`Resources/`** — 폴더 내용 전부가 빌드에 포함되고 시작 시 메모리에 올라간다. 런타임 로딩은 Addressables를 쓴다.
- **`StreamingAssets/`** — 가공 없이 빌드에 그대로 복사되는 원본 파일용(동영상, 외부 설정 등).
- **`Gizmos/`**, **`Editor Default Resources/`** — 에디터 기즈모/리소스 전용.
- **`Editor/`**, **`Plugins/`** — 위 구조에서 정해진 위치(`Script/Editor`, 루트 `Plugins`)에서만 사용한다.
