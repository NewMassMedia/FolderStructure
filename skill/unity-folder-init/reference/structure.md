# 폴더 구조 레퍼런스

## 핵심 결정 규칙
> 양산되고 통째로 교체·삭제·스트리밍되는 것(테마·캐릭터)은 **콘텐츠 단위**로 묶고,
> 여러 콘텐츠가 공유하는 인프라(셰이더·범용 VFX·범용 오디오·코드)는 **타입 단위**로 둔다.
> 콘텐츠 단위 안에서는 다시 타입별(Texture/Material/Mesh/Prefab…)로 정리한다.

## 트리
```
Assets/
├─ _Project/
│  ├─ Art/
│  │  ├─ Themes/{_Shared, _Template, ThemeA}/
│  │  │    ├─ Prop/{Texture,Material,Mesh,Prefab}        # _Shared는 카테고리 없이 바로 타입
│  │  │    ├─ Environment/{Texture,Material,Mesh,Prefab}
│  │  │    └─ Animation, VFX, Audio                      # 테마 전용
│  │  ├─ Characters/{_Shared,_Template,CharacterA}/{Mesh,Texture,Material,Animation,Prefab}
│  │  ├─ Audio/{Mixer,Music,Sound}      # 범용
│  │  ├─ Shader/{ShaderGraph,Script}
│  │  ├─ VFX/{Particle,VFXGraph}        # 범용
│  │  └─ Timeline/                      # 컷신/Timeline·Signal
│  ├─ UI/{Font,Sprite,Prefab,Animation, UIToolkit/{USS,UXML,Theme,Setting,Extension}}
│  ├─ Prefab/{System,Gameplay}          # 아트가 아닌 시스템/게임플레이 프리팹
│  ├─ Scene/{Dev,Production,UI,Test}
│  ├─ Script/{Core, Editor, Features/_Template/{Runtime,Editor,Tests}}
│  ├─ ScriptableObject/{Config,Data,Events}
│  ├─ Settings/{RenderPipeline,Input}
│  ├─ Localization/{StringTables,AssetTables,Locales}
│  └─ Test/{EditMode,PlayMode}
├─ _Sandbox/{_Template, <DesignerName>}  # 개인 실험. 빌드 전 정리
├─ Plugins/        # Unity 특수 폴더: 네이티브/플랫폼 바이너리 전용
└─ ThirdParty/     # 에셋스토어·외부 매니지드 패키지
```

## 주의
- **`.meta`** 는 실제 프로젝트에서 항상 커밋 (무시 금지).
- **asmdef** 는 이 스킬이 만들지 않음. 코드 작성 시 `Features/_Template` 복사 후
  `name`/`rootNamespace`를 `Game.<Feature>`로 변경.
- **예약 폴더**(`Resources`, `StreamingAssets`, `Gizmos`, `Editor Default Resources`)는
  임의 생성 금지. 런타임 로딩은 Addressables 사용.
- **Prefab 3종 분리**: 아트 → 콘텐츠 폴더 안 Prefab, UI → UI/Prefab, 시스템 → _Project/Prefab.
