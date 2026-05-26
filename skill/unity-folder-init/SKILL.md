---
name: unity-folder-init
description: >
  Unity 프로젝트의 Assets 폴더에 멀티 디자이너 협업용 폴더 구조(콘텐츠/타입 하이브리드)를
  생성하고 검증한다. 여러 디자이너가 테마/캐릭터별로 에셋을 넣고 관리하기 좋은 _Project,
  _Sandbox, Plugins, ThirdParty 골격을 .gitkeep과 함께 만든다. Unity 폴더 구조 초기화,
  Assets 폴더 셋업, 프로젝트 스캐폴딩이 필요할 때 사용.
---

# Unity Folder Init

Unity 프로젝트 `Assets/`에 멀티 디자이너 협업용 폴더 구조를 만든다.
설계 근거와 폴더 용도는 `reference/structure.md`를 참고한다.

## 핵심 규칙 (먼저 읽을 것)

- **`.meta` 절대 무시 금지:** 실제 Unity 프로젝트에서는 `*.meta`를 반드시 커밋한다.
  무시하면 GUID·import 설정이 공유되지 않아 참조가 끊기고 협업이 깨진다.
  프로젝트 `.gitignore`에 `*.meta` 무시 패턴이 있으면 제거하라고 사용자에게 알린다.
- **asmdef는 만들지 않는다:** 이 스킬은 폴더만 만든다. Assembly Definition은 실제 코드
  작성 시 `Script/Features/_Template`을 복사해 프로젝트에서 생성한다.
- **빈 폴더 유지:** Unity는 빈 폴더를 무시하므로 각 leaf 폴더에 `.gitkeep`을 둔다.

## 절차

1. **대상 확인** — 사용자에게 대상 Unity `Assets/` 폴더 경로를 확인한다.
   루트에 `Assets/`, `ProjectSettings/`, `Packages/`가 있어야 정상적인 Unity 프로젝트다.
   확인되지 않으면 경로를 다시 묻는다.

2. **기존 충돌 확인** — 대상 `Assets/`에 이미 `_Project` 등 같은 이름 폴더가 있으면
   덮어쓰기 전에 사용자에게 보고하고 진행 여부를 묻는다. (스크립트는 기존 폴더/파일을
   삭제하지 않고 없는 것만 추가하므로 안전하지만, 의도 확인은 한다.)

3. **생성 + 검증 실행** — PowerShell:
   ```powershell
   & "<skill-dir>/scripts/create_structure.ps1" -AssetsPath "<프로젝트>/Assets"
   ```
   이 스크립트는 폴더 생성 후 `verify_structure.ps1`을 자동 호출해 검증한다.
   Assets 폴더가 아닌 곳이면 중단하며, 의도한 것이면 `-Force`를 붙인다.

   (비-Windows 환경이면 `scripts/create_structure.sh` 사용.)

4. **결과 보고** — 검증 결과(PASS/FAIL, 누락 폴더, `.meta` 무시 경고)를 사용자에게 전달한다.

5. **후속 안내**
   - 새 테마/캐릭터: `_Template` 복사 후 이름만 변경, 하위 구조 유지.
   - 새 feature: `Script/Features/_Template` 복사 후 asmdef `name`을 `Game.<Feature>`로 변경.
   - `_Sandbox`는 릴리스 빌드 전 정리/제외.
   - 런타임 로딩은 `Resources/` 대신 Addressables 사용.

## 검증만 다시 하려면

```powershell
& "<skill-dir>/scripts/verify_structure.ps1" -AssetsPath "<프로젝트>/Assets"
```
