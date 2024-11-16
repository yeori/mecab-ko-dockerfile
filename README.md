
## 1. Installation

**[확인]** 작업 디렉토리

```
$ pwd
/home/user/mecab-demo
```

**[확인]** 프로젝트 구조

```
/home
 └─user
   └─mecab-demo
    ├── Dockerfile
    ├── install.sh
    ├── mecab.sh
    └── rebuild.sh
```

* `install.sh` - mecab을 실행하는데 필요한 다운로드, 설치, 컴파일을 진행합니다.
* `mecab.sh` - 형태소 분석 기능을 실행합니다.(테스트용)
* `rebuild.sh` - 시스템 사전을 수정한 후 사전 데이터를 컴파일할 때 사용합니다.

### 1.1. 설치

**[실행]** `install.sh` 실행합니다.

```bash
$ ./install.sh
```
* mecab 다운로드, 컴파일, 사전데이터 생성
* mecab docker image 와 container 생성

### 1.2. 확인

**[확인]** 도커 이미지 `mecab-img`

```bash
REPOSITORY   TAG       IMAGE ID   CREATED         SIZE
mecab-img    latest    ______     5 minutes ago   916MB
```

**[확인]** 컨테이너 `mecab-con`

```bash
$ docker ps
CONTAINER ID   IMAGE       COMMAND   NAMES
____________   mecab-img   "bash"    mecab-con
```

**[확인]** mecab 버전

```bash
$ docker exec mecab-con mecab --version
mecab of 0.996/ko-0.9.2
```

## 2. 사전 업데이트

**[확인]** 2018년도 사전이기 때문에 신조어가 인식되지 않습니다.

```bash
$ ./mecab.sh "오늘 뉴진스랑 펭수를 봤다."
오늘    MAG,성분부사|시간부사,T,오늘,*,*,*,*
뉴      NNG,*,F,뉴,*,*,*,*
진스    NNP,인명,F,진스,*,*,*,*
랑      JC,*,T,랑,*,*,*,*
펭      NNG,*,T,펭,*,*,*,*
수      NNG,*,F,수,*,*,*,*
를      JKO,*,T,를,*,*,*,*
봤      VV+EP,*,T,봤,Inflect,VV,EP,보/VV/*+았/EP/*
다      EF,*,F,다,*,*,*,*
.       SF,*,*,*,*,*,*,*
EOS
```

`뉴진스`와 `펭수`가 분석되지 않음.

### 2.1. 시스템 사전 업데이트

새롭게 발생한 신조어를 사전에 반영하는 작업을 합니다.

**[수정]** `nnp.csv`에 `뉴진스`를 입력합니다.

`mecab/app/mecab-ko-dict../user-dic/nnp.csv`

```
대우,,,,NNP,*,F,대우,*,*,*,*,*
구글,,,,NNP,*,T,구글,*,*,*,*,*
뉴진스,,,,NNP,*,T,뉴진스,*,*,*,*,*
```

**[수정]** `person.csv`에 `뉴진스`를 입력합니다.

`mecab/app/mecab-ko-dict../user-dic/person.csv`

```
까비,,,,NNP,인명,F,까비,*,*,*,*,*
펭수,,,,NNP,인명,F,펭수,*,*,*,*,*
```

**[실행]** 다음 명령어로 사전 데이터를 컴파일합니다.

```bash
$ ./rebuild.sh
```

```
nnp.csv
done!
person.csv
done!
reading ./unk.def ... 13
emitting double-array: 100% |##...##| 
reading ./XR.csv ... 3637
reading ./user-place.csv ... 2
reading ./user-person.csv ... 1
reading ./VCN.csv ... 7
((생략))
mitting double-array: 100% |#####...#####|
reading ./matrix.def ... 3822x2693
emitting matrix      : 100% |#####...#####|

/usr/bin/install -c -m 644 model.bin ...
```

컴파일된 사전 데이터는 호스트 컴퓨터의 `mecab/dictionary`에서 확인할 수 있습니다.

**[확인]** 신조어가 제대로 분석되는지 확인합니다.

```bash
$ ./mecab.sh "오늘 뉴진스랑 펭수를 봤다."
```

```
오늘    MAG,성분부사|시간부사,T,오늘,*,*,*,*
뉴진스  NNP,*,T,뉴진스,*,*,*,*,*
랑      JC,*,T,랑,*,*,*,*
펭수    NNP,인명,F,펭수,*,*,*,*,*
를      JKO,*,T,를,*,*,*,*
봤      VV+EP,*,T,봤,Inflect,VV,EP,보/VV/*+았/EP/*
다      EF,*,F,다,*,*,*,*
.       SF,*,*,*,*,*,*,*
EOS
```