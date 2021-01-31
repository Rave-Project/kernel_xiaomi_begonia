
# bot key -> @Peppe289build_bot
BOT_API_KEY="1563558743:AAH4nOnpWPeBsOjksWUgzqbPpGnaXutIZx0"

#PLOX DON'T SHARE

#download repo
# git rev-parse --abbrev-ref HEAD
# git log --pretty=format:'"%h : %s"' -1
BRANCH="HMP-oldcam"
REPO="kernel_xiaomi_sdm660"
ANYKERNEL_REPO="https://github.com/Peppe289/AnyKernel.git"

# build export
export KBUILD_BUILD_USER="Peppe289"
export KBUILD_BUILD_HOST="RaveRules"
ZIP="Rave"



rm -rf $REPO/AnyKernel/

# chose
echo "Chose group: "
echo " 1) Laveneder support"
echo " 2) Begonia support"

read INPUT

if [ "$INPUT" == "1" ]; then

    CHAT_ID="-1001340890952" # Laveneder support
    BRANCH_ANYKERNEL="AnyKernel" #chose branch to patch
    echo "Build for lavender "
    DEVICE="Lavender" # info for push 
    echo "chose toolchain "
    echo " 1) GCC 4.9"
    echo " 2) GCC 10.2"
    DEFCONFIG="lavender-perf_defconfig"
    read TOOL

    git clone -b $BRANCH https://github.com/Peppe289/$REPO.git

    # TOOLCHAIN 4.9
    if [ "$TOOL" == "1" ]; then
        echo "ur chose is GGC 4.9"
    
        # download toolchain
        git clone https://github.com/ZyCromerZ/aarch64-linux-android-4.9/
        git clone https://github.com/ZyCromerZ/arm-linux-androideabi-4.9/
        # toolchain
        
        export CROSS_COMPILE=/home/runner/work/Ubuntu-SSH/Ubuntu-SSH/aarch64-linux-android-4.9/bin/aarch64-linux-android-
        export CROSS_COMPILE_ARM32=/home/runner/work/Ubuntu-SSH/Ubuntu-SSH/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
        
        # info for push
        TOOLCHAIN_INFO="GCC 4.9"
    
    elif [ "$TOOL" == "2" ]; then
        echo "ur chose is GGC 10"
        
        # download toolchain
        git clone https://github.com/arter97/arm64-gcc
        git clone https://github.com/arter97/arm32-gcc
        
        # toolchain
        export CROSS_COMPILE=/home/runner/work/Ubuntu-SSH/Ubuntu-SSH/arm64-gcc/bin/aarch64-elf-
        export CROSS_COMPILE_ARM32=/home/runner/work/Ubuntu-SSH/Ubuntu-SSH/arm32-gcc/bin/arm-eabi-
        
        # info for push
        TOOLCHAIN_INFO="GCC 10"
        
    fi;

elif [ "$INPUT" == "2" ]; then

    DEFCONFIG="begonia_user_defconfig"
    
    git clone -b $BRANCH https://github.com/Peppe289/$REPO.git
    DEVICE="Begonia" # info for push
    CHAT_ID="-1001453427722" # Begonia
    BRANCH_ANYKERNEL="begonia" #chose branch to patch
    echo "Build for Begonia"
    echo " Using GCC 4.9"
    git clone -b $BRANCH https://github.com/Peppe289/$REPO.git

    # TOOLCHAIN 4.9
    # download toolchain
    git clone https://github.com/ZyCromerZ/aarch64-linux-android-4.9/
    git clone https://github.com/ZyCromerZ/arm-linux-androideabi-4.9/
    # toolchain
    export CROSS_COMPILE=/home/runner/work/Ubuntu-SSH/Ubuntu-SSH/aarch64-linux-android-4.9/bin/aarch64-linux-android-
    export CROSS_COMPILE_ARM32=/home/runner/work/Ubuntu-SSH/Ubuntu-SSH/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
    
    # info for push
    TOOLCHAIN_INFO="GCC 4.9"
fi;


# setting arm64
export ARCH=arm64 && export SUBARCH=arm64

# build
START=$(date +"%s")
cd $REPO
make O=out $DEFCONFIG
make O=out -j2 | tee kernel.log
END=$(date +"%s")
DIFF=$(($END - $START))

BRANCH_INFO=$(git rev-parse --abbrev-ref HEAD)
LAST_COMMIT=$(git log --pretty=format:'"%h : %s"' -1)
LOG=kernel.log
#PATCH KERNEL
git clone -b $BRANCH_ANYKERNEL $ANYKERNEL_REPO
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel/
cd AnyKernel
zip -r9 $ZIP.zip * -x .git README.md *placeholder

# check succesful buil
FILESIZE=$(stat -c%s "$ZIP.zip")

if [ "$FILESIZE" -gt "7340032" ]; then

    echo "succesfull BUILD XD"
    #PUSH KERNEL
    curl -s -X POST "https://api.telegram.org/bot$BOT_API_KEY/sendSticker" \
        -d sticker="CAACAgUAAxkBAAMDX_RZlK2ZmweY2MZdQNAKAnyZD3YAAjIAA4m8iize9s9qTasz6x4E" \
        -d chat_id=$CHAT_ID
        
    curl -F document=@$ZIP.zip "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
        -F chat_id="$CHAT_ID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)."

    curl -F document=@$LOG "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
        -F chat_id="$CHAT_ID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html"


    curl -s -X POST "https://api.telegram.org/bot$BOT_API_KEY/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>• RaveKernel •</b>%0AFor device <b>$DEVICE</b> %0Abranch <code>$BRANCH_INFO</code> (master) %0AUnder commit <code>$LAST_COMMIT</code>%0AUsing compiler: <code>$TOOLCHAIN_INFO</code>%0AStarted on <code>$(date)</code>%0A"
        
elif [ "$FILESIZE" -lt "7340032" ]; then

    echo "Error build "
    curl -s -X POST "https://api.telegram.org/bot$BOT_API_KEY/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="BUILD FAILLED"

fi;

cd ..
rm -rf AnyKernel




