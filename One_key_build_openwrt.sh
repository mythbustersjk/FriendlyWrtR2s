#!/bin/bash
# Bash Menu Script Example
echo "OpenWrt一键编译脚本"
PS3='Please enter your choice: '
options=("Make_Screen" "Install_Environment" "BuildingOpenWrt" "BuildingWrt_R2s_Stable" "Re-build" "Re-build_R2s_Stable" "Quit")
select opt in "${options[@]}"; do
    case $opt in
    "Make_Screen")
        screen_name=$"r2s" #修改此处可更改screen名称
        screen -dmS $screen_name
        cmd=$"cd FriendlyWrtR2s"
        screen -x -S $screen_name -p 0 -X stuff "$cmd"
        screen -x -S $screen_name -p 0 -X stuff $'\n'
        cmd=$"bash One_key_build_openwrt.sh"
        screen -x -S $screen_name -p 0 -X stuff "$cmd"
        screen -x -S $screen_name -p 0 -X stuff $'\n'
        screen -r $screen_name
        ;;
    "Install_Environment")
        #更新系统
        sudo apt-get update 
        sudo apt-get upgrade -y 
        sudo apt-get dist-upgrade -y 
        mkdir lede
        mkdir iosoutput
        mkdir ~/iosoutput/r2s
        sudo chmod -R 777 lede
        #lede编译环境
        sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3.5 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget swig
        #安装R2s编译环境
        wget -O - https://raw.githubusercontent.com/friendlyarm/build-env-on-ubuntu-bionic/master/install.sh | bash
        ;;
    "BuildingOpenWrt") #使用lean最新版Openwrt源
        #拉取lede源码
        cd ~/
        git clone https://github.com/coolsnowwolf/lede
        cd ~/lede/package/lean/
        #添加lua-maxminddb 依赖
        #git clone https://github.com/jerrykuku/lua-maxminddb.git
        #添加luci-app
        #git clone https://github.com/jerrykuku/luci-app-vssr.git
        #添加Adguardhome
        git clone https://github.com/rufengsuixing/luci-app-adguardhome
        #安装feeds
        cd ~/lede
        ./scripts/feeds update -a
        ./scripts/feeds install -a
        make menuconfig
        make -j8 download V=s
        #make -j1 V=s
        make -j$(($(nproc) + 1)) V=s
        #提取生成镜像（R2s镜像，可根据编译平台自行修改）
        sudo mv -f ~/lede/bin/targets/rockchip/armv8/openwrt-rockchip-armv8-friendlyarm_nanopi-r2s*.img.gz ~/iosoutput/r2s
        cd ~/iosoutput/r2s
        gzip -d openwrt-rockchip-armv8-friendlyarm_nanopi-r2s*.img.gz
        mv openwrt-rockchip-armv8-friendlyarm_nanopi-r2s-squashfs*.img friendlyarm_nanopi-r2s-squashfs-$(date "+%Y-%m-%d").img
        mv openwrt-rockchip-armv8-friendlyarm_nanopi-r2s-ext4*.img friendlyarm_nanopi-r2s-ext4-$(date "+%Y-%m-%d").img
        cd ~
        ;;
    "BuildingWrt_R2s_Stable") #使用lean稳定版openwrt源
        cd ~/
        #拉取Repo
        git clone https://github.com/friendlyarm/repo /repo
        #安装Repo
        sudo cp -rf ~/repo/repo /usr/bin/
        # 准备源目录
        mkdir openwrt
        mkdir friendlywrt-rk3328
        mkdir iosoutput
        mkdir ~/iosoutput/R2s
        #设置权限
        sudo chmod -R 777 friendlywrt-rk3328
        sudo chmod -R 777 openwrt
        #拉取lean源码
        git clone https://github.com/coolsnowwolf/openwrt
        #更改默认配置
        cd ~/openwrt
        #修改Feeds
        #sed -i '$asrc-git helloworld https://github.com/fw876/helloworld' feeds.conf.default
        #sed -i '$asrc-git kenzo https://github.com/V2RaySSR/openwrt-packages' feeds.conf.default
        #sed -i '$asrc-git small https://github.com/V2RaySSR/small' feeds.conf.default
        #添加Luci-app(可在此处自定义添加Luci-app)
        cd ~/openwrt/package/lean/
        #添加lua-maxminddb 依赖
        #git clone https://github.com/jerrykuku/lua-maxminddb.git
        #添加luci-app
        #git clone https://github.com/jerrykuku/luci-app-vssr.git
        #添加Adguardhome
        git clone https://github.com/rufengsuixing/luci-app-adguardhome
        #安装openwrt源
        cd ~/openwrt/
        ./scripts/feeds update -a
        ./scripts/feeds install -a
        #拉取FriendlyWRT源码
        cd ~/friendlywrt-rk3328/
        #配置Git-config
        git config --global user.name "xx@mail.com" #需改成自己的邮箱
        git config --global user.email "xx"         #修改成自己的用户名
        repo init -u https://github.com/friendlyarm/friendlywrt_manifests -b master-v19.07.1 -m rk3328.xml --repo-url=https://github.com/friendlyarm/repo --no-clone-bundle
        repo sync -c --no-clone-bundle
        sudo cp -rf ~/friendlywrt-rk3328/.repo/repo/repo /usr/bin/repo
        #源码融合
        cd ~/
        cp -rf ~/openwrt/feeds.conf.default ~/friendlywrt-rk3328/friendlywrt/
        cp -rf ~/openwrt/package/lean ~/friendlywrt-rk3328/friendlywrt/package/
        cp -rf ~/openwrt/tools/ucl ~/friendlywrt-rk3328/friendlywrt/tools/
        cp -rf ~/openwrt/tools/upx ~/friendlywrt-rk3328/friendlywrt/tools/
        cp -rf ~/openwrt/tools/gptfdisk ~/friendlywrt-rk3328/friendlywrt/tools/
        cp -rf ~/openwrt/tools/popt ~/friendlywrt-rk3328/friendlywrt/tools/
        cp -rf ~/openwrt/tools/Makefile ~/friendlywrt-rk3328/friendlywrt/tools/
        cp -rf ~/openwrt/package/libs/librpc ~/friendlywrt-rk3328/friendlywrt/package/libs/
        cp -rf ~/openwrt/package/libs/libcxx ~/friendlywrt-rk3328/friendlywrt/package/libs/
        cp -rf ~/openwrt/package/network/config/firewall/Makefile ~/friendlywrt-rk3328/friendlywrt/package/network/config/firewall/Makefile
        cp -rf ~/openwrt/package/network/config/firewall/patches ~/friendlywrt-rk3328/friendlywrt/package/network/config/firewall/
        #再次设置权限
        cd ~/
        sudo chmod -R 777 friendlywrt-rk3328
        #更新R2s
        cd ~/friendlywrt-rk3328/friendlywrt
        ./scripts/feeds update -a
        ./scripts/feeds install -a
        #配置文件
        make menuconfig
        #下载DLL
        make -j1 download V=s
        make -j8 download
        make -j8 download
        #开始编译
        cd ~/friendlywrt-rk3328/
        ./build.sh nanopi_r2s.mk
        #定义固件保存路径
        cd ~/
        sudo mv -f ~/friendlywrt-rk3328/scripts/sd-fuse/out/FriendlyWrt*NanoPi-R2S_arm64_sd.img ~/iosoutput/r2s
        ;;
    "Re-build")
        cd ~/lede
        rm -rf ./tmp && rm -rf .config
        #更新源码
        cd ~/lede
        git reset --hard
        git pull
        #更新Adguard
        cd ~/lede/package/lean/luci-app-adguardhome
        git reset --hard
        git pull
        #清除旧版feeds并更新
        ./scripts/feeds clean
        ./scripts/feeds update -a
        ./scripts/feeds install -a
        make menuconfig
        make -j8 download
        make -j$(($(nproc) + 1)) V=s
        #提取镜像
        sudo mv -f ~/lede/bin/targets/rockchip/armv8/openwrt-rockchip-armv8-friendlyarm_nanopi-r2s*.img.gz ~/iosoutput/r2s
        cd ~/iosoutput/r2s
        gzip -d openwrt-rockchip-armv8-friendlyarm_nanopi-r2s*.img.gz
        mv openwrt-rockchip-armv8-friendlyarm_nanopi-r2s-squashfs*.img friendlyarm_nanopi-r2s-squashfs-`date "+%Y-%m-%d"`.img
        mv openwrt-rockchip-armv8-friendlyarm_nanopi-r2s-ext4*.img friendlyarm_nanopi-r2s-ext4-`date "+%Y-%m-%d"`.img
        cd ~
        ;;
    "Re-build_R2s_Stable")
        cd ~/friendlywrt-rk3328/
        #更新R2s源码
        repo sync -c --no-clone-bundle
        #清除上次编译
        ./build.sh cleanall
        rm -rf ~/friendlywrt-rk3328/friendlywrt/tmp/
        #重新编译
        cd ~/friendlywrt-rk3328/friendlywrt
        ./scripts/feeds update -a
        ./scripts/feeds install -a
        make menuconfig
        make -j1 download V=s
        make -j8 download
        make -j8 download
        cd ~/friendlywrt-rk3328/
        ./build.sh nanopi_r2s.mk
        #提取镜像
        cd ~/
        sudo mv -f ~/friendlywrt-rk3328/scripts/sd-fuse/out/FriendlyWrt*NanoPi-R2S_arm64_sd.img ~/iosoutput/r2s
        ;;
    "Quit")
        break
        ;;
    *) echo 输入有误请重新输入 ;;
    esac
done
