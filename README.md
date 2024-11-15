
## 1. Creating Mecab Docker Image

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
     ├── mecab
     └── README.md
```

**[확인]** Docker 설치

```bash
$ docker -v
Docker version 25.0.6, build v25.0.6
```

**[실행]** 아래의 명령어로 mecab 이미지를 생성합니다.

```bash
$ docker build -t mecab-img .
```

**[확인]** 생성된 이미지를 확인합니다.

```bash
~/mecab-demo$ docker image ls
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
mecab-img    latest    6c6462ae6cdc   19 minutes ago   1.01GB
```

## 2. Creating mecab container

**[실행]** 생성한 이미지로부터 컨테이너 `mecab-ko`를 생성하고 시작합니다.

```bash
docker run -itd \
  --name mecab-ko \
  mecab-img bash
```

**[확인]** 컨테이너 `mecab-ko` 가 실행 중입니다.

```bash
$ docker ps
CONTAINER ID   IMAGE       COMMAND   CREATED         STATUS         PORTS     NAMES
764f5fc28c52   mecab-img   "bash"    8 minutes ago   Up 8 minutes             mecab-ko
```

**[확인]** 실행중인 mecab 버전을 출력합니다.

```bash
$ docker exec mecab-ko mecab --version
mecab of 0.996/ko-0.9.2
```

## 3. Creating Volume

사전 업데이트 작업을 위해서 컨테이너 `mecab-ko:/app` 디렉토리를 호스트로 가져온 후 volume으로 사용할 것입니다.

### 3.1. mecab-ko:/app => HOST:mecab

**[실행]** volume으료 사용할 디렉토리를 호스트에 생성합니다.

```bash
$ mkdir -p mecab/app
$ mkdir -p mecab/mecab-ko-dic
```
**[확인]** 현재의 디렉토리 상태

```
.
├── Dockerfile
├── mecab
│   ├── app
│   └── mecab-ko-dic
└── README.md
```

컨테이너 `mecab-ko` 내부의 `/app` 디렉토리를 전부 호스트의 `mecab` 디렉토리로 복사합니다.

```bash
$ docker cp mecab-ko:/app mecab
Successfully copied 413MB to /home/user/mecab-demo/mecab
```

**[확인]** 호스트의 `mecab` 디렉토리를 조회합니다.

```bash
tree -L 2 mecab
mecab
├── app
│   ├── mecab-0.996-ko-0.9.2
│   ├── mecab-0.996-ko-0.9.2.tar.gz
│   ├── mecab-ko-dic-2.1.1-20180720
│   └── mecab-ko-dic-2.1.1-20180720.tar.gz
└── mecab-ko-dic
```
컨테이너 디렉토리 `mecab-ko:/app`을 호스트의 `mecab/app` 디렉토리로 전부 복사했습니다.

### 3.2. mecab-ko:/usr/local/lib/mecab/dic/mecab-ko-dic => HOST:mecab

컴파일된 사전 데이터는 컨테이너 안에서 아래의 디렉토리에 존재합니다.

* `mecab-ko:/usr/local/lib/mecab/dic/mecab-ko-dic`

**[실행]** 다음 명령어로 사전 데이터를 호스트 디렉토리로 복사합니다.

```bash
$ docker cp mecab-ko:/usr/local/lib/mecab/dic/mecab-ko-dic mecab
Successfully copied 112MB to /home/user/mecab-demo/mecab
```

**[확인]** 호스트의 `mecab` 디렉토리를 조회합니다.

```bash
tree -L 2 mecab
mecab
├── app
│   ├── mecab-0.996-ko-0.9.2
│   ├── mecab-0.996-ko-0.9.2.tar.gz
│   ├── mecab-ko-dic-2.1.1-20180720
│   └── mecab-ko-dic-2.1.1-20180720.tar.gz
│
└── mecab-ko-dic
    ├── char.bin
    ├── dicrc
    ├── ...
    ├── right-id.def
    ├── sys.dic
    └── unk.dic
```

### 3.3. Volume 만들기

`meca/app`과 `mecab/mecab-ko-dic`을 volume으로 지정해서 컨테이너를 실행할 것입니다.

```
HOST                  CONTAINER(mecab-ko)
Dockerfile
mecab        
├── app          <==> /app
└── mecab-ko-dic <==> /usr/local/lib/mecab/dic/mecab-ko-dic
```

**[실행]** docker 명령어는 다음과 같이 두 개의 `mount` 설정을 추가합니다.

```docker
$ docker run -itd \
  --mount type=bind,source=$(pwd)/mecab/app,target=/app \
  --mount type=bind,source=$(pwd)/mecab/mecab-ko-dic,target=/usr/local/lib/mecab/dic/mecab-ko-dic \
  --name mecab-ko mecab-img bash
```
mecab은 이전과 똑같이 작동해야 합니다.

```bash
$ docker exec mecab-ko mecab --version
mecab of 0.996/ko-0.9.2
```

## 4. 사전 업데이트

**[확인]** 2018년도 사전이기 때문에 신조어가 인식되지 않습니다.

```bash
docker exec mecab-ko sh -c 'echo "오늘 뉴진스랑 펭수를 봤다." | mecab'
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

### 4.1. 시스템 사전 업데이트

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
$ docker exec mecab-ko ./update-dict-sh
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
mitting double-array: 100% |##...##| 
reading ./matrix.def ... 3822x2693
emitting matrix      : 100% |##...##| 

/usr/bin/install -c -m 644 model.bin ...
```

**[확인]** 신조어가 제대로 분석되는지 확인합니다.

```bash
$ docker exec mecab-ko sh -c 'echo "오늘 뉴진스랑 펭수를 봤다." | mecab'
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