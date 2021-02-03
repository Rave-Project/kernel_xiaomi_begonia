
# bot key -> @Peppe289build_bot
BOT_API_KEY="1563558743:AAH4nOnpWPeBsOjksWUgzqbPpGnaXutIZx0"

#PLOX DON'T SHARE

#download repo
# git rev-parse --abbrev-ref HEAD
# git log --pretty=format:'"%h : %s"' -1
ANYKERNEL_REPO="https://github.com/Peppe289/AnyKernel.git"
REPO="kernel_xiaomi_sdm660"
DEVICE="Lavender"
TOOLCHAIN_INFO="Proton Clang 13"
CHAT_ID="-1001340890952" # Laveneder support
BRANCH_ANYKERNEL="AnyKernel" #chose branch to patch

# build export
export KBUILD_BUILD_USER="Peppe289"
export KBUILD_BUILD_HOST="RaveRules"
ZIP="Rave"

rm -rf $REPO/AnyKernel/

git clone --depth=1 https://github.com/kdrag0n/proton-clang.git

# setting arm64
export ARCH=arm64 && export SUBARCH=arm64

# build
START=$(date +"%s")
cd $REPO

make O=out lavender-perf_defconfig

PATH="/home/runner/work/Ubuntu-SSH/Ubuntu-SSH/proton-clang/bin:${PATH}" \

make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      CROSS_COMPILE=aarch64-linux-gnu- | tee kernel.log

END=$(date +"%s")
DIFF=$(($END - $START))

BRANCH_INFO=$(git rev-parse --abbrev-ref HEAD)
LAST_COMMIT=$(git log --pretty=format:'"%h : %s"' -1)

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





