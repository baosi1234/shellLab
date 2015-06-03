**使用者自订启动启动程序 (/etc/rc.d/rc.local)**
>
>在完成默认 runlevel 指定的各项服务的启动后，如果我还有其他的动作想要完成时，举例来说， 我还想要寄一封 mail 给某个系统管理帐号，通知他，系统刚刚重新启动完毕，那么是否应该要制作一个 shell script 放置在 /etc/init.d/ 里面，然后再以连结方式连结到 /etc/rc5.d/ 里面呢？呵呵！当然不需要！还记得上一小节提到的 /etc/rc.d/rc.local 吧？ 这个文件就可以运行您自己想要运行的系统命令了。
>
>也就是说，我有任何想要在启动时就进行的工作时，直接将他写入 /etc/rc.d/rc.local ， 那么该工作就会在启动的时候自动被加载喔！而不必等我们登陆系统去启动呢！ 是否很方便啊！一般来说，鸟哥就很喜欢把自己制作的 shell script 完整档名写入 /etc/rc.d/rc.local ，如此一来，启动就会将我的 shell script 运行过，真是好棒那！

=====

*** 修改 /etc/rc.d/rc.local 文件 ***

```
s script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.

touch /var/lock/subsys/local

# add_root_20150412
bash /root/.autoTurnNet.sh

```
