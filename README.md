重新构建时，要手动下载

google-chrome-stable_current_amd64.deb

go1.23.4.linux-amd64.tar.gz

go安装包要下载最新的，并在dockerfile中修改对应的文件名

因为在docker中运行，要加上--no-sandbox启动vscode，使用下面的命令，在启动快捷方式中添加参数：

sudo vi /usr/share/applications/code.desktop

找到Exec=/usr/share/code/code %F，改为Exec=/usr/share/code/code --no-sandbox %F

目前还存在的问题，不能通过公网ssh到这个docker，不清楚是群晖dsm7.2的问题，还是容器设置的问题
