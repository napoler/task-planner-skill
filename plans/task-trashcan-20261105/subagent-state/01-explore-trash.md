# Explore 检查点：垃圾桶机制落点盘点（2026-11-05，主进程代落）
① Rule 100（discipline L670-680）：子条至 100.5；无废弃处置面；tmp/ 随清理链被清（100.1）→**垃圾桶不能挂 tmp/**；.gitignore 有 tmp/ 无 trash/；新子条挂 100.6
② deprecated.md/73.5=内容条目级登记（文本锚不移动物理文件），与文件级垃圾桶互补非重复；分工声明落 deprecated.md 头注释
③ 媒体稿件现状：47.5 淘汰件去向空白；variant image-type VC-6/video-type L61/L72=**原地 -failed/-superseded 重命名堆放**（用户指出的缺陷本体）
④ 检索排除惯例：Rule 100.2 git check-ignore 范式可类比
⑤ 落点建议：Rule 100.6 新子条（trash/ 目录+判废即移+检索排除+误删回取例外）+media-planner 指针+variant 两模板替代修改+deprecated.md 分工声明+.gitignore trash/+selftest 新建
