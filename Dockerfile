# 基础镜像
FROM ubuntu:22.04
# 维护者信息
MAINTAINER kelvin <ye.vip@qq.com>

# 环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    SIZE=1024x768 \
    PASSWD=123456 \
    TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LC_ALL=${LANG} \
    LANGUAGE=${LANG} \
	GO_PACKAGE=go1.23.4.linux-amd64.tar.gz
	#需要下载最新版本的go 安装包，否则到最后面安装会错误

USER root
WORKDIR /root

# 设定密码
RUN echo "root:$PASSWD" | chpasswd

COPY google-chrome-stable_current_amd64.deb /tmp/google-chrome-stable_current_amd64.deb
COPY $GO_PACKAGE /tmp/$GO_PACKAGE

# 安装
RUN apt-get -y update && \
    # tools
    apt-get install -y sudo vim git subversion wget curl net-tools locales bzip2 unzip iputils-ping traceroute firefox firefox-locale-zh-hans ttf-wqy-microhei gedit ibus-pinyin && \
    locale-gen zh_CN.UTF-8 && \
    # ssh
    apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    mkdir -p /root/.ssh && \
    # TigerVNC
    wget -qO- https://nchc.dl.sourceforge.net/project/tigervnc/stable/1.13.1/tigervnc-1.13.1.x86_64.tar.gz | tar xz --strip 1 -C / && \
    # xfce
    apt-get install -y xfce4 xfce4-terminal && \
    apt-get purge -y pm-utils xscreensaver* && \
    # xrdp
    apt-get install -y xrdp  && \
# 创建脚本文件
    apt-get install -y -f /tmp/google-chrome-stable_current_amd64.deb && \
    sed -e '/chrome/ s/^#*/#/' -i /opt/google/chrome/google-chrome && \
    echo 'exec -a "$0" "$HERE/chrome" "$@" --user-data-dir="$HOME/.config/chrome" --no-sandbox --disable-dev-shm-usage' >> /opt/google/chrome/google-chrome && \
    rm -f /tmp/google-chrome-stable_current_amd64.deb && \
	# VsCode
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list && \
    apt-get clean && \
    apt-get -y update && \
    apt-get install -y code && \
    apt-get install -y build-essential && \
    apt-get install -y tree && \
    sed -i 's/--unity-launch/--no-sandbox --unity-launch/' /usr/share/applications/code.desktop && \
	cd && \
    tar -C /usr/local -xzf /tmp/$GO_PACKAGE && \
    rm -f /tmp/$GO_PACKAGE && \
    echo '' >> ~/.bashrc && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc && \
    echo 'export GO111MODULE=on' >> ~/.bashrc && \
    echo 'export GOPROXY=https://goproxy.cn,direct' >> ~/.bashrc && \
    chmod 777 ~/.bashrc && \
    /usr/local/go/bin/go env -w GO111MODULE=on && \
    /usr/local/go/bin/go env -w GOPROXY=https://goproxy.io,direct && \
    mkdir -p ~/Desktop/project/hello && \
    cd ~/Desktop/project/hello && \
    /usr/local/go/bin/go mod init hello && \
    echo 'package main' > ~/Desktop/project/hello/main.go && \
    echo 'import "fmt"' >> ~/Desktop/project/hello/main.go && \
    echo 'func main() {' >> ~/Desktop/project/hello/main.go && \
    echo '    fmt.Println("hello")' >> ~/Desktop/project/hello/main.go && \
    echo '}' >> ~/Desktop/project/hello/main.go && \
    /usr/local/go/bin/go install -v golang.org/x/tools/gopls@latest && \
    /usr/local/go/bin/go install -v github.com/go-delve/delve/cmd/dlv@latest && \
    # clean
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 使用策略避免chrome出现禁用沙箱警告
RUN mkdir -p /etc/opt/chrome/policies/managed/ && \
echo '{"CommandLineFlagSecurityWarningsEnabled": false}' > /etc/opt/chrome/policies/managed/default_managed_policy.json

# 创建新用户并设置密码
RUN useradd -m -s /bin/bash kelvin && \
    echo "kelvin:$PASSWD" | chpasswd && \
    usermod -aG sudo kelvin && \
	mkdir -p /home/kelvin/.vnc && \
    echo $PASSWD | vncpasswd -f > /home/kelvin/.vnc/passwd && \
	chown kelvin:kelvin /home/kelvin -R && \
    chmod 600 /home/kelvin/.vnc/passwd && \
	echo "xfce4-session" > /home/kelvin/.xsession && \
	chown kelvin:kelvin /home/kelvin/.xsession && \
# 创建脚本文件
    echo "#!/bin/bash\n" > /home/kelvin/startup.sh && \
    # 修改密码
    echo 'if [ $PASSWD ] ; then' >> /home/kelvin/startup.sh && \
    echo '    echo "kelvin:$PASSWD" | chpasswd' >> /home/kelvin/startup.sh && \
    echo '    echo $PASSWD | vncpasswd -f > /home/kelvin/.vnc/passwd' >> /home/kelvin/startup.sh && \
    echo 'fi' >> /home/kelvin/startup.sh && \
    # SSH
    echo '/usr/sbin/sshd -D & source /home/kelvin/.bashrc' >> /home/kelvin/startup.sh && \
    # VNC
    echo 'echo "Switching to kelvin user..."' >> /home/kelvin/startup.sh && \
    echo 'su - kelvin -c "' >> /home/kelvin/startup.sh && \
    echo '  /usr/libexec/vncserver :0' >> /home/kelvin/startup.sh && \
    echo '  rm -rfv /tmp/.X*-lock /tmp/.X11-unix' >> /home/kelvin/startup.sh && \
    echo '  vncserver :0 -geometry $SIZE' >> /home/kelvin/startup.sh && \
    echo '  tail -f /home/kelvin/.vnc/*:0.log' >> /home/kelvin/startup.sh && \
    echo '"' >> /home/kelvin/startup.sh && \
    # 可执行脚本
    chmod +x /home/kelvin/startup.sh && \
    chown kelvin:kelvin /home/kelvin/startup.sh && \
    mkdir /home/kelvin/share && \
    chmod 777 /home/kelvin/share

# 配置xfce图形界面
ADD ./xfce/ /home/kelvin

# 用户目录不使用中文
RUN LANG=C xdg-user-dirs-update --force


# 导出特定端口
EXPOSE 22 5900 3389 6001 6002 6003 6004 6005 6006 6007 6008 6009

# 启动脚本
CMD ["/home/kelvin/startup.sh"]
#CMD ["tail", "-f", "/dev/null"]