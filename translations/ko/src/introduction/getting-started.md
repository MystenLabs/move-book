# 시작하기

> **경고:** 이 페이지에 있는 컨텐츠는 더 이상 유효하지 않으며 재작업이 필요합니다. Move IDE의 최신 버전이 곧 배포될 것입니다. 현재로서는 [move-cli](https://github.com/diem/move/tree/main/language/tools/move-cli) 를 사용하실 것을 권고드립니다.

---

컴파일된 모든 언어들이 그렇듯이, Move 어플리케이션을 컴파일, 구동 및 디버그 하려면 적절한 도구 모음이 필요합니다. 이 언어는 블록체인 용도로 개발되어 해당 분야에서만 사용되기에, 체인 외부 환경에서 스크립트를 구동하는 것은 간단한 일이 아닙니다. 그러한 경우 각 모듈마다 별도의 환경과 계정 처리 및 컴파일 배포 시스템을 배정해야 하기 때문입니다.

Move 모듈 개발의 간소화가 이루어질 수 있도록 Visual Studio Code에 대응하는 [Move IDE](https://github.com/damirka/vscode-move-ide) 확장프로그램을 개발했습니다. 이 확장 프로그램은 환경 요구사항에 대응하는 것을 도울 것이며, 빌드/구동 환경을 처리해 줌으로써 CLI와 씨름하는 일 없이 Move 언어 학습에만 집중할 수 있도록 돕기 때문에, 사용하시는 것을 강력하게 추천드립니다.

## Move IDE 설치 방법

설치를 진행하려면 다음의 항목이 필요합니다.

1.  VSCode (버전 1.43.0 이상) – [이 곳](https://code.visualstudio.com/download) 에서 받으실 수 있습니다. 이미 있으시다면 다음 단계로 진행해 주십시오.
2.  Move IDE – VSCode를 설치한 뒤 [이 링크](https://marketplace.visualstudio.com/items?itemName=damirka.move-ide) 로 들어가 최신 IDE 버전을 설치하십시오

### 설치 환경

Move IDE는 디렉토리 구조를 정리할 수 있는 방법을 제공합니다. 프로젝트에 새 디렉토리를 생성하여 VSCode에서 실행하십시오. 이후 아래의 디렉토리 구조를 설치하십시오.

```
modules/   - directory for our modules
scripts/   - directory for transaction scripts
out/       - this directory will hold compiled sources
```

또한 `.mvconfig.json` 이라는 이름의 파일을 생성하여 작업 환경에 `libra` 를 구성합니다. 아래 내용은 하나의 예시입니다. 

```json
{
    "network": "libra",
    "sender": "0x1"
}
```

또는 `difnance`를 네트워크로 사용할 수도 있습니다.

```json
{
    "network": "dfinance",
    "sender": "0x1"
}
```

> dfinance는 bech32 'wallet1...' 주소를 사용하며, libra는 16-byte '0x...' 주소를 사용합니다. 로컬 구동 및 실험의 경우 간단하고 짧은 0x1 주소만으로 충분할 것입니다. 그러나 testnet이나 제품환경에서 작업하는 경우 선택한 네트워크에 대응하는 정확한 주소를 사용해야 합니다.

## Move로 만든 최초의 어플리케이션

Move IDE를 사용하면 시험 환경에서 스크립트를 구동할 수 있습니다. `gimme_five()` 함수를 구현한 뒤 VSCode 내부에서 구동하여 작동법을 함께 알아봅시다.

### 모듈 생성

프로젝트의 `modules/` 디렉토리 내부에 `hello_world.move` 라는 이름의 새로운 파일을 생성합시다. 

```Move
// modules/hello_world.move
address 0x1 {
module HelloWorld {
    public fun gimme_five(): u8 {
        5
    }
}
}
```

> `0x1` 이 아닌 본인만의 주소를 사용하기로 결정했다면 반드시 이 파일과 다음 파일에 등장하는 0x1 값을 해당 주소 값으로 수정해 주십시오.

### 스크립트 작성

다음으로 `scripts/` 디렉토리 안에 `me.move`라고 하는 스크립트를 생성합니다.
```Move
// scripts/run_hello.move
script {
    use 0x1::HelloWorld;
    use 0x1::Debug;

    fun main() {
        let five = HelloWorld::gimme_five();

        Debug::print<u8>(&five);
    }
}
```

이후 스크립트를 열어놓은 상태로 다음의 단계들을 진행하십시오.

1. (맥의 경우) `⌘+Shift+P` 또는 (리눅스/윈도우의 경우) `Ctrl+Shift+P` 를 눌러 VSCode의 명령 팔레트를 전환합니다.
2.  `>Move: Run Script` 를 입력한 뒤 적절한 옵션이 나오면 엔터 키를 누르거나 클릭합니다.

짜잔! 실행 결과를 보면 디버그에 5가 출력된 로그 메시지를 확인할 수 있습니다. 이 창이 등장하지 않는다면 이 부분을 다시 진행해 주십시오.

디렉토리 구조는 아래의 형태와 같아야 합니다.
```
modules/
  hello_world.move
scripts/
  run_hello.move
out/
.mvconfig.json
```

> 모듈 디렉토리에 둘 수 있는 모듈의 개수에는 제한이 없습니다. 해당 디렉토리에 있는 모든 모듈은 .mvconfig.json에서 명시해 둔 주소를 사용해서 스크립트에서 접근할 수 있습니다.
