### object-c 代码混淆

> 源自 [这里，码云一个项目](https://gitee.com/dhar/YTTInjectedContentKit)

此工程完全由shell脚本构成， 不同的.sh文件对应不同部分功能， 默认在linux环境执行，如果是一个一个.sh文件执行的话， .sh最好按照
```
RenameClasses.sh                          # 修改类名
RenameFunction.sh                         # 修改函数名
addFunctions.sh                           # 在.h文件添加未实现的垃圾方法
injectFunctions.sh                        # 在工程代码方法中加入垃圾代码(垃圾方法的调用)
RenameStatic.sh                           # 修改静态文件名
RenameDir.sh                              # 修改目录名 包括工程名字
```
的执行顺序执行。 如果是是执行startAll.sh文件， 要求工程名，工程文件目录得是 工程名.xcodeproj格式的， 静态文件目录得是 工程名.bundle格式的

#### 注意
1 开始前需要把工程整个复制到shell脚本的工作目录， 也就是和这个README.md同级的
2 提供的参数， 路径填写相对路径， 并且不以 . 或者 / 开头， 比如填写本目录下的Sup_SDK_ket/Sup_SDK_ket.m这个文件 就填写 -i Sup_SDK_ket/Sup_SDK_ket.m
3 默认类名同文件名

#### RenameClasses.sh
功能： 修改类名
需要参数
> 1. i    需要替换类名的代码的根目录
> 2. o    工程文件目录
> 3. p    工程名字

例：
```bash
./RenameClasses.sh  -i Sup_SDK_ket -o Sup_SDK_ket/Sup_SDK_ket.xcodeproj -p Sup_SDK_ket
```

过滤：
如果需要过滤哪些子目录或者文件类名不需要替换， 在configures/filterDirAndFileOfClass.cfg中写入目录或者文件名
例：
```
# 在filterDirAndFileOfClass.cfg文件中
Mos_SDK_ket
Kit_getUsers.m
Kit_getPost.m
```

代表不替换Mos_SDK_ket目录以及Kit_getUsers.m，Kit_getPost.m文件中的类名（填.m别填.h）

#### RenameFunction.sh
功能： 修改方法名
需要参数
> 1. i    需要替换方法的代码的根目录

例：
```bash
./RenameFunction.sh  -i Sup_SDK_ket/Sup_SDK_ket
```
过滤：
如果需要过滤哪些子目录或者文件方法不需要替换， 在configures/filterDirAndFileOfFunction.cfg中写入目录或者文件名
例：
```
# filterDirAndFileOfFunction.cfg文件中
Mos_SDK_ket
Kit_getUsers.m
Kit_getPost.m
```

代表不替换Mos_SDK_ket目录以及Kit_getUsers.m，Kit_getPost.m文件中的方法（填.m别填.h）
 
如果想单独几个方法不想被替换， 在configures/DefaultFunctionsBlackListConfig.cfg中填入方法名（第一个参数前的名字）
例：
```
# DefaultFunctionsBlackListConfig.cfg
Equ_btnBack_ome
Equ_btnBindPhone_ome
Equ_btnCompletion_ome
Equ_btnCover_ome
Equ_btnGetSecurity_ome
Equ_btnGiftDetail_ome
Equ_btnNavBack_ome
Equ_btnNo_ome
```
这几个方法就不会被替换

#### addFunctions.sh
功能： 添加垃圾未实现方法
需要参数
> 1. i  需要添加方法的代码的根目录

例：
```bash
./addFunctions.sh  -i Sup_SDK_ket/Sup_SDK_ket
```

#### injectFunctions.sh
功能： 在工程代码方法中加入垃圾代码(垃圾方法的调用)
需要参数
> 1. i  需要添加垃圾代码的代码的根目录
> 2. o  垃圾代码的根目录

例：
```bash
./injectFunctions.sh  -i Sup_SDK_ket/Sup_SDK_ket -o Sup_SDK_ket/ImmediateRelations
```
前提：
需要现在ImmediateRelations目录下生成一堆垃圾代码， 垃圾代码格式必须为
-(void)AAA:(id)BBB AAA:(id)BBB AAA:(id)BBB 格式的, ImmediateRelations目录下只有一级结构，没有更多的文件夹了
方法名AAA随意，参数名BBB随意, 但是必须是id类型。 参数个数为3个
例： 
```
-(void)InputsProveEnumeratingIndexesCompensationIntegrate:(id)_Raw_ Picometers:(id)_Clipboard_ Export:(id)_Advertisement_
```

#### RenameStatic.sh
功能： 修改静态文件名
需要参数
> 1. i  有使用到静态文件的代码的根目录
> 2. o  静态文件根目录

例：
```bash
./RenameStatic.sh  -i Sup_SDK_ket -o Sup_SDK_ket.bundle
```

#### RenameDir.sh
功能： 修改目录名 包括工程名字
需要参数
> 1. i  根目录
> 2. o  工程文件目录

例：
```bash
./RenameDir.sh  -i  -o Sup_SDK_ket/Sup_SDK_ket.xcodeproj
```

#### startAll.sh
功能： 上面所有.sh的集合
需要参数
> 1. i    需要替换类名的代码的根目录
> 2. o    工程文件目录
> 3. p    工程名字
> 4. s    静态文件目录
> 5. j    垃圾代码目录
> 6. d    添加垃圾代码的目录

例：
```
./startAll.sh   -i Sup_SDK_ket \
                -o Sup_SDK_ket/Sup_SDK_ket.xcodeproj \
                -p Sup_SDK_ket \
                -s Sup_SDK_ket.bundle \
                -j Sup_SDK_ket/ImmediateRelations \
                -d Sup_SDK_ket/Sup_SDK_ket
```