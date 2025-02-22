重新构建时，要手动下载

google-chrome-stable_current_amd64.deb

go1.23.4.linux-amd64.tar.gz

go安装包要下载最新的，并在dockerfile中修改对应的文件名

因为在docker中运行，要加上--no-sandbox启动vscode，使用下面的命令，在启动快捷方式中添加参数：

sudo vi /usr/share/applications/code.desktop

找到Exec=/usr/share/code/code %F，改为Exec=/usr/share/code/code --no-sandbox %F

目前还存在的问题，不能通过公网ssh到这个docker，不清楚是群晖dsm7.2的问题，还是容器设置的问题

docker运行Ubuntu，并通过vnc连接，打开web browser提示：failed to execute default web browser input/output error. 是哪里的权限设置有问题吗，我不是用root账号登录的，是用普通用户

先把.config 目录chmod 给普通用户

创建一个包装脚本（wrapper script）然后将这个脚本作为默认浏览器。
创建 /usr/local/bin/chrome-nosandbox，内容如下：
#!/bin/bash
exec /usr/bin/google-chrome --no-sandbox "$@"

保存后，给予执行权限：
chmod +x /usr/local/bin/chrome-nosandbox

你可以在用户的 shell 配置文件中（如 ~/.bashrc）设置 export BROWSER="/usr/local/bin/chrome-nosandbox"，这样在调用默认 web browser 时就会使用你自定义的命令。
